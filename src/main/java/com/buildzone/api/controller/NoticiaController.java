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
 * Endpoints del blog. Leer es publico. Crear exige sesion de ADMIN o de un
 * usuario con plan de pago activo (mensual o anual); editar y eliminar, ser ADMIN o el autor (las
 * reglas estan en NoticiaServiceImpl).
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

    /** GET /api/noticias/mias - publicaciones de quien hace la peticion (requiere sesion). */
    @GetMapping("/mias")
    public ResponseEntity<List<NoticiaResponse>> listarMias(@AuthenticationPrincipal UsuarioAutenticado actual) {
        return ResponseEntity.ok(noticiaService.listarMias(actual));
    }

    /** GET /api/noticias/{id} - una noticia. */
    @GetMapping("/{id}")
    public ResponseEntity<NoticiaResponse> obtenerPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(noticiaService.obtenerPorId(id));
    }

    /** POST /api/noticias - publica a nombre de quien la crea (ADMIN o usuario con plan de pago). */
    @PostMapping
    public ResponseEntity<NoticiaResponse> crear(@AuthenticationPrincipal UsuarioAutenticado actual,
                                                 @Valid @RequestBody NoticiaRequest request) {
        NoticiaResponse creada = noticiaService.crear(request, actual);
        return ResponseEntity.status(HttpStatus.CREATED).body(creada);
    }

    /** PUT /api/noticias/{id} - edita una noticia (conserva autor y fecha). */
    @PutMapping("/{id}")
    public ResponseEntity<NoticiaResponse> actualizar(@PathVariable Integer id,
                                                      @Valid @RequestBody NoticiaRequest request,
                                                      @AuthenticationPrincipal UsuarioAutenticado actual) {
        return ResponseEntity.ok(noticiaService.actualizar(id, request, actual));
    }

    /** DELETE /api/noticias/{id} - elimina una noticia. */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id,
                                         @AuthenticationPrincipal UsuarioAutenticado actual) {
        noticiaService.eliminar(id, actual);
        return ResponseEntity.noContent().build();
    }
}
