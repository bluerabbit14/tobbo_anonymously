abstract final class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'https://tobbo-anonymously.onrender.com';

  static String get baseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    final value = fromDefine.isEmpty ? _defaultBaseUrl : fromDefine;
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
