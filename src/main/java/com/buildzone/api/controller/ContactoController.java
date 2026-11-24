package com.buildzone.api.controller;

import java.util.List;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.buildzone.api.dto.CambioEstadoMensajeRequest;
import com.buildzone.api.dto.ContactoRequest;
import com.buildzone.api.dto.MensajeContactoResponse;
import com.buildzone.api.security.LimiteDeIntentos;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.ContactoService;

/**
 * Formulario de contacto. Enviar es publico (con o sin sesion); ver, cambiar
 * el estado y eliminar mensajes es solo para ADMIN (ver SecurityConfig).
 */
@RestController
@RequestMapping("/api/contacto")
public class ContactoController {

    private final ContactoService contactoService;
    private final LimiteDeIntentos limiteDeIntentos;

    public ContactoController(ContactoService contactoService, LimiteDeIntentos limiteDeIntentos) {
        this.contactoService = contactoService;
        this.limiteDeIntentos = limiteDeIntentos;
    }

    /** POST /api/contacto - guarda un mensaje y devuelve su numero. */
    @PostMapping
    public ResponseEntity<MensajeContactoResponse> enviar(@Valid @RequestBody ContactoRequest request,
                                                          @AuthenticationPrincipal UsuarioAutenticado actual,
                                                          HttpServletRequest http) {
        // Ademas del limite por correo (servicio), un limite por conexion contra spam
        limiteDeIntentos.consumirFormulario(http.getRemoteAddr());
        return ResponseEntity.status(HttpStatus.CREATED).body(contactoService.enviar(request, actual));
    }

    /** GET /api/contacto - todos los mensajes, el mas reciente primero (ADMIN). */
    @GetMapping
    public ResponseEntity<List<MensajeContactoResponse>> listar() {
        return ResponseEntity.ok(contactoService.listar());
    }

    /** PATCH /api/contacto/{id}/estado - NUEVO, LEIDO o RESPONDIDO (ADMIN). */
    @PatchMapping("/{id}/estado")
    public ResponseEntity<MensajeContactoResponse> cambiarEstado(@PathVariable Long id,
                                                                 @Valid @RequestBody CambioEstadoMensajeRequest request) {
        return ResponseEntity.ok(contactoService.cambiarEstado(id, request.estado()));
    }

    /** DELETE /api/contacto/{id} - elimina un mensaje (ADMIN). */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        contactoService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
