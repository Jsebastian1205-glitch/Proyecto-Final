package com.buildzone.api.service;

import java.util.List;

import com.buildzone.api.dto.NoticiaRequest;
import com.buildzone.api.dto.NoticiaResponse;

/** Casos de uso del blog: listar y leer (publico); crear, editar y eliminar (ADMIN). */
public interface NoticiaService {

    List<NoticiaResponse> listar();

    NoticiaResponse obtenerPorId(Integer id);

    /**
     * @param request     datos de la noticia
     * @param idUsuario   id de la cuenta (usuario_cuenta) del administrador que publica
     */
    NoticiaResponse crear(NoticiaRequest request, Long idUsuario);

    NoticiaResponse actualizar(Integer id, NoticiaRequest request);

    void eliminar(Integer id);
}
