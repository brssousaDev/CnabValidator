package br.com.cnabvalidador.model;

import java.util.List;

public class CnabRecord {
    private int lineNumber;
    private String recordType;
    private List<CnabField> fields;
    private int lineLength;

    public CnabRecord() {
    }

    public CnabRecord(int lineNumber, String recordType, List<CnabField> fields) {
        this.lineNumber = lineNumber;
        this.recordType = recordType;
        this.fields = fields;
    }

    public int getLineNumber() {
        return lineNumber;
    }

    public void setLineNumber(int lineNumber) {
        this.lineNumber = lineNumber;
    }

    public String getRecordType() {
        return recordType;
    }

    public void setRecordType(String recordType) {
        this.recordType = recordType;
    }

    public List<CnabField> getFields() {
        return fields;
    }

    public void setFields(List<CnabField> fields) {
        this.fields = fields;
    }

    public int getLineLength() {
        return lineLength;
    }

    public void setLineLength(int lineLength) {
        this.lineLength = lineLength;
    }
}
