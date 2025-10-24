import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'auth_service.dart';

class BillService {
  static const _base = 'https://split-pay-q4wa.onrender.com/api/v1';

  /// Upload a bill image
  static Future<Map<String, dynamic>> uploadBill({
    required File imageFile,
    required String groupId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final uri = Uri.parse('$_base/bills/upload');
      var request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['groupId'] = groupId;
      
      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'bill',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': parsed['message'] ?? 'Bill uploaded successfully',
          'expenseId': parsed['expenseId'] ?? parsed['data']?['expenseId'],
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Failed to upload bill',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Get bill details by expense ID
  static Future<Map<String, dynamic>?> getBillDetails(String expenseId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return null;
    }

    final uri = Uri.parse('$_base/bills/getBillDetails/$expenseId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final res = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);
        
        // Handle different response structures
        if (parsed is Map<String, dynamic>) {
          if (parsed['bill'] is Map<String, dynamic>) {
            return parsed['bill'] as Map<String, dynamic>;
          } else if (parsed['data'] is Map<String, dynamic>) {
            return parsed['data'] as Map<String, dynamic>;
          }
          return parsed;
        }
      }
    } catch (e) {
      print('Error fetching bill details: $e');
    }
    return null;
  }
}