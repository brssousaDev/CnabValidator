package br.com.cnabvalidador.model;

import java.util.List;

public class RegisterDefinition {
    private String occurrence;
    private String type;
    private List<FieldDefinition> fields;

    public RegisterDefinition() {
    }

    public RegisterDefinition(String occurrence, String type, List<FieldDefinition> fields) {
        this.occurrence = occurrence;
        this.type = type;
        this.fields = fields;
    }

    public String getOccurrence() {
        return occurrence;
    }

    public void setOccurrence(String occurrence) {
        this.occurrence = occurrence;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<FieldDefinition> getFields() {
        return fields;
    }

    public void setFields(List<FieldDefinition> fields) {
        this.fields = fields;
    }
}
