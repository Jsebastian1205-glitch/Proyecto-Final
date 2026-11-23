package com.buildzone.api.integracion;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
 * Pruebas de integracion (controlador + seguridad + servicio + JPA sobre H2)
 * de lo agregado despues de unificar el proyecto: el blog con sus reglas por
 * plan y el catalogo con precio, puntajes y ficha tecnica.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class BlogYCatalogoIntegracionTest {

    private static final AtomicInteger SECUENCIA = new AtomicInteger();

    @Autowired
    private MockMvc mvc;

    // ── Utilidades ──

    private String tokenDeUsuarioNuevo() throws Exception {
        String username = "blog" + SECUENCIA.incrementAndGet();
        String respuesta = mvc.perform(post("/api/auth/registro").contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"nombre":"Lector","apellido":"Blog","username":"%s",
                                 "email":"%s@test.com","password":"Secreta123"}
                                """.formatted(username, username)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(respuesta, "$.token");
    }

    private String tokenAdmin() throws Exception {
        String respuesta = mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"admin@buildzone.com\",\"password\":\"Admin1234\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(respuesta, "$.token");
    }

    private static String bearer(String token) {
        return "Bearer " + token;
    }

    /** Id de un plan por su nombre (Gratuito, Premium o Premium Anual). */
    private long idPlan(String nombre) throws Exception {
        String planes = mvc.perform(get("/api/planes")).andReturn().getResponse().getContentAsString();
        List<Number> ids = JsonPath.read(planes, "$[?(@.nombre == '" + nombre + "')].id");
        return ids.get(0).longValue();
    }

    private void suscribir(String token, String plan) throws Exception {
        mvc.perform(post("/api/suscripciones").header(HttpHeaders.AUTHORIZATION, bearer(token))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"planId\":" + idPlan(plan) + "}"))
                .andExpect(status().isCreated());
    }

    private static final String NOTICIA = """
            {"titulo":"Como limpiar el polvo de tu PC","categoria":"Tutorial",
             "contenido":"Apaga el equipo y usa aire comprimido en los ventiladores."}
            """;

    private long crearIdDe(String url, String token, String json) throws Exception {
        String respuesta = mvc.perform(post(url).header(HttpHeaders.AUTHORIZATION, bearer(token))
                        .contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        Number id = JsonPath.read(respuesta, url.endsWith("productos") ? "$.idProducto"
                : url.endsWith("marcas") ? "$.idMarca" : url.endsWith("categorias") ? "$.idCategoria" : "$.idNoticia");
        return id.longValue();
    }

    // ── Blog ──

    @Test
    @DisplayName("El blog se lee sin iniciar sesion")
    void blogPublico() throws Exception {
        mvc.perform(get("/api/noticias")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("Publicar sin sesion devuelve 401")
    void publicarSinSesion() throws Exception {
        mvc.perform(post("/api/noticias").contentType(MediaType.APPLICATION_JSON).content(NOTICIA))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Sin plan o con el plan Gratuito, publicar devuelve 403")
    void publicarSinPlanDePago() throws Exception {
        String token = tokenDeUsuarioNuevo();
        mvc.perform(post("/api/noticias").header(HttpHeaders.AUTHORIZATION, bearer(token))
                        .contentType(MediaType.APPLICATION_JSON).content(NOTICIA))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.mensaje", containsString("plan de pago")));

        suscribir(token, "Gratuito");
        mvc.perform(post("/api/noticias").header(HttpHeaders.AUTHORIZATION, bearer(token))
                        .contentType(MediaType.APPLICATION_JSON).content(NOTICIA))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Con Premium se publica; otro usuario no la puede editar; el autor la elimina")
    void flujoBlogPremium() throws Exception {
        String autor = tokenDeUsuarioNuevo();
        String otro = tokenDeUsuarioNuevo();
        suscribir(autor, "Premium");

        long id = crearIdDe("/api/noticias", autor, NOTICIA);

        mvc.perform(get("/api/noticias/mias").header(HttpHeaders.AUTHORIZATION, bearer(autor)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].idNoticia", hasItem((int) id)));
        mvc.perform(put("/api/noticias/" + id).header(HttpHeaders.AUTHORIZATION, bearer(otro))
                        .contentType(MediaType.APPLICATION_JSON).content(NOTICIA))
                .andExpect(status().isForbidden());
        mvc.perform(delete("/api/noticias/" + id).header(HttpHeaders.AUTHORIZATION, bearer(autor)))
                .andExpect(status().isNoContent());
        mvc.perform(get("/api/noticias/" + id)).andExpect(status().isNotFound());
    }

    // ── Catalogo con precio, puntajes y ficha ──

    @Test
    @DisplayName("El ADMIN crea un producto con precio, puntajes y ficha, y luego lo elimina")
    void productoCompleto() throws Exception {
        String admin = tokenAdmin();
        int n = SECUENCIA.incrementAndGet();
        long idMarca = crearIdDe("/api/marcas", admin, "{\"nombre\":\"MarcaPrueba" + n + "\"}");
        long idCategoria = crearIdDe("/api/categorias", admin, "{\"nombre\":\"CategoriaPrueba" + n + "\"}");
        String producto = """
                {"nombre":"Procesador de prueba %d","descripcion":"Integracion",
                 "idMarca":%d,"idCategoria":%d,"precioReferencia":899000,
                 "puntajes":{"potencia":80,"eficiencia":85,"valor":88,"popularidad":70},
                 "especificaciones":[{"atributo":"Nucleos","valor":"6"},{"atributo":"Socket","valor":"AM5"}]}
                """.formatted(n, idMarca, idCategoria);

        long id = crearIdDe("/api/productos", admin, producto);

        mvc.perform(get("/api/productos/" + id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.precio").value(899000))
                .andExpect(jsonPath("$.precios[0].referencia").value(true))
                .andExpect(jsonPath("$.puntajes.potencia").value(80))
                .andExpect(jsonPath("$.especificaciones.length()").value(2))
                .andExpect(jsonPath("$.especificaciones[1].valor").value("AM5"));

        mvc.perform(delete("/api/productos/" + id).header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andExpect(status().isNoContent());
        mvc.perform(get("/api/productos/" + id)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Un puntaje fuera de 0 a 100 devuelve 400")
    void puntajeInvalido() throws Exception {
        String admin = tokenAdmin();
        int n = SECUENCIA.incrementAndGet();
        long idMarca = crearIdDe("/api/marcas", admin, "{\"nombre\":\"MarcaMala" + n + "\"}");
        long idCategoria = crearIdDe("/api/categorias", admin, "{\"nombre\":\"CategoriaMala" + n + "\"}");

        mvc.perform(post("/api/productos").header(HttpHeaders.AUTHORIZATION, bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON).content("""
                                {"nombre":"Malo","idMarca":%d,"idCategoria":%d,"puntajes":{"potencia":150}}
                                """.formatted(idMarca, idCategoria)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensaje", containsString("entre 0 y 100")));
    }
}
