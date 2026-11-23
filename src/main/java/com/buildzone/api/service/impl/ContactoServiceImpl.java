package com.buildzone.api.service.impl;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.buildzone.api.dto.ContactoRequest;
import com.buildzone.api.dto.MensajeContactoResponse;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.MensajeContacto;
import com.buildzone.api.model.enums.EstadoMensaje;
import com.buildzone.api.repository.MensajeContactoRepository;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.ContactoService;

/** Implementacion de {@link ContactoService}. */
@Service
@Transactional(readOnly = true)
public class ContactoServiceImpl implements ContactoService {

    private static final int LARGO_MINIMO = 10;

    private final MensajeContactoRepository repository;
    private final Clock clock;

    public ContactoServiceImpl(MensajeContactoRepository repository, Clock clock) {
        this.repository = repository;
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
