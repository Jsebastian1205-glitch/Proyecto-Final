package com.buildzone.api.service;

import java.util.List;

import com.buildzone.api.dto.CambioPasswordRequest;
import com.buildzone.api.dto.PasswordTemporalResponse;
import com.buildzone.api.dto.PerfilRequest;
import com.buildzone.api.dto.UsuarioResponse;
import com.buildzone.api.model.enums.EstadoUsuario;
import com.buildzone.api.model.enums.Rol;

/** Casos de uso sobre usuarios: perfil propio y administracion. */
public interface UsuarioService {

    UsuarioResponse obtenerPerfil(Long usuarioId);

    UsuarioResponse actualizarPerfil(Long usuarioId, PerfilRequest request);

    void cambiarPassword(Long usuarioId, CambioPasswordRequest request);

    List<UsuarioResponse> listar();

    UsuarioResponse cambiarRol(Long actorId, Long usuarioId, Rol nuevoRol);

    UsuarioResponse cambiarEstado(Long actorId, Long usuarioId, EstadoUsuario nuevoEstado);

    /**
     * Genera una contrasena temporal (ADMIN). La anterior deja de funcionar y
     * el usuario debe crear una nueva al entrar. La temporal no vence: sirve
     * hasta que el usuario la use para crear la suya.
     */
    PasswordTemporalResponse restablecerPassword(Long actorId, Long usuarioId);
}
