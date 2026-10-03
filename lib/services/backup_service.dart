// lib/services/backup_service.dart
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../database/app_database.dart';

/// Сервис для шифрованного резервного копирования и восстановления БД (Сцена 7).
class BackupService {
  const BackupService._();

  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static const String _dbFileName = 'disciphobby.sqlite';

  /// Создаёт зашифрованную резервную копию БД и предлагает сохранить её.
  static Future<bool> createBackup() async {
    try {
      await db.close();

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, _dbFileName));
      
      if (!await dbFile.exists()) {
        await _reopenDb();
        return false;
      }

      final bytes = await dbFile.readAsBytes();
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);
      
      final backupBytes = Uint8List.fromList(iv.bytes + encrypted.bytes);

      final result = await FilePicker.saveFile(
        dialogTitle: 'Сохранить резервную копию',
        fileName: 'disciphobby_backup_${DateTime.now().millisecondsSinceEpoch}.dht',
        bytes: backupBytes,
      );
      
      await _reopenDb();
      return result != null;
    } catch (e) {
      debugPrint('❌ Ошибка создания бэкапа: $e');
      await _reopenDb();
      return false;
    }
  }

  /// Восстанавливает БД из зашифрованной резервной копии.
  /// Возвращает true при успехе, false при отмене или ошибке.
  static Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Выберите файл резервной копии',
        type: FileType.custom,
        allowedExtensions: ['dht'],
        withData: true, // ✅ КРИТИЧНО: гарантирует загрузку байтов в память
      );
      
      if (result == null || result.files.isEmpty) {
        return false; // Пользователь отменил выбор
      }

      final file = result.files.first;
      Uint8List backupBytes;
      
      // ✅ НАДЕЖНЫЙ ФОЛЛБЭК: используем bytes, если нет — читаем по path
      if (file.bytes != null) {
        backupBytes = file.bytes!;
      } else if (file.path != null) {
        backupBytes = await File(file.path!).readAsBytes();
      } else {
        debugPrint('❌ Ошибка восстановления: файл не содержит ни bytes, ни path');
        return false;
      }

      // Защита от поврежденных или пустых файлов
      if (backupBytes.length < 16) {
        debugPrint('❌ Ошибка восстановления: файл слишком мал для расшифровки');
        return false;
      }

      // Извлекаем IV (первые 16 байт) и зашифрованные данные
      final iv = encrypt.IV(Uint8List.fromList(backupBytes.sublist(0, 16)));
      final encryptedBytes = backupBytes.sublist(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedBytes),
        iv: iv,
      );

      // КРИТИЧНО: Перед заменой файла БД нужно закрыть активное соединение Drift!
      await db.close();

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, _dbFileName));
      
      // КРИТИЧНО: Удаляем старые файлы журналов SQLite (WAL/SHM).
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();

      await dbFile.writeAsBytes(decryptedBytes);

      // ✅ УБРАНО: await restartApp(); 
      // Перезапуск теперь управляется из settings_screen.dart, чтобы успел отрисоваться SnackBar.
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка восстановления БД: $e');
      debugPrint('StackTrace: $stackTrace');
      await _reopenDb();
      return false;
    }
  }

  /// Вспомогательный метод для повторного открытия БД при отмене или ошибке.
  static Future<void> _reopenDb() async {
    try {
      db = AppDatabase();
    } catch (_) {
      // Игнорируем ошибки, если БД уже пересоздается
    }
  }
}