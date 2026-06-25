package br.com.cnabvalidador.exporter;

import br.com.cnabvalidador.model.CnabField;
import br.com.cnabvalidador.model.CnabRecord;
import br.com.cnabvalidador.model.FieldType;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

public class CnabExporter {

    private static final String ENCODING = "ISO-8859-1";

    public byte[] export(List<CnabRecord> records, Map<String, String> originalLines) throws Exception {
        StringBuilder content = new StringBuilder();

        for (CnabRecord record : records) {
            String line = reconstructLine(record, originalLines);
            content.append(line).append("\n");
        }

        return content.toString().getBytes(ENCODING);
    }

    private String reconstructLine(CnabRecord record, Map<String, String> originalLines) {
        // Start with the original line content
        String key = String.valueOf(record.getLineNumber() - 1);
        String originalLine = originalLines.getOrDefault(key, "");
        
        // Use the stored line length from the record, or fall back to original line length
        int lineLength = record.getLineLength() > 0 ? record.getLineLength() : 
                         (originalLine.isEmpty() ? 400 : originalLine.length());
        
        // Expand original line to match required lineLength if needed
        if (originalLine.isEmpty()) {
            originalLine = " ".repeat(lineLength);
        } else if (originalLine.length() < lineLength) {
            // Pad the original line to the required length
            StringBuilder sb = new StringBuilder(originalLine);
            while (sb.length() < lineLength) {
                sb.append(" ");
            }
            originalLine = sb.toString();
        }
        
        char[] lineChars = originalLine.toCharArray();

        // Replace with edited field values
        for (CnabField field : record.getFields()) {
            String value = field.getValue();
            
            // Apply padding based on type
            value = applyPadding(value, field);

            // Insert value into the line
            int begin = field.getBegin() - 1; // 1-based to 0-based
            int end = field.getEnd();

            for (int i = begin; i < end && i < lineChars.length; i++) {
                if ((i - begin) < value.length()) {
                    lineChars[i] = value.charAt(i - begin);
                } else {
                    lineChars[i] = ' '; // Pad with spaces
                }
            }
        }

        String result = new String(lineChars);

        // Ensure line has correct length
        if (result.length() > lineLength) {
            result = result.substring(0, lineLength);
        } else if (result.length() < lineLength) {
            StringBuilder sb = new StringBuilder(result);
            while (sb.length() < lineLength) {
                sb.append(" ");
            }
            result = sb.toString();
        }

        return result;
    }

    private String applyPadding(String value, CnabField field) {
        if (value == null) {
            value = "";
        }
        
        int expectedLength = field.getEnd() - field.getBegin() + 1;

        if (value.length() == expectedLength) {
            return value;
        }

        if (value.length() > expectedLength) {
            return value.substring(0, expectedLength);
        }

        // Pad based on type
        if (field.getType() == FieldType.NUMERICO) {
            // Left-pad with zeros for numeric
            String trimmed = value.trim();
            if (trimmed.isEmpty()) {
                return String.format("%0" + expectedLength + "d", 0);
            }
            try {
                return String.format("%0" + expectedLength + "d", Long.parseLong(trimmed));
            } catch (NumberFormatException e) {
                // If value is not a valid number, pad with zeros
                return String.format("%0" + expectedLength + "d", 0);
            }
        } else {
            // Right-pad with spaces for text/alphanumeric
            return String.format("%-" + expectedLength + "s", value);
        }
    }
}
