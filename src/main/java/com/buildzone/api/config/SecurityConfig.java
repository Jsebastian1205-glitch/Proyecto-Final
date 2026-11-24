package com.buildzone.api.config;

import static org.springframework.security.web.util.matcher.AntPathRequestMatcher.antMatcher;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.header.writers.DelegatingRequestMatcherHeaderWriter;
import org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter;
import org.springframework.security.web.header.writers.StaticHeadersWriter;
import org.springframework.security.web.util.matcher.NegatedRequestMatcher;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.security.JwtAuthenticationFilter;
import com.buildzone.api.security.JwtService;
import com.buildzone.api.security.RespuestaErrorSeguridad;

/**
 * Configuracion de seguridad de la API.
 * <ul>
 *   <li>Sin sesion de servidor (STATELESS): cada peticion se autentica con JWT.</li>
 *   <li>CSRF deshabilitado: no se usan cookies de sesion, el token viaja en un encabezado.</li>
 *   <li>El front-end (static/) es publico; CORS solo hace falta si la pagina se abre desde otro origen.</li>
 *   <li>Autorizacion por ruta y verbo HTTP segun el rol (tabla en README.md).</li>
 * </ul>
 */
@Configuration
public class SecurityConfig {

    private static final String ADMIN = "ADMIN";

    /**
     * Content-Security-Policy. 'unsafe-inline' es necesario porque index.html usa
     * atributos onclick y style; aun asi bloquea scripts de otros dominios,
     * plugins, formularios hacia otros sitios y conexiones a otras APIs.
     */
    static final String POLITICA_CONTENIDO = String.join("; ",
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline'",
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
            "font-src 'self' https://fonts.gstatic.com",
            "img-src 'self' data: https:",
            "connect-src 'self'",
            "object-src 'none'",
            "base-uri 'self'",
            "form-action 'self'",
            "frame-ancestors 'self'");

    private final JwtService jwtService;
    private final UsuarioRepository usuarioRepository;
    private final RespuestaErrorSeguridad respuestaErrorSeguridad;
    private final List<String> origenesPermitidos;

    public SecurityConfig(JwtService jwtService,
                          UsuarioRepository usuarioRepository,
                          RespuestaErrorSeguridad respuestaErrorSeguridad,
                          @Value("${buildzone.cors.origenes-permitidos:*}") String origenes) {
        this.jwtService = jwtService;
        this.usuarioRepository = usuarioRepository;
        this.respuestaErrorSeguridad = respuestaErrorSeguridad;
        // Vacio = ningun otro sitio puede llamar a la API desde el navegador (en
        // produccion la pagina y la API estan en el mismo dominio y no lo necesitan).
        this.origenesPermitidos = Arrays.stream(origenes.split(","))
                .map(String::trim)
                .filter(o -> !o.isEmpty())
                .toList();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            // Cabeceras de seguridad (ver CABECERAS_SEGURIDAD mas abajo)
            .headers(headers -> headers
                    // Ninguna otra pagina puede mostrar BuildZone dentro de un iframe
                    // (sameOrigin y no deny: la consola H2 del perfil dev usa iframes).
                    .frameOptions(frame -> frame.sameOrigin())
                    // HTTPS obligatorio por un ano. Spring solo la envia en peticiones
                    // HTTPS, asi que en http://localhost no tiene efecto.
                    .httpStrictTransportSecurity(hsts -> hsts.includeSubDomains(true).maxAgeInSeconds(31_536_000))
                    // No enviar la URL completa a otros sitios
                    .referrerPolicy(ref -> ref.policy(ReferrerPolicyHeaderWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN))
                    .addHeaderWriter(new StaticHeadersWriter("Permissions-Policy",
                            "camera=(), microphone=(), geolocation=(), payment=()"))
                    // Politica de contenido: solo scripts, estilos y datos del propio sitio
                    // (mas Google Fonts). No se aplica a la consola H2 del perfil dev.
                    .addHeaderWriter(new DelegatingRequestMatcherHeaderWriter(
                            new NegatedRequestMatcher(antMatcher("/h2-console/**")),
                            new StaticHeadersWriter("Content-Security-Policy", POLITICA_CONTENIDO))))
            .exceptionHandling(ex -> ex
                    .authenticationEntryPoint(respuestaErrorSeguridad)
                    .accessDeniedHandler(respuestaErrorSeguridad))
            .authorizeHttpRequests(auth -> auth
                    // Preflight CORS
                    .requestMatchers(antMatcher(HttpMethod.OPTIONS, "/**")).permitAll()
                    // Front-end (src/main/resources/static): la pagina y sus archivos son
                    // publicos; la proteccion de datos se hace en las rutas /api/**.
                    .requestMatchers(antMatcher(HttpMethod.GET, "/"),
                            antMatcher(HttpMethod.GET, "/index.html"),
                            antMatcher(HttpMethod.GET, "/css/**"),
                            antMatcher(HttpMethod.GET, "/js/**"),
                            antMatcher(HttpMethod.GET, "/img/**"),
                            antMatcher(HttpMethod.GET, "/favicon.ico")).permitAll()
                    // Publico
                    .requestMatchers(antMatcher("/api/auth/**")).permitAll()
                    .requestMatchers(antMatcher(HttpMethod.GET, "/api/planes")).permitAll()
                    // Contacto: enviar es publico; ver y gestionar mensajes, solo ADMIN
                    .requestMatchers(antMatcher(HttpMethod.POST, "/api/contacto")).permitAll()
                    .requestMatchers(antMatcher("/api/contacto/**")).hasRole(ADMIN)
                    // Blog: "mis publicaciones" pide sesion aunque sea un GET
                    .requestMatchers(antMatcher(HttpMethod.GET, "/api/noticias/mias")).authenticated()
                    .requestMatchers(antMatcher(HttpMethod.GET, "/api/productos/**"),
                            antMatcher(HttpMethod.GET, "/api/marcas/**"),
                            antMatcher(HttpMethod.GET, "/api/categorias/**"),
                            antMatcher(HttpMethod.GET, "/api/noticias/**")).permitAll()
                    .requestMatchers(antMatcher("/h2-console/**"), antMatcher("/error")).permitAll()
                    // Solo ADMIN
                    .requestMatchers(antMatcher(HttpMethod.GET, "/api/planes/todos")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.POST, "/api/planes")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.PUT, "/api/planes/**")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.DELETE, "/api/planes/**")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.GET, "/api/usuarios")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.PATCH, "/api/usuarios/**")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.POST, "/api/usuarios/*/restablecer-password")).hasRole(ADMIN)
                    .requestMatchers(antMatcher(HttpMethod.GET, "/api/suscripciones")).hasRole(ADMIN)
                    .requestMatchers(antMatcher("/api/productos/**"), antMatcher("/api/marcas/**"),
                            antMatcher("/api/categorias/**")).hasRole(ADMIN)
                    // Todo lo demas requiere sesion (perfil propio, suscripciones propias y
                    // publicar en el blog: el plan activo o la autoria se validan en NoticiaServiceImpl)
                    .anyRequest().authenticated())
            .addFilterBefore(new JwtAuthenticationFilter(jwtService, usuarioRepository),
                    UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /** BCrypt con factor de costo por defecto (10). */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(origenesPermitidos);
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
