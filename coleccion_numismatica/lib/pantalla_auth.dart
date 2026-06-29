import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'servicio_auth.dart';
import 'pantalla_principal.dart';

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
  int _intentosFallidos = 0;
  bool _cuentaBloqueada = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLogin && _cuentaBloqueada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La cuenta está bloqueada tras varios intentos fallidos. Usa restablecer contraseña o inténtalo más tarde.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isLinking) {
        final credential = EmailAuthProvider.credential(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        try {
          await _auth.linkAnonymousAccount(credential);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cuenta vinculada correctamente.')),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
              (route) => false,
            );
          }
          return;
        } on FirebaseAuthException catch (e) {
          if (mounted) setState(() => _isLoading = false);
          String mensaje;
          switch (e.code) {
            case 'invalid-credential':
            case 'wrong-password':
              mensaje =
                  'Credenciales incorrectas. Verifica tu email y contraseña.';
              break;
            case 'provider-already-linked':
              mensaje = 'Esta cuenta ya está vinculada a otro usuario.';
              break;
            case 'credential-already-in-use':
              mensaje = 'Este correo ya se está usando en otra cuenta.';
              break;
            default:
              mensaje = 'Error al vincular: ${e.message}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

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

      if (mounted) {
        _intentosFallidos = 0;
        _cuentaBloqueada = false;
        // Usamos pushReplacement para evitar pantalla negra
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe una cuenta con este correo electrónico';
          break;
        case 'wrong-password':
          _intentosFallidos++;
          if (_intentosFallidos >= 4) {
            _cuentaBloqueada = true;
            mensaje =
                'Contraseña incorrecta. Tu cuenta ha sido bloqueada tras 4 intentos fallidos.';
          } else {
            mensaje =
                'Contraseña incorrecta. Te quedan ${4 - _intentosFallidos} intentos.';
          }
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
        case 'too-many-requests':
          _cuentaBloqueada = true;
          mensaje =
              'Tu cuenta ha sido bloqueada tras varios intentos fallidos. Restablece la contraseña para recuperarla.';
          break;
        case 'invalid-credential':
          _intentosFallidos++;
          if (_intentosFallidos >= 4) {
            _cuentaBloqueada = true;
            mensaje =
                'Tu cuenta ha sido bloqueada tras varios intentos fallidos. Restablece la contraseña para recuperarla.';
          } else {
            mensaje =
                'Credenciales incorrectas. Verifica tu email y contraseña. Te quedan ${4 - _intentosFallidos} intentos.';
          }
          break;
        default:
          mensaje = 'Error al iniciar sesión: ${e.message}';
      }
      if (mounted) setState(() => _isLoading = false);
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (widget.isLinking) {
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
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
            (route) => false,
          );
        }
        return;
      }

      final user = await _auth.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PantallaPrincipal()),
          (route) => false,
        );
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      String mensaje;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          mensaje =
              'Esta cuenta de Google ya está registrada con otro método. Inicia sesión con tu email y contraseña.';
          break;
        case 'credential-already-in-use':
          mensaje = 'Esta cuenta de Google ya está vinculada a otro usuario.';
          break;
        case 'network-request-failed':
          mensaje = 'No hay conexión a internet. Verifica tu red.';
          break;
        case 'popup-closed-by-user':
          mensaje = 'Se canceló el inicio de sesión con Google.';
          break;
        default:
          mensaje = 'Error con Google: ${e.message ?? 'Inténtalo de nuevo.'}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo completar el inicio de sesión con Google.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _mostrarDialogoRestablecer() async {
    final emailController = TextEditingController(
      text: _emailController.text, // precargar el email actual si existe
    );

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // ← Oscurece el fondo de la pantalla
      builder:
          (context) => AlertDialog(
            backgroundColor:
                Theme.of(context).colorScheme.surface, // ← Fondo sólido
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            title: const Text('Restablecer contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Te enviaremos un enlace a tu correo para restablecer tu contraseña.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'tu@correo.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa tu correo electrónico.'),
                      ),
                    );
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    String mensaje;
                    switch (e.code) {
                      case 'user-not-found':
                        mensaje =
                            'No existe una cuenta con ese correo electrónico.';
                        break;
                      case 'invalid-email':
                        mensaje = 'El correo electrónico no es válido.';
                        break;
                      case 'network-request-failed':
                        mensaje =
                            'No hay conexión a internet. Verifica tu red.';
                        break;
                      default:
                        mensaje = 'Error: ${e.message}';
                    }
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(mensaje),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          labelLarge: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isLinking
                ? 'Vincular cuenta'
                : (_isLogin ? 'Iniciar sesión' : 'Registrarse'),
          ),
        ),
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
                      child: Icon(
                        Icons.monetization_on,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pestañas login/registro
                  if (!widget.isLinking) ...[
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
                          _emailController.clear();
                          _passwordController.clear();
                          _confirmController.clear();
                          _intentosFallidos = 0;
                          _cuentaBloqueada = false;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.primary;
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.onPrimary;
                          }
                          return Theme.of(context).colorScheme.onSurface;
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Crea una cuenta para vincular tu colección',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),

                  // Campo email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El correo es obligatorio';
                      }
                      if (!value.contains('@')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Campo contraseña
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña es obligatoria';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  // Enlace "¿Olvidaste tu contraseña?" (solo login)
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _mostrarDialogoRestablecer,
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Campo confirmar contraseña (solo registro)
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

                  // Botón principal
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    OutlinedButton(
                      onPressed:
                          (_isLogin && _cuentaBloqueada) ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: Text(
                        widget.isLinking
                            ? 'Vincular cuenta'
                            : (_isLogin ? 'Iniciar sesión' : 'Registrarse'),
                      ),
                    ),
                  if (_isLogin && _cuentaBloqueada) ...[
                    const SizedBox(height: 12),
                    Text(
                      'La cuenta está bloqueada tras 4 intentos fallidos. Restablece la contraseña para recuperarla.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Botón Google
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _googleSignIn,
                    icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                    label: const Text('Continuar con Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón invitado
                  if (!widget.isLinking) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        try {
                          await _auth.iniciarSesionAnonimo();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const PantallaPrincipal(),
                              ),
                              (route) => false,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
