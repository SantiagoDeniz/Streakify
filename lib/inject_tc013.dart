// Script temporal para inyectar datos de TC-ACT-013
// Ejecutar con: flutter run lib/inject_tc013.dart --debug

import 'package:flutter/material.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🧪 Ejecutando inyección manual de TC-ACT-013...');

  try {
    final db = DatabaseHelper();
    await db.injectTestDataTC013();

    print('✅ Inyección completada exitosamente');
    print('');
    print('Ahora puedes:');
    print('1. Cerrar esta ventana');
    print('2. Abrir la app Streakify normal');
    print('3. Buscar "Test Salto" y completarla');
  } catch (e) {
    print('❌ Error: $e');
  }
}
