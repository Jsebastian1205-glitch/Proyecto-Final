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

/**
 * Un dato de la ficha tecnica de un producto (tabla {@code especificacion}).
 * <p>
 * Los puntajes que usa el comparador tambien se guardan aqui, con el
 * atributo "Puntaje: Potencia", "Puntaje: Eficiencia", "Puntaje: Valor" y
 * "Puntaje: Popularidad" (valor de 0 a 100, unidad "pts").
 */
@Entity
@Table(name = "especificacion")
public class Especificacion {

    /** Prefijo de los atributos que guardan los puntajes del comparador. */
    public static final String PREFIJO_PUNTAJE = "Puntaje: ";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_especificacion")
    private Integer idEspecificacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;

    @Column(name = "atributo", nullable = false, length = 100)
    private String atributo;

    @Column(name = "valor", nullable = false, length = 255)
    private String valor;

    @Column(name = "unidad", length = 50)
    private String unidad;

    public Especificacion() {
    }

    public Especificacion(Producto producto, String atributo, String valor, String unidad) {
        this.producto = producto;
        this.atributo = atributo;
        this.valor = valor;
        this.unidad = unidad;
    }

    /** true si este dato es uno de los puntajes del comparador. */
    public boolean esPuntaje() {
        return atributo != null && atributo.startsWith(PREFIJO_PUNTAJE);
    }

    public Integer getIdEspecificacion() {
        return idEspecificacion;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    public String getAtributo() {
        return atributo;
    }

    public void setAtributo(String atributo) {
        this.atributo = atributo;
    }

    public String getValor() {
        return valor;
    }

    public void setValor(String valor) {
        this.valor = valor;
    }

    public String getUnidad() {
        return unidad;
    }

    public void setUnidad(String unidad) {
        this.unidad = unidad;
    }
}
