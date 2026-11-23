package com.buildzone.api.dto;

import com.buildzone.api.model.enums.EstadoMensaje;

import jakarta.validation.constraints.NotNull;

/** Cambiar el estado de un mensaje de contacto (PATCH /api/contacto/{id}/estado) - solo ADMIN. */
public record CambioEstadoMensajeRequest(@NotNull(message = "El estado es obligatorio.") EstadoMensaje estado) {
}
