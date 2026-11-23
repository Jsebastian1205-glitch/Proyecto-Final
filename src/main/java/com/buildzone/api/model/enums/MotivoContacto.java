package com.buildzone.api.model.enums;

/** Motivos que el visitante puede elegir en el formulario de contacto. */
public enum MotivoContacto {
    DUDA_PRODUCTO("Duda sobre un producto"),
    SUGERENCIA("Sugerencia"),
    PROBLEMA_CUENTA("Problema con mi cuenta"),
    PLANES("Planes y suscripciones"),
    OTRO("Otro");

    private final String etiqueta;

    MotivoContacto(String etiqueta) {
        this.etiqueta = etiqueta;
    }

    /** Texto que se muestra en pantalla. */
    public String getEtiqueta() {
        return etiqueta;
    }
}
