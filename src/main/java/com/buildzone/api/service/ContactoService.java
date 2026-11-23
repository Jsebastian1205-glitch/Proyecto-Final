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

    List<MensajeContactoResponse> listar();

    MensajeContactoResponse cambiarEstado(Long id, EstadoMensaje estado);

    void eliminar(Long id);
}
