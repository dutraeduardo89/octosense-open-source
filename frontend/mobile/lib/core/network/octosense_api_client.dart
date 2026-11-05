// ignore_for_file: use_null_aware_elements

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/google_health/domain/entities/google_health_link.dart';
import '../../features/readings/domain/entities/daily_summary.dart';
import '../../features/readings/domain/entities/health_reading.dart';

class OctoSenseApiClient {
  OctoSenseApiClient({
    this.baseUrl = 'http://localhost:5137',
    http.Client? client,
  }) : _httpClient = client ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      // Header exigido pelo ngrok free tier pra pular a página
      // de aviso "You are about to visit..." que ele mostra pra browsers.
      // Sem isso, o app recebe HTML em vez de JSON.
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // 1. READINGS
  Future<List<HealthReading>> getReadings(String userId) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/readings?userId=$userId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => HealthReading.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Falha ao carregar leituras: ${response.statusCode}');
  }

  Future<HealthReading> createReading({
    required String userId,
    required String deviceId,
    required String deviceSource,
    required DateTime recordedAt,
    double? heartRateBpm,
    int? steps,
    Duration? sleepDuration,
    double? oxygenSaturationPercent,
    double? activeCaloriesKcal,
    double? totalCaloriesKcal,
    String? syncMode,
    int? batteryLevel,
    String? externalId,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{
      'userId': userId,
      'deviceId': deviceId,
      'deviceSource': deviceSource,
      'recordedAt': recordedAt.toIso8601String(),
      if (heartRateBpm != null) 'heartRateBpm': heartRateBpm,
      if (steps != null) 'steps': steps,
      if (sleepDuration != null) 'sleepDuration': sleepDuration.toString(),
      if (oxygenSaturationPercent != null)
        'oxygenSaturationPercent': oxygenSaturationPercent,
      if (activeCaloriesKcal != null) 'activeCaloriesKcal': activeCaloriesKcal,
      if (totalCaloriesKcal != null) 'totalCaloriesKcal': totalCaloriesKcal,
      if (syncMode != null) 'syncMode': syncMode,
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      if (externalId != null) 'externalId': externalId,
    };

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/readings'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return HealthReading.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      'Falha ao criar leitura: ${response.statusCode} - ${response.body}',
    );
  }

  // 2. DASHBOARD & SUMMARY
  Future<List<DailySummary>> getDailySummary({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final headers = await _getHeaders();
    final fromStr = _formatDate(from);
    final toStr = _formatDate(to);

    final response = await _httpClient.get(
      Uri.parse(
        '$baseUrl/readings/summary?userId=$userId&from=$fromStr&to=$toStr',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded['summaries'] as List<dynamic>? ?? <dynamic>[]);
      return list
          .map((json) => DailySummary.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Falha ao carregar resumo: ${response.statusCode}');
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<String> getWeeklyFeedback() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/readings/feedback?period=7d'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['insight'] as String? ?? '').trim();
    }
    throw Exception('Falha ao gerar insight: ${response.statusCode}');
  }

  // 3. GOOGLE HEALTH LINK
  Future<Uri> fetchGoogleHealthAuthorizationUri() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/auth/google/health/uri'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Uri.parse(
        (data['uri'] ??
                data['authorizationUri'] ??
                '$baseUrl/auth/google/health')
            as String,
      );
    }
    return Uri.parse('$baseUrl/auth/google/health?userId=demo');
  }

  Future<GoogleHealthLink> fetchActiveGoogleHealthLink() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/auth/google/health/status'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return GoogleHealthLink(
        userId: (data['userId'] ?? 'unknown') as String,
        linked: (data['linked'] ?? false) as bool,
      );
    }
    throw Exception('Falha ao verificar vínculo: ${response.statusCode}');
  }

  Future<void> unlinkGoogleHealth(String userId) async {
    final headers = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/google/health/unlink'),
      headers: headers,
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao desvincular: ${response.statusCode}');
    }
  }

  // 4. HEALTH CHECK
  Future<({bool healthy, int readings, String? userId})> checkHealth() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/health'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (
        healthy: (data['healthy'] ?? true) as bool,
        readings: (data['readings'] ?? 0) as int,
        userId: data['userId'] as String?,
      );
    }
    return (healthy: false, readings: 0, userId: null);
  }

  // 4.5. DELETE ACCOUNT
  /// Apaga a conta + readings + refresh tokens no backend.
  ///
  /// Idempotente: retorna 204 mesmo se já foi deletada.
  /// Se der erro, lança Exception.
  Future<void> deleteAccount() async {
    final headers = await _getHeaders();
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl/auth/me'),
      headers: headers,
    );

    // 204 = sucesso. 404 = já deletada (aceita como sucesso).
    if (response.statusCode != 204 && response.statusCode != 404) {
      throw Exception(
        'Falha ao excluir conta: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // 5. RAW (para HealthSyncService)
  Future<http.Response> postRaw(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    return _httpClient.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
