package com.buildzone.api.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.Especificacion;

/**
 * Acceso a la ficha tecnica de los productos. Las consultas reciben varios
 * ids a la vez para traer las fichas de todo el catalogo en una sola
 * consulta (y no una por producto).
 */
public interface EspecificacionRepository extends JpaRepository<Especificacion, Integer> {

    List<Especificacion> findByProductoIdProductoInOrderByIdEspecificacionAsc(Collection<Integer> idsProducto);

    List<Especificacion> findByProductoIdProductoOrderByIdEspecificacionAsc(Integer idProducto);
}
