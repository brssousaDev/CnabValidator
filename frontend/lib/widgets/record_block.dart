import 'package:flutter/material.dart';
import '../models/cnab_record.dart';
import '../theme/app_theme.dart';
import 'field_row.dart';

class RecordBlock extends StatefulWidget {
  final CnabRecord record;
  final Function(int, int, String) onFieldEdit;
  final bool hasErrors;

  const RecordBlock({
    Key? key,
    required this.record,
    required this.onFieldEdit,
    required this.hasErrors,
  }) : super(key: key);

  @override
  State<RecordBlock> createState() => _RecordBlockState();
}

class _RecordBlockState extends State<RecordBlock> {
  bool _isExpanded = false;
  bool _showFullLine = false;

  String _getFullLine() {
    return widget.record.fields.fold<String>('', (acc, field) => acc + field.value);
  }

  @override
  Widget build(BuildContext context) {
    final fullLine = _getFullLine();
    
    return Card(
      elevation: widget.hasErrors ? 2 : 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          // Header colapsável
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: widget.hasErrors 
                    ? AppColors.alertRed.withOpacity(0.05)
                    : AppColors.lightGray,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.mediumGray.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Linha ${widget.record.lineNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.record.recordType,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  if (widget.hasErrors)
                    Icon(
                      Icons.error,
                      color: AppColors.alertRed,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
          
          // Campos expandíveis
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ...widget.record.fields.map((field) => FieldRow(
                    field: field,
                    onEdit: (newValue) => widget.onFieldEdit(
                      widget.record.lineNumber,
                      field.fieldIndex,
                      newValue,
                    ),
                  )).toList(),
                  const SizedBox(height: 12),
                  
                  // Sub-bloco: Ver linha completa
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showFullLine = !_showFullLine;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.mediumGray.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showFullLine
                              ? Icons.expand_less
                              : Icons.expand_more,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ver linha completa (${fullLine.length} caracteres)',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Linha completa expandida com quebra de linha
                  if (_showFullLine)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.8),
                        border: Border.all(
                          color: AppColors.mediumGray,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fullLine,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.darkBlue,
                              height: 1.8,
                            ),
                        softWrap: true,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
