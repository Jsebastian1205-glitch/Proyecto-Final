package com.buildzone.api.integracion;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import com.jayway.jsonpath.JsonPath;

/**
 * Pruebas de integracion de "Mis comparaciones": exclusivo de los planes de
 * pago, sin duplicados y se borran si el admin elimina uno de sus productos.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ComparacionIntegracionTest {

    private static final AtomicInteger SECUENCIA = new AtomicInteger();

    @Autowired
    private MockMvc mvc;

    // ── Utilidades ──

    private static String bearer(String token) {
        return "Bearer " + token;
    }

    private String tokenUsuarioNuevo() throws Exception {
        String u = "comp" + SECUENCIA.incrementAndGet();
        String r = mvc.perform(post("/api/auth/registro").contentType(MediaType.APPLICATION_JSON).content("""
                        {"nombre":"Lector","apellido":"Duelo","username":"%s","email":"%s@test.com","password":"Secreta123"}
                        """.formatted(u, u)))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        return JsonPath.read(r, "$.token");
    }

    private String tokenAdmin() throws Exception {
        String r = mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"admin@buildzone.com\",\"password\":\"Admin1234\"}"))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        return JsonPath.read(r, "$.token");
    }

    private void suscribir(String token, String plan) throws Exception {
        String planes = mvc.perform(get("/api/planes")).andReturn().getResponse().getContentAsString();
        List<Number> ids = JsonPath.read(planes, "$[?(@.nombre == '" + plan + "')].id");
        mvc.perform(post("/api/suscripciones").header(HttpHeaders.AUTHORIZATION, bearer(token))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"planId\":" + ids.get(0) + "}"))
                .andExpect(status().isCreated());
    }

    private long crear(String url, String token, String json, String campoId) throws Exception {
        String r = mvc.perform(post(url).header(HttpHeaders.AUTHORIZATION, bearer(token))
                        .contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(r, "$." + campoId)).longValue();
    }

    /** Crea una categoria con dos productos; devuelve {idA, idB, idCategoria}. */
    private long[] dosProductos(String admin) throws Exception {
        int n = SECUENCIA.incrementAndGet();
        long marca = crear("/api/marcas", admin, "{\"nombre\":\"MarcaDuelo" + n + "\"}", "idMarca");
        long categoria = crear("/api/categorias", admin, "{\"nombre\":\"CategoriaDuelo" + n + "\"}", "idCategoria");
        String plantilla = "{\"nombre\":\"%s\",\"idMarca\":%d,\"idCategoria\":%d}";
        long a = crear("/api/productos", admin, plantilla.formatted("Producto A " + n, marca, categoria), "idProducto");
        long b = crear("/api/productos", admin, plantilla.formatted("Producto B " + n, marca, categoria), "idProducto");
        return new long[] {a, b, categoria};
    }

    private static String duelo(long a, long b) {
        return "{\"idProductoA\":" + a + ",\"idProductoB\":" + b + "}";
    }

    // ── Pruebas ──

    @Test
    @DisplayName("Sin sesion 401; con plan Gratuito 403")
    void soloPlanesDePago() throws Exception {
        mvc.perform(get("/api/comparaciones/mias")).andExpect(status().isUnauthorized());

        String gratis = tokenUsuarioNuevo();
        suscribir(gratis, "Gratuito");
        mvc.perform(get("/api/comparaciones/mias").header(HttpHeaders.AUTHORIZATION, bearer(gratis)))
                .andExpect(status().isForbidden());
        mvc.perform(post("/api/comparaciones").header(HttpHeaders.AUTHORIZATION, bearer(gratis))
                        .contentType(MediaType.APPLICATION_JSON).content(duelo(1, 2)))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Premium guarda, no duplica el duelo invertido y luego lo elimina")
    void premiumGuardaYElimina() throws Exception {
        long[] p = dosProductos(tokenAdmin());
        String premium = tokenUsuarioNuevo();
        suscribir(premium, "Premium");

        long id = crear("/api/comparaciones", premium, duelo(p[0], p[1]), "idComparacion");
        long otraVez = crear("/api/comparaciones", premium, duelo(p[1], p[0]), "idComparacion");
        org.assertj.core.api.Assertions.assertThat(otraVez).isEqualTo(id);

        mvc.perform(get("/api/comparaciones/mias").header(HttpHeaders.AUTHORIZATION, bearer(premium)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].productos", hasSize(2)));

        // Otro usuario Premium no puede borrarla
        String otro = tokenUsuarioNuevo();
        suscribir(otro, "Premium");
        mvc.perform(delete("/api/comparaciones/" + id).header(HttpHeaders.AUTHORIZATION, bearer(otro)))
                .andExpect(status().isForbidden());

        mvc.perform(delete("/api/comparaciones/" + id).header(HttpHeaders.AUTHORIZATION, bearer(premium)))
                .andExpect(status().isNoContent());
        mvc.perform(get("/api/comparaciones/mias").header(HttpHeaders.AUTHORIZATION, bearer(premium)))
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    @DisplayName("Si el admin elimina un producto, se borran las comparaciones que lo incluian")
    void eliminarProductoBorraComparaciones() throws Exception {
        String admin = tokenAdmin();
        long[] p = dosProductos(admin);
        String premium = tokenUsuarioNuevo();
        suscribir(premium, "Premium");
        crear("/api/comparaciones", premium, duelo(p[0], p[1]), "idComparacion");

        mvc.perform(delete("/api/productos/" + p[0]).header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andExpect(status().isNoContent());
        mvc.perform(get("/api/comparaciones/mias").header(HttpHeaders.AUTHORIZATION, bearer(premium)))
                .andExpect(jsonPath("$", hasSize(0)));
    }
}
