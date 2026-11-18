import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilac360/main.dart';
import 'package:ilac360/storage.dart';
class EmptyStorage implements JournalStorage {@override Future<String?> read() async=>null;@override Future<void> write(String s) async {}@override Future<void> clear() async {}}
void main(){testWidgets('Shows four tabs', (tester)async{await tester.pumpWidget(MedicationApp(repository:JournalRepository(EmptyStorage())));await tester.pumpAndSettle();expect(find.text('Bugün'),findsWidgets);expect(find.byType(NavigationBar),findsOneWidget);});}
