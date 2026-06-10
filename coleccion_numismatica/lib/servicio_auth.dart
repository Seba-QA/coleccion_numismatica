import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ServicioAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de cambios de usuario (útil para escuchar el estado)
  Stream<User?> get userChanges => _auth.userChanges();

  // Obtener usuario actual (no stream)
  User? get currentUser => _auth.currentUser;

  // Iniciar sesión con email y contraseña
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error signInWithEmail: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Registrar nuevo usuario con email y contraseña
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error signUpWithEmail: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error signInWithGoogle: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Vincular cuenta anónima actual con una credencial (email o google)
  Future<void> linkAnonymousAccount(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      await user.linkWithCredential(credential);
      print('Cuenta anónima vinculada con éxito');
    } else {
      throw Exception('No hay usuario anónimo o ya está vinculado');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Iniciar sesión anónimo
  Future<User?> iniciarSesionAnonimo() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error iniciarSesionAnonimo: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}