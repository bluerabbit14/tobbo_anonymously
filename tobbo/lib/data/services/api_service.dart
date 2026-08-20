import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:Tobbo/core/config/api_config.dart';
import 'package:Tobbo/core/error/api_exception.dart';
import 'package:Tobbo/data/models/api_dtos.dart';

class AuthTokenStore {
  String? token;
  DateTime? expiresAt;

  bool get isValid {
    final current = token;
    final expiry = expiresAt;
    if (current == null || current.isEmpty || expiry == null) return false;
    return expiry.isAfter(DateTime.now().toUtc().add(const Duration(minutes: 1)));
  }

  void clear() {
    token = null;
    expiresAt = null;
  }
}

class ApiService {
  ApiService({
    required AuthTokenStore tokenStore,
    http.Client? client,
    String? baseUrl,
  })  : _tokenStore = tokenStore,
        _client = client ?? http.Client(),
        _baseUrl = _normalize(baseUrl ?? ApiConfig.baseUrl);

  final AuthTokenStore _tokenStore;
  final http.Client _client;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 25);

  Future<void> Function()? refreshToken;

  static String _normalize(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  Future<AnonymousTokenResponse> createAnonymous() async {
    final json = await _sendJson(
      'POST',
      '/api/v1/anonymous',
      auth: false,
    );
    return AnonymousTokenResponse.fromJson(json);
  }

  Future<CreatePollResponse> createPoll({
    required String question,
    required List<String> options,
    required bool allowNearby,
    double? latitude,
    double? longitude,
  }) async {
    final json = await _sendJson(
      'POST',
      '/api/v1/polls',
      body: {
        'question': question,
        'options': options,
        'allowNearby': allowNearby,
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
    );
    return CreatePollResponse.fromJson(json);
  }

  Future<List<NearbyPollItemResponse>> getNearbyPolls({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final json = await _sendJson(
      'GET',
      '/api/v1/polls/nearby',
      query: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radiusKm': radiusKm.toString(),
      },
    );
    final items = json['items'] as List<dynamic>? ?? const [];
    return [
      for (final item in items) NearbyPollItemResponse.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<PollDetailResponse> getPoll({
    required String publicCode,
    double? latitude,
    double? longitude,
  }) async {
    final json = await _sendJson(
      'GET',
      '/api/v1/polls/${Uri.encodeComponent(publicCode)}',
      query: {
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      },
    );
    return PollDetailResponse.fromJson(json);
  }

  Future<void> vote({required String publicCode, required String optionId}) async {
    await _send(
      'POST',
      '/api/v1/polls/${Uri.encodeComponent(publicCode)}/votes',
      body: {'optionId': optionId},
    );
  }

  Future<PollResultsResponse> getResults(String publicCode) async {
    final json = await _sendJson(
      'GET',
      '/api/v1/polls/${Uri.encodeComponent(publicCode)}/results',
    );
    return PollResultsResponse.fromJson(json);
  }

  Future<List<MyPollItemResponse>> getMyPolls() async {
    final json = await _sendJson('GET', '/api/v1/me/polls');
    final items = json['items'] as List<dynamic>? ?? const [];
    return [
      for (final item in items) MyPollItemResponse.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<MyVoteItemResponse>> getMyVotes() async {
    final json = await _sendJson('GET', '/api/v1/me/votes');
    final items = json['items'] as List<dynamic>? ?? const [];
    return [
      for (final item in items) MyVoteItemResponse.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final response = await _send(method, path, body: body, query: query, auth: auth);
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const ApiException('Something went wrong.');
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
    bool retried = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = _tokenStore.token;
    if (auth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    late http.Response response;
    try {
      final encoded = body == null ? null : jsonEncode(body);
      response = switch (method) {
        'GET' => await _client.get(uri, headers: headers).timeout(_timeout),
        'POST' => await _client.post(uri, headers: headers, body: encoded).timeout(_timeout),
        _ => throw ArgumentError.value(method, 'method'),
      };
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unable to reach Tobbo. Check your connection and try again.');
    }

    if (auth && response.statusCode == 401 && !retried && refreshToken != null) {
      await refreshToken!();
      return _send(method, path, body: body, query: query, auth: auth, retried: true);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    throw _errorFrom(response);
  }

  ApiException _errorFrom(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] as String?;
        final code = decoded['code'] as String?;
        if (message != null && message.isNotEmpty) {
          return ApiException(message, code: code);
        }
      }
    } catch (_) {}
    return const ApiException('Something went wrong.');
  }
}
