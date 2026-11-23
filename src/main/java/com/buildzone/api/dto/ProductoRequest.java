package com.buildzone.api.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Datos de entrada para crear o actualizar un Producto. Recibe los ids
 * de marca y categoria (no los objetos completos); el servicio se
 * encarga de buscarlos y validar que existan.
 * <p>
 * Los tres ultimos campos son opcionales. Si llegan en null no se tocan
 * los datos guardados; si llegan con valor, reemplazan lo que habia:
 * <ul>
 *   <li>{@code precioReferencia}: precio de referencia de BuildZone (COP).
 *       Los precios reales de las tiendas no se modifican.</li>
 *   <li>{@code puntajes}: claves potencia, eficiencia, valor y popularidad
 *       (0 a 100), los que usa el comparador.</li>
 *   <li>{@code especificaciones}: la ficha tecnica completa.</li>
 * </ul>
 */
public class ProductoRequest {

    @NotBlank(message = "El nombre del producto es obligatorio")
    @Size(max = 150, message = "El nombre no puede superar los 150 caracteres")
    private String nombre;

    private String descripcion;

    @Size(max = 255, message = "La ruta/URL de la imagen no puede superar los 255 caracteres")
    private String imagen;

    @NotNull(message = "El id de la marca es obligatorio")
    private Integer idMarca;

    @NotNull(message = "El id de la categoria es obligatorio")
    private Integer idCategoria;

    @DecimalMin(value = "0", message = "El precio de referencia no puede ser negativo")
    @Digits(integer = 10, fraction = 2, message = "El precio de referencia no es valido")
    private BigDecimal precioReferencia;

    private Map<String, Integer> puntajes;

    @Size(max = 40, message = "La ficha tecnica admite maximo 40 datos")
    private List<@Valid EspecificacionDto> especificaciones;

    public BigDecimal getPrecioReferencia() {
        return precioReferencia;
    }

    public void setPrecioReferencia(BigDecimal precioReferencia) {
        this.precioReferencia = precioReferencia;
    }

    public Map<String, Integer> getPuntajes() {
        return puntajes;
    }

    public void setPuntajes(Map<String, Integer> puntajes) {
        this.puntajes = puntajes;
    }

    public List<EspecificacionDto> getEspecificaciones() {
        return especificaciones;
    }

    public void setEspecificaciones(List<EspecificacionDto> especificaciones) {
        this.especificaciones = especificaciones;
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

    public Integer getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(Integer idCategoria) {
        this.idCategoria = idCategoria;
    }
}
