import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models.dart';

abstract class JournalStorage {Future<String?> read();Future<void> write(String value);Future<void> clear();}
class SecureJournalStorage implements JournalStorage {
  final FlutterSecureStorage storage;
  const SecureJournalStorage([this.storage=const FlutterSecureStorage(aOptions:AndroidOptions(encryptedSharedPreferences:true))]);
  static const key='ilac360_journal_v1';
  @override Future<String?> read()=>storage.read(key:key);
  @override Future<void> write(String value)=>storage.write(key:key,value:value);
  @override Future<void> clear()=>storage.delete(key:key);
}
class JournalRepository {
  final JournalStorage storage;
  JournalRepository(this.storage);
  Future<Journal> load() async {final value=await storage.read();return value==null?const Journal():Journal.import(value);}
  Future<void> save(Journal journal)=>storage.write(journal.export());
  Future<void> erase()=>storage.clear();
}
