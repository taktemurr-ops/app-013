import 'package:flutter_test/flutter_test.dart';
import 'package:ilac360/models.dart';
import 'package:ilac360/storage.dart';
class FakeStorage implements JournalStorage {String? value;@override Future<String?> read() async=>value;@override Future<void> write(String s) async {value=s;}@override Future<void> clear() async {value=null;}}
void main(){test('Persist and erase journal',()async{final s=FakeStorage(),r=JournalRepository(s);await r.save(const Journal());expect((await r.load()).medications,isEmpty);await r.erase();expect(s.value,isNull);});}
