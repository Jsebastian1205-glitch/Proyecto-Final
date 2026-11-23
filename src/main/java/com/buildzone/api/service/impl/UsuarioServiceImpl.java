package com.buildzone.api.service.impl;

import java.security.SecureRandom;
import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.buildzone.api.dto.CambioPasswordRequest;
import com.buildzone.api.dto.PasswordTemporalResponse;
import com.buildzone.api.dto.PerfilRequest;
import com.buildzone.api.dto.UsuarioResponse;
import com.buildzone.api.exception.RecursoDuplicadoException;
import com.buildzone.api.exception.RecursoNoEncontradoException;
import com.buildzone.api.exception.ReglaNegocioException;
import com.buildzone.api.model.Usuario;
import com.buildzone.api.model.enums.EstadoUsuario;
import com.buildzone.api.model.enums.Rol;
import com.buildzone.api.repository.UsuarioRepository;
import com.buildzone.api.service.UsuarioService;

/**
 * Implementacion de {@link UsuarioService}.
 * <p>
 * Regla de seguridad: un administrador no puede quitarse a si mismo el
 * rol ADMIN ni desactivar su propia cuenta, para evitar que el sistema
 * se quede sin ningun administrador por error.
 */
@Service
@Transactional(readOnly = true)
public class UsuarioServiceImpl implements UsuarioService {

    private static final String ALFABETO_TEMPORAL = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
    private static final SecureRandom ALEATORIO = new SecureRandom();

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioServiceImpl(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public UsuarioResponse obtenerPerfil(Long usuarioId) {
        return UsuarioResponse.desde(buscarOFallar(usuarioId));
    }

    @Override
    @Transactional
    public UsuarioResponse actualizarPerfil(Long usuarioId, PerfilRequest request) {
        Usuario usuario = buscarOFallar(usuarioId);
        String nuevoEmail = request.email().trim().toLowerCase();

        boolean cambiaEmail = !usuario.getEmail().equalsIgnoreCase(nuevoEmail);
        if (cambiaEmail && usuarioRepository.existsByEmailIgnoreCase(nuevoEmail)) {
            throw new RecursoDuplicadoException("El correo ya esta registrado por otra cuenta.");
        }

        usuario.setNombre(request.nombre().trim());
        usuario.setApellido(request.apellido().trim());
        usuario.setEmail(nuevoEmail);
        return UsuarioResponse.desde(usuarioRepository.save(usuario));
    }

    @Override
    @Transactional
    public void cambiarPassword(Long usuarioId, CambioPasswordRequest request) {
        Usuario usuario = buscarOFallar(usuarioId);

        if (usuario.isDebeCambiarPassword()) {
            // Entro con una contrasena temporal: no se le pide la actual,
            // pero la nueva no puede ser la misma temporal.
            if (passwordEncoder.matches(request.passwordNueva(), usuario.getPasswordHash())) {
                throw new ReglaNegocioException("La contrasena nueva debe ser diferente de la temporal.");
            }
        } else {
            if (request.passwordActual() == null || request.passwordActual().isBlank()) {
                throw new ReglaNegocioException("La contrasena actual es obligatoria.");
            }
            if (!passwordEncoder.matches(request.passwordActual(), usuario.getPasswordHash())) {
                throw new ReglaNegocioException("La contrasena actual no es correcta.");
            }
            if (request.passwordActual().equals(request.passwordNueva())) {
                throw new ReglaNegocioException("La contrasena nueva debe ser diferente de la actual.");
            }
        }

        usuario.setPasswordHash(passwordEncoder.encode(request.passwordNueva()));
        usuario.setDebeCambiarPassword(false);
        usuarioRepository.save(usuario);
    }

    @Override
    public List<UsuarioResponse> listar() {
        return usuarioRepository.findAll().stream()
                .map(UsuarioResponse::desde)
                .toList();
    }

    @Override
    @Transactional
    public UsuarioResponse cambiarRol(Long actorId, Long usuarioId, Rol nuevoRol) {
        if (actorId.equals(usuarioId) && nuevoRol != Rol.ADMIN) {
            throw new ReglaNegocioException("No puedes quitarte a ti mismo el rol de administrador.");
        }
        Usuario usuario = buscarOFallar(usuarioId);
        usuario.setRol(nuevoRol);
        return UsuarioResponse.desde(usuarioRepository.save(usuario));
    }

    @Override
    @Transactional
    public UsuarioResponse cambiarEstado(Long actorId, Long usuarioId, EstadoUsuario nuevoEstado) {
        if (actorId.equals(usuarioId) && nuevoEstado == EstadoUsuario.INACTIVO) {
            throw new ReglaNegocioException("No puedes desactivar tu propia cuenta.");
        }
        Usuario usuario = buscarOFallar(usuarioId);
        usuario.setEstado(nuevoEstado);
        return UsuarioResponse.desde(usuarioRepository.save(usuario));
    }

    @Override
    @Transactional
    public PasswordTemporalResponse restablecerPassword(Long actorId, Long usuarioId) {
        if (actorId.equals(usuarioId)) {
            throw new ReglaNegocioException("Tu propia contrasena la cambias desde Mi cuenta > Seguridad.");
        }
        Usuario usuario = buscarOFallar(usuarioId);
        String temporal = generarPasswordTemporal();
        usuario.setPasswordHash(passwordEncoder.encode(temporal));
        usuario.setDebeCambiarPassword(true);
        usuarioRepository.save(usuario);
        return new PasswordTemporalResponse(usuario.getId(), usuario.getUsername(), usuario.getEmail(), temporal);
    }

    /**
     * Contrasena temporal facil de dictar o copiar, por ejemplo "Bz-7K4M-Q92T".
     * Sin letras ni numeros que se confunden (0/O, 1/I/L). SecureRandom: no es predecible.
     */
    static String generarPasswordTemporal() {
        StringBuilder sb = new StringBuilder("Bz-");
        for (int i = 0; i < 8; i++) {
            if (i == 4) {
                sb.append('-');
            }
            sb.append(ALFABETO_TEMPORAL.charAt(ALEATORIO.nextInt(ALFABETO_TEMPORAL.length())));
        }
        return sb.toString();
    }

    private Usuario buscarOFallar(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("No existe un usuario con id " + id));
    }
}
