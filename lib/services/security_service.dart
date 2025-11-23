import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para manejar seguridad de la app (PIN, biometría, modo privado)
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves para almacenamiento seguro
  static const String _keySecurityEnabled = 'security_enabled';
  static const String _keyPIN = 'user_pin';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPrivateModeEnabled = 'private_mode_enabled';

  /// Verifica si el dispositivo puede usar biometría
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Error al verificar biometría: $e');
      return false;
    }
  }

  /// Obtiene los tipos de biometría disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error al obtener biometrías disponibles: $e');
      return [];
    }
  }

  /// Verifica si la seguridad está habilitada
  Future<bool> isSecurityEnabled() async {
    final value = await _secureStorage.read(key: _keySecurityEnabled);
    return value == 'true';
  }

  /// Activa o desactiva la seguridad
  Future<void> setSecurityEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _keySecurityEnabled,
      value: enabled.toString(),
    );
  }

  /// Verifica si la biometría está habilitada
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  /// Activa o desactiva la biometría
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _keyBiometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Configura un PIN
  Future<void> setPIN(String pin) async {
    await _secureStorage.write(key: _keyPIN, value: pin);
  }

  /// Obtiene el PIN almacenado (solo para verificación interna)
  Future<String?> _getPIN() async {
    return await _secureStorage.read(key: _keyPIN);
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
    await _secureStorage.delete(key: _keyPIN);
  }

  /// Autentica al usuario con biometría
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder a Streakify',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
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
    final value = await _secureStorage.read(key: _keyPrivateModeEnabled);
    return value == 'true';
  }

  /// Activa o desactiva el modo privado
  Future<void> setPrivateModeEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _keyPrivateModeEnabled,
      value: enabled.toString(),
    );
  }

  /// Resetea toda la configuración de seguridad
  Future<void> resetSecurity() async {
    await _secureStorage.deleteAll();
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
