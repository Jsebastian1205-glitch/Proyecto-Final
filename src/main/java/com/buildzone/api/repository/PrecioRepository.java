package com.buildzone.api.repository;

import java.util.Collection;
import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.Precio;

/**
 * Acceso a los precios por tienda. Trae la tienda (fuente) en la misma
 * consulta para poder mostrar su nombre sin consultas adicionales.
 */
public interface PrecioRepository extends JpaRepository<Precio, Integer> {

    @EntityGraph(attributePaths = "fuente")
    List<Precio> findByProductoIdProductoInOrderByValorAsc(Collection<Integer> idsProducto);

    @EntityGraph(attributePaths = "fuente")
    List<Precio> findByProductoIdProductoOrderByValorAsc(Integer idProducto);
}
