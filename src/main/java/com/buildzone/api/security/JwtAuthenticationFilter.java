package com.buildzone.api.security;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import com.buildzone.api.repository.UsuarioRepository;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Filtro que se ejecuta una vez por peticion: si llega el encabezado
 * {@code Authorization: Bearer <token>} y el token es valido, carga el
 * usuario desde la base de datos y, si sigue ACTIVO, lo registra como
 * autenticado con la autoridad {@code ROLE_<rol>}.
 * <p>
 * Si el token falta o es invalido no se corta la peticion: simplemente
 * queda anonima, y es {@code SecurityConfig} quien decide si la ruta
 * lo permite (rutas publicas) o responde 401.
 * <p>
 * No es un {@code @Component} a proposito: lo crea {@code SecurityConfig}
 * para que se ejecute solo dentro de la cadena de Spring Security y no
 * tambien como filtro general del servidor.
 */
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String PREFIJO = "Bearer ";

    private final JwtService jwtService;
    private final UsuarioRepository usuarioRepository;

    public JwtAuthenticationFilter(JwtService jwtService, UsuarioRepository usuarioRepository) {
        this.jwtService = jwtService;
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String encabezado = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (encabezado != null && encabezado.startsWith(PREFIJO)
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            String token = encabezado.substring(PREFIJO.length()).trim();

            var usuarioOpt = jwtService.extraerUsername(token)
                    .flatMap(usuarioRepository::findByUsernameIgnoreCase)
                    .filter(usuario -> usuario.estaActivo());

            if (usuarioOpt.isPresent()) {
                var usuario = usuarioOpt.get();
                // Con contrasena temporal solo puede ver su perfil, crear su
                // contrasena nueva y leer lo publico; lo demas responde 403.
                if (usuario.isDebeCambiarPassword() && !permitidoConPasswordTemporal(request)) {
                    responderCambioPendiente(request, response);
                    return;
                }
                UsuarioAutenticado principal = new UsuarioAutenticado(
                        usuario.getId(), usuario.getUsername(), usuario.getRol());
                var autenticacion = new UsernamePasswordAuthenticationToken(
                        principal, null,
                        List.of(new SimpleGrantedAuthority("ROLE_" + usuario.getRol().name())));
                SecurityContextHolder.getContext().setAuthentication(autenticacion);
            }
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Rutas que puede usar quien entro con una contrasena temporal: su perfil,
     * el cambio de contrasena, autenticacion, el formulario de contacto y las
     * lecturas publicas del catalogo, el blog y los planes.
     */
    static boolean permitidoConPasswordTemporal(HttpServletRequest request) {
        String metodo = request.getMethod();
        String ruta = request.getRequestURI();
        if (ruta.startsWith("/api/auth/") || !ruta.startsWith("/api/")) {
            return true;
        }
        if ("GET".equals(metodo)) {
            return ruta.equals("/api/usuarios/me")
                    || ruta.startsWith("/api/productos") || ruta.startsWith("/api/marcas")
                    || ruta.startsWith("/api/categorias") || ruta.equals("/api/planes")
                    || (ruta.startsWith("/api/noticias") && !ruta.equals("/api/noticias/mias"));
        }
        return ("PUT".equals(metodo) && ruta.equals("/api/usuarios/me/password"))
                || ("POST".equals(metodo) && ruta.equals("/api/contacto"));
    }

    private static void responderCambioPendiente(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String ruta = request.getRequestURI().replace("\"", "").replace("\\", "");
        response.getWriter().write("{\"timestamp\":\"" + LocalDateTime.now() + "\",\"status\":403,"
                + "\"error\":\"Forbidden\",\"codigo\":\"CAMBIO_PASSWORD_PENDIENTE\","
                + "\"mensaje\":\"Debes crear tu contrasena nueva antes de continuar.\","
                + "\"ruta\":\"" + ruta + "\",\"detalles\":[]}");
    }
}
