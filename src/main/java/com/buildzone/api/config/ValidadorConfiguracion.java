package com.buildzone.api.config;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;

import org.apache.commons.logging.Log;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.boot.logging.DeferredLogFactory;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;

/**
 * Revisa las claves secretas ANTES de que arranque la aplicacion.
 * <ul>
 *   <li>Perfil <b>prod</b> (hosting): si falta una clave, es la de ejemplo o es
 *       debil, la aplicacion NO arranca y explica que corregir.</li>
 *   <li>Cualquier otro perfil (tu PC): solo muestra un aviso en la consola si se
 *       usan las claves de ejemplo, para que el proyecto funcione sin configurar nada.</li>
 * </ul>
 * Se registra en META-INF/spring.factories para ejecutarse antes de crear
 * cualquier componente (asi nunca se firma un token con una clave insegura).
 */
public class ValidadorConfiguracion implements EnvironmentPostProcessor, Ordered {

    /** Valores de ejemplo de application.properties (publicos en el repositorio). */
    static final String JWT_EJEMPLO = "V+ClppfJJpplwJCoBw1+E+TWBZw4ONFPwklx1J/omza5hFoT6/D9yO/EiKdHLRvV";
    static final String ADMIN_EJEMPLO = "Admin1234";

    static final int LARGO_MINIMO_JWT_BYTES = 32;
    static final int LARGO_MINIMO_ADMIN = 12;

    private final Log log;

    public ValidadorConfiguracion(DeferredLogFactory logFactory) {
        this.log = logFactory.getLog(ValidadorConfiguracion.class);
    }

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment env, SpringApplication application) {
        boolean produccion = Arrays.asList(env.getActiveProfiles()).contains("prod");
        String jwt = env.getProperty("buildzone.jwt.secret", "");
        String admin = env.getProperty("buildzone.admin.password", "");

        if (produccion) {
            List<String> problemas = revisarProduccion(jwt, admin,
                    env.getProperty("spring.datasource.url", ""),
                    env.getProperty("spring.datasource.password", ""),
                    env.getProperty("buildzone.cors.origenes-permitidos", ""));
            if (!problemas.isEmpty()) {
                throw new IllegalStateException("\n\nBuildZone NO arranca en modo produccion (perfil prod). Corrige:\n  - "
                        + String.join("\n  - ", problemas)
                        + "\nVer docs/DESPLIEGUE.md, seccion \"Variables de entorno\".\n");
            }
            log.info("Configuracion de produccion revisada: claves propias definidas.");
        } else if (JWT_EJEMPLO.equals(jwt) || ADMIN_EJEMPLO.equals(admin)) {
            log.warn("Se estan usando las claves de EJEMPLO (JWT_SECRET / ADMIN_PASSWORD). Sirven para "
                    + "desarrollo local; para publicar el proyecto usa el perfil prod con claves propias.");
        }
    }

    /** Lista de problemas de configuracion para produccion (vacia si todo esta bien). */
    static List<String> revisarProduccion(String jwt, String adminPassword, String urlBase,
                                          String passwordBase, String cors) {
        List<String> problemas = new ArrayList<>();

        if (jwt == null || jwt.isBlank()) {
            problemas.add("Falta JWT_SECRET (clave para firmar las sesiones). Genera una con: openssl rand -base64 48");
        } else if (JWT_EJEMPLO.equals(jwt)) {
            problemas.add("JWT_SECRET es la clave de EJEMPLO que esta publicada en el repositorio. Genera una nueva.");
        } else if (bytesBase64(jwt) < LARGO_MINIMO_JWT_BYTES) {
            problemas.add("JWT_SECRET debe ser texto Base64 de al menos " + LARGO_MINIMO_JWT_BYTES
                    + " bytes. Genera una con: openssl rand -base64 48");
        }

        if (adminPassword == null || adminPassword.isBlank()) {
            problemas.add("Falta ADMIN_PASSWORD (contrasena del administrador inicial).");
        } else if (ADMIN_EJEMPLO.equals(adminPassword)) {
            problemas.add("ADMIN_PASSWORD es la contrasena de EJEMPLO (Admin1234). Usa una propia.");
        } else if (!esFuerte(adminPassword)) {
            problemas.add("ADMIN_PASSWORD debe tener al menos " + LARGO_MINIMO_ADMIN
                    + " caracteres, con mayusculas, minusculas y numeros.");
        }

        if (urlBase == null || urlBase.isBlank() || urlBase.contains("//:") || urlBase.contains("/?")) {
            problemas.add("Falta la base de datos: define DB_URL o las variables MYSQLHOST, MYSQLPORT y MYSQLDATABASE.");
        }
        if (passwordBase == null || passwordBase.isBlank()) {
            problemas.add("Falta la contrasena de la base de datos (DB_PASSWORD o MYSQLPASSWORD).");
        }

        if (cors != null && cors.contains("*")) {
            problemas.add("CORS_ORIGENES no puede ser \"*\" en produccion. Dejalo vacio o pon tu dominio exacto.");
        }
        return problemas;
    }

    static boolean esFuerte(String password) {
        return password.length() >= LARGO_MINIMO_ADMIN
                && password.chars().anyMatch(Character::isUpperCase)
                && password.chars().anyMatch(Character::isLowerCase)
                && password.chars().anyMatch(Character::isDigit);
    }

    private static int bytesBase64(String texto) {
        try {
            return Base64.getDecoder().decode(texto.trim()).length;
        } catch (IllegalArgumentException e) {
            return 0;
        }
    }

    /** Despues de cargar application*.properties y las variables de entorno. */
    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }
}
