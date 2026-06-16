import 'package:flutter/material.dart';
import 'main.dart';
import 'pantalla_perfil.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceSeleccionado = 0; // 0 = Colección, 1 = Perfil

  // Lista de páginas (widgets)
  final List<Widget> _paginas = [
    const ListaMonedas(),
    const PantallaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_indiceSeleccionado == 0 ? 'Mi Colección' : 'Mi Perfil'),
      ),
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: _paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        onTap: (index) {
          setState(() {
            _indiceSeleccionado = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Mi Colección',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        type: BottomNavigationBarType.fixed, // para que no haya animación de desplazamiento
      ),
    );
  }
}