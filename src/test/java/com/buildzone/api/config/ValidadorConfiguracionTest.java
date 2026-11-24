package com.buildzone.api.config;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** Pruebas de la revision de claves del perfil prod. */
class ValidadorConfiguracionTest {

    private static final String JWT_BUENA = "c2VjcmV0by1kZS1wcnVlYmEtY29uLW11Y2hvcy1ieXRlcy0xMjM0NTY3ODkwMTI=";
    private static final String URL = "jdbc:mysql://mysql.railway.internal:3306/railway?sslMode=PREFERRED";

    @Test
    @DisplayName("Con claves propias y fuertes no hay problemas")
    void configuracionCorrecta() {
        assertThat(ValidadorConfiguracion.revisarProduccion(JWT_BUENA, "ClaveAdmin2026", URL, "pw-base", ""))
                .isEmpty();
    }

    @Test
    @DisplayName("Sin claves: reporta JWT, admin, base de datos y contrasena de la base")
    void sinNada() {
        List<String> problemas = ValidadorConfiguracion.revisarProduccion("", "",
                "jdbc:mysql://:3306/?sslMode=PREFERRED", "", "");
        assertThat(problemas).hasSize(4);
        assertThat(String.join(" ", problemas)).contains("JWT_SECRET", "ADMIN_PASSWORD", "MYSQLHOST", "DB_PASSWORD");
    }

    @Test
    @DisplayName("Rechaza las claves de ejemplo del repositorio")
    void clavesDeEjemplo() {
        List<String> problemas = ValidadorConfiguracion.revisarProduccion(
                ValidadorConfiguracion.JWT_EJEMPLO, ValidadorConfiguracion.ADMIN_EJEMPLO, URL, "pw", "");
        assertThat(problemas).hasSize(2);
        assertThat(String.join(" ", problemas)).contains("EJEMPLO");
    }

    @Test
    @DisplayName("Rechaza JWT corta o que no es Base64, contrasena de admin debil y CORS abierto")
    void valoresDebiles() {
        assertThat(ValidadorConfiguracion.revisarProduccion("c2hvcnQ=", "ClaveAdmin2026", URL, "pw", ""))
                .singleElement().asString().contains("32 bytes");
        assertThat(ValidadorConfiguracion.revisarProduccion("esto no es base64!!", "ClaveAdmin2026", URL, "pw", ""))
                .singleElement().asString().contains("Base64");
        assertThat(ValidadorConfiguracion.revisarProduccion(JWT_BUENA, "solominusculas123", URL, "pw", ""))
                .singleElement().asString().contains("mayusculas");
        assertThat(ValidadorConfiguracion.revisarProduccion(JWT_BUENA, "ClaveAdmin2026", URL, "pw", "*"))
                .singleElement().asString().contains("CORS");
    }
}
