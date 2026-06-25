import 'package:flutter/foundation.dart';
import '../models/validation_result.dart';
import '../models/cnab_field.dart';

class ValidationProvider extends ChangeNotifier {
  ValidationResult? _result;
  int _errorCount = 0;

  ValidationResult? get result => _result;
  int get errorCount => _errorCount;
  bool get isValid => _errorCount == 0;

  void loadResult(ValidationResult result) {
    _result = result;
    _errorCount = result.errorCount;
    notifyListeners();
  }

  void updateField(int lineNumber, int fieldIndex, String newValue) {
    if (_result == null) return;

    final recordIndex = _result!.records
        .indexWhere((r) => r.lineNumber == lineNumber);
    
    if (recordIndex == -1) return;

    final record = _result!.records[recordIndex];
    final fieldIdx = record.fields.indexWhere((f) => f.fieldIndex == fieldIndex);
    
    if (fieldIdx == -1) return;

    final oldField = record.fields[fieldIdx];
    final newField = oldField.copyWith(value: newValue);

    // Re-validar localmente (espelhar regras do backend)
    final validatedField = _validateField(newField);

    // Atualizar contagem de erros
    if (!oldField.valid && validatedField.valid) {
      _errorCount--;
    } else if (oldField.valid && !validatedField.valid) {
      _errorCount++;
    }

    // Atualizar estrutura
    record.fields[fieldIdx] = validatedField;
    
    notifyListeners();
  }

  CnabField _validateField(CnabField field) {
    // Regra 1: exception-values
    if (field.exceptionValues != null && 
        field.exceptionValues!.contains(field.value)) {
      return field.copyWith(valid: true, errorMessage: null);
    }

    // Regra 2: campo vazio
    if (field.value.isEmpty) {
      return field.copyWith(
        valid: false,
        errorMessage: 'Campo obrigatório',
      );
    }

    // Regra 3: comprimento incorreto
    final expectedLength = field.end - field.begin + 1;
    if (field.value.length != expectedLength) {
      return field.copyWith(
        valid: false,
        errorMessage: 'Campo deve ter $expectedLength caracteres e possui ${field.value.length}',
      );
    }

    // Regra 4: tipo numérico
    if (field.type == 'NUMERICO') {
      if (!RegExp(r'^\d+$').hasMatch(field.value)) {
        return field.copyWith(
          valid: false,
          errorMessage: 'Campo numérico não pode conter letras ou símbolos',
        );
      }
    }

    // Regra 5: tipo texto
    if (field.type == 'TEXTO') {
      if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(field.value)) {
        return field.copyWith(
          valid: false,
          errorMessage: 'Campo texto não pode conter dígitos ou caracteres especiais',
        );
      }
    }

    // Regra 6: tipo alfanumérico (aceita tudo)
    if (field.type == 'ALFANUMERICO') {
      // Válido por padrão se passou nas verificações anteriores
    }

    // Regra 7: validar data (DDMMYY ou DDMMYYYY)
    if (field.format != null && 
        (field.format == 'DDMMYY' || field.format == 'DDMMYYYY')) {
      if (!_isValidDate(field.value, field.format!)) {
        return field.copyWith(
          valid: false,
          errorMessage: 'Data inválida (formato: ${field.format})',
        );
      }
    }

    return field.copyWith(valid: true, errorMessage: null);
  }

  bool _isValidDate(String dateStr, String format) {
    try {
      int day, month, year;
      
      if (format == 'DDMMYY') {
        day = int.parse(dateStr.substring(0, 2));
        month = int.parse(dateStr.substring(2, 4));
        year = int.parse(dateStr.substring(4, 6));
        // Converter YY para YYYY (2000-2099)
        year += 2000;
      } else if (format == 'DDMMYYYY') {
        day = int.parse(dateStr.substring(0, 2));
        month = int.parse(dateStr.substring(2, 4));
        year = int.parse(dateStr.substring(4, 8));
      } else {
        return false;
      }

      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Verificação básica de dias em mês
      final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      
      // Ajustar para anos bissextos
      if (month == 2 && ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)) {
        if (day > 29) return false;
      } else if (day > daysInMonth[month - 1]) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void clearResult() {
    _result = null;
    _errorCount = 0;
    notifyListeners();
  }
}
