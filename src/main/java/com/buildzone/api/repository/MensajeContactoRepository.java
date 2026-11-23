package com.buildzone.api.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.buildzone.api.model.MensajeContacto;

/** Acceso a datos de {@link MensajeContacto}. */
public interface MensajeContactoRepository extends JpaRepository<MensajeContacto, Long> {

    /** Todos los mensajes, del mas reciente al mas antiguo. */
    List<MensajeContacto> findAllByOrderByFechaEnvioDescIdMensajeDesc();

    /** Cuantos mensajes envio un correo desde cierto momento (limite antispam). */
    long countByCorreoIgnoreCaseAndFechaEnvioAfter(String correo, LocalDateTime desde);
}
