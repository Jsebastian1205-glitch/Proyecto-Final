package com.buildzone.api.integracion;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.concurrent.atomic.AtomicInteger;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

/** Pruebas de integracion de seguridad para publicar el proyecto. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SeguridadIntegracionTest {

    private static final AtomicInteger SECUENCIA = new AtomicInteger();

    @Autowired
    private MockMvc mvc;

    private static String login(String identificador, String password) {
        return "{\"identificador\":\"%s\",\"password\":\"%s\"}".formatted(identificador, password);
    }

    @Test
    @DisplayName("Tras 5 intentos fallidos la cuenta se bloquea (429), aunque luego la contrasena sea correcta")
    void fuerzaBrutaBloqueada() throws Exception {
        String u = "seg" + SECUENCIA.incrementAndGet();
        mvc.perform(post("/api/auth/registro").contentType(MediaType.APPLICATION_JSON).content("""
                        {"nombre":"Prueba","apellido":"Seguridad","username":"%s","email":"%s@test.com","password":"Secreta123"}
                        """.formatted(u, u)))
                .andExpect(status().isCreated());

        for (int i = 0; i < 5; i++) {
            mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON).content(login(u, "Mala" + i)))
                    .andExpect(status().isUnauthorized());
        }
        mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON).content(login(u, "Secreta123")))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.mensaje", containsString("15 minutos")));
    }

    @Test
    @DisplayName("La pagina se sirve con cabeceras de seguridad")
    void cabeceras() throws Exception {
        mvc.perform(get("/api/planes"))
                .andExpect(status().isOk())
                .andExpect(header().string("X-Content-Type-Options", "nosniff"))
                .andExpect(header().string("X-Frame-Options", "SAMEORIGIN"))
                .andExpect(header().string("Referrer-Policy", "strict-origin-when-cross-origin"))
                .andExpect(header().string("Content-Security-Policy", containsString("object-src 'none'")))
                .andExpect(header().string("Permissions-Policy", containsString("camera=()")));
    }

    @Test
    @DisplayName("Por HTTPS se exige HTTPS durante un ano (HSTS)")
    void hstsEnHttps() throws Exception {
        mvc.perform(get("/api/planes").secure(true))
                .andExpect(header().string("Strict-Transport-Security", containsString("max-age=31536000")));
    }

    @Test
    @DisplayName("Los errores no exponen detalles internos")
    void erroresSinDetalles() throws Exception {
        mvc.perform(get("/api/no-existe"))
                .andExpect(status().is4xxClientError())
                .andExpect(jsonPath("$.trace").doesNotExist());
    }
}
