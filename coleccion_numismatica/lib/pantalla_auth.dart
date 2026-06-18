import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'servicio_auth.dart';
import 'main.dart'; // ← Importante para usar ListaMonedas

class PantallaAuth extends StatefulWidget {
  final bool isLinking;
  const PantallaAuth({super.key, this.isLinking = false});

  @override
  State<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends State<PantallaAuth> {
  final ServicioAuth _auth = ServicioAuth();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      User? user;
      if (_isLogin) {
        user = await _auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        user = await _auth.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (widget.isLinking &&
          user != null &&
          _auth.currentUser != null &&
          _auth.currentUser!.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await _auth.linkAnonymousAccount(credential);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta vinculada correctamente.')),
        );
      }

      if (mounted) {
        // Usamos pushReplacement para evitar pantalla negra
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ListaMonedas()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe una cuenta con este correo electrónico';
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta. Por favor, inténtalo de nuevo';
          break;
        case 'email-already-in-use':
          mensaje =
              'Este correo electrónico ya está registrado. ¿Quieres iniciar sesión?';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es muy débil. Usa al menos 6 caracteres';
          break;
        case 'invalid-email':
          mensaje = 'El formato del correo electrónico no es válido';
          break;
        case 'user-disabled':
          mensaje = 'Esta cuenta ha sido deshabilitada. Contacta con soporte';
          break;
        case 'operation-not-allowed':
          mensaje =
              'El inicio de sesión con email/contraseña no está habilitado';
          break;
        default:
          mensaje = 'Error al iniciar sesión: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isLinking) {
        // Vinculación con cuenta anónima
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.linkAnonymousAccount(credential);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta de Google vinculada correctamente.'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ListaMonedas()),
          );
        }
      } else {
        // Inicio de sesión normal con Google
        User? user = await _auth.signInWithGoogle();
        if (user != null && mounted) {
          // Pequeño retraso para asegurar estado (opcional)
          await Future.delayed(const Duration(milliseconds: 100));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ListaMonedas()),
          );
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error en Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error al iniciar sesión con Google. Verifica tu conexión e inténtalo de nuevo.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo provisional
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'N',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'login',
                      label: Text('Iniciar sesión'),
                    ),
                    ButtonSegment(
                      value: 'registro',
                      label: Text('Registrarse'),
                    ),
                  ],
                  selected: {_isLogin ? 'login' : 'registro'},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _isLogin = selection.first == 'login';
                      _confirmController.clear();
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) => value!.contains('@') ? null : 'Email inválido',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator:
                      (value) =>
                          value!.length >= 6 ? null : 'Mínimo 6 caracteres',
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ],
                  ),
                ],
                if (!_isLogin) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            value == _passwordController.text
                                ? null
                                : 'Las contraseñas no coinciden',
                  ),
                ],
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  OutlinedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: Text(_isLogin ? 'Ingresar' : 'Registrarse'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _googleSignIn,
                  icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                  label: const Text('Continuar con Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await _auth.iniciarSesionAnonimo();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListaMonedas(),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'No se pudo ingresar como invitado. Inténtalo de nuevo.',
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: const Text('Seguir como invitado →'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
