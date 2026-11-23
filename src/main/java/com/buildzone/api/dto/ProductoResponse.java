package com.buildzone.api.dto;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.buildzone.api.model.Especificacion;
import com.buildzone.api.model.Precio;
import com.buildzone.api.model.Producto;

/**
 * Datos de salida de un Producto. Incluye el nombre de la marca y de la
 * categoria (no solo sus ids), para que quien consuma la API no tenga
 * que hacer otra llamada para mostrar esa informacion.
 * <p>
 * Tambien trae lo que la pagina necesita para mostrarlo y compararlo:
 * <ul>
 *   <li>{@code precio}: el menor precio entre las tiendas (null si no hay).</li>
 *   <li>{@code precios}: el precio en cada tienda, de menor a mayor.</li>
 *   <li>{@code puntajes}: potencia, eficiencia, valor y popularidad (0-100).</li>
 *   <li>{@code especificaciones}: la ficha tecnica, sin los puntajes.</li>
 * </ul>
 */
public class ProductoResponse {

    private Integer idProducto;
    private String nombre;
    private String descripcion;
    private String imagen;
    private Integer idMarca;
    private String nombreMarca;
    private Integer idCategoria;
    private String nombreCategoria;
    private BigDecimal precio;
    private List<PrecioTiendaResponse> precios = List.of();
    private Map<String, Integer> puntajes = Map.of();
    private List<EspecificacionDto> especificaciones = List.of();

    public ProductoResponse() {
    }

    /**
     * Respuesta completa: el producto con su ficha tecnica, sus puntajes y
     * sus precios por tienda.
     */
    public ProductoResponse(Producto producto, List<Especificacion> ficha, List<Precio> preciosTienda) {
        this(producto);
        this.especificaciones = ficha.stream()
                .filter(e -> !e.esPuntaje())
                .map(e -> new EspecificacionDto(e.getAtributo(), e.getValor(), e.getUnidad()))
                .toList();
        Map<String, Integer> mapa = new LinkedHashMap<>();
        for (Especificacion e : ficha) {
            if (!e.esPuntaje()) {
                continue;
            }
            String clave = e.getAtributo().substring(Especificacion.PREFIJO_PUNTAJE.length())
                    .trim().toLowerCase(Locale.ROOT);
            try {
                mapa.put(clave, Integer.valueOf(e.getValor().trim()));
            } catch (NumberFormatException ignorado) {
                // Un puntaje mal escrito en la BD no debe romper el catalogo
            }
        }
        this.puntajes = mapa;
        this.precios = preciosTienda.stream()
                .sorted(Comparator.comparing(Precio::getValor))
                .map(PrecioTiendaResponse::new)
                .toList();
        this.precio = this.precios.isEmpty() ? null : this.precios.get(0).valor();
    }

    /**
     * Construye la respuesta a partir de la entidad JPA ya cargada
     * (incluyendo marca y categoria, para poder leer sus nombres).
     *
     * @param producto entidad con marca y categoria accesibles
     */
    public ProductoResponse(Producto producto) {
        this.idProducto = producto.getIdProducto();
        this.nombre = producto.getNombre();
        this.descripcion = producto.getDescripcion();
        this.imagen = producto.getImagen();
        this.idMarca = producto.getMarca().getIdMarca();
        this.nombreMarca = producto.getMarca().getNombre();
        this.idCategoria = producto.getCategoria().getIdCategoria();
        this.nombreCategoria = producto.getCategoria().getNombre();
    }

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
    }

    public Integer getIdMarca() {
        return idMarca;
    }

    public void setIdMarca(Integer idMarca) {
        this.idMarca = idMarca;
    }

    public String getNombreMarca() {
        return nombreMarca;
    }

    public void setNombreMarca(String nombreMarca) {
        this.nombreMarca = nombreMarca;
    }

    public Integer getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(Integer idCategoria) {
        this.idCategoria = idCategoria;
    }

    public String getNombreCategoria() {
        return nombreCategoria;
    }

    public void setNombreCategoria(String nombreCategoria) {
        this.nombreCategoria = nombreCategoria;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public List<PrecioTiendaResponse> getPrecios() {
        return precios;
    }

    public Map<String, Integer> getPuntajes() {
        return puntajes;
    }

    public List<EspecificacionDto> getEspecificaciones() {
        return especificaciones;
    }
}
