import 'package:flutter/material.dart';
import '../services/security_service.dart';
import 'package:local_auth/local_auth.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final SecurityService _securityService = SecurityService();
  
  bool _securityEnabled = false;
  bool _hasPIN = false;
  bool _biometricEnabled = false;
  bool _canUseBiometrics = false;
  bool _privateModeEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    setState(() => _loading = true);
    
    final status = await _securityService.getSecurityStatus();
    
    setState(() {
      _securityEnabled = status['securityEnabled'] ?? false;
      _hasPIN = status['hasPIN'] ?? false;
      _biometricEnabled = status['biometricEnabled'] ?? false;
      _canUseBiometrics = status['canUseBiometrics'] ?? false;
      _availableBiometrics = status['availableBiometrics'] ?? [];
      _privateModeEnabled = status['privateModeEnabled'] ?? false;
      _loading = false;
    });
  }

  Future<void> _toggleSecurity(bool value) async {
    if (value && !_hasPIN) {
      // Si activa seguridad pero no tiene PIN, pedirlo
      await _setupPIN();
      return;
    }

    await _securityService.setSecurityEnabled(value);
    _loadSecurityStatus();
  }

  Future<void> _setupPIN() async {
    final pin = await _showPINDialog(isChange: false);
    if (pin == null || pin.isEmpty) return;

    if (pin.length < 4) {
      _showError('El PIN debe tener al menos 4 dígitos');
      return;
    }

    // Confirmar PIN
    final confirmPin = await _showPINDialog(isChange: false, isConfirm: true);
    if (confirmPin != pin) {
      _showError('Los PINs no coinciden');
      return;
    }

    await _securityService.setPIN(pin);
    await _securityService.setSecurityEnabled(true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN configurado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    _loadSecurityStatus();
  }

  Future<void> _changePIN() async {
    // Primero verificar PIN actual
    final currentPin = await _showPINDialog(isChange: true, isConfirm: false);
    if (currentPin == null) return;

    final isValid = await _securityService.verifyPIN(currentPin);
    if (!isValid) {
      _showError('PIN incorrecto');
      return;
    }

    // Pedir nuevo PIN
    final newPin = await _showPINDialog(isChange: false, isConfirm: false);
    if (newPin == null || newPin.isEmpty) return;

    if (newPin.length < 4) {
      _showError('El PIN debe tener al menos 4 dígitos');
      return;
    }

    // Confirmar nuevo PIN
    final confirmPin = await _showPINDialog(isChange: false, isConfirm: true);
    if (confirmPin != newPin) {
      _showError('Los PINs no coinciden');
      return;
    }

    await _securityService.setPIN(newPin);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PIN cambiado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value && !_canUseBiometrics) {
      _showError('Biometría no disponible en este dispositivo');
      return;
    }

    // Probar autenticación biométrica antes de activar
    if (value) {
      final authenticated = await _securityService.authenticateWithBiometrics();
      if (!authenticated) {
        _showError('No se pudo autenticar con biometría');
        return;
      }
    }

    await _securityService.setBiometricEnabled(value);
    _loadSecurityStatus();
  }

  Future<void> _togglePrivateMode(bool value) async {
    await _securityService.setPrivateModeEnabled(value);
    _loadSecurityStatus();
  }

  Future<String?> _showPINDialog({
    required bool isChange,
    bool isConfirm = false,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isChange
              ? '🔐 PIN Actual'
              : isConfirm
                  ? '🔐 Confirmar PIN'
                  : '🔐 Nuevo PIN',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isChange
                  ? 'Ingresa tu PIN actual:'
                  : isConfirm
                      ? 'Confirma tu PIN:'
                      : 'Crea un PIN de al menos 4 dígitos:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getBiometricTypeString(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Reconocimiento facial';
      case BiometricType.fingerprint:
        return 'Huella dactilar';
      case BiometricType.iris:
        return 'Reconocimiento de iris';
      case BiometricType.strong:
        return 'Biometría fuerte';
      case BiometricType.weak:
        return 'Biometría débil';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Seguridad'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Activar/Desactivar Seguridad
          Card(
            child: SwitchListTile(
              title: const Text(
                'Protección de la App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Requiere autenticación para abrir la app',
              ),
              value: _securityEnabled,
              onChanged: _toggleSecurity,
              secondary: Icon(
                _securityEnabled ? Icons.lock : Icons.lock_open,
                color: _securityEnabled ? Colors.green : Colors.grey,
              ),
            ),
          ),

          if (_securityEnabled) ...[
            const SizedBox(height: 24),
            const Text(
              'Métodos de Autenticación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // PIN
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.pin, color: Colors.blue),
                    title: const Text('PIN'),
                    subtitle: Text(
                      _hasPIN
                          ? 'PIN configurado'
                          : 'No hay PIN configurado',
                    ),
                    trailing: _hasPIN
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _changePIN,
                            tooltip: 'Cambiar PIN',
                          )
                        : null,
                  ),
                  if (!_hasPIN)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: _setupPIN,
                        icon: const Icon(Icons.add),
                        label: const Text('Configurar PIN'),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Biometría
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Autenticación Biométrica'),
                    subtitle: Text(
                      _canUseBiometrics
                          ? 'Usar huella/face ID para desbloquear'
                          : 'No disponible en este dispositivo',
                    ),
                    value: _biometricEnabled,
                    onChanged: _canUseBiometrics ? _toggleBiometric : null,
                    secondary: Icon(
                      Icons.fingerprint,
                      color: _canUseBiometrics ? Colors.purple : Colors.grey,
                    ),
                  ),
                  if (_availableBiometrics.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Métodos disponibles:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ..._availableBiometrics.map(
                            (type) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '• ${_getBiometricTypeString(type)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text(
            'Privacidad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Modo Privado
          Card(
            child: SwitchListTile(
              title: const Text('Modo Privado'),
              subtitle: const Text(
                'Oculta actividades marcadas como privadas',
              ),
              value: _privateModeEnabled,
              onChanged: _togglePrivateMode,
              secondary: Icon(
                _privateModeEnabled ? Icons.visibility_off : Icons.visibility,
                color: _privateModeEnabled ? Colors.orange : Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Información
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Información',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• La protección de la app requiere autenticación cada vez que abres Streakify\n'
                    '• Puedes usar PIN, biometría o ambos\n'
                    '• El modo privado oculta actividades sensibles de la vista principal\n'
                    '• Tus datos de seguridad se almacenan de forma segura en el dispositivo',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
