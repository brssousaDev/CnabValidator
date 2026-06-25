package br.com.cnabvalidador.service;

import br.com.cnabvalidador.model.Layout;
import br.com.cnabvalidador.model.CnabRecord;
import br.com.cnabvalidador.model.ValidationResult;
import br.com.cnabvalidador.parser.CnabParser;
import br.com.cnabvalidador.validator.CnabValidator;
import br.com.cnabvalidador.exporter.CnabExporter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
public class CnabService {

    @Autowired
    private LayoutService layoutService;

    public ValidationResult validate(InputStream fileStream, String fileName,
                                     String category, String layoutName) throws IOException {
        // Load layout
        Layout layout = layoutService.loadLayout(category, layoutName);

        // Read file lines
        List<String> lines = readLines(fileStream);

        // Parse CNAB
        CnabParser cnabParser = new CnabParser();
        List<CnabRecord> records = cnabParser.parse(lines, layout);

        // Validate
        CnabValidator validator = new CnabValidator();
        validator.validateAll(records);

        // Count errors
        int errorCount = 0;
        for (CnabRecord record : records) {
            for (var field : record.getFields()) {
                if (!field.isValid()) {
                    errorCount++;
                }
            }
        }

        // Build result
        ValidationResult result = new ValidationResult();
        result.setFileName(fileName);
        result.setFormat(cnabParser.inferFormat(lines));
        result.setType(cnabParser.inferType(layoutName));
        result.setTotalLines(lines.size());
        result.setErrorCount(errorCount);
        result.setStatus(errorCount == 0 ? "VALID" : "INVALID");
        result.setRecords(records);

        // Store original lines for export
        Map<String, String> originalLines = new HashMap<>();
        for (int i = 0; i < lines.size(); i++) {
            originalLines.put(String.valueOf(i), lines.get(i));
        }
        result.setOriginalLines(originalLines);

        return result;
    }

    public byte[] export(ValidationResult result) throws Exception {
        if (result.getRecords() == null || result.getRecords().isEmpty()) {
            return new byte[0];
        }

        Map<String, String> originalLines = new HashMap<>();

        // Use stored original lines or create empty ones as fallback
        if (result.getOriginalLines() != null && !result.getOriginalLines().isEmpty()) {
            originalLines.putAll(result.getOriginalLines());
        } else {
            for (CnabRecord record : result.getRecords()) {
                originalLines.put(String.valueOf(record.getLineNumber() - 1), "");
            }
        }

        CnabExporter exporter = new CnabExporter();
        return exporter.export(result.getRecords(), originalLines);
    }

    private List<String> readLines(InputStream stream) throws IOException {
        List<String> lines = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(stream, StandardCharsets.ISO_8859_1))) {
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        }

        return lines;
    }
}
