package com.buildzone.api.model.enums;

/**
 * Estado de un mensaje del formulario de contacto.
 * NUEVO al llegar, LEIDO cuando el administrador lo abre y RESPONDIDO
 * cuando el administrador lo marca asi despues de contestar por correo.
 */
public enum EstadoMensaje {
    NUEVO,
    LEIDO,
    RESPONDIDO
}
