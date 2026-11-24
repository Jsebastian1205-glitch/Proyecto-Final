package com.buildzone.api.security;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.buildzone.api.exception.DemasiadosIntentosException;

/**
 * Limites de intentos en memoria, contra ataques de fuerza bruta y spam.
 * <ul>
 *   <li>Inicio de sesion: 5 intentos fallidos por cuenta cada 15 minutos
 *       (y un limite mas alto por direccion IP).</li>
 *   <li>Registro: cuentas nuevas por IP cada hora.</li>
 *   <li>Formularios publicos (contacto y "olvide mi contrasena"): envios por IP
 *       cada 10 minutos.</li>
 * </ul>
 * Los valores se cambian en application.properties (buildzone.limites.*).
 * Al reiniciar el servidor los contadores vuelven a cero; para un proyecto con
 * una sola instancia es suficiente.
 */
@Component
public class LimiteDeIntentos {

    private static final Duration VENTANA_LOGIN = Duration.ofMinutes(15);
    private static final Duration VENTANA_REGISTRO = Duration.ofHours(1);
    private static final Duration VENTANA_FORMULARIOS = Duration.ofMinutes(10);
    private static final int MAXIMO_CLAVES = 10_000;

    private final Map<String, Deque<Instant>> registros = new ConcurrentHashMap<>();
    private final Clock clock;
    private final int loginPorCuenta;
    private final int loginPorIp;
    private final int registroPorIp;
    private final int formulariosPorIp;

    public LimiteDeIntentos(Clock clock,
                            @Value("${buildzone.limites.login-por-cuenta:5}") int loginPorCuenta,
                            @Value("${buildzone.limites.login-por-ip:50}") int loginPorIp,
                            @Value("${buildzone.limites.registro-por-ip:30}") int registroPorIp,
                            @Value("${buildzone.limites.formularios-por-ip:30}") int formulariosPorIp) {
        this.clock = clock;
        this.loginPorCuenta = loginPorCuenta;
        this.loginPorIp = loginPorIp;
        this.registroPorIp = registroPorIp;
        this.formulariosPorIp = formulariosPorIp;
    }

    // ── Inicio de sesion ──

    /** Lanza 429 si la cuenta o la IP ya agotaron sus intentos fallidos. */
    public void verificarLogin(String identificador, String ip) {
        if (alcanzado(claveCuenta(identificador), loginPorCuenta, VENTANA_LOGIN)
                || alcanzado("login-ip:" + ip, loginPorIp, VENTANA_LOGIN)) {
            throw new DemasiadosIntentosException(
                    "Demasiados intentos fallidos. Espera 15 minutos e intenta de nuevo.");
        }
    }

    public void registrarLoginFallido(String identificador, String ip) {
        anotar(claveCuenta(identificador), VENTANA_LOGIN);
        anotar("login-ip:" + ip, VENTANA_LOGIN);
    }

    /** Al entrar bien se olvidan los fallos de esa cuenta. */
    public void registrarLoginExitoso(String identificador) {
        registros.remove(claveCuenta(identificador));
    }

    // ── Registro y formularios publicos ──

    public void verificarRegistro(String ip) {
        if (alcanzado("registro-ip:" + ip, registroPorIp, VENTANA_REGISTRO)) {
            throw new DemasiadosIntentosException(
                    "Se crearon demasiadas cuentas desde tu conexion. Intenta de nuevo en una hora.");
        }
    }

    public void registrarRegistro(String ip) {
        anotar("registro-ip:" + ip, VENTANA_REGISTRO);
    }

    /** Contacto y "olvide mi contrasena": verifica y cuenta el envio. */
    public void consumirFormulario(String ip) {
        String clave = "formulario-ip:" + ip;
        if (alcanzado(clave, formulariosPorIp, VENTANA_FORMULARIOS)) {
            throw new DemasiadosIntentosException(
                    "Enviaste demasiados formularios seguidos. Espera unos minutos e intenta de nuevo.");
        }
        anotar(clave, VENTANA_FORMULARIOS);
    }

    // ── Apoyo ──

    private static String claveCuenta(String identificador) {
        return "login-cuenta:" + (identificador == null ? "" : identificador.trim().toLowerCase());
    }

    private boolean alcanzado(String clave, int maximo, Duration ventana) {
        Deque<Instant> marcas = registros.get(clave);
        if (marcas == null) {
            return false;
        }
        synchronized (marcas) {
            descartarViejas(marcas, ventana);
            return marcas.size() >= maximo;
        }
    }

    private void anotar(String clave, Duration ventana) {
        if (registros.size() >= MAXIMO_CLAVES) {
            limpiarVencidas();
        }
        Deque<Instant> marcas = registros.computeIfAbsent(clave, k -> new ArrayDeque<>());
        synchronized (marcas) {
            descartarViejas(marcas, ventana);
            marcas.addLast(clock.instant());
        }
    }

    private void descartarViejas(Deque<Instant> marcas, Duration ventana) {
        Instant limite = clock.instant().minus(ventana);
        while (!marcas.isEmpty() && marcas.peekFirst().isBefore(limite)) {
            marcas.pollFirst();
        }
    }

    /** Evita que la memoria crezca sin limite: quita contadores sin actividad reciente. */
    private void limpiarVencidas() {
        Instant limite = clock.instant().minus(VENTANA_REGISTRO);
        registros.entrySet().removeIf(e -> {
            synchronized (e.getValue()) {
                return e.getValue().isEmpty() || e.getValue().peekLast().isBefore(limite);
            }
        });
    }
}
