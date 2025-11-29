// TODO: Agregar paquetes faltantes a pubspec.yaml:
// - local_auth: ^2.1.0
// - flutter_secure_storage: ^9.0.0
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar seguridad de la app (PIN, biometría, modo privado)
/// NOTA: Temporalmente usando SharedPreferences en lugar de FlutterSecureStorage
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // final LocalAuthentication _localAuth = LocalAuthentication();
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves para almacenamiento seguro
  static const String _keySecurityEnabled = 'security_enabled';
  static const String _keyPIN = 'user_pin';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPrivateModeEnabled = 'private_mode_enabled';

  /// Verifica si el dispositivo puede usar biometría
  Future<bool> canCheckBiometrics() async {
    try {
      // return await _localAuth.canCheckBiometrics;
      return false; // Retornar false hasta que se agregue el paquete local_auth
    } catch (e) {
      print('Error al verificar biometría: $e');
      return false;
    }
  }

  /// Obtiene los tipos de biometría disponibles
  Future<List<String>> getAvailableBiometrics() async {
    try {
      // return await _localAuth.getAvailableBiometrics();
      return []; // Retornar vacío hasta que se agregue el paquete local_auth
    } catch (e) {
      print('Error al obtener biometrías disponibles: $e');
      return [];
    }
  }

  /// Verifica si la seguridad está habilitada
  Future<bool> isSecurityEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySecurityEnabled) ?? false;
  }

  /// Activa o desactiva la seguridad
  Future<void> setSecurityEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySecurityEnabled, enabled);
  }

  /// Verifica si la biometría está habilitada
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Activa o desactiva la biometría
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Configura un PIN
  Future<void> setPIN(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPIN, pin);
  }

  /// Obtiene el PIN almacenado (solo para verificación interna)
  Future<String?> _getPIN() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPIN);
  }

  /// Verifica si hay un PIN configurado
  Future<bool> hasPIN() async {
    final pin = await _getPIN();
    return pin != null && pin.isNotEmpty;
  }

  /// Verifica si un PIN es correcto
  Future<bool> verifyPIN(String pin) async {
    final storedPIN = await _getPIN();
    return storedPIN == pin;
  }

  /// Elimina el PIN
  Future<void> removePIN() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPIN);
  }

  /// Autentica al usuario con biometría
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      // TODO: Implementar cuando se agregue el paquete local_auth
      // final authenticated = await _localAuth.authenticate(
      //   localizedReason: 'Autentícate para acceder a Streakify',
      //   options: const AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: true,
      //   ),
      // );
      // return authenticated;

      return false; // Retornar false hasta que se implemente
    } catch (e) {
      print('Error en autenticación biométrica: $e');
      return false;
    }
  }

  /// Autentica al usuario (biometría o PIN según configuración)
  Future<bool> authenticate({String? pin}) async {
    final securityEnabled = await isSecurityEnabled();
    if (!securityEnabled) return true; // Si no hay seguridad, permitir acceso

    final biometricEnabled = await isBiometricEnabled();

    // Intentar biometría primero si está habilitada
    if (biometricEnabled) {
      final canUseBiometric = await canCheckBiometrics();
      if (canUseBiometric) {
        final authenticated = await authenticateWithBiometrics();
        if (authenticated) return true;
      }
    }

    // Si biometría falló o no está disponible, verificar PIN
    if (pin != null) {
      return await verifyPIN(pin);
    }

    return false;
  }

  /// Verifica si el modo privado está habilitado
  Future<bool> isPrivateModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrivateModeEnabled) ?? false;
  }

  /// Activa o desactiva el modo privado
  Future<void> setPrivateModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivateModeEnabled, enabled);
  }

  /// Resetea toda la configuración de seguridad
  Future<void> resetSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySecurityEnabled);
    await prefs.remove(_keyPIN);
    await prefs.remove(_keyBiometricEnabled);
    await prefs.remove(_keyPrivateModeEnabled);
  }

  /// Obtiene un resumen del estado de seguridad
  Future<Map<String, dynamic>> getSecurityStatus() async {
    return {
      'securityEnabled': await isSecurityEnabled(),
      'hasPIN': await hasPIN(),
      'biometricEnabled': await isBiometricEnabled(),
      'canUseBiometrics': await canCheckBiometrics(),
      'availableBiometrics': await getAvailableBiometrics(),
      'privateModeEnabled': await isPrivateModeEnabled(),
    };
  }
}
