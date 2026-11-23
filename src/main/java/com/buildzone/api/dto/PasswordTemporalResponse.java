package com.buildzone.api.dto;

/**
 * Contrasena temporal generada por el ADMIN (POST /api/usuarios/{id}/restablecer-password).
 * Solo viaja en esta respuesta: en la base queda unicamente su hash BCrypt.
 */
public record PasswordTemporalResponse(Long idUsuario, String username, String email, String passwordTemporal) {
}
