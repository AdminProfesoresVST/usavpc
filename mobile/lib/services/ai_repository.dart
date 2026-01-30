import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/service_locator/app_config_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/models/simulator_models.dart';
import 'dart:convert';

part 'ai_repository.g.dart';

@riverpod
AiRepository aiRepository(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return AiRepository(Dio(), config.netlifyFunctionsUrl, config.supabaseAnonKey);
}

class AiRepository {
  final Dio _dio;
  final String _baseUrl;
  final String _anonKey;

  AiRepository(this._dio, this._baseUrl, this._anonKey);

  Future<String> sendMessage({
    required String message, 
    required String visaType,
    String mode = 'standard', // Default to standard (Intake)
    Map<String, dynamic>? extraContext,
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) throw Exception('User not logged in');

      final token = session.accessToken;
      
      final response = await _dio.post(
        _baseUrl.endsWith('/api/chat') ? _baseUrl : '$_baseUrl/api/chat',
        data: {
          'answer': message,
          'mode': mode, // Dynamic Mode
          'locale': 'es',
          'context': {
            'visa_type': visaType,
            ...?extraContext,
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'apikey': _anonKey, 
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // The API returns { response: "...", nextStep: ... }
        return data['response'] ?? 'Error: No response text.';
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        // Try to extract backend error message
        final serverError = data is Map ? (data['error'] ?? data.toString()) : data.toString();
        final stack = data is Map ? data['stack'] : null;
        
        throw Exception('Server Error (${e.response?.statusCode}): $serverError\nStack: $stack');
      } else {
        throw Exception('Connection Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  Future<SimulatorResponse> sendSimulatorInteraction({
    required String message,
    required String visaType,
    Map<String, dynamic>? profileData,
  }) async {
    // 2. Send via Standard Chat API (Native Backend Logic)
    final rawResponse = await sendMessage(
      message: message, 
      visaType: visaType,
      mode: 'simulator', // Connect to the fixed route.ts logic
      extraContext: profileData
    );

    // 3. Parse JSON
    try {
      // Clean markdown if present (```json ... ```)
      String cleanJson = rawResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // Attempt decode
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      return SimulatorResponse(
        textToSpeak: data['consul_response'] ?? "Error processing response.",
        feedback: data['feedback'] != null ? SimulatorFeedback.fromJson(data['feedback']) : null,
      );
    } catch (e) {
      // Fallback if AI fails to output JSON
      return SimulatorResponse(
        textToSpeak: rawResponse, // Speak the raw text if parse fails
        feedback: null
      );
    }
  }
}
