package com.buildzone.api.model;

import java.time.LocalDateTime;

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
 * Entidad JPA de una noticia (articulo) del blog.
 * <p>
 * Mapea la tabla {@code noticia} del modelo original (id_noticia,
 * id_usuario, titulo, contenido, fecha_publicacion) mas dos columnas que
 * agrega el script {@code 00_estructura.sql}: {@code categoria} (Guias,
 * Tutorial, Novedades...) y {@code resumen} (texto corto de la tarjeta).
 */
@Entity
@Table(name = "noticia")
public class Noticia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_noticia")
    private Integer idNoticia;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Autor autor;

    @Column(name = "titulo", nullable = false, length = 200)
    private String titulo;

    @Column(name = "categoria", length = 50)
    private String categoria;

    @Column(name = "resumen", length = 300)
    private String resumen;

    @Column(name = "contenido", nullable = false, length = 20000)
    private String contenido;

    @Column(name = "fecha_publicacion", nullable = false)
    private LocalDateTime fechaPublicacion;

    /** Constructor vacio requerido por JPA. */
    public Noticia() {
    }

    public Integer getIdNoticia() {
        return idNoticia;
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

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public String getResumen() {
        return resumen;
    }

    public void setResumen(String resumen) {
        this.resumen = resumen;
    }

    public String getContenido() {
        return contenido;
    }

    public void setContenido(String contenido) {
        this.contenido = contenido;
    }

    public LocalDateTime getFechaPublicacion() {
        return fechaPublicacion;
    }

    public void setFechaPublicacion(LocalDateTime fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
    }
}
