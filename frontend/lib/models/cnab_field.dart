class CnabField {
  final int fieldIndex;
  final String description;
  final int begin;
  final int end;
  final String value;
  final String type;
  final String? format;
  final List<String>? exceptionValues;
  final bool valid;
  final String? errorMessage;

  CnabField({
    required this.fieldIndex,
    required this.description,
    required this.begin,
    required this.end,
    required this.value,
    required this.type,
    this.format,
    this.exceptionValues,
    required this.valid,
    this.errorMessage,
  });

  factory CnabField.fromJson(Map<String, dynamic> json) {
    return CnabField(
      fieldIndex: json['fieldIndex'] as int,
      description: json['description'] as String,
      begin: json['begin'] as int,
      end: json['end'] as int,
      value: json['value'] as String,
      type: json['type'] as String,
      format: json['format'] as String?,
      exceptionValues: json['exceptionValues'] != null
          ? List<String>.from(json['exceptionValues'] as List)
          : null,
      valid: json['valid'] as bool,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldIndex': fieldIndex,
      'description': description,
      'begin': begin,
      'end': end,
      'value': value,
      'type': type,
      'format': format,
      'exceptionValues': exceptionValues,
      'valid': valid,
      'errorMessage': errorMessage,
    };
  }

  CnabField copyWith({
    int? fieldIndex,
    String? description,
    int? begin,
    int? end,
    String? value,
    String? type,
    String? format,
    List<String>? exceptionValues,
    bool? valid,
    String? errorMessage,
  }) {
    return CnabField(
      fieldIndex: fieldIndex ?? this.fieldIndex,
      description: description ?? this.description,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      value: value ?? this.value,
      type: type ?? this.type,
      format: format ?? this.format,
      exceptionValues: exceptionValues ?? this.exceptionValues,
      valid: valid ?? this.valid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
