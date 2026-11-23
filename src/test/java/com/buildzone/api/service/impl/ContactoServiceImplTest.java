package com.buildzone.api.service.impl;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.buildzone.api.dto.ContactoRequest;
import com.buildzone.api.dto.MensajeContactoResponse;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.MensajeContacto;
import com.buildzone.api.model.enums.EstadoMensaje;
import com.buildzone.api.model.enums.MotivoContacto;
import com.buildzone.api.model.enums.Rol;
import com.buildzone.api.repository.MensajeContactoRepository;
import com.buildzone.api.security.UsuarioAutenticado;

/** Pruebas unitarias del formulario de contacto: guardado, antispam y estados. */
@ExtendWith(MockitoExtension.class)
class ContactoServiceImplTest {

    private static final Clock RELOJ = Clock.fixed(Instant.parse("2026-11-23T21:00:00Z"), ZoneId.of("America/Bogota"));
    private static final LocalDateTime AHORA = LocalDateTime.now(RELOJ);

    @Mock
    private MensajeContactoRepository repository;

    private ContactoServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new ContactoServiceImpl(repository, RELOJ);
    }

    private static ContactoRequest request(String correo, String mensaje) {
        return new ContactoRequest("  Pedro Ruiz ", correo, MotivoContacto.DUDA_PRODUCTO, mensaje);
    }

    private void guardarDevuelveLoMismo() {
        when(repository.save(any(MensajeContacto.class))).thenAnswer(inv -> inv.getArgument(0));
    }

    @Test
    @DisplayName("Un visitante envia un mensaje: queda NUEVO, sin cuenta y con los datos recortados")
    void enviarComoVisitante() {
        when(repository.countByCorreoIgnoreCaseAndFechaEnvioAfter(anyString(), any())).thenReturn(0L);
        guardarDevuelveLoMismo();

        MensajeContactoResponse r = service.enviar(
                request(" Pedro@Correo.com ", "  Tienen la RTX 5070 disponible?  "), null);

        assertThat(r.nombre()).isEqualTo("Pedro Ruiz");
        assertThat(r.correo()).isEqualTo("pedro@correo.com");
        assertThat(r.mensaje()).isEqualTo("Tienen la RTX 5070 disponible?");
        assertThat(r.estado()).isEqualTo(EstadoMensaje.NUEVO);
        assertThat(r.motivoTexto()).isEqualTo("Duda sobre un producto");
        assertThat(r.fechaEnvio()).isEqualTo(AHORA);
        assertThat(r.cuentaRegistrada()).isFalse();
    }

    @Test
    @DisplayName("Si quien escribe tiene sesion se guarda el id de su cuenta")
    void enviarConSesion() {
        when(repository.countByCorreoIgnoreCaseAndFechaEnvioAfter(anyString(), any())).thenReturn(0L);
        guardarDevuelveLoMismo();

        service.enviar(request("laura@test.com", "Hola, tengo una duda con mi plan."),
                new UsuarioAutenticado(7L, "laura", Rol.USUARIO));

        ArgumentCaptor<MensajeContacto> captor = ArgumentCaptor.forClass(MensajeContacto.class);
        verify(repository).save(captor.capture());
        assertThat(captor.getValue().getIdUsuario()).isEqualTo(7L);
    }

    @Test
    @DisplayName("El antispam cuenta los mensajes de los ultimos 10 minutos de ese correo")
    void antispamUsaLaVentanaDeDiezMinutos() {
        when(repository.countByCorreoIgnoreCaseAndFechaEnvioAfter(anyString(), any())).thenReturn(2L);
        guardarDevuelveLoMismo();

        service.enviar(request("pedro@correo.com", "Tercer mensaje permitido."), null);

        verify(repository).countByCorreoIgnoreCaseAndFechaEnvioAfter(eq("pedro@correo.com"), eq(AHORA.minusMinutes(10)));
    }

    @Test
    @DisplayName("El cuarto mensaje en 10 minutos se rechaza y no se guarda")
    void antispamRechazaElCuarto() {
        when(repository.countByCorreoIgnoreCaseAndFechaEnvioAfter(anyString(), any())).thenReturn(3L);

        assertThatThrownBy(() -> service.enviar(request("pedro@correo.com", "Otro mensaje mas aqui."), null))
                .isInstanceOf(ReglaNegocioException.class)
                .hasMessageContaining("3 mensajes");
        verify(repository, never()).save(any());
    }

    @Test
    @DisplayName("Un mensaje que solo alcanza 10 caracteres gracias a los espacios se rechaza")
    void mensajeCortoSinEspacios() {
        assertThatThrownBy(() -> service.enviar(request("pedro@correo.com", "   hola       "), null))
                .isInstanceOf(ReglaNegocioException.class);
        verify(repository, never()).save(any());
    }

    @Test
    @DisplayName("El administrador cambia el estado de un mensaje")
    void cambiarEstado() {
        MensajeContacto m = new MensajeContacto();
        m.setNombre("Pedro");
        m.setCorreo("pedro@correo.com");
        m.setMotivo(MotivoContacto.OTRO);
        m.setMensaje("Mensaje de prueba");
        m.setEstado(EstadoMensaje.NUEVO);
        m.setFechaEnvio(AHORA);
        when(repository.findById(5L)).thenReturn(Optional.of(m));
        guardarDevuelveLoMismo();

        assertThat(service.cambiarEstado(5L, EstadoMensaje.RESPONDIDO).estado()).isEqualTo(EstadoMensaje.RESPONDIDO);
    }

    @Test
    @DisplayName("Cambiar el estado o eliminar un mensaje que no existe da 404")
    void mensajeInexistente() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.cambiarEstado(99L, EstadoMensaje.LEIDO))
                .isInstanceOf(RecursoNoEncontradoException.class);
        assertThatThrownBy(() -> service.eliminar(99L))
                .isInstanceOf(RecursoNoEncontradoException.class);
    }
}
