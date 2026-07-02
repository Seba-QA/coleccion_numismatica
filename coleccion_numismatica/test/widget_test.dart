// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coleccion_numismatica/pantalla_crear_catalogo.dart';

void main() {
  testWidgets('al activar lista oficial se muestra la sección de elementos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaCrearCatalogo()));

    expect(find.text('Agregar elemento'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(find.text('Agregar elemento'), findsOneWidget);
  });
}
