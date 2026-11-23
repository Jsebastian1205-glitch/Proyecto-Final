package com.buildzone.api.service.impl;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.buildzone.api.dto.EspecificacionDto;
import com.buildzone.api.dto.ProductoRequest;
import com.buildzone.api.dto.ProductoResponse;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.Categoria;
import com.buildzone.api.model.Especificacion;
import com.buildzone.api.model.FuentePrecio;
import com.buildzone.api.model.Marca;
import com.buildzone.api.model.Precio;
import com.buildzone.api.model.Producto;
import com.buildzone.api.repository.CategoriaRepository;
import com.buildzone.api.repository.ComparacionRepository;
import com.buildzone.api.repository.EspecificacionRepository;
import com.buildzone.api.repository.FuentePrecioRepository;
import com.buildzone.api.repository.MarcaRepository;
import com.buildzone.api.repository.PrecioRepository;
import com.buildzone.api.repository.ProductoRepository;
import com.buildzone.api.service.ProductoService;

/**
 * Implementacion de {@link ProductoService}. A diferencia de Marca y
 * Categoria, crear o actualizar un Producto requiere primero resolver
 * (buscar) la Marca y la Categoria referenciadas por id, y fallar con un
 * mensaje claro si alguna de las dos no existe.
 * <p>
 * Cada producto se entrega con su ficha tecnica, sus puntajes y sus precios
 * por tienda (tablas {@code especificacion}, {@code precio} y
 * {@code fuente_precio}). Al listar, la ficha y los precios de todo el
 * catalogo se traen en dos consultas, no en dos por producto.
 * <p>
 * La clase se marca {@code @Transactional(readOnly = true)} por defecto:
 * como {@link Producto} carga su {@code marca} y {@code categoria} de
 * forma perezosa (LAZY), esos datos solo se pueden leer mientras la
 * transaccion/sesion de Hibernate sigue abierta. Sin esta anotacion, el
 * repositorio abre y cierra su propia transaccion en cada llamada, y al
 * intentar leer {@code producto.getMarca()} ya fuera de ella se lanza
 * {@code LazyInitializationException} (se manifiesta como un error 500).
 * Los metodos que escriben (crear/actualizar/eliminar) sobrescriben esto
 * con {@code @Transactional} de lectura-escritura.
 */
@Service
@Transactional(readOnly = true)
public class ProductoServiceImpl implements ProductoService {

    /** Puntajes que usa el comparador (rondas del duelo). */
    static final Set<String> PUNTAJES = Set.of("potencia", "eficiencia", "valor", "popularidad");

    private final ProductoRepository productoRepository;
    private final MarcaRepository marcaRepository;
    private final CategoriaRepository categoriaRepository;
    private final EspecificacionRepository especificacionRepository;
    private final PrecioRepository precioRepository;
    private final FuentePrecioRepository fuentePrecioRepository;
    private final ComparacionRepository comparacionRepository;
    private final Clock clock;

    public ProductoServiceImpl(ProductoRepository productoRepository,
                                MarcaRepository marcaRepository,
                                CategoriaRepository categoriaRepository,
                                EspecificacionRepository especificacionRepository,
                                PrecioRepository precioRepository,
                                FuentePrecioRepository fuentePrecioRepository,
                                ComparacionRepository comparacionRepository,
                                Clock clock) {
        this.productoRepository = productoRepository;
        this.marcaRepository = marcaRepository;
        this.categoriaRepository = categoriaRepository;
        this.especificacionRepository = especificacionRepository;
        this.precioRepository = precioRepository;
        this.fuentePrecioRepository = fuentePrecioRepository;
        this.comparacionRepository = comparacionRepository;
        this.clock = clock;
    }

    @Override
    public List<ProductoResponse> listar() {
        List<Producto> productos = productoRepository.findAll();
        if (productos.isEmpty()) {
            return List.of();
        }
        List<Integer> ids = productos.stream().map(Producto::getIdProducto).toList();
        Map<Integer, List<Especificacion>> fichas = especificacionRepository
                .findByProductoIdProductoInOrderByIdEspecificacionAsc(ids).stream()
                .collect(Collectors.groupingBy(e -> e.getProducto().getIdProducto()));
        Map<Integer, List<Precio>> precios = precioRepository
                .findByProductoIdProductoInOrderByValorAsc(ids).stream()
                .collect(Collectors.groupingBy(p -> p.getProducto().getIdProducto()));
        return productos.stream()
                .map(p -> new ProductoResponse(p,
                        fichas.getOrDefault(p.getIdProducto(), Collections.emptyList()),
                        precios.getOrDefault(p.getIdProducto(), Collections.emptyList())))
                .toList();
    }

    @Override
    public ProductoResponse obtenerPorId(Integer id) {
        return respuestaCompleta(buscarOFallar(id));
    }

    @Override
    @Transactional
    public ProductoResponse crear(ProductoRequest request) {
        Marca marca = buscarMarcaOFallar(request.getIdMarca());
        Categoria categoria = buscarCategoriaOFallar(request.getIdCategoria());
        validarPuntajes(request.getPuntajes());

        Producto producto = new Producto();
        producto.setNombre(request.getNombre());
        producto.setDescripcion(request.getDescripcion());
        producto.setImagen(request.getImagen());
        producto.setMarca(marca);
        producto.setCategoria(categoria);
        producto = productoRepository.save(producto);

        guardarDatosExtra(producto, request);
        return respuestaCompleta(producto);
    }

    @Override
    @Transactional
    public ProductoResponse actualizar(Integer id, ProductoRequest request) {
        Producto producto = buscarOFallar(id);
        Marca marca = buscarMarcaOFallar(request.getIdMarca());
        Categoria categoria = buscarCategoriaOFallar(request.getIdCategoria());
        validarPuntajes(request.getPuntajes());

        producto.setNombre(request.getNombre());
        producto.setDescripcion(request.getDescripcion());
        producto.setImagen(request.getImagen());
        producto.setMarca(marca);
        producto.setCategoria(categoria);
        producto = productoRepository.save(producto);

        guardarDatosExtra(producto, request);
        return respuestaCompleta(producto);
    }

    @Override
    @Transactional
    public void eliminar(Integer id) {
        Producto producto = buscarOFallar(id);
        // Se borran primero la ficha y los precios: en MySQL lo haria el
        // ON DELETE CASCADE, pero en H2 (perfil dev) las tablas las crea
        // Hibernate sin esa regla.
        especificacionRepository.deleteAll(
                especificacionRepository.findByProductoIdProductoOrderByIdEspecificacionAsc(id));
        precioRepository.deleteAll(precioRepository.findByProductoIdProductoOrderByValorAsc(id));
        // Una comparacion sin uno de sus dos productos ya no tiene sentido:
        // se borran las comparaciones guardadas que lo incluian.
        comparacionRepository.deleteAll(comparacionRepository.findDistinctByDetallesProductoIdProducto(id));
        productoRepository.delete(producto);
    }

    // ── Ficha tecnica, puntajes y precio de referencia ──

    /** Guarda lo opcional del formulario; lo que llega en null no se toca. */
    private void guardarDatosExtra(Producto producto, ProductoRequest request) {
        Integer id = producto.getIdProducto();
        List<Especificacion> actuales = request.getEspecificaciones() != null || request.getPuntajes() != null
                ? especificacionRepository.findByProductoIdProductoOrderByIdEspecificacionAsc(id)
                : List.of();

        if (request.getEspecificaciones() != null) {
            especificacionRepository.deleteAll(actuales.stream().filter(e -> !e.esPuntaje()).toList());
            for (EspecificacionDto dato : request.getEspecificaciones()) {
                especificacionRepository.save(new Especificacion(producto, dato.atributo().trim(),
                        dato.valor().trim(), vacioANull(dato.unidad())));
            }
        }

        if (request.getPuntajes() != null) {
            for (Map.Entry<String, Integer> puntaje : request.getPuntajes().entrySet()) {
                String atributo = Especificacion.PREFIJO_PUNTAJE + capitalizar(puntaje.getKey());
                Especificacion fila = actuales.stream()
                        .filter(e -> atributo.equalsIgnoreCase(e.getAtributo()))
                        .findFirst()
                        .orElseGet(() -> new Especificacion(producto, atributo, "0", "pts"));
                fila.setValor(String.valueOf(puntaje.getValue()));
                especificacionRepository.save(fila);
            }
        }

        if (request.getPrecioReferencia() != null) {
            FuentePrecio referencia = fuenteReferencia();
            Precio precio = precioRepository.findByProductoIdProductoOrderByValorAsc(id).stream()
                    .filter(p -> Objects.equals(p.getFuente().getIdFuente(), referencia.getIdFuente()))
                    .findFirst()
                    .orElseGet(Precio::new);
            precio.setProducto(producto);
            precio.setFuente(referencia);
            precio.setValor(request.getPrecioReferencia());
            precio.setFechaConsulta(LocalDateTime.now(clock));
            precio.setUrlProducto(null);
            precioRepository.save(precio);
        }
    }

    /** Los puntajes deben ser potencia, eficiencia, valor o popularidad, de 0 a 100. */
    private void validarPuntajes(Map<String, Integer> puntajes) {
        if (puntajes == null) {
            return;
        }
        for (Map.Entry<String, Integer> p : puntajes.entrySet()) {
            String clave = p.getKey() == null ? "" : p.getKey().toLowerCase(Locale.ROOT);
            if (!PUNTAJES.contains(clave)) {
                throw new ReglaNegocioException("Puntaje desconocido: " + p.getKey()
                        + ". Use potencia, eficiencia, valor o popularidad.");
            }
            if (p.getValue() == null || p.getValue() < 0 || p.getValue() > 100) {
                throw new ReglaNegocioException("El puntaje de " + clave + " debe estar entre 0 y 100.");
            }
        }
    }

    private FuentePrecio fuenteReferencia() {
        return fuentePrecioRepository.findFirstByNombreIgnoreCase(FuentePrecio.NOMBRE_REFERENCIA)
                .orElseGet(() -> {
                    FuentePrecio nueva = new FuentePrecio();
                    nueva.setNombre(FuentePrecio.NOMBRE_REFERENCIA);
                    nueva.setDescripcion("Precio de referencia estimado por BuildZone; no corresponde a una tienda.");
                    return fuentePrecioRepository.save(nueva);
                });
    }

    private ProductoResponse respuestaCompleta(Producto producto) {
        Integer id = producto.getIdProducto();
        return new ProductoResponse(producto,
                especificacionRepository.findByProductoIdProductoOrderByIdEspecificacionAsc(id),
                precioRepository.findByProductoIdProductoOrderByValorAsc(id));
    }

    private static String capitalizar(String texto) {
        String t = texto.trim().toLowerCase(Locale.ROOT);
        return t.isEmpty() ? t : Character.toUpperCase(t.charAt(0)) + t.substring(1);
    }

    private static String vacioANull(String texto) {
        return texto == null || texto.isBlank() ? null : texto.trim();
    }

    private Producto buscarOFallar(Integer id) {
        return productoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "No existe un producto con id " + id));
    }

    private Marca buscarMarcaOFallar(Integer idMarca) {
        return marcaRepository.findById(idMarca)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "No existe una marca con id " + idMarca));
    }

    private Categoria buscarCategoriaOFallar(Integer idCategoria) {
        return categoriaRepository.findById(idCategoria)
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "No existe una categoria con id " + idCategoria));
    }
}
