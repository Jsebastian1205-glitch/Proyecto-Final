package com.buildzone.api.service;

import java.util.List;

import com.buildzone.api.dto.ComparacionRequest;
import com.buildzone.api.dto.ComparacionResponse;
import com.buildzone.api.security.UsuarioAutenticado;

/**
 * "Mis comparaciones": guardar duelos del comparador y volver a verlos.
 * Es exclusivo de los planes de pago (mensual o anual) y del ADMIN; con el
 * plan Gratuito o sin plan se responde 403.
 */
public interface ComparacionService {

    List<ComparacionResponse> listarMias(UsuarioAutenticado actual);

    /** Guarda el duelo; si ya estaba guardado, solo actualiza su fecha. */
    ComparacionResponse guardar(ComparacionRequest request, UsuarioAutenticado actual);

    void eliminar(Integer id, UsuarioAutenticado actual);
}
