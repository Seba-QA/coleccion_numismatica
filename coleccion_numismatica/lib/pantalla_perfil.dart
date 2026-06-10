import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'servicio_auth.dart';
import 'pantalla_auth.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final ServicioAuth _auth = ServicioAuth();
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }

  Future<void> _cerrarSesion() async {
    await _auth.signOut();  // o _auth.cerrarSesion() según tu método real
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  String _obtenerMetodoAutenticacion() {
    // Si es anónimo, devolver 'anonimo' directamente
    if (_user.isAnonymous) {
      return 'anonimo';
    }
    // Si no es anónimo, obtener el proveedor de forma segura
    if (_user.providerData.isNotEmpty) {
      return _user.providerData.first.providerId;
    }
    return 'desconocido';
  }

  String _metodoString(String provider) {
    switch (provider) {
      case 'google.com':
        return 'Google';
      case 'password':
        return 'Email/Contraseña';
      case 'anonimo':
        return 'Invitado (anónimo)';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _user.email ?? 'Sin email';
    final providerId = _obtenerMetodoAutenticacion();
    final metodoString = _metodoString(providerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 50, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(email),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Método de autenticación'),
                subtitle: Text(metodoString),
              ),
            ),
            if (_user.isAnonymous) ...[
              const SizedBox(height: 20),
              const Card(
                color: Colors.amberAccent,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Estás en modo invitado. Tus datos no están vinculados a una cuenta y podrías perderlos al desinstalar la app.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaAuth(isLinking: true)),
                  );
                },
                icon: const Icon(Icons.link),
                label: const Text('Vincular cuenta (Registrarse o Iniciar sesión)'),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _cerrarSesion,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}