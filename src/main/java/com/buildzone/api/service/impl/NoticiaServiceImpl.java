package com.buildzone.api.service.impl;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.buildzone.api.dto.NoticiaRequest;
import com.buildzone.api.dto.NoticiaResponse;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.model.Autor;
import com.buildzone.api.model.Noticia;
import com.buildzone.api.model.Usuario;
import com.buildzone.api.repository.AutorRepository;
import com.buildzone.api.repository.NoticiaRepository;
import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.service.NoticiaService;

/**
 * Implementacion de {@link NoticiaService}.
 * <p>
 * Igual que en productos, la clase es {@code @Transactional(readOnly = true)}
 * para que el autor (relacion LAZY) se pueda leer al armar la respuesta, y
 * los metodos que escriben se marcan con {@code @Transactional}.
 */
@Service
@Transactional(readOnly = true)
public class NoticiaServiceImpl implements NoticiaService {

    /** Largo maximo del resumen que se genera cuando el admin no escribe uno. */
    private static final int LARGO_RESUMEN_AUTOMATICO = 180;

    private final NoticiaRepository noticiaRepository;
    private final AutorRepository autorRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final Clock clock;

    public NoticiaServiceImpl(NoticiaRepository noticiaRepository, AutorRepository autorRepository,
                              UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder, Clock clock) {
        this.noticiaRepository = noticiaRepository;
        this.autorRepository = autorRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.clock = clock;
    }

    @Override
    public List<NoticiaResponse> listar() {
        return noticiaRepository.findAllByOrderByFechaPublicacionDescIdNoticiaDesc().stream()
                .map(NoticiaResponse::new)
                .toList();
    }

    @Override
    public NoticiaResponse obtenerPorId(Integer id) {
        return new NoticiaResponse(buscarOFallar(id));
    }

    @Override
    @Transactional
    public NoticiaResponse crear(NoticiaRequest request, Long idUsuario) {
        Noticia noticia = new Noticia();
        copiarDatos(request, noticia);
        noticia.setAutor(autorDeLaCuenta(idUsuario));
        noticia.setFechaPublicacion(LocalDateTime.now(clock));
        return new NoticiaResponse(noticiaRepository.save(noticia));
    }

    @Override
    @Transactional
    public NoticiaResponse actualizar(Integer id, NoticiaRequest request) {
        Noticia noticia = buscarOFallar(id);
        copiarDatos(request, noticia);
        return new NoticiaResponse(noticiaRepository.save(noticia));
    }

    @Override
    @Transactional
    public void eliminar(Integer id) {
        noticiaRepository.delete(buscarOFallar(id));
    }

    private void copiarDatos(NoticiaRequest request, Noticia noticia) {
        noticia.setTitulo(request.getTitulo().trim());
        noticia.setCategoria(request.getCategoria().trim());
        noticia.setContenido(request.getContenido().trim());
        String resumen = request.getResumen() == null ? "" : request.getResumen().trim();
        noticia.setResumen(resumen.isEmpty() ? resumenAutomatico(noticia.getContenido()) : resumen);
    }

    /** Primeras palabras del contenido, cortadas sin partir una palabra. */
    static String resumenAutomatico(String contenido) {
        String texto = contenido.replaceAll("\\s+", " ").trim();
        if (texto.length() <= LARGO_RESUMEN_AUTOMATICO) {
            return texto;
        }
        String corte = texto.substring(0, LARGO_RESUMEN_AUTOMATICO);
        int ultimoEspacio = corte.lastIndexOf(' ');
        return (ultimoEspacio > 0 ? corte.substring(0, ultimoEspacio) : corte) + "…";
    }

    /**
     * Perfil de autor (tabla usuario) del administrador que publica. Se busca
     * por el correo de su cuenta; si es su primera noticia se crea con su
     * nombre y apellido. La columna contrasena es obligatoria en el modelo
     * original, asi que se guarda el hash de un valor aleatorio: este perfil
     * no sirve para iniciar sesion.
     */
    private Autor autorDeLaCuenta(Long idUsuario) {
        Usuario cuenta = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe la cuenta con id " + idUsuario));
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

    private Noticia buscarOFallar(Integer id) {
        return noticiaRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe una noticia con id " + id));
    }
}
