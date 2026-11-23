package com.buildzone.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/** Un producto dentro de una comparacion (tabla {@code detalle_comparacion}). */
@Entity
@Table(name = "detalle_comparacion")
public class DetalleComparacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_detalle")
    private Integer idDetalle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_comparacion", nullable = false)
    private Comparacion comparacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;

    /** Constructor vacio requerido por JPA. */
    public DetalleComparacion() {
    }

    public DetalleComparacion(Comparacion comparacion, Producto producto) {
        this.comparacion = comparacion;
        this.producto = producto;
    }

    public Integer getIdDetalle() {
        return idDetalle;
    }

    public Comparacion getComparacion() {
        return comparacion;
    }

    public Producto getProducto() {
        return producto;
    }
}
