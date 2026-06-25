import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../models/layout_category.dart';
import '../models/validation_result.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:9084'});

  Future<List<LayoutCategory>> getLayouts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/layouts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => LayoutCategory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load layouts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading layouts: $e');
    }
  }

  Future<ValidationResult> validateFile(
    List<int> fileBytes,
    String fileName,
    String category,
    String layout,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/validate'),
      );

      request.fields['category'] = category;
      request.fields['layout'] = layout;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      request.headers['Accept'] = 'application/json';

      var response = await request.send().timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        return ValidationResult.fromJson(json);
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Validation failed: $responseBody');
      }
    } catch (e) {
      throw Exception('Error validating file: $e');
    }
  }

  Future<Uint8List?> exportFile(ValidationResult result) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/export'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(result.toJson()),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Export failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting file: $e');
    }
  }
}
