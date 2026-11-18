import 'dart:convert';

class Medication {
  final String id;
  final String name;
  final String dose;
  final List<String> times;
  final DateTime start;
  final DateTime? end;
  final String notes;
  final bool active;
  const Medication({required this.id, required this.name, required this.dose, required this.times, required this.start, this.end, this.notes = '', this.active = true});
  bool scheduledOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = end == null ? null : DateTime(end!.year, end!.month, end!.day);
    return active && !d.isBefore(s) && (e == null || !d.isAfter(e));
  }
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'dose': dose, 'times': times, 'start': start.toIso8601String(), 'end': end?.toIso8601String(), 'notes': notes, 'active': active};
  factory Medication.fromJson(Map<String, dynamic> j) {
    final id = j['id']; final name = j['name']; final dose = j['dose']; final times = j['times']; final start = j['start'];
    if (id is! String || id.isEmpty || name is! String || name.trim().isEmpty || dose is! String || times is! List || start is! String) throw const FormatException('Invalid medication');
    final t = times.map((x) {if (x is! String || !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(x)) throw const FormatException('Invalid time'); return x;}).toSet().toList()..sort();
    if (t.isEmpty || t.length > 24) throw const FormatException('Invalid schedule');
    final s = DateTime.tryParse(start); final endRaw = j['end']; final e = endRaw == null ? null : (endRaw is String ? DateTime.tryParse(endRaw) : null);
    if (s == null || (endRaw != null && e == null) || (e != null && e.isBefore(s))) throw const FormatException('Invalid dates');
    return Medication(id:id, name:name.trim(), dose:dose.trim(), times:t, start:s, end:e, notes:j['notes'] is String ? j['notes'] as String : '', active:j['active'] == true);
  }
  Medication copyWith({bool? active}) => Medication(id:id,name:name,dose:dose,times:times,start:start,end:end,notes:notes,active:active??this.active);
}

class DoseLog {
  final String medicationId;
  final String day;
  final String time;
  final String status;
  final DateTime recordedAt;
  const DoseLog({required this.medicationId,required this.day,required this.time,required this.status,required this.recordedAt});
  String get key => '$medicationId|$day|$time';
  Map<String,dynamic> toJson() => {'medicationId':medicationId,'day':day,'time':time,'status':status,'recordedAt':recordedAt.toIso8601String()};
  factory DoseLog.fromJson(Map<String,dynamic> j) {
    if (j['medicationId'] is! String || j['day'] is! String || j['time'] is! String || !['taken','skipped'].contains(j['status']) || j['recordedAt'] is! String) throw const FormatException('Invalid dose log');
    final at=DateTime.tryParse(j['recordedAt'] as String); if(at==null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(j['day'] as String) || !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(j['time'] as String)) throw const FormatException('Invalid dose log fields');
    return DoseLog(medicationId:j['medicationId'] as String,day:j['day'] as String,time:j['time'] as String,status:j['status'] as String,recordedAt:at);
  }
}

String dateKey(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

class Journal {
  final List<Medication> medications;
  final List<DoseLog> logs;
  const Journal({this.medications=const [],this.logs=const []});
  Map<String,dynamic> toJson() => {'version':1,'medications':medications.map((x)=>x.toJson()).toList(),'logs':logs.map((x)=>x.toJson()).toList()};
  String export() => jsonEncode(toJson());
  factory Journal.import(String raw) {
    final decoded=jsonDecode(raw); if(decoded is! Map<String,dynamic> || decoded['version']!=1 || decoded['medications'] is! List || decoded['logs'] is! List) throw const FormatException('Unsupported backup');
    final meds=(decoded['medications'] as List).map((x)=>Medication.fromJson(Map<String,dynamic>.from(x as Map))).toList();
    final logs=(decoded['logs'] as List).map((x)=>DoseLog.fromJson(Map<String,dynamic>.from(x as Map))).toList();
    if(meds.length>2000 || logs.length>200000 || meds.map((x)=>x.id).toSet().length!=meds.length) throw const FormatException('Backup limit exceeded');
    return Journal(medications:meds,logs:logs);
  }
  Journal add(Medication m) {if(medications.any((x)=>x.id==m.id)) throw StateError('Duplicate medication'); return Journal(medications:[...medications,m],logs:logs);}
  Journal remove(String id) => Journal(medications:medications.where((x)=>x.id!=id).toList(),logs:logs.where((x)=>x.medicationId!=id).toList());
  Journal setActive(String id,bool active) => Journal(medications:medications.map((x)=>x.id==id?x.copyWith(active:active):x).toList(),logs:logs);
  Journal record(DoseLog log) {if(!medications.any((x)=>x.id==log.medicationId && x.times.contains(log.time))) throw StateError('Unknown schedule');return Journal(medications:medications,logs:[...logs.where((x)=>x.key!=log.key),log]);}
  DoseLog? find(String id,String day,String time) {for(final l in logs.reversed){if(l.medicationId==id&&l.day==day&&l.time==time)return l;}return null;}
  List<ScheduleEntry> schedule(DateTime day) {final k=dateKey(day);final out=<ScheduleEntry>[];for(final m in medications.where((x)=>x.scheduledOn(day))){for(final t in m.times){out.add(ScheduleEntry(m,t,find(m.id,k,t)));}}out.sort((a,b)=>a.time.compareTo(b.time));return out;}
  double adherence(DateTime start,DateTime end) {var expected=0,taken=0;for(var day=DateTime(start.year,start.month,start.day);!day.isAfter(end);day=day.add(const Duration(days:1))){for(final x in schedule(day)){expected++;if(x.log?.status=='taken')taken++;}}return expected==0?0:taken/expected;}
}
class ScheduleEntry {final Medication medication;final String time;final DoseLog? log;const ScheduleEntry(this.medication,this.time,this.log);}
