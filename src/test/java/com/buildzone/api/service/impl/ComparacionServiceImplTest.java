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
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.buildzone.api.dto.ComparacionRequest;
import com.buildzone.api.dto.ComparacionResponse;
import com.buildzone.api.dto.PlanResponse;
import com.buildzone.api.dto.SuscripcionResponse;
import com.buildzone.api.exception.AccesoDenegadoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.Autor;
import com.buildzone.api.model.Categoria;
import com.buildzone.api.model.Comparacion;
import com.buildzone.api.model.Marca;
import com.buildzone.api.model.Producto;
import com.buildzone.api.model.Usuario;
import com.buildzone.api.model.enums.EstadoSuscripcion;
import com.buildzone.api.model.enums.Rol;
import com.buildzone.api.repository.AutorRepository;
import com.buildzone.api.repository.ComparacionRepository;
import com.buildzone.api.repository.ProductoRepository;
import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.security.UsuarioAutenticado;
import com.buildzone.api.service.SuscripcionService;

/** Pruebas unitarias de "Mis comparaciones": solo planes de pago, reglas del duelo y autoria. */
@ExtendWith(MockitoExtension.class)
class ComparacionServiceImplTest {

    private static final Clock RELOJ = Clock.fixed(Instant.parse("2026-11-23T21:00:00Z"), ZoneId.of("America/Bogota"));

    @Mock
    private ComparacionRepository comparacionRepository;
    @Mock
    private ProductoRepository productoRepository;
    @Mock
    private AutorRepository autorRepository;
    @Mock
    private UsuarioRepository usuarioRepository;
    @Mock
    private SuscripcionService suscripcionService;
    @Mock
    private PasswordEncoder passwordEncoder;

    private ComparacionServiceImpl service;

    private final UsuarioAutenticado laura = new UsuarioAutenticado(2L, "laura", Rol.USUARIO);
    private final UsuarioAutenticado andres = new UsuarioAutenticado(3L, "andres", Rol.USUARIO);

    private Categoria procesador;
    private Categoria grafica;

    @BeforeEach
    void setUp() {
        service = new ComparacionServiceImpl(comparacionRepository, productoRepository, autorRepository,
                usuarioRepository, suscripcionService, passwordEncoder, RELOJ);
        procesador = new Categoria("Procesador", null);
        procesador.setIdCategoria(1);
        grafica = new Categoria("Tarjeta Grafica", null);
        grafica.setIdCategoria(2);
    }

    // ── Datos de apoyo ──

    private static Usuario cuenta(Long id, String nombre, String email) {
        Usuario u = new Usuario(nombre, "Prueba", nombre.toLowerCase(), email, "hash");
        u.setId(id);
        return u;
    }

    private Producto producto(int id, String nombre, Categoria categoria) {
        Producto p = new Producto();
        p.setIdProducto(id);
        p.setNombre(nombre);
        p.setMarca(new Marca("Marca", null));
        p.setCategoria(categoria);
        when(productoRepository.findById(id)).thenReturn(Optional.of(p));
        return p;
    }

    private void conPlan(Long usuarioId, String precio) {
        PlanResponse plan = new PlanResponse(5L, "Plan", "", new BigDecimal(precio), 30, true);
        when(suscripcionService.obtenerActiva(usuarioId)).thenReturn(Optional.of(new SuscripcionResponse(
                9L, usuarioId, plan, LocalDate.of(2026, 11, 1), LocalDate.of(2026, 12, 1), EstadoSuscripcion.ACTIVA)));
    }

    private void lauraConCuentaYAutor() {
        when(usuarioRepository.findById(2L)).thenReturn(Optional.of(cuenta(2L, "Laura", "laura@test.com")));
        when(autorRepository.findByCorreoIgnoreCase("laura@test.com"))
                .thenReturn(Optional.of(new Autor("Laura", "Prueba", "laura@test.com", "hash", LocalDateTime.now(RELOJ))));
    }

    // ── Pruebas ──

    @Test
    @DisplayName("Sin plan o con el plan Gratuito no se puede guardar ni listar")
    void exigePlanDePago() {
        when(suscripcionService.obtenerActiva(3L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.listarMias(andres)).isInstanceOf(AccesoDenegadoException.class);

        conPlan(2L, "0");
        assertThatThrownBy(() -> service.guardar(new ComparacionRequest(1, 2), laura))
                .isInstanceOf(AccesoDenegadoException.class)
                .hasMessageContaining("mensual o anual");
        verify(comparacionRepository, never()).save(any());
    }

    @Test
    @DisplayName("Con plan de pago se guarda el duelo con titulo, fecha y sus dos productos")
    void guardaConPlanDePago() {
        conPlan(2L, "29900");
        lauraConCuentaYAutor();
        producto(1, "Ryzen 7 7800X3D", procesador);
        producto(2, "Core i7-14700K", procesador);
        when(comparacionRepository.findByAutorCorreoIgnoreCaseOrderByFechaCreacionDescIdComparacionDesc(anyString()))
                .thenReturn(List.of());
        when(comparacionRepository.save(any(Comparacion.class))).thenAnswer(inv -> inv.getArgument(0));

        ComparacionResponse r = service.guardar(new ComparacionRequest(1, 2), laura);

        assertThat(r.titulo()).isEqualTo("Duelo: Ryzen 7 7800X3D vs Core i7-14700K");
        assertThat(r.fechaCreacion()).isEqualTo(LocalDateTime.now(RELOJ));
        assertThat(r.productos()).extracting(ComparacionResponse.ProductoComparado::idProducto).containsExactly(1, 2);
    }

    @Test
    @DisplayName("El mismo duelo en orden inverso no se duplica: solo se actualiza la fecha")
    void noDuplica() {
        conPlan(2L, "29900");
        when(usuarioRepository.findById(2L)).thenReturn(Optional.of(cuenta(2L, "Laura", "laura@test.com")));
        Producto a = producto(1, "Ryzen 7 7800X3D", procesador);
        Producto b = producto(2, "Core i7-14700K", procesador);
        Comparacion guardada = new Comparacion();
        guardada.setTitulo("Duelo: Ryzen 7 7800X3D vs Core i7-14700K");
        guardada.setFechaCreacion(LocalDateTime.of(2026, 1, 1, 10, 0));
        guardada.agregarProducto(a);
        guardada.agregarProducto(b);
        when(comparacionRepository.findByAutorCorreoIgnoreCaseOrderByFechaCreacionDescIdComparacionDesc("laura@test.com"))
                .thenReturn(List.of(guardada));
        when(comparacionRepository.save(guardada)).thenReturn(guardada);

        service.guardar(new ComparacionRequest(2, 1), laura);

        assertThat(guardada.getFechaCreacion()).isEqualTo(LocalDateTime.now(RELOJ));
        assertThat(guardada.getDetalles()).hasSize(2);
    }

    @Test
    @DisplayName("No se comparan dos veces el mismo producto ni productos de distinta categoria")
    void reglasDelDuelo() {
        conPlan(2L, "29900");
        assertThatThrownBy(() -> service.guardar(new ComparacionRequest(1, 1), laura))
                .isInstanceOf(ReglaNegocioException.class);

        producto(1, "Ryzen 7 7800X3D", procesador);
        producto(3, "RTX 4070", grafica);
        assertThatThrownBy(() -> service.guardar(new ComparacionRequest(1, 3), laura))
                .isInstanceOf(ReglaNegocioException.class)
                .hasMessageContaining("misma categoria");
    }

    @Test
    @DisplayName("Solo el dueno puede eliminar su comparacion")
    void soloElDuenoElimina() {
        Comparacion deLaura = new Comparacion();
        deLaura.setAutor(new Autor("Laura", "Prueba", "laura@test.com", "hash", LocalDateTime.now(RELOJ)));
        when(comparacionRepository.findById(7)).thenReturn(Optional.of(deLaura));
        when(usuarioRepository.findById(3L)).thenReturn(Optional.of(cuenta(3L, "Andres", "andres@test.com")));

        assertThatThrownBy(() -> service.eliminar(7, andres)).isInstanceOf(AccesoDenegadoException.class);
        verify(comparacionRepository, never()).delete(any());

        when(usuarioRepository.findById(2L)).thenReturn(Optional.of(cuenta(2L, "Laura", "laura@test.com")));
        service.eliminar(7, laura);
        verify(comparacionRepository).delete(deLaura);
    }
}
