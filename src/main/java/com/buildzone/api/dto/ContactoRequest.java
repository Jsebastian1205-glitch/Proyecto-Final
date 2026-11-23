package com.buildzone.api.dto;

import com.buildzone.api.model.enums.MotivoContacto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** Datos del formulario de contacto (POST /api/contacto, publico). */
public record ContactoRequest(
        @NotBlank(message = "El nombre es obligatorio.")
        @Size(max = 100, message = "El nombre no puede superar los 100 caracteres.")
        String nombre,

        @NotBlank(message = "El correo es obligatorio.")
        @Email(message = "El correo no tiene un formato valido.")
        @Size(max = 150, message = "El correo no puede superar los 150 caracteres.")
        String correo,

        @NotNull(message = "El motivo es obligatorio.")
        MotivoContacto motivo,

        @NotBlank(message = "El mensaje es obligatorio.")
        @Size(min = 10, max = 1000, message = "El mensaje debe tener entre 10 y 1000 caracteres.")
        String mensaje) {
}
