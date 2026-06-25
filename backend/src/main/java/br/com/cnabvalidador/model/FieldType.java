package br.com.cnabvalidador.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum FieldType {
    NUMERICO("NUMERICO"),
    TEXTO("TEXTO"),
    ALFANUMERICO("ALFANUMERICO");

    private final String value;

    FieldType(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }

    @JsonCreator
    public static FieldType fromValue(String value) {
        for (FieldType type : FieldType.values()) {
            if (type.value.equalsIgnoreCase(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown FieldType: " + value);
    }
}
