package com.buildzone.api.integracion;

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
 * Pruebas de integracion de "Olvide mi contrasena": solicitud publica,
 * contrasena temporal generada por el ADMIN y cambio obligatorio al entrar.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class RecuperacionIntegracionTest {

    private static final AtomicInteger SECUENCIA = new AtomicInteger();

    @Autowired
    private MockMvc mvc;

    private static String bearer(String token) {
        return "Bearer " + token;
    }

    private String login(String identificador, String password) throws Exception {
        String r = mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"%s\",\"password\":\"%s\"}".formatted(identificador, password)))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        return JsonPath.read(r, "$.token");
    }

    /** Registra una cuenta y devuelve su username (el correo es username@test.com). */
    private String registrar() throws Exception {
        String u = "recu" + SECUENCIA.incrementAndGet();
        mvc.perform(post("/api/auth/registro").contentType(MediaType.APPLICATION_JSON).content("""
                        {"nombre":"Lector","apellido":"Olvidadizo","username":"%s","email":"%s@test.com","password":"Secreta123"}
                        """.formatted(u, u)))
                .andExpect(status().isCreated());
        return u;
    }

    private long idDe(String admin, String username) throws Exception {
        String lista = mvc.perform(get("/api/usuarios").header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andReturn().getResponse().getContentAsString();
        List<Number> ids = JsonPath.read(lista, "$[?(@.username == '" + username + "')].id");
        return ids.get(0).longValue();
    }

    @Test
    @DisplayName("La solicitud responde igual exista o no el correo, y solo la real llega a Mensajes")
    void solicitudNoRevelaCuentas() throws Exception {
        String u = registrar();
        String respuestaReal = mvc.perform(post("/api/auth/recuperar").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + u + "@test.com\"}"))
                .andExpect(status().isAccepted()).andReturn().getResponse().getContentAsString();
        String respuestaFalsa = mvc.perform(post("/api/auth/recuperar").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"nadie" + u + "@test.com\"}"))
                .andExpect(status().isAccepted()).andReturn().getResponse().getContentAsString();
        org.assertj.core.api.Assertions.assertThat(respuestaFalsa).isEqualTo(respuestaReal);

        String admin = login("admin@buildzone.com", "Admin1234");
        String mensajes = mvc.perform(get("/api/contacto").header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andReturn().getResponse().getContentAsString();
        List<Object> reales = JsonPath.read(mensajes, "$[?(@.correo == '" + u + "@test.com' && @.recuperacion == true)]");
        List<Object> falsas = JsonPath.read(mensajes, "$[?(@.correo == 'nadie" + u + "@test.com')]");
        org.assertj.core.api.Assertions.assertThat(reales).hasSize(1);
        org.assertj.core.api.Assertions.assertThat(falsas).isEmpty();
    }

    @Test
    @DisplayName("Flujo completo: temporal del admin, acceso limitado, contrasena nueva y la temporal deja de servir")
    void flujoCompleto() throws Exception {
        String u = registrar();
        String admin = login("admin@buildzone.com", "Admin1234");
        long id = idDe(admin, u);

        // Solo el ADMIN puede generar la temporal
        String otro = login(registrar(), "Secreta123");
        mvc.perform(post("/api/usuarios/" + id + "/restablecer-password").header(HttpHeaders.AUTHORIZATION, bearer(otro)))
                .andExpect(status().isForbidden());

        String r = mvc.perform(post("/api/usuarios/" + id + "/restablecer-password")
                        .header(HttpHeaders.AUTHORIZATION, bearer(admin)))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        String temporal = JsonPath.read(r, "$.passwordTemporal");

        // La contrasena anterior ya no funciona
        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"" + u + "\",\"password\":\"Secreta123\"}"))
                .andExpect(status().isUnauthorized());

        // Entra con la temporal: el login avisa que debe cambiarla
        String tokenTemporal = JsonPath.read(mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"" + u + "\",\"password\":\"" + temporal + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.usuario.debeCambiarPassword").value(true))
                .andReturn().getResponse().getContentAsString(), "$.token");

        // Mientras no la cambie: ve su perfil, pero lo demas da 403
        mvc.perform(get("/api/usuarios/me").header(HttpHeaders.AUTHORIZATION, bearer(tokenTemporal)))
                .andExpect(status().isOk());
        mvc.perform(get("/api/suscripciones/me").header(HttpHeaders.AUTHORIZATION, bearer(tokenTemporal)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.codigo").value("CAMBIO_PASSWORD_PENDIENTE"));

        // No puede dejar la misma temporal
        mvc.perform(put("/api/usuarios/me/password").header(HttpHeaders.AUTHORIZATION, bearer(tokenTemporal))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"passwordNueva\":\"" + temporal + "\"}"))
                .andExpect(status().isBadRequest());

        // Crea la nueva sin escribir la actual
        mvc.perform(put("/api/usuarios/me/password").header(HttpHeaders.AUTHORIZATION, bearer(tokenTemporal))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"passwordNueva\":\"MiClave2026\"}"))
                .andExpect(status().isNoContent());

        // Ya tiene acceso normal, entra con la nueva y la temporal dejo de servir
        mvc.perform(get("/api/suscripciones/me").header(HttpHeaders.AUTHORIZATION, bearer(tokenTemporal)))
                .andExpect(status().isOk());
        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"" + u + "\",\"password\":\"MiClave2026\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.usuario.debeCambiarPassword").value(false));
        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"identificador\":\"" + u + "\",\"password\":\"" + temporal + "\"}"))
                .andExpect(status().isUnauthorized());
    }
}
