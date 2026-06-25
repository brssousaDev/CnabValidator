package br.com.cnabvalidador.model;

import java.util.List;
import java.util.Map;

public class ValidationResult {
    private String fileName;
    private String status;
    private String format;
    private String type;
    private int totalLines;
    private int errorCount;
    private List<CnabRecord> records;
    private Map<String, String> originalLines;

    public ValidationResult() {
    }

    public ValidationResult(String fileName, String status, String format, String type,
                           int totalLines, int errorCount, List<CnabRecord> records) {
        this.fileName = fileName;
        this.status = status;
        this.format = format;
        this.type = type;
        this.totalLines = totalLines;
        this.errorCount = errorCount;
        this.records = records;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getTotalLines() {
        return totalLines;
    }

    public void setTotalLines(int totalLines) {
        this.totalLines = totalLines;
    }

    public int getErrorCount() {
        return errorCount;
    }

    public void setErrorCount(int errorCount) {
        this.errorCount = errorCount;
    }

    public List<CnabRecord> getRecords() {
        return records;
    }

    public void setRecords(List<CnabRecord> records) {
        this.records = records;
    }

    public Map<String, String> getOriginalLines() {
        return originalLines;
    }

    public void setOriginalLines(Map<String, String> originalLines) {
        this.originalLines = originalLines;
    }

    public boolean isValid() {
        return errorCount == 0;
    }
}
