import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_move/models/app_user.dart';
import 'package:projeto_move/services/auth_service.dart';
import '../utils/.env';

class AuthFirebaseService implements AuthService {
  static AppUser? _currentUser;
  late String userName;

  static final _userStream = Stream<AppUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : _toAppUser(user);
      if (_currentUser != null) {
        await user!.reload(); 
      }
      controller.add(_currentUser);
    }
  });

  @override
  AppUser? get currentUser {
    return _currentUser;
  }

  @override
  Stream<AppUser?> get userChanges {
    return _userStream;
  }

  @override
  Future<void> signup(
    String name,
    String email,
    String password,
  ) async {
    final auth = FirebaseAuth.instance;
    UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      //Atualizar atributos
      await credential.user?.updateDisplayName(name);

      await login(email, password);

      //Salvar usuário no BD
      _currentUser = _toAppUser(credential.user!, name);
      await _saveAppUser(_currentUser!);
    }
  }

  @override
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _saveAppUser(AppUser user) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'name': user.name,
      'email': user.email,
      'image': defaultImageUrl
    });
  }

  static AppUser _toAppUser(User user, [String? name, String? imageUrl]) {
    return AppUser(
      id: user.uid,
      name: name ?? user.displayName ?? user.email!.split('@')[0],
      email: user.email!,
    );
  }
}
