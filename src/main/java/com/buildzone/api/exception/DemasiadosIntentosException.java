package com.buildzone.api.exception;

/**
 * Se supero un limite de intentos (inicio de sesion, registro o formularios).
 * GlobalExceptionHandler la convierte en 429 Too Many Requests.
 */
public class DemasiadosIntentosException extends RuntimeException {

    public DemasiadosIntentosException(String mensaje) {
        super(mensaje);
    }
}
