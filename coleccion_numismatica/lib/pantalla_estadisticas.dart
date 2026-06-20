import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class PantallaEstadisticas extends StatelessWidget {
  const PantallaEstadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    String _normalizarTexto(String texto) {
      // Convertir a minúsculas
      String normalizado = texto.toLowerCase().trim();

      // Eliminar tildes
      final Map<String, String> reemplazos = {
        'á': 'a',
        'é': 'e',
        'í': 'i',
        'ó': 'o',
        'ú': 'u',
        'Á': 'a',
        'É': 'e',
        'Í': 'i',
        'Ó': 'o',
        'Ú': 'u',
      };
      normalizado =
          normalizado.split('').map((char) {
            return reemplazos[char] ?? char;
          }).join();

      // Eliminar caracteres especiales (puntos, comas, paréntesis, etc.)
      normalizado = normalizado.replaceAll(RegExp(r'[^a-z0-9 ]'), '');

      // Eliminar espacios múltiples y al inicio/final
      normalizado = normalizado.replaceAll(RegExp(r'\s+'), ' ').trim();

      return normalizado;
    }

    String _capitalizar(String texto) {
      final textoNormalizado = _normalizarTexto(texto);
      if (textoNormalizado.isEmpty) return textoNormalizado;
      return textoNormalizado[0].toUpperCase() + textoNormalizado.substring(1).toLowerCase();
    }

    Map<String, String> _nombreOriginalPais = {};

    final Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('monedas')
            .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no hay datos en tu colección.\nAgrega algunas monedas o billetes para ver estadísticas.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<Map<String, String>> monedas =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final moneda = Map<String, String>.from(data);
                moneda['_id'] = doc.id;
                return moneda;
              }).toList();

          final totalPiezas = monedas.length;
          final totalMonedas =
              monedas.where((m) => m['tipo'] == 'moneda').length;
          final totalBilletes =
              monedas.where((m) => m['tipo'] == 'billete').length;

          final paises =
              monedas
                  .map((m) => m['pais'] ?? '')
                  .where((p) => p.isNotEmpty)
                  .toSet();
          final totalPaises = paises.length;

          final Map<String, int> conteoPais = {};
          _nombreOriginalPais = {};
          for (var moneda in monedas) {
            final paisRaw = moneda['pais'] ?? 'Desconocido';
            final paisNormalizado = _normalizarTexto(paisRaw);
            // Guardar el primer nombre original que aparece para cada normalizado
            if (!_nombreOriginalPais.containsKey(paisNormalizado)) {
              _nombreOriginalPais[paisNormalizado] = paisRaw;
            }
            conteoPais[paisNormalizado] =
                (conteoPais[paisNormalizado] ?? 0) + 1;
          }
          final sortedPaises =
              conteoPais.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
          final topPaises = <String, int>{};
          for (var entry in sortedPaises.take(5)) {
            // Mostrar el nombre original (el primero que apareció)
            final nombreOriginal = _nombreOriginalPais[entry.key] ?? entry.key;
            final nombreCapitalizado = _capitalizar(nombreOriginal);
            topPaises[nombreCapitalizado] = entry.value;
          }

          final Map<int, int> conteoAnio = {};
          for (var moneda in monedas) {
            final anioStr = moneda['anio'] ?? '';
            final anio = int.tryParse(anioStr);
            if (anio != null && anio > 0) {
              final decada = (anio ~/ 10) * 10;
              conteoAnio[decada] = (conteoAnio[decada] ?? 0) + 1;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildResumenCard(
                      'Total piezas',
                      '$totalPiezas',
                      Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildResumenCard(
                      'Países',
                      '$totalPaises',
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildResumenCard(
                      'Monedas',
                      '$totalMonedas',
                      Theme.of(context).colorScheme.tertiary ?? Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildResumenCard(
                      'Billetes',
                      '$totalBilletes',
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Distribución por tipo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPieChartTipo(context, totalMonedas, totalBilletes),
                const SizedBox(height: 24),

                if (topPaises.isNotEmpty) ...[
                  const Text(
                    'Top 5 países',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildBarChartPaises(context, topPaises),
                  const SizedBox(height: 24),
                ],

                if (conteoAnio.isNotEmpty) ...[
                  const Text(
                    'Distribución por década',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildBarChartAnios(context, conteoAnio),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Métodos auxiliares ----------

  Widget _buildResumenCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartTipo(
    BuildContext context,
    int totalMonedas,
    int totalBilletes,
  ) {
    final data = [
      PieChartSectionData(
        value: totalMonedas.toDouble(),
        color: Color(0xFFC9A03D),
        title: 'Monedas',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: totalBilletes.toDouble(),
        color: Colors.green,
        title: 'Billetes',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(sections: data, sectionsSpace: 4, centerSpaceRadius: 20),
      ),
    );
  }

  Widget _buildBarChartPaises(
    BuildContext context,
    Map<String, int> topPaises,
  ) {
    final entries = topPaises.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxValue =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue + 2,
          barGroups:
              entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.value.toDouble(),
                      color: Theme.of(context).colorScheme.primary,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  // Mostrar solo números enteros (sin decimales)
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartAnios(BuildContext context, Map<int, int> topAnios) {
    final entries =
        topAnios.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxValue =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue + 3,
          barGroups:
              entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.value.toDouble(),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          Text(
                            '${entries[index].key}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 50,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}
