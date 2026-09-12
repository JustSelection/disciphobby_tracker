// lib/services/backup_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../main.dart'; // Для доступа к глобальной переменной db

/// Сервис для шифрованного резервного копирования и восстановления БД (Сцена 7).
class BackupService {
  const BackupService._();

  // Примечание: В продакшене ключ должен генерироваться из пароля пользователя (PBKDF2)!
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  
  // Имя файла БД. Должно точно совпадать с тем, что указано в main.dart при инициализации Drift!
  static const String _dbFileName = 'disciphobby.sqlite'; 

  /// Создаёт зашифрованную резервную копию БД и предлагает сохранить её.
  static Future<bool> createBackup() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, _dbFileName));
      if (!await dbFile.exists()) return false;

      final bytes = await dbFile.readAsBytes();
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);
      
      // Сохраняем IV (вектор инициализации) в начале файла для последующей расшифровки
      final backupBytes = Uint8List.fromList(iv.bytes + encrypted.bytes);

      // ИСПРАВЛЕНО: FilePicker.saveFile вместо FilePicker.platform.saveFile
      final result = await FilePicker.saveFile(
        dialogTitle: 'Сохранить резервную копию',
        fileName: 'disciphobby_backup_${DateTime.now().millisecondsSinceEpoch}.dht',
        bytes: backupBytes,
      );
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Восстанавливает БД из зашифрованной резервной копии.
  static Future<bool> restoreBackup() async {
    try {
      // ИСПРАВЛЕНО: FilePicker.pickFiles вместо FilePicker.platform.pickFiles
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Выберите файл резервной копии',
        type: FileType.custom,
        allowedExtensions: ['dht'],
      );
      if (result == null || result.files.single.path == null) return false;

      final backupFile = File(result.files.single.path!);
      final backupBytes = await backupFile.readAsBytes();

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
      await dbFile.writeAsBytes(decryptedBytes);

      // После успешного восстановления рекомендуется перезапустить приложение,
      // чтобы Drift заново инициализировал соединение с новым файлом БД.
      return true;
    } catch (e) {
      return false;
    }
  }
}