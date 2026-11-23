package com.buildzone.api.service.impl;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.buildzone.api.dto.ContactoRequest;
import com.buildzone.api.dto.MensajeContactoResponse;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.MensajeContacto;
import com.buildzone.api.model.Usuario;
import com.buildzone.api.model.enums.EstadoMensaje;
import com.buildzone.api.model.enums.MotivoContacto;
import com.buildzone.api.repository.MensajeContactoRepository;
import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.ContactoService;

/** Implementacion de {@link ContactoService}. */
@Service
@Transactional(readOnly = true)
public class ContactoServiceImpl implements ContactoService {

    private static final int LARGO_MINIMO = 10;

    static final String TEXTO_RECUPERACION =
            "Solicitud de recuperacion de contrasena enviada desde el inicio de sesion. "
            + "Genera una contrasena temporal en Panel admin > Usuarios > Restablecer contrasena.";

    private final MensajeContactoRepository repository;
    private final UsuarioRepository usuarioRepository;
    private final Clock clock;

    public ContactoServiceImpl(MensajeContactoRepository repository, UsuarioRepository usuarioRepository,
                               Clock clock) {
        this.repository = repository;
        this.usuarioRepository = usuarioRepository;
        this.clock = clock;
    }

    @Override
    @Transactional
    public MensajeContactoResponse enviar(ContactoRequest request, UsuarioAutenticado actual) {
        String nombre = request.nombre().trim();
        String correo = request.correo().trim().toLowerCase();
        String mensaje = request.mensaje().trim();

        // @Size cuenta los espacios; aqui se valida el texto ya recortado.
        if (mensaje.length() < LARGO_MINIMO) {
            throw new ReglaNegocioException("El mensaje debe tener entre 10 y 1000 caracteres.");
        }

        LocalDateTime ahora = LocalDateTime.now(clock);
        long recientes = repository.countByCorreoIgnoreCaseAndFechaEnvioAfter(
                correo, ahora.minusMinutes(VENTANA_MINUTOS));
        if (recientes >= MAXIMO_MENSAJES) {
            throw new ReglaNegocioException("Ya enviaste " + MAXIMO_MENSAJES + " mensajes en los ultimos "
                    + VENTANA_MINUTOS + " minutos. Espera un momento antes de escribir de nuevo.");
        }

        MensajeContacto nuevo = new MensajeContacto();
        nuevo.setNombre(nombre);
        nuevo.setCorreo(correo);
        nuevo.setMotivo(request.motivo());
        nuevo.setMensaje(mensaje);
        nuevo.setEstado(EstadoMensaje.NUEVO);
        nuevo.setFechaEnvio(ahora);
        nuevo.setIdUsuario(actual != null ? actual.id() : null);
        return new MensajeContactoResponse(repository.save(nuevo));
    }

    @Override
    @Transactional
    public void solicitarRecuperacion(String email) {
        String correo = email.trim().toLowerCase();
        Optional<Usuario> cuenta = usuarioRepository.findByEmailIgnoreCase(correo);
        if (cuenta.isEmpty()) {
            return;
        }
        LocalDateTime ahora = LocalDateTime.now(clock);
        if (repository.countByCorreoIgnoreCaseAndFechaEnvioAfter(correo, ahora.minusMinutes(VENTANA_MINUTOS))
                >= MAXIMO_MENSAJES) {
            return;
        }
        Usuario u = cuenta.get();
        MensajeContacto solicitud = new MensajeContacto();
        solicitud.setNombre(recortar((u.getNombre() + " " + u.getApellido()).trim(), 100));
        solicitud.setCorreo(u.getEmail());
        solicitud.setMotivo(MotivoContacto.PROBLEMA_CUENTA);
        solicitud.setMensaje(TEXTO_RECUPERACION);
        solicitud.setEstado(EstadoMensaje.NUEVO);
        solicitud.setFechaEnvio(ahora);
        solicitud.setIdUsuario(u.getId());
        solicitud.setRecuperacion(true);
        repository.save(solicitud);
    }

    private static String recortar(String texto, int largo) {
        return texto.length() <= largo ? texto : texto.substring(0, largo);
    }

    @Override
    public List<MensajeContactoResponse> listar() {
        return repository.findAllByOrderByFechaEnvioDescIdMensajeDesc().stream()
                .map(MensajeContactoResponse::new)
                .toList();
    }

    @Override
    @Transactional
    public MensajeContactoResponse cambiarEstado(Long id, EstadoMensaje estado) {
        MensajeContacto mensaje = buscarOFallar(id);
        mensaje.setEstado(estado);
        return new MensajeContactoResponse(repository.save(mensaje));
    }

    @Override
    @Transactional
    public void eliminar(Long id) {
        repository.delete(buscarOFallar(id));
    }

    private MensajeContacto buscarOFallar(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe el mensaje con id " + id));
    }
}
