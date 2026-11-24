package com.buildzone.api.controller;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.buildzone.api.dto.AuthResponse;
import com.buildzone.api.dto.LoginRequest;
import com.buildzone.api.dto.RecuperacionRequest;
import com.buildzone.api.dto.RegistroRequest;
import com.buildzone.api.exception.CredencialesInvalidasException;
import com.buildzone.api.security.LimiteDeIntentos;
import com.buildzone.api.service.AuthService;
import com.buildzone.api.service.ContactoService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

/** Endpoints publicos de autenticacion. */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    /** Misma respuesta exista o no la cuenta: no revela que correos estan registrados. */
    static final String RESPUESTA_RECUPERACION =
            "Si el correo esta registrado, el equipo de BuildZone te escribira con una contrasena temporal.";

    private final AuthService authService;
    private final ContactoService contactoService;
    private final LimiteDeIntentos limiteDeIntentos;

    public AuthController(AuthService authService, ContactoService contactoService,
                          LimiteDeIntentos limiteDeIntentos) {
        this.authService = authService;
        this.contactoService = contactoService;
        this.limiteDeIntentos = limiteDeIntentos;
    }

    /** POST /api/auth/registro - crea una cuenta USUARIO y devuelve su token. */
    @PostMapping("/registro")
    public ResponseEntity<AuthResponse> registrar(@Valid @RequestBody RegistroRequest request,
                                                  HttpServletRequest http) {
        limiteDeIntentos.verificarRegistro(http.getRemoteAddr());
        AuthResponse respuesta = authService.registrar(request);
        limiteDeIntentos.registrarRegistro(http.getRemoteAddr());
        return ResponseEntity.status(HttpStatus.CREATED).body(respuesta);
    }

    /**
     * POST /api/auth/login - valida credenciales y devuelve un token JWT.
     * Tras 5 intentos fallidos sobre la misma cuenta en 15 minutos responde 429,
     * aunque la contrasena sea correcta (proteccion contra fuerza bruta).
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> iniciarSesion(@Valid @RequestBody LoginRequest request,
                                                      HttpServletRequest http) {
        String ip = http.getRemoteAddr();
        limiteDeIntentos.verificarLogin(request.identificador(), ip);
        try {
            AuthResponse respuesta = authService.iniciarSesion(request);
            limiteDeIntentos.registrarLoginExitoso(request.identificador());
            return ResponseEntity.ok(respuesta);
        } catch (CredencialesInvalidasException e) {
            limiteDeIntentos.registrarLoginFallido(request.identificador(), ip);
            throw e;
        }
    }

    /**
     * POST /api/auth/recuperar - "Olvide mi contrasena". Deja la solicitud en
     * Panel admin > Mensajes; el admin genera una contrasena temporal.
     */
    @PostMapping("/recuperar")
    public ResponseEntity<Map<String, String>> recuperar(@Valid @RequestBody RecuperacionRequest request,
                                                         HttpServletRequest http) {
        limiteDeIntentos.consumirFormulario(http.getRemoteAddr());
        contactoService.solicitarRecuperacion(request.email());
        return ResponseEntity.accepted().body(Map.of("mensaje", RESPUESTA_RECUPERACION));
    }
}
