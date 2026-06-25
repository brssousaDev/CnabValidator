package br.com.cnabvalidador.validator;

import br.com.cnabvalidador.model.CnabField;
import br.com.cnabvalidador.model.CnabRecord;
import br.com.cnabvalidador.model.FieldType;

import java.util.List;
import java.util.regex.Pattern;

public class CnabValidator {

    private static final Pattern NUMERIC_PATTERN = Pattern.compile("^\\d+$");
    private static final Pattern TEXT_PATTERN = Pattern.compile("^[A-Za-z\\s]+$");

    public CnabField validate(CnabField field) {
        // Rule 1: exception-values
        if (field.getExceptionValues() != null && field.getExceptionValues().contains(field.getValue())) {
            field.setValid(true);
            field.setErrorMessage(null);
            return field;
        }

        // Rule 2: null or completely empty field (length 0)
        if (field.getValue() == null || field.getValue().isEmpty()) {
            field.setValid(false);
            field.setErrorMessage("Campo obrigatório");
            return field;
        }

        // Rule 3: incorrect length
        int expectedLength = field.getEnd() - field.getBegin() + 1;
        if (field.getValue().length() != expectedLength) {
            field.setValid(false);
            field.setErrorMessage("Campo deve ter " + expectedLength + " caracteres e possui " + field.getValue().length());
            return field;
        }

        // For alfanumeric fields, spaces are valid, so we accept and return early
        if (field.getType() == FieldType.ALFANUMERICO && field.getValue().trim().isEmpty()) {
            field.setValid(true);
            field.setErrorMessage(null);
            return field;
        }

        // Rule 2b: empty or only spaces for numeric/text fields
        if (field.getValue().trim().isEmpty()) {
            field.setValid(false);
            field.setErrorMessage("Campo obrigatório");
            return field;
        }

        // Rule 4: numeric type
        if (field.getType() == FieldType.NUMERICO) {
            if (!NUMERIC_PATTERN.matcher(field.getValue()).matches()) {
                field.setValid(false);
                field.setErrorMessage("Campo numérico não pode conter letras ou símbolos");
                return field;
            }
        }

        // Rule 5: text type
        if (field.getType() == FieldType.TEXTO) {
            if (!TEXT_PATTERN.matcher(field.getValue()).matches()) {
                field.setValid(false);
                field.setErrorMessage("Campo texto não pode conter dígitos ou caracteres especiais");
                return field;
            }
        }

        // Rule 6: alphanumeric type (accepts everything)
        if (field.getType() == FieldType.ALFANUMERICO) {
            // Valid by default if passed previous checks
        }

        // Rule 7: date validation
        if (field.getFormat() != null) {
            if (field.getFormat().equals("DDMMYY") || field.getFormat().equals("DDMMYYYY")) {
                if (!isValidDate(field.getValue(), field.getFormat())) {
                    field.setValid(false);
                    field.setErrorMessage("Data inválida (formato: " + field.getFormat() + ")");
                    return field;
                }
            }
        }

        field.setValid(true);
        field.setErrorMessage(null);
        return field;
    }

    public void validateAll(List<CnabRecord> records) {
        for (CnabRecord record : records) {
            if (record.getFields() != null) {
                for (CnabField field : record.getFields()) {
                    validate(field);
                }
            }
        }
    }

    private boolean isValidDate(String dateStr, String format) {
        try {
            int day, month, year;

            if ("DDMMYY".equals(format)) {
                if (dateStr.length() != 6) return false;
                day = Integer.parseInt(dateStr.substring(0, 2));
                month = Integer.parseInt(dateStr.substring(2, 4));
                year = Integer.parseInt(dateStr.substring(4, 6));
                year += 2000; // Convert YY to YYYY (2000-2099)
            } else if ("DDMMYYYY".equals(format)) {
                if (dateStr.length() != 8) return false;
                day = Integer.parseInt(dateStr.substring(0, 2));
                month = Integer.parseInt(dateStr.substring(2, 4));
                year = Integer.parseInt(dateStr.substring(4, 8));
            } else {
                return false;
            }

            if (month < 1 || month > 12) return false;
            if (day < 1 || day > 31) return false;

            // Check days in month
            int[] daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

            // Adjust for leap years
            if (month == 2 && ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)) {
                if (day > 29) return false;
            } else if (day > daysInMonth[month - 1]) {
                return false;
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
