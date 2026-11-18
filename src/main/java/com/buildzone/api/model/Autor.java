package com.buildzone.api.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Autor de las noticias del blog.
 * <p>
 * Mapea la tabla {@code usuario} del modelo original de la base de datos
 * (id_usuario, nombre, apellido, correo, contrasena, fecha_registro), que es
 * a la que apunta {@code noticia.id_usuario}. No es una cuenta para iniciar
 * sesion: las cuentas viven en {@code usuario_cuenta} (entidad
 * {@link Usuario}). Cuando un administrador publica por primera vez, el
 * servicio de noticias le crea aqui su perfil de autor con el mismo nombre
 * y correo de su cuenta.
 */
@Entity
@Table(name = "usuario")
public class Autor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuario")
    private Integer idUsuario;

    @Column(name = "nombre", nullable = false, length = 50)
    private String nombre;

    @Column(name = "apellido", nullable = false, length = 50)
    private String apellido;

    @Column(name = "correo", unique = true, length = 100)
    private String correo;

    /** Columna obligatoria del modelo original; aqui solo se guarda un hash BCrypt. */
    @Column(name = "contrasena", nullable = false, length = 255)
    private String contrasena;

    @Column(name = "fecha_registro", nullable = false)
    private LocalDateTime fechaRegistro;

    /** Constructor vacio requerido por JPA. */
    public Autor() {
    }

    public Autor(String nombre, String apellido, String correo, String contrasena, LocalDateTime fechaRegistro) {
        this.nombre = nombre;
        this.apellido = apellido;
        this.correo = correo;
        this.contrasena = contrasena;
        this.fechaRegistro = fechaRegistro;
    }

    /** Nombre para mostrar en el blog, por ejemplo "Equipo BuildZone". */
    public String getNombreCompleto() {
        return (nombre + " " + apellido).trim();
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public String getCorreo() {
        return correo;
    }

    public String getContrasena() {
        return contrasena;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }
}
