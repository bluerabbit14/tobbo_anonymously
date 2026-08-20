import 'package:Tobbo/data/datasources/sample_poll_datasource.dart';
import 'package:Tobbo/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  String _userId = SamplePollDataSource.currentUserId;

  @override
  Future<String> ensureSession() async => _userId;

  @override
  Future<void> clearSession() async {
    _userId = SamplePollDataSource.currentUserId;
  }
}
