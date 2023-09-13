import '../models/app_user.dart';
import 'auth_firebase_service.dart';

abstract class AuthService {

  AppUser? get currentUser;
  
  Stream<AppUser?> get userChanges;

  Future<void> signup(
    String name,
    String email,
    String password,
  );

  Future<void> login(
    String email,
    String password,
  );

  Future<void> logout();

  factory AuthService() {
    return AuthFirebaseService();
  }
}
