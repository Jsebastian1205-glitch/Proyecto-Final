package com.buildzone.api.dto;

import jakarta.validation.constraints.NotNull;

/** Guardar un duelo del comparador (POST /api/comparaciones). */
public record ComparacionRequest(
        @NotNull(message = "Falta el primer producto.") Integer idProductoA,
        @NotNull(message = "Falta el segundo producto.") Integer idProductoB) {
}
