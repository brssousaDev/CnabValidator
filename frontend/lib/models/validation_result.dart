import 'cnab_record.dart';

class ValidationResult {
  final String fileName;
  final String status;
  final String? format;
  final String? type;
  final int totalLines;
  final int errorCount;
  final List<CnabRecord> records;
  final Map<String, String>? originalLines;

  ValidationResult({
    required this.fileName,
    required this.status,
    this.format,
    this.type,
    required this.totalLines,
    required this.errorCount,
    required this.records,
    this.originalLines,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    Map<String, String>? origLines;
    if (json['originalLines'] != null && json['originalLines'] is Map) {
      origLines = Map<String, String>.from(
        (json['originalLines'] as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
      );
    }
    
    return ValidationResult(
      fileName: json['fileName'] as String,
      status: json['status'] as String,
      format: json['format'] as String?,
      type: json['type'] as String?,
      totalLines: json['totalLines'] as int,
      errorCount: json['errorCount'] as int,
      records: (json['records'] as List)
          .map((r) => CnabRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
      originalLines: origLines,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'status': status,
      'format': format,
      'type': type,
      'totalLines': totalLines,
      'errorCount': errorCount,
      'records': records.map((r) => r.toJson()).toList(),
      'originalLines': originalLines,
    };
  }

  bool get isValid => status == 'VALID';

  ValidationResult copyWith({
    String? fileName,
    String? status,
    String? format,
    String? type,
    int? totalLines,
    int? errorCount,
    List<CnabRecord>? records,
    Map<String, String>? originalLines,
  }) {
    return ValidationResult(
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      format: format ?? this.format,
      type: type ?? this.type,
      totalLines: totalLines ?? this.totalLines,
      errorCount: errorCount ?? this.errorCount,
      records: records ?? this.records,
      originalLines: originalLines ?? this.originalLines,
    );
  }
}
