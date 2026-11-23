package com.buildzone.api.service.impl;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.buildzone.api.dto.ComparacionRequest;
import com.buildzone.api.dto.ComparacionResponse;
import com.buildzone.api.exception.AccesoDenegadoException;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.Autor;
import com.buildzone.api.model.Comparacion;
import com.buildzone.api.model.Producto;
import com.buildzone.api.model.Usuario;
import com.buildzone.api.model.enums.Rol;
import com.buildzone.api.repository.AutorRepository;
import com.buildzone.api.repository.ComparacionRepository;
import com.buildzone.api.repository.ProductoRepository;
import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.ComparacionService;
import com.buildzone.api.service.SuscripcionService;

/**
 * Implementacion de {@link ComparacionService}.
 * <p>
 * La tabla {@code comparacion} apunta a la tabla {@code usuario} del modelo
 * original, igual que el blog: la cuenta se relaciona con su perfil
 * ({@link Autor}) por correo, y si no lo tiene se le crea.
 */
@Service
@Transactional(readOnly = true)
public class ComparacionServiceImpl implements ComparacionService {

    static final String MENSAJE_SIN_PLAN =
            "Guardar comparaciones es exclusivo de los planes de pago (mensual o anual).";
    private static final int LARGO_TITULO = 150;

    private final ComparacionRepository comparacionRepository;
    private final ProductoRepository productoRepository;
    private final AutorRepository autorRepository;
    private final UsuarioRepository usuarioRepository;
    private final SuscripcionService suscripcionService;
    private final PasswordEncoder passwordEncoder;
    private final Clock clock;

    public ComparacionServiceImpl(ComparacionRepository comparacionRepository,
                                  ProductoRepository productoRepository,
                                  AutorRepository autorRepository,
                                  UsuarioRepository usuarioRepository,
                                  SuscripcionService suscripcionService,
                                  PasswordEncoder passwordEncoder,
                                  Clock clock) {
        this.comparacionRepository = comparacionRepository;
        this.productoRepository = productoRepository;
        this.autorRepository = autorRepository;
        this.usuarioRepository = usuarioRepository;
        this.suscripcionService = suscripcionService;
        this.passwordEncoder = passwordEncoder;
        this.clock = clock;
    }

    @Override
    public List<ComparacionResponse> listarMias(UsuarioAutenticado actual) {
        exigirPlan(actual);
        return comparacionRepository
                .findByAutorCorreoIgnoreCaseOrderByFechaCreacionDescIdComparacionDesc(cuentaDe(actual).getEmail())
                .stream()
                .map(ComparacionResponse::new)
                .toList();
    }

    @Override
    @Transactional
    public ComparacionResponse guardar(ComparacionRequest request, UsuarioAutenticado actual) {
        exigirPlan(actual);
        if (Objects.equals(request.idProductoA(), request.idProductoB())) {
            throw new ReglaNegocioException("Elige dos productos distintos para comparar.");
        }
        Producto a = buscarProducto(request.idProductoA());
        Producto b = buscarProducto(request.idProductoB());
        if (!Objects.equals(a.getCategoria().getIdCategoria(), b.getCategoria().getIdCategoria())) {
            throw new ReglaNegocioException("Solo se pueden comparar productos de la misma categoria.");
        }

        Usuario cuenta = cuentaDe(actual);
        LocalDateTime ahora = LocalDateTime.now(clock);

        // Si ya guardo este mismo duelo (en cualquier orden), solo se actualiza la fecha.
        Optional<Comparacion> existente = buscarMismoDuelo(cuenta.getEmail(), a, b);
        if (existente.isPresent()) {
            Comparacion c = existente.get();
            c.setFechaCreacion(ahora);
            return new ComparacionResponse(comparacionRepository.save(c));
        }

        Comparacion nueva = new Comparacion();
        nueva.setAutor(autorDeLaCuenta(cuenta));
        nueva.setTitulo(recortar("Duelo: " + a.getNombre() + " vs " + b.getNombre(), LARGO_TITULO));
        nueva.setFechaCreacion(ahora);
        nueva.agregarProducto(a);
        nueva.agregarProducto(b);
        return new ComparacionResponse(comparacionRepository.save(nueva));
    }

    @Override
    @Transactional
    public void eliminar(Integer id, UsuarioAutenticado actual) {
        Comparacion c = comparacionRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe la comparacion con id " + id));
        String correoAutor = c.getAutor() == null ? null : c.getAutor().getCorreo();
        if (correoAutor == null || !correoAutor.equalsIgnoreCase(cuentaDe(actual).getEmail())) {
            throw new AccesoDenegadoException("Solo puedes eliminar tus propias comparaciones.");
        }
        comparacionRepository.delete(c);
    }

    // ── Apoyo ──

    /** ADMIN, o suscripcion vigente a un plan con precio (el Gratuito no cuenta). */
    private void exigirPlan(UsuarioAutenticado actual) {
        if (actual.rol() == Rol.ADMIN) {
            return;
        }
        boolean dePago = suscripcionService.obtenerActiva(actual.id())
                .map(s -> s.plan() != null && s.plan().precio() != null
                        && s.plan().precio().compareTo(BigDecimal.ZERO) > 0)
                .orElse(false);
        if (!dePago) {
            throw new AccesoDenegadoException(MENSAJE_SIN_PLAN);
        }
    }

    private Optional<Comparacion> buscarMismoDuelo(String correo, Producto a, Producto b) {
        Set<Integer> buscado = Set.of(a.getIdProducto(), b.getIdProducto());
        return comparacionRepository.findByAutorCorreoIgnoreCaseOrderByFechaCreacionDescIdComparacionDesc(correo)
                .stream()
                .filter(c -> c.getDetalles().stream()
                        .map(d -> d.getProducto().getIdProducto())
                        .collect(Collectors.toSet())
                        .equals(buscado))
                .findFirst();
    }

    private Producto buscarProducto(Integer id) {
        return productoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe el producto con id " + id));
    }

    private Usuario cuentaDe(UsuarioAutenticado actual) {
        return usuarioRepository.findById(actual.id())
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe la cuenta con id " + actual.id()));
    }

    /** Perfil en la tabla usuario del modelo original (lo crea si es la primera vez). */
    private Autor autorDeLaCuenta(Usuario cuenta) {
        return autorRepository.findByCorreoIgnoreCase(cuenta.getEmail())
                .orElseGet(() -> autorRepository.save(new Autor(
                        recortar(cuenta.getNombre(), 50),
                        recortar(cuenta.getApellido(), 50),
                        recortar(cuenta.getEmail(), 100),
                        passwordEncoder.encode(UUID.randomUUID().toString()),
                        LocalDateTime.now(clock))));
    }

    private static String recortar(String texto, int largo) {
        return texto.length() <= largo ? texto : texto.substring(0, largo);
    }
}
