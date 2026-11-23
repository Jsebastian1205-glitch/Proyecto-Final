package com.buildzone.api.integracion;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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
 * Pruebas de integracion del formulario de contacto: enviar es publico y
 * gestionar los mensajes es solo para ADMIN.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ContactoIntegracionTest {

    private static final AtomicInteger SECUENCIA = new AtomicInteger();

    @Autowired
    private MockMvc mvc;

    private static String cuerpo(String correo, String mensaje) {
        return """
                {"nombre":"Pedro Ruiz","correo":"%s","motivo":"DUDA_PRODUCTO","mensaje":"%s"}
                """.formatted(correo, mensaje);
    }

    private static String correoNuevo() {
        return "contacto" + SECUENCIA.incrementAndGet() + "@test.com";
    }

    private String token(String json, String url) throws Exception {
        String respuesta = mvc.perform(post(url).contentType(MediaType.APPLICATION_JSON).content(json))
                .andReturn().getResponse().getContentAsString();
        return "Bearer " + JsonPath.read(respuesta, "$.token");
    }

    private String tokenAdmin() throws Exception {
        return token("{\"identificador\":\"admin@buildzone.com\",\"password\":\"Admin1234\"}", "/api/auth/login");
    }

    private String tokenUsuario() throws Exception {
        String u = "cont" + SECUENCIA.incrementAndGet();
        return token("""
                {"nombre":"Lector","apellido":"Contacto","username":"%s","email":"%s@test.com","password":"Secreta123"}
                """.formatted(u, u), "/api/auth/registro");
    }

    private long enviar(String correo) throws Exception {
        String r = mvc.perform(post("/api/contacto").contentType(MediaType.APPLICATION_JSON)
                        .content(cuerpo(correo, "Tienen la RTX 5070 disponible?")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.estado").value("NUEVO"))
                .andExpect(jsonPath("$.motivoTexto").value("Duda sobre un producto"))
                .andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(r, "$.idMensaje")).longValue();
    }

    @Test
    @DisplayName("Un visitante sin sesion puede enviar un mensaje")
    void visitanteEnvia() throws Exception {
        enviar(correoNuevo());
    }

    @Test
    @DisplayName("Datos invalidos (correo y mensaje corto) devuelven 400")
    void validaciones() throws Exception {
        mvc.perform(post("/api/contacto").contentType(MediaType.APPLICATION_JSON)
                        .content(cuerpo("no-es-correo", "corto")))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("El cuarto mensaje del mismo correo en 10 minutos se rechaza con 400")
    void antispam() throws Exception {
        String correo = correoNuevo();
        enviar(correo);
        enviar(correo);
        enviar(correo);
        mvc.perform(post("/api/contacto").contentType(MediaType.APPLICATION_JSON)
                        .content(cuerpo(correo, "Cuarto mensaje seguido aqui")))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Ver los mensajes exige sesion de ADMIN")
    void listarSoloAdmin() throws Exception {
        mvc.perform(get("/api/contacto")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/contacto").header(HttpHeaders.AUTHORIZATION, tokenUsuario()))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/contacto").header(HttpHeaders.AUTHORIZATION, tokenAdmin()))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("El ADMIN marca un mensaje como respondido y luego lo elimina")
    void adminGestiona() throws Exception {
        long id = enviar(correoNuevo());
        String admin = tokenAdmin();

        mvc.perform(patch("/api/contacto/" + id + "/estado").header(HttpHeaders.AUTHORIZATION, admin)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"estado\":\"RESPONDIDO\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.estado").value("RESPONDIDO"));

        mvc.perform(delete("/api/contacto/" + id).header(HttpHeaders.AUTHORIZATION, tokenUsuario()))
                .andExpect(status().isForbidden());
        mvc.perform(delete("/api/contacto/" + id).header(HttpHeaders.AUTHORIZATION, admin))
                .andExpect(status().isNoContent());
        mvc.perform(delete("/api/contacto/" + id).header(HttpHeaders.AUTHORIZATION, admin))
                .andExpect(status().isNotFound());
    }
}
