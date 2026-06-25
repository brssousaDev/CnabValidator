import 'cnab_field.dart';

class CnabRecord {
  final int lineNumber;
  final String recordType;
  final List<CnabField> fields;
  final int lineLength;

  CnabRecord({
    required this.lineNumber,
    required this.recordType,
    required this.fields,
    this.lineLength = 0,
  });

  factory CnabRecord.fromJson(Map<String, dynamic> json) {
    return CnabRecord(
      lineNumber: json['lineNumber'] as int,
      recordType: json['recordType'] as String,
      fields: (json['fields'] as List)
          .map((f) => CnabField.fromJson(f as Map<String, dynamic>))
          .toList(),
      lineLength: json['lineLength'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lineNumber': lineNumber,
      'recordType': recordType,
      'fields': fields.map((f) => f.toJson()).toList(),
      'lineLength': lineLength,
    };
  }

  CnabRecord copyWith({
    int? lineNumber,
    String? recordType,
    List<CnabField>? fields,
    int? lineLength,
  }) {
    return CnabRecord(
      lineNumber: lineNumber ?? this.lineNumber,
      recordType: recordType ?? this.recordType,
      fields: fields ?? this.fields,
      lineLength: lineLength ?? this.lineLength,
    );
  }
}
