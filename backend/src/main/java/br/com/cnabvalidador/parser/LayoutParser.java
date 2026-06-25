package br.com.cnabvalidador.parser;

import br.com.cnabvalidador.model.*;
import org.yaml.snakeyaml.Yaml;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class LayoutParser {

    public Layout parse(InputStream yamlStream) throws IOException {
        Yaml yaml = new Yaml();
        // Use ISO_8859_1 to handle YAML files that may contain Latin-1 encoded characters
        Reader reader = new InputStreamReader(yamlStream, StandardCharsets.ISO_8859_1);
        Map<String, Object> data = yaml.load(reader);

        Layout layout = new Layout();

        // Parse rules
        if (data.containsKey("rules")) {
            Map<String, Object> rulesMap = (Map<String, Object>) data.get("rules");
            List<KeyLength> keyLengths = new ArrayList<>();
            
            if (rulesMap != null) {
                Map<String, Object> columnMap = (Map<String, Object>) rulesMap.get("column");
                if (columnMap != null) {
                    List<Map<String, Object>> keyLengthList = (List<Map<String, Object>>) columnMap.get("key-length");
                    if (keyLengthList != null) {
                        for (Map<String, Object> kl : keyLengthList) {
                            Integer begin = toInt(kl.get("begin-column"));
                            Integer end = toInt(kl.get("end-column"));
                            keyLengths.add(new KeyLength(begin, end));
                        }
                    }
                }
            }
            
            layout.setRules(new Rules(keyLengths));
        }

        // Parse key-map
        if (data.containsKey("key-map")) {
            Map<Object, String> rawKeyMap = (Map<Object, String>) data.get("key-map");
            if (rawKeyMap != null) {
                Map<String, String> keyMap = new HashMap<>();
                for (Map.Entry<Object, String> entry : rawKeyMap.entrySet()) {
                    keyMap.put(String.valueOf(entry.getKey()), entry.getValue());
                }
                layout.setKeyMap(keyMap);
            }
        }

        // Parse layout-definition
        if (data.containsKey("layout-definition")) {
            Map<String, Object> layoutDefMap = (Map<String, Object>) data.get("layout-definition");
            Map<String, RegisterDefinition> layoutDefinition = new HashMap<>();

            for (Map.Entry<String, Object> entry : layoutDefMap.entrySet()) {
                String registerType = entry.getKey();
                Object registerData = entry.getValue();

                RegisterDefinition registerDef = parseRegisterDefinition(registerType, registerData);
                layoutDefinition.put(registerType, registerDef);
            }

            layout.setLayoutDefinition(layoutDefinition);
        }

        // Parse seq-show if exists
        if (data.containsKey("seq-show")) {
            layout.setSeqShow((Boolean) data.getOrDefault("seq-show", false));
        }

        return layout;
    }

    private RegisterDefinition parseRegisterDefinition(String registerType, Object registerData) {
        RegisterDefinition registerDef = new RegisterDefinition();
        registerDef.setType(registerType);

        if (registerData instanceof List) {
            List<Object> registerList = (List<Object>) registerData;

            // First element should be metadata
            for (Object item : registerList) {
                if (item instanceof Map) {
                    Map<String, Object> itemMap = (Map<String, Object>) item;

                    if (itemMap.containsKey("metadata")) {
                        Map<String, Object> metadata = (Map<String, Object>) itemMap.get("metadata");
                        if (metadata.containsKey("occurrence")) {
                            registerDef.setOccurrence(metadata.get("occurrence").toString());
                        }
                    }

                    if (itemMap.containsKey("fields")) {
                        List<Map<String, Object>> fieldsList = (List<Map<String, Object>>) itemMap.get("fields");
                        List<FieldDefinition> fields = parseFields(fieldsList);
                        registerDef.setFields(fields);
                    }
                }
            }
        }

        return registerDef;
    }

    private List<FieldDefinition> parseFields(List<Map<String, Object>> fieldsList) {
        List<FieldDefinition> fields = new ArrayList<>();
        int fieldIndex = 1;

        for (Map<String, Object> fieldMap : fieldsList) {
            FieldDefinition field = new FieldDefinition();

            field.setFieldIndex(fieldIndex++);
            field.setDescription((String) fieldMap.get("description"));
            field.setBegin(toInt(fieldMap.get("begin")));
            field.setEnd(toInt(fieldMap.get("end")));

            String typeStr = (String) fieldMap.get("type");
            field.setType(FieldType.fromValue(typeStr));

            if (fieldMap.containsKey("format")) {
                field.setFormat((String) fieldMap.get("format"));
            }

            if (fieldMap.containsKey("exception-values")) {
                Object exceptionValuesObj = fieldMap.get("exception-values");
                if (exceptionValuesObj instanceof List) {
                    field.setExceptionValues((List<String>) exceptionValuesObj);
                }
            }

            fields.add(field);
        }

        return fields;
    }

    private Integer toInt(Object value) {
        if (value == null) return null;
        if (value instanceof Integer) return (Integer) value;
        if (value instanceof String) return Integer.parseInt((String) value);
        return null;
    }
}
