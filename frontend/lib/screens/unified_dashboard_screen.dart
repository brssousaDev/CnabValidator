import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/layout_category.dart';
import '../services/api_service.dart';
import '../providers/validation_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/file_info_card.dart';
import '../widgets/record_block.dart';

class UnifiedDashboardScreen extends StatefulWidget {
  const UnifiedDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedDashboardScreen> createState() => _UnifiedDashboardScreenState();
}

class _UnifiedDashboardScreenState extends State<UnifiedDashboardScreen> {
  late ApiService apiService;
  List<LayoutCategory> categories = [];
  bool isLoadingCategories = false;
  bool isValidating = false;

  String? selectedCategory;
  String? selectedLayout;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoadingCategories = true);
    try {
      final cats = await apiService.getLayouts();
      setState(() => categories = cats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar categorias: $e')),
      );
    } finally {
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _pickAndValidateFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['rem', 'ret', 'txt'],
      );

      if (result != null && selectedCategory != null && selectedLayout != null) {
        setState(() => isValidating = true);

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        final validationResult = await apiService.validateFile(
          bytes,
          fileName,
          selectedCategory!,
          selectedLayout!,
        );

        if (mounted) {
          Provider.of<ValidationProvider>(context, listen: false)
              .loadResult(validationResult);
          
          // Scroll para a seção de resultado
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      } else if (selectedCategory == null || selectedLayout == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecione categoria e layout')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao validar arquivo: $e')),
      );
    } finally {
      setState(() => isValidating = false);
    }
  }

  void _newValidation() {
    setState(() {
      selectedCategory = null;
      selectedLayout = null;
    });
    Provider.of<ValidationProvider>(context, listen: false).clearResult();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableLayouts = selectedCategory != null
        ? categories
            .firstWhere((c) => c.category == selectedCategory)
            .layouts
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CNAB Validador'),
      ),
      body: Consumer<ValidationProvider>(
        builder: (context, provider, _) {
          return Center(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // ========== SEÇÃO SUPERIOR (Seleção e Importação) ==========
                    Column(
                      children: [
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          hint: const Text('Selecione uma categoria'),
                          isExpanded: true,
                          items: categories
                              .map((c) => DropdownMenuItem(
                                    value: c.category,
                                    child: Text(c.category),
                                  ))
                              .toList(),
                          onChanged: provider.result != null
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedCategory = value;
                                    selectedLayout = null;
                                  });
                                },
                          decoration: InputDecoration(
                            labelText: 'Categoria de Layout',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.category),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Layout Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedLayout,
                          hint: const Text('Selecione um layout'),
                          isExpanded: true,
                          disabledHint: const Text('Selecione uma categoria primeiro'),
                          items: availableLayouts
                              .map((l) => DropdownMenuItem(
                                    value: l,
                                    child: Text(l),
                                  ))
                              .toList(),
                          onChanged: selectedCategory != null && provider.result == null
                              ? (value) {
                                  setState(() => selectedLayout = value);
                                }
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Layout CNAB',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Import Button + New Validation Button (Side by Side)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Import Button
                            SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: (selectedLayout != null && !isValidating && provider.result == null)
                                    ? _pickAndValidateFile
                                    : null,
                                icon: isValidating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              AppColors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file, size: 18),
                                label: Text(
                                  isValidating
                                      ? 'Validando...'
                                      : 'Importar',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  disabledBackgroundColor: AppColors.mediumGray,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // New Validation Button (Shows after result)
                            if (provider.result != null)
                              SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: _newValidation,
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  label: const Text(
                                    'Novo',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neonGreen,
                                    foregroundColor: AppColors.darkBlue,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),

                    // ========== SEÇÃO INFERIOR (Resultado e Edição) ==========
                    if (provider.result != null)
                      Column(
                        children: [
                          // File Info Card
                          FileInfoCard(result: provider.result!),
                          const SizedBox(height: 20),

                          // Records List
                          if (provider.result!.records.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'Nenhum registro foi processado',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: AppColors.primaryPurple,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Visualização de Registros',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightGray,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${provider.result!.records.length}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: AppColors.primaryPurple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...provider.result!.records.map((record) {
                                  final hasErrors = record.fields
                                      .any((field) => !field.valid);

                                  return RecordBlock(
                                    record: record,
                                    onFieldEdit:
                                        (lineNumber, fieldIndex, newValue) {
                                      provider.updateField(
                                        lineNumber,
                                        fieldIndex,
                                        newValue,
                                      );
                                    },
                                    hasErrors: hasErrors,
                                  );
                                }).toList(),
                              ],
                            ),
                          const SizedBox(height: 40),
                        ],
                      )
                    else
                      // Info Card quando não há validação
                      Card(
                        color: AppColors.lightGray,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primaryPurple,
                                size: 36,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Como usar:',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '1. Selecione a categoria de layout\n'
                                '2. Escolha o layout específico\n'
                                '3. Clique para importar arquivo CNAB\n'
                                '4. Visualize erros e edite os campos\n'
                                '5. Exporte o arquivo corrigido',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
