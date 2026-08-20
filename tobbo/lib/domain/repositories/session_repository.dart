abstract class SessionRepository {
  bool get hasStoredIdentity;

  Future<String> ensureSession();

  Future<String> refreshSession();

  Future<void> clearSession();
}
