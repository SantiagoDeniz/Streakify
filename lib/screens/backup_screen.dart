import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  List<File> _backups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _loading = true);
    final backups = await _backupService.listBackups();
    setState(() {
      _backups = backups;
      _loading = false;
    });
  }

  Future<void> _createBackup() async {
    try {
      await _backupService.exportToFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Backup creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadBackups();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareBackup() async {
    try {
      await _backupService.shareBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📤 Compartiendo backup...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Preguntar si merge o replace
        final merge = await _showImportDialog();
        if (merge == null) return; // Usuario canceló

        final success =
            await _backupService.importFromFile(file, merge: merge);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Datos importados exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar la app
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error al importar datos'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showImportDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modo de importación'),
        content: const Text(
          '¿Cómo deseas importar los datos?\n\n'
          '• Reemplazar: Elimina todos los datos actuales\n'
          '• Combinar: Agrega solo datos nuevos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Combinar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Reemplazar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCSV() async {
    try {
      final file = await _backupService.exportToCSV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ CSV exportado: ${file.path.split('/').last}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Compartir',
              textColor: Colors.white,
              onPressed: () async {
                await Share.shareXFiles([XFile(file.path)]);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportExcel() async {
    try {
      final file = await _backupService.exportToExcel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Excel exportado: ${file.path.split('/').last}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Compartir',
              textColor: Colors.white,
              onPressed: () async {
                await Share.shareXFiles([XFile(file.path)]);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al exportar Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createEncryptedBackup() async {
    final password = await _showPasswordDialog(isImport: false);
    if (password == null || password.isEmpty) return;

    try {
      await _backupService.exportToFileEncrypted(password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Backup cifrado creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadBackups();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al crear backup cifrado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importEncryptedBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Verificar si es un backup cifrado
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        
        if (!data.containsKey('encrypted')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Este no es un backup cifrado'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final password = await _showPasswordDialog(isImport: true);
        if (password == null || password.isEmpty) return;

        final success = await _backupService.importFromFileEncrypted(file, password);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Backup cifrado importado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error: Contraseña incorrecta o archivo corrupto'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog({required bool isImport}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isImport ? '🔐 Ingresar Contraseña' : '🔐 Crear Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isImport
                  ? 'Ingresa la contraseña para descifrar el backup:'
                  : 'Crea una contraseña para cifrar el backup:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              autofocus: true,
            ),
            if (!isImport) ...[
              const SizedBox(height: 12),
              const Text(
                '⚠️ Guarda esta contraseña en un lugar seguro. No podrás recuperar el backup sin ella.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
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


  Future<void> _restoreBackup(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar restauración'),
        content: Text(
          '¿Deseas restaurar este backup?\n\n'
          'Archivo: ${file.path.split('/').last}\n\n'
          'Esto REEMPLAZARÁ todos tus datos actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _backupService.importFromFile(file, merge: false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Backup restaurado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Recargar la app
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al restaurar backup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteBackup(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Eliminar backup'),
        content: Text(
          '¿Deseas eliminar este backup?\n\n'
          'Archivo: ${file.path.split('/').last}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _backupService.deleteBackup(file);
      _loadBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Backup eliminado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showBackupInfo(File file) async {
    final info = await _backupService.getBackupInfo(file);
    if (info == null || !mounted) return;

    final metadata = info['metadata'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Información del Backup'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Nombre', info['fileName']),
              _buildInfoRow('Tamaño',
                  '${(info['fileSize'] / 1024).toStringAsFixed(2)} KB'),
              _buildInfoRow(
                'Fecha de archivo',
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(info['fileDate'] as DateTime),
              ),
              _buildInfoRow(
                'Fecha de exportación',
                DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.parse(info['exportDate'] as String)),
              ),
              _buildInfoRow('Versión', info['version']),
              const Divider(height: 24),
              const Text(
                'Contenido:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                  '📝 Actividades', metadata['totalActivities'].toString()),
              _buildInfoRow(
                  '✅ Activas', metadata['activeActivities'].toString()),
              _buildInfoRow(
                  '📁 Categorías', metadata['totalCategories'].toString()),
              _buildInfoRow('🔥 Racha más larga', metadata['longestStreak'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup y Restauración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackups,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sección de acciones rápidas
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createBackup,
                        icon: const Icon(Icons.save),
                        label: const Text('Crear Backup'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareBackup,
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _importBackup,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Importar desde archivo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Formatos de Exportación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportCSV,
                        icon: const Icon(Icons.table_chart),
                        label: const Text('CSV'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportExcel,
                        icon: const Icon(Icons.grid_on),
                        label: const Text('Excel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seguridad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createEncryptedBackup,
                        icon: const Icon(Icons.lock),
                        label: const Text('Backup Cifrado'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importEncryptedBackup,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Importar Cifrado'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de backups
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _backups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.backup,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay backups disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primer backup',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _backups.length,
                        itemBuilder: (context, index) {
                          final backup = _backups[index];
                          final fileName = backup.path.split('/').last;
                          final isAuto = fileName.contains('auto_backup');
                          final fileDate = backup.statSync().modified;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAuto
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                                child: Icon(
                                  isAuto ? Icons.schedule : Icons.backup,
                                  color:
                                      isAuto ? Colors.blue[700] : Colors.green[700],
                                ),
                              ),
                              title: Text(
                                fileName,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(fileDate),
                                  ),
                                  if (isAuto)
                                    const Text(
                                      'Backup automático',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'restore':
                                      _restoreBackup(backup);
                                      break;
                                    case 'info':
                                      _showBackupInfo(backup);
                                      break;
                                    case 'delete':
                                      _deleteBackup(backup);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'info',
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, size: 20),
                                        SizedBox(width: 8),
                                        Text('Ver detalles'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'restore',
                                    child: Row(
                                      children: [
                                        Icon(Icons.restore, size: 20),
                                        SizedBox(width: 8),
                                        Text('Restaurar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar',
                                            style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
