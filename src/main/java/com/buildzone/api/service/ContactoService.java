package com.buildzone.api.service;

import java.util.List;

import com.buildzone.api.dto.ContactoRequest;
import com.buildzone.api.dto.MensajeContactoResponse;
import com.buildzone.api.model.enums.EstadoMensaje;
import com.buildzone.api.security.UsuarioAutenticado;

/**
 * Casos de uso del formulario de contacto.
 * <ul>
 *   <li>Enviar: publico, con limite antispam por correo.</li>
 *   <li>Listar, cambiar estado y eliminar: solo ADMIN (lo exige SecurityConfig).</li>
 * </ul>
 */
public interface ContactoService {

    /** Maximo de mensajes por correo dentro de la ventana antispam. */
    int MAXIMO_MENSAJES = 3;

    /** Duracion de la ventana antispam, en minutos. */
    int VENTANA_MINUTOS = 10;

    /**
     * @param actual cuenta con sesion iniciada, o null si es un visitante
     */
    MensajeContactoResponse enviar(ContactoRequest request, UsuarioAutenticado actual);

    /**
     * "Olvide mi contrasena": si el correo es de una cuenta, deja una
     * solicitud en los mensajes del administrador. Si no existe (o supera el
     * limite antispam) no hace nada, sin avisar: asi nadie puede averiguar
     * que correos estan registrados.
     */
    void solicitarRecuperacion(String email);

    List<MensajeContactoResponse> listar();

    MensajeContactoResponse cambiarEstado(Long id, EstadoMensaje estado);

    void eliminar(Long id);
}
