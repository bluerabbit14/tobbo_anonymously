abstract class SessionRepository {
  Future<String> ensureSession();

  Future<void> clearSession();
}
