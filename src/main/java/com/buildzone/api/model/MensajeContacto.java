package com.buildzone.api.model;

import java.time.LocalDateTime;

import com.buildzone.api.model.enums.EstadoMensaje;
import com.buildzone.api.model.enums.MotivoContacto;

import org.hibernate.annotations.ColumnDefault;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Mensaje enviado desde la pagina de Contacto (tabla {@code mensaje_contacto}).
 * <p>
 * Lo puede enviar cualquier visitante. Si quien escribe tenia sesion
 * iniciada se guarda tambien el id de su cuenta ({@code id_usuario}), solo
 * como referencia para el administrador.
 */
@Entity
@Table(name = "mensaje_contacto")
public class MensajeContacto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_mensaje")
    private Long idMensaje;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    @Column(name = "correo", nullable = false, length = 150)
    private String correo;

    @Enumerated(EnumType.STRING)
    @Column(name = "motivo", nullable = false, length = 30)
    private MotivoContacto motivo;

    @Column(name = "mensaje", nullable = false, length = 1000)
    private String mensaje;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoMensaje estado;

    @Column(name = "fecha_envio", nullable = false)
    private LocalDateTime fechaEnvio;

    /** true si es una solicitud de "Olvide mi contrasena" (la crea el inicio de sesion). */
    @ColumnDefault("false")
    @Column(name = "recuperacion", nullable = false)
    private boolean recuperacion;

    /** Cuenta que envio el mensaje, o null si fue un visitante sin sesion. */
    @Column(name = "id_usuario")
    private Long idUsuario;

    /** Constructor vacio requerido por JPA. */
    public MensajeContacto() {
    }

    public Long getIdMensaje() {
        return idMensaje;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public MotivoContacto getMotivo() {
        return motivo;
    }

    public void setMotivo(MotivoContacto motivo) {
        this.motivo = motivo;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public EstadoMensaje getEstado() {
        return estado;
    }

    public void setEstado(EstadoMensaje estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaEnvio() {
        return fechaEnvio;
    }

    public void setFechaEnvio(LocalDateTime fechaEnvio) {
        this.fechaEnvio = fechaEnvio;
    }

    public boolean isRecuperacion() {
        return recuperacion;
    }

    public void setRecuperacion(boolean recuperacion) {
        this.recuperacion = recuperacion;
    }

    public Long getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Long idUsuario) {
        this.idUsuario = idUsuario;
    }
}
