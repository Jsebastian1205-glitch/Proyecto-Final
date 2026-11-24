package com.buildzone.api.security;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZoneOffset;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.buildzone.api.exception.DemasiadosIntentosException;

/** Pruebas de los limites contra fuerza bruta y spam. */
class LimiteDeIntentosTest {

    /** Reloj que se puede adelantar a mano. */
    static final class RelojMovible extends Clock {
        private Instant ahora = Instant.parse("2026-11-23T20:00:00Z");

        void adelantar(Duration d) {
            ahora = ahora.plus(d);
        }

        @Override
        public ZoneId getZone() {
            return ZoneOffset.UTC;
        }

        @Override
        public Clock withZone(ZoneId zone) {
            return this;
        }

        @Override
        public Instant instant() {
            return ahora;
        }
    }

    private RelojMovible reloj;
    private LimiteDeIntentos limite;

    @BeforeEach
    void setUp() {
        reloj = new RelojMovible();
        limite = new LimiteDeIntentos(reloj, 5, 8, 3, 2);
    }

    @Test
    @DisplayName("Login: 5 fallos sobre la misma cuenta la bloquean 15 minutos")
    void bloqueoPorCuenta() {
        for (int i = 0; i < 5; i++) {
            limite.verificarLogin("Ana@Mail.com", "1.1.1." + i);
            limite.registrarLoginFallido("ana@mail.com", "1.1.1." + i);
        }
        assertThatThrownBy(() -> limite.verificarLogin(" ana@mail.com ", "9.9.9.9"))
                .isInstanceOf(DemasiadosIntentosException.class);

        reloj.adelantar(Duration.ofMinutes(16));
        assertThatCode(() -> limite.verificarLogin("ana@mail.com", "9.9.9.9")).doesNotThrowAnyException();
    }

    @Test
    @DisplayName("Login: entrar bien borra los fallos de esa cuenta")
    void exitoLimpia() {
        for (int i = 0; i < 4; i++) {
            limite.registrarLoginFallido("ana", "1.1.1.1");
        }
        limite.registrarLoginExitoso("ana");
        limite.registrarLoginFallido("ana", "1.1.1.1");
        assertThatCode(() -> limite.verificarLogin("ana", "2.2.2.2")).doesNotThrowAnyException();
    }

    @Test
    @DisplayName("Login: una misma IP probando muchas cuentas tambien se bloquea")
    void bloqueoPorIp() {
        for (int i = 0; i < 8; i++) {
            limite.registrarLoginFallido("cuenta" + i, "5.5.5.5");
        }
        assertThatThrownBy(() -> limite.verificarLogin("otra", "5.5.5.5"))
                .isInstanceOf(DemasiadosIntentosException.class);
        assertThatCode(() -> limite.verificarLogin("otra", "6.6.6.6")).doesNotThrowAnyException();
    }

    @Test
    @DisplayName("Registro y formularios: limite por IP dentro de su ventana")
    void registroYFormularios() {
        for (int i = 0; i < 3; i++) {
            limite.verificarRegistro("7.7.7.7");
            limite.registrarRegistro("7.7.7.7");
        }
        assertThatThrownBy(() -> limite.verificarRegistro("7.7.7.7")).isInstanceOf(DemasiadosIntentosException.class);
        reloj.adelantar(Duration.ofMinutes(61));
        assertThatCode(() -> limite.verificarRegistro("7.7.7.7")).doesNotThrowAnyException();

        limite.consumirFormulario("8.8.8.8");
        limite.consumirFormulario("8.8.8.8");
        assertThatThrownBy(() -> limite.consumirFormulario("8.8.8.8")).isInstanceOf(DemasiadosIntentosException.class);
        reloj.adelantar(Duration.ofMinutes(11));
        assertThatCode(() -> limite.consumirFormulario("8.8.8.8")).doesNotThrowAnyException();
    }
}
