package com.buildzone.api.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.FuentePrecio;

/**
 * Acceso a las tiendas o fuentes de precio.
 */
public interface FuentePrecioRepository extends JpaRepository<FuentePrecio, Integer> {

    Optional<FuentePrecio> findFirstByNombreIgnoreCase(String nombre);
}
