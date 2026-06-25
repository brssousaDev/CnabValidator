package br.com.cnabvalidador.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class CnabField {
    private int fieldIndex;
    private String description;
    private int begin;
    private int end;
    private String value;
    @JsonProperty("type")
    private FieldType type;
    private String format;
    private List<String> exceptionValues;
    private boolean valid;
    private String errorMessage;

    public CnabField() {
    }

    public CnabField(int fieldIndex, String description, int begin, int end, String value,
                    FieldType type, String format, List<String> exceptionValues, 
                    boolean valid, String errorMessage) {
        this.fieldIndex = fieldIndex;
        this.description = description;
        this.begin = begin;
        this.end = end;
        this.value = value;
        this.type = type;
        this.format = format;
        this.exceptionValues = exceptionValues;
        this.valid = valid;
        this.errorMessage = errorMessage;
    }

    public int getFieldIndex() {
        return fieldIndex;
    }

    public void setFieldIndex(int fieldIndex) {
        this.fieldIndex = fieldIndex;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getBegin() {
        return begin;
    }

    public void setBegin(int begin) {
        this.begin = begin;
    }

    public int getEnd() {
        return end;
    }

    public void setEnd(int end) {
        this.end = end;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public FieldType getType() {
        return type;
    }

    public void setType(FieldType type) {
        this.type = type;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public List<String> getExceptionValues() {
        return exceptionValues;
    }

    public void setExceptionValues(List<String> exceptionValues) {
        this.exceptionValues = exceptionValues;
    }

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
}
