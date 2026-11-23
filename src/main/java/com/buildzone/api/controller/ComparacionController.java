package com.buildzone.api.controller;

import java.util.List;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.buildzone.api.dto.ComparacionRequest;
import com.buildzone.api.dto.ComparacionResponse;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.ComparacionService;

/**
 * "Mis comparaciones". Todas las rutas piden sesion y un plan de pago activo
 * (o rol ADMIN); esa regla esta en ComparacionServiceImpl.
 */
@RestController
@RequestMapping("/api/comparaciones")
public class ComparacionController {

    private final ComparacionService comparacionService;

    public ComparacionController(ComparacionService comparacionService) {
        this.comparacionService = comparacionService;
    }

    /** GET /api/comparaciones/mias - duelos guardados, el mas reciente primero. */
    @GetMapping("/mias")
    public ResponseEntity<List<ComparacionResponse>> listarMias(@AuthenticationPrincipal UsuarioAutenticado actual) {
        return ResponseEntity.ok(comparacionService.listarMias(actual));
    }

    /** POST /api/comparaciones - guarda un duelo de dos productos. */
    @PostMapping
    public ResponseEntity<ComparacionResponse> guardar(@Valid @RequestBody ComparacionRequest request,
                                                       @AuthenticationPrincipal UsuarioAutenticado actual) {
        return ResponseEntity.status(HttpStatus.CREATED).body(comparacionService.guardar(request, actual));
    }

    /** DELETE /api/comparaciones/{id} - elimina una comparacion propia. */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id,
                                         @AuthenticationPrincipal UsuarioAutenticado actual) {
        comparacionService.eliminar(id, actual);
        return ResponseEntity.noContent().build();
    }
}
