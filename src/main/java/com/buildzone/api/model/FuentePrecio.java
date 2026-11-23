package com.buildzone.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Tienda o fuente de la que sale un precio (tabla {@code fuente_precio}).
 * La fuente "BuildZone (precio de referencia)" agrupa los precios
 * estimados que no vienen de una tienda.
 */
@Entity
@Table(name = "fuente_precio")
public class FuentePrecio {

    /** Nombre de la fuente de los precios de referencia (no es una tienda). */
    public static final String NOMBRE_REFERENCIA = "BuildZone (precio de referencia)";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_fuente")
    private Integer idFuente;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    @Column(name = "sitio_web", length = 255)
    private String sitioWeb;

    @Column(name = "descripcion", length = 1000)
    private String descripcion;

    public FuentePrecio() {
    }

    public boolean esReferencia() {
        return NOMBRE_REFERENCIA.equalsIgnoreCase(nombre);
    }

    public Integer getIdFuente() {
        return idFuente;
    }

    public void setIdFuente(Integer idFuente) {
        this.idFuente = idFuente;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getSitioWeb() {
        return sitioWeb;
    }

    public void setSitioWeb(String sitioWeb) {
        this.sitioWeb = sitioWeb;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}
