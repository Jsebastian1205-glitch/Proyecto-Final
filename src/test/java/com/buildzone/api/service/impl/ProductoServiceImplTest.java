package com.buildzone.api.service.impl;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.buildzone.api.dto.EspecificacionDto;
import com.buildzone.api.dto.PrecioTiendaResponse;
import com.buildzone.api.dto.ProductoRequest;
import com.buildzone.api.dto.ProductoResponse;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.Categoria;
import com.buildzone.api.model.Especificacion;
import com.buildzone.api.model.FuentePrecio;
import com.buildzone.api.model.Marca;
import com.buildzone.api.model.Precio;
import com.buildzone.api.model.Producto;
import com.buildzone.api.repository.CategoriaRepository;
import com.buildzone.api.repository.EspecificacionRepository;
import com.buildzone.api.repository.FuentePrecioRepository;
import com.buildzone.api.repository.MarcaRepository;
import com.buildzone.api.repository.PrecioRepository;
import com.buildzone.api.repository.ProductoRepository;

/**
 * Pruebas unitarias del modulo de catalogo: Producto, con su ficha tecnica,
 * sus puntajes del comparador y sus precios por tienda.
 */
@ExtendWith(MockitoExtension.class)
class ProductoServiceImplTest {

    private static final Clock RELOJ = Clock.fixed(Instant.parse("2026-11-23T20:00:00Z"), ZoneId.of("America/Bogota"));

    @Mock
    private ProductoRepository productoRepository;
    @Mock
    private MarcaRepository marcaRepository;
    @Mock
    private CategoriaRepository categoriaRepository;
    @Mock
    private EspecificacionRepository especificacionRepository;
    @Mock
    private PrecioRepository precioRepository;
    @Mock
    private FuentePrecioRepository fuentePrecioRepository;

    private ProductoServiceImpl productoService;

    private Marca amd;
    private Categoria procesador;

    @BeforeEach
    void preparar() {
        productoService = new ProductoServiceImpl(productoRepository, marcaRepository, categoriaRepository,
                especificacionRepository, precioRepository, fuentePrecioRepository, RELOJ);
        amd = new Marca("AMD", null);
        amd.setIdMarca(2);
        procesador = new Categoria("Procesador", null);
        procesador.setIdCategoria(1);
    }

    private ProductoRequest request(Integer idMarca, Integer idCategoria) {
        ProductoRequest r = new ProductoRequest();
        r.setNombre("Ryzen 7 7700X");
        r.setDescripcion("8 nucleos");
        r.setIdMarca(idMarca);
        r.setIdCategoria(idCategoria);
        return r;
    }

    private Producto producto(int id) {
        Producto p = new Producto();
        p.setIdProducto(id);
        p.setNombre("Ryzen 7 9800X3D");
        p.setMarca(amd);
        p.setCategoria(procesador);
        return p;
    }

    private static FuentePrecio tienda(int id, String nombre) {
        FuentePrecio f = new FuentePrecio();
        f.setIdFuente(id);
        f.setNombre(nombre);
        return f;
    }

    private static Precio precio(Producto producto, FuentePrecio fuente, String valor, String url) {
        Precio p = new Precio();
        p.setProducto(producto);
        p.setFuente(fuente);
        p.setValor(new BigDecimal(valor));
        p.setFechaConsulta(LocalDateTime.of(2026, 11, 18, 0, 0));
        p.setUrlProducto(url);
        return p;
    }

    // ── CRUD basico ──

    @Test
    @DisplayName("Crear: responde con el nombre de marca y categoria resueltos")
    void crearProducto() {
        when(marcaRepository.findById(2)).thenReturn(Optional.of(amd));
        when(categoriaRepository.findById(1)).thenReturn(Optional.of(procesador));
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> {
            Producto p = inv.getArgument(0);
            p.setIdProducto(15);
            return p;
        });

        ProductoResponse r = productoService.crear(request(2, 1));

        assertThat(r.getIdProducto()).isEqualTo(15);
        assertThat(r.getNombreMarca()).isEqualTo("AMD");
        assertThat(r.getNombreCategoria()).isEqualTo("Procesador");
        assertThat(r.getPrecio()).isNull();
    }

    @Test
    @DisplayName("Crear: una marca inexistente lanza 404 y no guarda nada")
    void crearConMarcaInexistente() {
        when(marcaRepository.findById(99)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> productoService.crear(request(99, 1)))
                .isInstanceOf(RecursoNoEncontradoException.class)
                .hasMessageContaining("marca");
        verify(productoRepository, never()).save(any());
    }

    @Test
    @DisplayName("Obtener: id inexistente lanza 404")
    void obtenerInexistente() {
        when(productoRepository.findById(404)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> productoService.obtenerPorId(404))
                .isInstanceOf(RecursoNoEncontradoException.class);
    }

    // ── Precios, puntajes y ficha tecnica ──

    @Test
    @DisplayName("Listar: el precio es el menor entre las tiendas y los precios van de menor a mayor")
    void listarConPrecioMenor() {
        Producto p = producto(7);
        when(productoRepository.findAll()).thenReturn(List.of(p));
        when(especificacionRepository.findByProductoIdProductoInOrderByIdEspecificacionAsc(anyCollection()))
                .thenReturn(List.of());
        when(precioRepository.findByProductoIdProductoInOrderByValorAsc(anyCollection())).thenReturn(List.of(
                precio(p, tienda(1, "Mercado Libre Colombia"), "2569000", "https://ejemplo.com/a"),
                precio(p, tienda(2, "PC Store Colombia"), "2470000", "https://ejemplo.com/b")));

        ProductoResponse r = productoService.listar().get(0);

        assertThat(r.getPrecio()).isEqualByComparingTo("2470000");
        assertThat(r.getPrecios()).extracting(PrecioTiendaResponse::tienda)
                .containsExactly("PC Store Colombia", "Mercado Libre Colombia");
        assertThat(r.getPrecios().get(0).referencia()).isFalse();
    }

    @Test
    @DisplayName("Listar: los puntajes se separan de la ficha tecnica")
    void puntajesSeparadosDeLaFicha() {
        Producto p = producto(7);
        when(productoRepository.findAll()).thenReturn(List.of(p));
        when(especificacionRepository.findByProductoIdProductoInOrderByIdEspecificacionAsc(anyCollection()))
                .thenReturn(List.of(
                        new Especificacion(p, "Socket", "AM5", null),
                        new Especificacion(p, "Puntaje: Potencia", "99", "pts"),
                        new Especificacion(p, "Hilos", "16", null),
                        new Especificacion(p, "Puntaje: Valor", "72", "pts")));
        when(precioRepository.findByProductoIdProductoInOrderByValorAsc(anyCollection())).thenReturn(List.of());

        ProductoResponse r = productoService.listar().get(0);

        assertThat(r.getEspecificaciones()).extracting(EspecificacionDto::atributo).containsExactly("Socket", "Hilos");
        assertThat(r.getPuntajes()).containsEntry("potencia", 99).containsEntry("valor", 72);
        assertThat(r.getPrecio()).isNull();
    }

    @Test
    @DisplayName("Crear: un puntaje fuera de 0 a 100 se rechaza y no guarda nada")
    void puntajeFueraDeRango() {
        when(marcaRepository.findById(2)).thenReturn(Optional.of(amd));
        when(categoriaRepository.findById(1)).thenReturn(Optional.of(procesador));
        ProductoRequest r = request(2, 1);
        r.setPuntajes(Map.of("potencia", 150));

        assertThatThrownBy(() -> productoService.crear(r))
                .isInstanceOf(ReglaNegocioException.class)
                .hasMessageContaining("entre 0 y 100");
        verify(productoRepository, never()).save(any());
    }

    @Test
    @DisplayName("Crear: un puntaje desconocido se rechaza")
    void puntajeDesconocido() {
        when(marcaRepository.findById(2)).thenReturn(Optional.of(amd));
        when(categoriaRepository.findById(1)).thenReturn(Optional.of(procesador));
        ProductoRequest r = request(2, 1);
        r.setPuntajes(Map.of("velocidad", 80));

        assertThatThrownBy(() -> productoService.crear(r))
                .isInstanceOf(ReglaNegocioException.class)
                .hasMessageContaining("velocidad");
    }

    @Test
    @DisplayName("Actualizar: el precio de referencia se guarda con la fuente de BuildZone")
    void guardaPrecioDeReferencia() {
        Producto p = producto(20);
        FuentePrecio referencia = tienda(27, FuentePrecio.NOMBRE_REFERENCIA);
        when(productoRepository.findById(20)).thenReturn(Optional.of(p));
        when(marcaRepository.findById(2)).thenReturn(Optional.of(amd));
        when(categoriaRepository.findById(1)).thenReturn(Optional.of(procesador));
        when(productoRepository.save(any(Producto.class))).thenAnswer(inv -> inv.getArgument(0));
        when(fuentePrecioRepository.findFirstByNombreIgnoreCase(FuentePrecio.NOMBRE_REFERENCIA))
                .thenReturn(Optional.of(referencia));
        ProductoRequest r = request(2, 1);
        r.setPrecioReferencia(new BigDecimal("899000"));

        productoService.actualizar(20, r);

        ArgumentCaptor<Precio> guardado = ArgumentCaptor.forClass(Precio.class);
        verify(precioRepository).save(guardado.capture());
        assertThat(guardado.getValue().getValor()).isEqualByComparingTo("899000");
        assertThat(guardado.getValue().getFuente().esReferencia()).isTrue();
        assertThat(guardado.getValue().getFechaConsulta()).isEqualTo(LocalDateTime.now(RELOJ));
    }

    @Test
    @DisplayName("Eliminar: borra la ficha y los precios antes que el producto")
    void eliminarBorraFichaYPrecios() {
        Producto p = producto(30);
        List<Especificacion> ficha = List.of(new Especificacion(p, "Socket", "AM5", null));
        List<Precio> precios = List.of(precio(p, tienda(1, "Falabella Colombia"), "500000", null));
        when(productoRepository.findById(30)).thenReturn(Optional.of(p));
        when(especificacionRepository.findByProductoIdProductoOrderByIdEspecificacionAsc(30)).thenReturn(ficha);
        when(precioRepository.findByProductoIdProductoOrderByValorAsc(30)).thenReturn(precios);

        productoService.eliminar(30);

        verify(especificacionRepository).deleteAll(ficha);
        verify(precioRepository).deleteAll(precios);
        verify(productoRepository).delete(p);
    }
}
