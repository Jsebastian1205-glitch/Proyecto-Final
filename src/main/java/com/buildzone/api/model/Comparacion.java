package com.buildzone.api.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;

/**
 * Comparacion (duelo) guardada por un usuario. Mapea la tabla
 * {@code comparacion} del modelo original; sus productos estan en
 * {@code detalle_comparacion} ({@link DetalleComparacion}).
 * <p>
 * Igual que {@link Noticia}, apunta a la tabla {@code usuario} del modelo
 * original ({@link Autor}); el servicio la relaciona con la cuenta por correo.
 */
@Entity
@Table(name = "comparacion")
public class Comparacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_comparacion")
    private Integer idComparacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Autor autor;

    @Column(name = "titulo", length = 150)
    private String titulo;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion;

    @OneToMany(mappedBy = "comparacion", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("idDetalle ASC")
    private List<DetalleComparacion> detalles = new ArrayList<>();

    /** Constructor vacio requerido por JPA. */
    public Comparacion() {
    }

    /** Agrega un producto a la comparacion (enlaza los dos lados de la relacion). */
    public void agregarProducto(Producto producto) {
        detalles.add(new DetalleComparacion(this, producto));
    }

    public Integer getIdComparacion() {
        return idComparacion;
    }

    public Autor getAutor() {
        return autor;
    }

    public void setAutor(Autor autor) {
        this.autor = autor;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public List<DetalleComparacion> getDetalles() {
        return detalles;
    }
}
