package com.buildzone.api.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.Comparacion;

/** Acceso a datos de {@link Comparacion}. */
public interface ComparacionRepository extends JpaRepository<Comparacion, Integer> {

    /** Comparaciones de un autor (tabla usuario), de la mas reciente a la mas antigua. */
    List<Comparacion> findByAutorCorreoIgnoreCaseOrderByFechaCreacionDescIdComparacionDesc(String correo);

    /** Comparaciones que incluyen un producto (para borrarlas si el producto se elimina). */
    List<Comparacion> findDistinctByDetallesProductoIdProducto(Integer idProducto);
}
