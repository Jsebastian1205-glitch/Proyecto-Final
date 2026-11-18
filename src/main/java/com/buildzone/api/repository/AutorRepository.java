package com.buildzone.api.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.Autor;

/** Acceso a datos de {@link Autor} (tabla {@code usuario} del modelo original). */
public interface AutorRepository extends JpaRepository<Autor, Integer> {

    Optional<Autor> findByCorreoIgnoreCase(String correo);
}
