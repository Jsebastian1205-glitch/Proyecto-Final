package com.buildzone.api.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.buildzone.api.model.Precio;

/**
 * Precio de un producto en una tienda. {@code referencia} es true cuando
 * no viene de una tienda sino del precio de referencia de BuildZone.
 */
public record PrecioTiendaResponse(
        String tienda,
        BigDecimal valor,
        LocalDateTime fechaConsulta,
        String url,
        boolean referencia) {

    public PrecioTiendaResponse(Precio precio) {
        this(precio.getFuente().getNombre(), precio.getValor(), precio.getFechaConsulta(),
                precio.getUrlProducto(), precio.getFuente().esReferencia());
    }
}
