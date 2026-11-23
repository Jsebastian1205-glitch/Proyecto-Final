package com.buildzone.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Un dato de la ficha tecnica, por ejemplo {"atributo": "Socket",
 * "valor": "AM5", "unidad": null}. Se usa tanto en las respuestas como
 * al crear o editar un producto.
 */
public record EspecificacionDto(
        @NotBlank(message = "El atributo de la ficha tecnica es obligatorio")
        @Size(max = 100, message = "El atributo no puede superar los 100 caracteres")
        String atributo,
        @NotBlank(message = "El valor de la ficha tecnica es obligatorio")
        @Size(max = 255, message = "El valor no puede superar los 255 caracteres")
        String valor,
        @Size(max = 50, message = "La unidad no puede superar los 50 caracteres")
        String unidad) {
}
