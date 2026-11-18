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
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.buildzone.api.dto.NoticiaRequest;
import com.buildzone.api.dto.NoticiaResponse;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.NoticiaService;

/**
 * Endpoints del blog. Leer es publico; crear, editar y eliminar exige rol
 * ADMIN (ver SecurityConfig).
 */
@RestController
@RequestMapping("/api/noticias")
public class NoticiaController {

    private final NoticiaService noticiaService;

    public NoticiaController(NoticiaService noticiaService) {
        this.noticiaService = noticiaService;
    }

    /** GET /api/noticias - todas las noticias, la mas reciente primero. */
    @GetMapping
    public ResponseEntity<List<NoticiaResponse>> listar() {
        return ResponseEntity.ok(noticiaService.listar());
    }

    /** GET /api/noticias/{id} - una noticia. */
    @GetMapping("/{id}")
    public ResponseEntity<NoticiaResponse> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(noticiaService.obtenerPorId(id));
    }

    /** POST /api/noticias - publica una noticia a nombre del admin que la crea. */
    @PostMapping
    public ResponseEntity<NoticiaResponse> crear(@AuthenticationPrincipal UsuarioAutenticado actual,
                                                 @Valid @RequestBody NoticiaRequest request) {
        NoticiaResponse creada = noticiaService.crear(request, actual.id());
        return ResponseEntity.status(HttpStatus.CREATED).body(creada);
    }

    /** PUT /api/noticias/{id} - edita una noticia (conserva autor y fecha). */
    @PutMapping("/{id}")
    public ResponseEntity<NoticiaResponse> actualizar(@PathVariable Integer id,
                                                      @Valid @RequestBody NoticiaRequest request) {
        return ResponseEntity.ok(noticiaService.actualizar(id, request));
    }

    /** DELETE /api/noticias/{id} - elimina una noticia. */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        noticiaService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
