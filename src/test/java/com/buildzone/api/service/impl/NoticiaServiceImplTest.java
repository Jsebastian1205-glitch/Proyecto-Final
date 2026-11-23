package com.buildzone.api.service.impl;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.buildzone.api.dto.NoticiaRequest;
import com.buildzone.api.dto.NoticiaResponse;
import com.buildzone.api.dto.PlanResponse;
import com.buildzone.api.dto.SuscripcionResponse;
import com.buildzone.api.exception.AccesoDenegadoException;
import com.buildzone.api.model.Autor;
import com.buildzone.api.model.Noticia;
import com.buildzone.api.model.Usuario;
import com.buildzone.api.model.enums.EstadoSuscripcion;
import com.buildzone.api.model.enums.Rol;
import com.buildzone.api.repository.AutorRepository;
import com.buildzone.api.repository.NoticiaRepository;
import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.SuscripcionService;

/**
 * Pruebas unitarias del blog: quien puede publicar (ADMIN o usuario con un
 * plan de pago) y quien puede editar o eliminar (ADMIN o el autor).
 */
@ExtendWith(MockitoExtension.class)
class NoticiaServiceImplTest {

    private static final Clock RELOJ = Clock.fixed(Instant.parse("2026-11-23T20:00:00Z"), ZoneId.of("America/Bogota"));

    @Mock
    private NoticiaRepository noticiaRepository;
    @Mock
    private AutorRepository autorRepository;
    @Mock
    private UsuarioRepository usuarioRepository;
    @Mock
    private SuscripcionService suscripcionService;
    @Mock
    private PasswordEncoder passwordEncoder;

    private NoticiaServiceImpl noticiaService;

    private final UsuarioAutenticado admin = new UsuarioAutenticado(1L, "admin", Rol.ADMIN);
    private final UsuarioAutenticado laura = new UsuarioAutenticado(2L, "laura", Rol.USUARIO);
    private final UsuarioAutenticado andres = new UsuarioAutenticado(3L, "andres", Rol.USUARIO);

    @BeforeEach
    void preparar() {
        noticiaService = new NoticiaServiceImpl(noticiaRepository, autorRepository, usuarioRepository,
                suscripcionService, passwordEncoder, RELOJ);
    }

    // ── Utilidades ──

    private static Usuario cuenta(Long id, String nombre, String email, Rol rol) {
        Usuario u = new Usuario(nombre, "Prueba", nombre.toLowerCase(), email, "hash");
        u.setId(id);
        u.setRol(rol);
        return u;
    }

    private static Autor autor(String nombre, String correo) {
        return new Autor(nombre, "Prueba", correo, "hash", LocalDateTime.of(2026, 1, 1, 0, 0));
    }

    private static NoticiaRequest request(String resumen, String contenido) {
        NoticiaRequest r = new NoticiaRequest();
        r.setTitulo("  Como limpiar el polvo de tu PC  ");
        r.setCategoria("Tutorial");
        r.setResumen(resumen);
        r.setContenido(contenido);
        return r;
    }

    private static Optional<SuscripcionResponse> plan(String nombre, String precio) {
        PlanResponse p = new PlanResponse(5L, nombre, "", new BigDecimal(precio), 30, true);
        return Optional.of(new SuscripcionResponse(9L, 2L, p, LocalDate.of(2026, 11, 1),
                LocalDate.of(2026, 12, 1), EstadoSuscripcion.ACTIVA));
    }

    private static Noticia noticiaDe(Autor autor) {
        Noticia n = new Noticia();
        n.setAutor(autor);
        n.setTitulo("Guia de fuentes");
        n.setCategoria("Guias");
        n.setResumen("Resumen");
        n.setContenido("Contenido");
        n.setFechaPublicacion(LocalDateTime.of(2026, 11, 1, 10, 0));
        return n;
    }

    // ── Publicar ──

    @Test
    @DisplayName("El ADMIN publica sin necesitar plan, con fecha y autor")
    void adminPublica() {
        Autor equipo = autor("Root", "admin@buildzone.com");
        when(usuarioRepository.findById(1L)).thenReturn(Optional.of(cuenta(1L, "Root", "admin@buildzone.com", Rol.ADMIN)));
        when(autorRepository.findByCorreoIgnoreCase("admin@buildzone.com")).thenReturn(Optional.of(equipo));
        when(noticiaRepository.save(any(Noticia.class))).thenAnswer(inv -> inv.getArgument(0));

        NoticiaResponse r = noticiaService.crear(request("Resumen corto", "Contenido"), admin);

        assertThat(r.titulo()).isEqualTo("Como limpiar el polvo de tu PC");
        assertThat(r.autor()).isEqualTo("Root Prueba");
        assertThat(r.fechaPublicacion()).isEqualTo(LocalDateTime.now(RELOJ));
        verify(suscripcionService, never()).obtenerActiva(any());
    }

    @Test
    @DisplayName("Un usuario con plan Premium publica y se le crea su perfil de autor")
    void usuarioPremiumPublica() {
        when(suscripcionService.obtenerActiva(2L)).thenReturn(plan("Premium", "29900"));
        when(usuarioRepository.findById(2L)).thenReturn(Optional.of(cuenta(2L, "Laura", "laura@test.com", Rol.USUARIO)));
        when(autorRepository.findByCorreoIgnoreCase("laura@test.com")).thenReturn(Optional.empty());
        when(passwordEncoder.encode(anyString())).thenReturn("hash-aleatorio");
        when(autorRepository.save(any(Autor.class))).thenAnswer(inv -> inv.getArgument(0));
        when(noticiaRepository.save(any(Noticia.class))).thenAnswer(inv -> inv.getArgument(0));

        NoticiaResponse r = noticiaService.crear(request(null, "Apaga el equipo y usa aire comprimido."), laura);

        assertThat(r.autor()).isEqualTo("Laura Prueba");
        verify(autorRepository).save(any(Autor.class));
    }

    @Test
    @DisplayName("Con el plan Gratuito no se puede publicar")
    void planGratuitoNoPublica() {
        when(suscripcionService.obtenerActiva(2L)).thenReturn(plan("Gratuito", "0"));

        assertThatThrownBy(() -> noticiaService.crear(request(null, "Contenido"), laura))
                .isInstanceOf(AccesoDenegadoException.class)
                .hasMessageContaining("plan de pago");
        verify(noticiaRepository, never()).save(any());
    }

    @Test
    @DisplayName("Sin plan activo no se puede publicar")
    void sinPlanNoPublica() {
        when(suscripcionService.obtenerActiva(2L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> noticiaService.crear(request(null, "Contenido"), laura))
                .isInstanceOf(AccesoDenegadoException.class);
        verify(noticiaRepository, never()).save(any());
    }

    // ── Editar y eliminar ──

    @Test
    @DisplayName("El autor puede editar su propia publicacion")
    void autorEditaLaSuya() {
        Noticia suya = noticiaDe(autor("Laura", "LAURA@test.com"));
        when(noticiaRepository.findById(10)).thenReturn(Optional.of(suya));
        when(usuarioRepository.findById(2L)).thenReturn(Optional.of(cuenta(2L, "Laura", "laura@test.com", Rol.USUARIO)));
        when(noticiaRepository.save(any(Noticia.class))).thenAnswer(inv -> inv.getArgument(0));

        NoticiaResponse r = noticiaService.actualizar(10, request("Nuevo resumen", "Nuevo contenido"), laura);

        assertThat(r.resumen()).isEqualTo("Nuevo resumen");
    }

    @Test
    @DisplayName("Un usuario no puede editar ni eliminar publicaciones de otro")
    void noModificaLasAjenas() {
        Noticia deLaura = noticiaDe(autor("Laura", "laura@test.com"));
        when(noticiaRepository.findById(10)).thenReturn(Optional.of(deLaura));
        when(usuarioRepository.findById(3L)).thenReturn(Optional.of(cuenta(3L, "Andres", "andres@test.com", Rol.USUARIO)));

        assertThatThrownBy(() -> noticiaService.actualizar(10, request(null, "Cambio"), andres))
                .isInstanceOf(AccesoDenegadoException.class)
                .hasMessageContaining("propias");
        assertThatThrownBy(() -> noticiaService.eliminar(10, andres))
                .isInstanceOf(AccesoDenegadoException.class);
        verify(noticiaRepository, never()).save(any());
        verify(noticiaRepository, never()).delete(any());
    }

    @Test
    @DisplayName("El ADMIN puede eliminar cualquier publicacion")
    void adminEliminaCualquiera() {
        Noticia deLaura = noticiaDe(autor("Laura", "laura@test.com"));
        when(noticiaRepository.findById(10)).thenReturn(Optional.of(deLaura));

        noticiaService.eliminar(10, admin);

        verify(noticiaRepository).delete(deLaura);
    }

    // ── Resumen automatico ──

    @Test
    @DisplayName("Sin resumen se toma el inicio del contenido, cortado sin partir palabras")
    void resumenAutomatico() {
        String largo = "palabra ".repeat(40).trim();

        String resumen = NoticiaServiceImpl.resumenAutomatico(largo);

        assertThat(resumen).endsWith("…");
        assertThat(resumen.length()).isLessThanOrEqualTo(181);
        assertThat(resumen).doesNotContain("palab…");
        assertThat(NoticiaServiceImpl.resumenAutomatico("Texto corto")).isEqualTo("Texto corto");
    }
}
