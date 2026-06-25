import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../models/validation_result.dart';
import '../providers/validation_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class FileInfoCard extends StatelessWidget {
  final ValidationResult result;

  const FileInfoCard({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ValidationProvider>(
      builder: (context, provider, _) {
        final isValid = provider.errorCount == 0;
        
        return Card(
          elevation: 2,
          color: isValid 
              ? AppColors.lightGray.withOpacity(0.5)
              : AppColors.alertRed.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com status
                Row(
                  children: [
                    Icon(
                      isValid ? Icons.check_circle : Icons.error,
                      color: isValid 
                          ? AppColors.neonGreen 
                          : AppColors.alertRed,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isValid ? 'Arquivo Válido' : 'Arquivo Inválido',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: isValid 
                                      ? AppColors.neonGreen 
                                      : AppColors.alertRed,
                                ),
                          ),
                          Text(
                            result.fileName,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.mediumGray,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Informações compactas lado a lado
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _CompactInfo('Formato', result.format ?? 'N/A'),
                    if (result.type != null)
                      _CompactInfo('Tipo', result.type!),
                    _CompactInfo('Total de Linhas', result.totalLines.toString()),
                    _CompactInfo(
                      'Status',
                      isValid ? 'OK' : 'Erros',
                      valueColor: isValid 
                          ? AppColors.neonGreen 
                          : AppColors.alertRed,
                    ),
                    _CompactInfo(
                      'Erros Encontrados',
                      provider.errorCount.toString(),
                      valueColor: provider.errorCount > 0 
                        ? AppColors.alertRed 
                        : AppColors.neonGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Botão de ação
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final apiService = ApiService();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exportando arquivo...')),
                        );
                        
                        final fileBytes = await apiService.exportFile(result);
                        
                        if (fileBytes != null) {
                          final blob = html.Blob([fileBytes], 'application/octet-stream');
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          html.AnchorElement(href: url)
                            ..setAttribute('download', result.fileName)
                            ..click();
                          html.Url.revokeObjectUrl(url);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Arquivo ${result.fileName} exportado com sucesso!')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao exportar: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text(
                      'Exportar',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.errorCount > 0 ? AppColors.primaryPurple : AppColors.neonGreen,
                      foregroundColor: AppColors.darkBlue,
                      disabledBackgroundColor: AppColors.mediumGray,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CompactInfo(
    this.label,
    this.value, {
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
                  color: AppColors.darkBlue,
                ),
          ),
          TextSpan(
            text: value,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.darkBlue,
                ),
          ),
        ],
      ),
    );
  }
}
