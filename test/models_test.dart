import 'package:flutter_test/flutter_test.dart';
import 'package:ilac360/models.dart';
void main(){
  final med=Medication(id:'m1',name:'Example',dose:'one unit',times:['09:00','21:00'],start:DateTime(2026,11,1));
  test('Medication roundtrip',(){expect(Medication.fromJson(med.toJson()).times,['09:00','21:00']);});
  test('Date range',(){expect(med.scheduledOn(DateTime(2026,10,31)),false);expect(med.scheduledOn(DateTime(2026,11,1)),true);});
  test('Journal roundtrip',(){final j=Journal(medications:[med]);expect(Journal.import(j.export()).medications.single.id,'m1');});
  test('Reject invalid time',(){final j=med.toJson()..['times']=['99:00'];expect(()=>Medication.fromJson(j),throwsFormatException);});
  test('Reject invalid backup',(){expect(()=>Journal.import('{"version":2}'),throwsFormatException);});
  test('Reject duplicate',(){final j=Journal(medications:[med]);expect(()=>j.add(med),throwsStateError);});
  test('Record and replace dose',(){var j=Journal(medications:[med]);final a=DoseLog(medicationId:'m1',day:'2026-11-02',time:'09:00',status:'taken',recordedAt:DateTime(2026,11,2));j=j.record(a);expect(j.logs.length,1);j=j.record(DoseLog(medicationId:'m1',day:a.day,time:a.time,status:'skipped',recordedAt:a.recordedAt));expect(j.logs.length,1);expect(j.logs.single.status,'skipped');});
  test('Schedule and adherence',(){var j=Journal(medications:[med]);expect(j.schedule(DateTime(2026,11,2)).length,2);expect(j.adherence(DateTime(2026,11,2),DateTime(2026,11,2)),0);j=j.record(DoseLog(medicationId:'m1',day:'2026-11-02',time:'09:00',status:'taken',recordedAt:DateTime(2026,11,2)));expect(j.adherence(DateTime(2026,11,2),DateTime(2026,11,2)),0.5);});
  test('Remove purges logs',(){var j=Journal(medications:[med]);j=j.record(DoseLog(medicationId:'m1',day:'2026-11-02',time:'09:00',status:'taken',recordedAt:DateTime(2026,11,2)));expect(j.remove('m1').logs,isEmpty);});
}
