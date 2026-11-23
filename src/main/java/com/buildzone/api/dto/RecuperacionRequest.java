package com.buildzone.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** "Olvide mi contrasena" (POST /api/auth/recuperar, publico). */
public record RecuperacionRequest(
        @NotBlank(message = "El correo es obligatorio.")
        @Email(message = "El correo no tiene un formato valido.")
        @Size(max = 150, message = "El correo no puede superar los 150 caracteres.")
        String email) {
}
