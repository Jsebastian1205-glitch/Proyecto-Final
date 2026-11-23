package com.buildzone.api.dto;

import java.time.LocalDateTime;

import com.buildzone.api.model.MensajeContacto;
import com.buildzone.api.model.enums.EstadoMensaje;
import com.buildzone.api.model.enums.MotivoContacto;

/** Datos de salida de un mensaje de contacto. */
public record MensajeContactoResponse(
        Long idMensaje,
        String nombre,
        String correo,
        MotivoContacto motivo,
        String motivoTexto,
        String mensaje,
        EstadoMensaje estado,
        LocalDateTime fechaEnvio,
        boolean cuentaRegistrada) {

    public MensajeContactoResponse(MensajeContacto m) {
        this(m.getIdMensaje(),
                m.getNombre(),
                m.getCorreo(),
                m.getMotivo(),
                m.getMotivo().getEtiqueta(),
                m.getMensaje(),
                m.getEstado(),
                m.getFechaEnvio(),
                m.getIdUsuario() != null);
    }
}
