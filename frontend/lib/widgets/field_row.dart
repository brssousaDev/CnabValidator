import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cnab_field.dart';
import '../theme/app_theme.dart';

class FieldRow extends StatefulWidget {
  final CnabField field;
  final Function(String) onEdit;

  const FieldRow({
    Key? key,
    required this.field,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<FieldRow> {
  late TextEditingController _controller;
  bool _isEditing = false;
  late FocusNode _focusNode;
  bool _isValid = true;

  int get _expectedLength => widget.field.end - widget.field.begin + 1;

  String _getInputTypeLabel() {
    switch (widget.field.type.toLowerCase()) {
      case 'numeric':
        return 'Numerico';
      case 'alphanumeric':
        return 'Alfanumerico';
      case 'date':
        return 'Data';
      case 'text':
        return 'Texto';
      default:
        return widget.field.type;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[
      LengthLimitingTextInputFormatter(_expectedLength),
    ];

    switch (widget.field.type.toLowerCase()) {
      case 'numeric':
      case 'date':
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case 'text':
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]')));
        break;
      case 'alphanumeric':
        // Permite qualquer caractere
        break;
    }

    return formatters;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isValid = widget.field.valid;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      widget.onEdit(_controller.text);
      setState(() => _isEditing = false);
    }
  }

  void _validateInRealTime(String value) {
    setState(() {
      _isValid = value.length == _expectedLength;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = !_isValid || !widget.field.valid;
    final lineColor = hasError ? AppColors.alertRed : AppColors.darkBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.mediumGray.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _isEditing = true);
            _focusNode.requestFocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha 1: Posição, Label, Info
                      Row(
                        children: [
                          // Posição
                          SizedBox(
                            width: 80,
                            child: Text(
                              '[${widget.field.begin.toString().padLeft(3, '0')}-${widget.field.end.toString().padLeft(3, '0')}]',
                              style: TextStyle(
                                fontSize: 13,
                                color: lineColor,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Label (descrição) em negrito
                          Expanded(
                            child: Text(
                              widget.field.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: lineColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Tipo de input
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getInputTypeLabel(),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Linha 2: TextField inline
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: _validateInRealTime,
                              inputFormatters: _getInputFormatters(),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: _isValid ? AppColors.primaryPurple : AppColors.alertRed,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: _isValid ? AppColors.primaryPurple : AppColors.alertRed,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(
                                    color: _isValid ? AppColors.primaryPurple : AppColors.alertRed,
                                    width: 2,
                                  ),
                                ),
                                hintText: 'Editar valor',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.mediumGray,
                                    ),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: lineColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          
                          // Contador
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              '${_controller.text.length}/$_expectedLength',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isValid ? AppColors.neonGreen : AppColors.alertRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Linha 3: Mensagem de erro (se houver)
                      if (!widget.field.valid && widget.field.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.alertRed.withOpacity(0.1),
                              border: Border.all(
                                color: AppColors.alertRed.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.alertRed,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.field.errorMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.alertRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      // Posição
                      SizedBox(
                        width: 80,
                        child: Text(
                          '[${widget.field.begin.toString().padLeft(3, '0')}-${widget.field.end.toString().padLeft(3, '0')}]',
                          style: TextStyle(
                            fontSize: 13,
                            color: lineColor,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Label (descrição) em negrito
                      SizedBox(
                        width: 200,
                        child: Text(
                          widget.field.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: lineColor,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Valor
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            widget.field.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: lineColor,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      
                      // Ícone final
                      if (!widget.field.valid)
                        Icon(
                          Icons.error,
                          color: AppColors.alertRed,
                          size: 16,
                        )
                      else
                        Icon(
                          Icons.edit,
                          color: AppColors.mediumGray,
                          size: 16,
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
