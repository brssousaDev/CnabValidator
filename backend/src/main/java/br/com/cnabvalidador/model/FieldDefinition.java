package br.com.cnabvalidador.model;

import java.util.List;

public class FieldDefinition {
    private int fieldIndex;
    private String description;
    private int begin;
    private int end;
    private FieldType type;
    private String format;
    private List<String> exceptionValues;

    public FieldDefinition() {
    }

    public FieldDefinition(int fieldIndex, String description, int begin, int end, 
                          FieldType type, String format, List<String> exceptionValues) {
        this.fieldIndex = fieldIndex;
        this.description = description;
        this.begin = begin;
        this.end = end;
        this.type = type;
        this.format = format;
        this.exceptionValues = exceptionValues;
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
}
