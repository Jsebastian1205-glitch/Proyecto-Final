package com.buildzone.api.service;

import java.util.List;

import com.buildzone.api.dto.NoticiaRequest;
import com.buildzone.api.dto.NoticiaResponse;
import com.buildzone.api.security.UsuarioAutenticado;

/**
 * Casos de uso del blog.
 * <ul>
 *   <li>Listar y leer: publico.</li>
 *   <li>Crear: ADMIN, o usuario con una suscripcion activa a un plan de pago
 *       (mensual o anual; el plan Gratuito no alcanza).</li>
 *   <li>Editar y eliminar: ADMIN cualquier publicacion; el usuario, solo las suyas.</li>
 * </ul>
 */
public interface NoticiaService {

    List<NoticiaResponse> listar();

    NoticiaResponse obtenerPorId(Integer id);

    /** Publicaciones escritas por la cuenta que hace la peticion. */
    List<NoticiaResponse> listarMias(UsuarioAutenticado actual);

    NoticiaResponse crear(NoticiaRequest request, UsuarioAutenticado actual);

    NoticiaResponse actualizar(Integer id, NoticiaRequest request, UsuarioAutenticado actual);

    void eliminar(Integer id, UsuarioAutenticado actual);
}
