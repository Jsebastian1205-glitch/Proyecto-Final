package com.buildzone.api.repository;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.Noticia;

/** Acceso a datos de {@link Noticia}. */
public interface NoticiaRepository extends JpaRepository<Noticia, Integer> {

    /**
     * Todas las noticias, de la mas reciente a la mas antigua. Trae el autor
     * en la misma consulta (EntityGraph) para no hacer una consulta extra
     * por cada noticia al armar la respuesta.
     */
    @EntityGraph(attributePaths = "autor")
    List<Noticia> findAllByOrderByFechaPublicacionDescIdNoticiaDesc();
}
