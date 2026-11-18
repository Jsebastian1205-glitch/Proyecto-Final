package com.buildzone.api.dto;

import java.time.LocalDateTime;

import com.buildzone.api.model.Noticia;

/**
 * Datos de salida de una noticia. Incluye el nombre del autor para que el
 * blog no tenga que pedirlo aparte.
 */
public record NoticiaResponse(
        Integer idNoticia,
        String titulo,
        String categoria,
        String resumen,
        String contenido,
        LocalDateTime fechaPublicacion,
        String autor) {

    /**
     * @param noticia entidad con su autor accesible (dentro de la transaccion)
     */
    public NoticiaResponse(Noticia noticia) {
        this(noticia.getIdNoticia(),
                noticia.getTitulo(),
                noticia.getCategoria(),
                noticia.getResumen(),
                noticia.getContenido(),
                noticia.getFechaPublicacion(),
                noticia.getAutor().getNombreCompleto());
    }
}
