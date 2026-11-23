package com.buildzone.api.dto;

import java.time.LocalDateTime;
import java.util.List;

import com.buildzone.api.model.Comparacion;
import com.buildzone.api.model.Producto;

/**
 * Comparacion guardada. Trae solo los datos basicos de cada producto: el
 * front-end calcula el ganador con los precios y puntajes actuales del catalogo.
 */
public record ComparacionResponse(
        Integer idComparacion,
        String titulo,
        LocalDateTime fechaCreacion,
        List<ProductoComparado> productos) {

    /** Datos basicos de un producto de la comparacion. */
    public record ProductoComparado(Integer idProducto, String nombre, String marca, String categoria) {

        static ProductoComparado de(Producto p) {
            return new ProductoComparado(p.getIdProducto(), p.getNombre(),
                    p.getMarca().getNombre(), p.getCategoria().getNombre());
        }
    }

    /** @param c comparacion con sus productos accesibles (dentro de la transaccion) */
    public ComparacionResponse(Comparacion c) {
        this(c.getIdComparacion(), c.getTitulo(), c.getFechaCreacion(),
                c.getDetalles().stream().map(d -> ProductoComparado.de(d.getProducto())).toList());
    }
}
