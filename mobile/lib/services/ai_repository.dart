import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/service_locator/app_config_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/models/simulator_models.dart';
import 'dart:convert';

part 'ai_repository.g.dart';

@riverpod
AiRepository aiRepository(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  ));
  return AiRepository(dio, config.netlifyFunctionsUrl, config.supabaseAnonKey);
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

  /// IAMI: Intelligent Migration Assistant - Intake Mode
  /// Returns structured response with optional suggestion for user consent
  Future<IAMIResponse> sendIntakeMessage({
    required String? message, // Null for first interaction
    required String formType,
    Map<String, dynamic>? existingData,
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) throw Exception('User not logged in');

      final token = session.accessToken;
      
      final response = await _dio.post(
        _baseUrl.endsWith('/api/chat') ? _baseUrl : '$_baseUrl/api/chat',
        data: {
          'answer': message,
          'mode': 'intake', // IAMI Mode
          'locale': 'es',
          'context': {
            'form_type': formType,
            ...?existingData,
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
        return IAMIResponse.fromJson(data);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final serverError = e.response?.data?.toString() ?? e.message;
      throw Exception('IAMI Error: $serverError');
    }
  }
}

/// IAMI Response Model
class IAMIResponse {
  final String message;
  final List<String>? skippedFields;
  final IAMISuggestion? suggestion;
  final bool requiresConsent;
  final Map<String, dynamic>? nextStep;

  IAMIResponse({
    required this.message,
    this.skippedFields,
    this.suggestion,
    this.requiresConsent = false,
    this.nextStep,
  });

  factory IAMIResponse.fromJson(Map<String, dynamic> json) {
    return IAMIResponse(
      message: json['response'] ?? 'Error: No response',
      skippedFields: (json['skipped_fields'] as List?)?.cast<String>(),
      suggestion: json['suggestion'] != null 
          ? IAMISuggestion.fromJson(json['suggestion']) 
          : null,
      requiresConsent: json['requiresConsent'] ?? false,
      nextStep: json['nextStep'] as Map<String, dynamic>?,
    );
  }
}

/// IAMI Suggestion (Proactive Refinement)
class IAMISuggestion {
  final String original;
  final String improved;
  final String reason;

  IAMISuggestion({
    required this.original,
    required this.improved,
    required this.reason,
  });

  factory IAMISuggestion.fromJson(Map<String, dynamic> json) {
    return IAMISuggestion(
      original: json['original'] ?? '',
      improved: json['improved'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

