package br.com.cnabvalidador.parser;

import br.com.cnabvalidador.model.*;

import java.util.*;

public class CnabParser {

    public String getSectionName(String line, Layout layout) {
        if (layout == null || layout.getRules() == null || layout.getRules().getKeyLength() == null) {
            return null;
        }

        List<KeyLength> keyLengths = layout.getRules().getKeyLength();
        StringBuilder key = new StringBuilder();

        for (KeyLength kl : keyLengths) {
            int begin = kl.getBegin() - 1; // YAML is 1-based
            int end = kl.getEnd();

            if (end > line.length()) {
                end = line.length();
            }

            if (begin < line.length()) {
                key.append(line.substring(begin, Math.min(end, line.length())));
            }
        }

        String keyStr = key.toString();
        Map<String, String> keyMap = layout.getKeyMap();
        
        if (keyMap == null) {
            return null;
        }

        // Try exact match first
        if (keyMap.containsKey(keyStr)) {
            return keyMap.get(keyStr);
        }

        // Try fallback: shorten from right to left
        for (int i = keyStr.length(); i > 0; i--) {
            String partialKey = keyStr.substring(0, i);
            if (keyMap.containsKey(partialKey)) {
                return keyMap.get(partialKey);
            }
        }

        return null;
    }

    public List<CnabRecord> parse(List<String> lines, Layout layout) {
        if (layout == null || layout.getLayoutDefinition() == null) {
            return new ArrayList<>();
        }
        
        List<CnabRecord> records = new ArrayList<>();

        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);

            String sectionName = getSectionName(line, layout);
            if (sectionName == null) {
                continue; // Skip unrecognized lines
            }

            RegisterDefinition registerDef = layout.getLayoutDefinition().get(sectionName);
            if (registerDef == null) {
                continue;
            }

            CnabRecord record = new CnabRecord();
            record.setLineNumber(i + 1);
            record.setRecordType(sectionName);
            
            // Set line length based on layout definition (max field end position)
            // Falls back to actual line length if no fields defined
            int layoutLineLength = getMaxFieldEndPosition(registerDef);
            record.setLineLength(layoutLineLength > 0 ? layoutLineLength : line.length());

            List<CnabField> fields = new ArrayList<>();
            if (registerDef.getFields() != null) {
                for (FieldDefinition fieldDef : registerDef.getFields()) {
                    CnabField field = extractField(line, fieldDef);
                    fields.add(field);
                }
            }

            record.setFields(fields);
            records.add(record);
        }

        return records;
    }

    private int getMaxFieldEndPosition(RegisterDefinition registerDef) {
        if (registerDef == null || registerDef.getFields() == null || registerDef.getFields().isEmpty()) {
            return 0;
        }
        
        int maxEnd = 0;
        for (FieldDefinition field : registerDef.getFields()) {
            if (field.getEnd() > maxEnd) {
                maxEnd = field.getEnd();
            }
        }
        
        return maxEnd;
    }

    private CnabField extractField(String line, FieldDefinition fieldDef) {
        CnabField field = new CnabField();

        field.setFieldIndex(fieldDef.getFieldIndex());
        field.setDescription(fieldDef.getDescription());
        field.setBegin(fieldDef.getBegin());
        field.setEnd(fieldDef.getEnd());
        field.setType(fieldDef.getType());
        field.setFormat(fieldDef.getFormat());
        field.setExceptionValues(fieldDef.getExceptionValues());

        // Extract value from line (1-based to 0-based)
        int begin = fieldDef.getBegin() - 1;
        int end = fieldDef.getEnd();

        if (end > line.length()) {
            end = line.length();
        }

        if (begin < line.length()) {
            field.setValue(line.substring(begin, end));
        } else {
            field.setValue("");
        }

        // Mark as not validated yet
        field.setValid(false);
        field.setErrorMessage("Not validated");

        return field;
    }

    public String inferFormat(List<String> lines) {
        if (lines.isEmpty()) {
            return null;
        }

        int lineLength = lines.get(0).length();

        if (lineLength == 240) {
            return "CNAB240";
        } else if (lineLength == 400) {
            return "CNAB400";
        }

        return null;
    }

    public String inferType(String layoutName) {
        if (layoutName == null) {
            return null;
        }

        String lowerName = layoutName.toLowerCase();

        if (lowerName.contains("remessa")) {
            return "REMESSA";
        } else if (lowerName.contains("retorno")) {
            return "RETORNO";
        }

        return null;
    }
}
