import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'storage.dart';
import 'words.dart';

void main() {WidgetsFlutterBinding.ensureInitialized();runApp(const MedicationApp());}
class MedicationApp extends StatefulWidget {
  final JournalRepository? repository;
  const MedicationApp({super.key,this.repository});
  @override State<MedicationApp> createState()=>_MedicationAppState();
}
class _MedicationAppState extends State<MedicationApp> {
  Locale locale=const Locale('tr');
  @override Widget build(BuildContext context)=>MaterialApp(
    title:'İlaç 360',debugShowCheckedModeBanner:false,locale:locale,
    supportedLocales:const [Locale('tr'),Locale('en'),Locale('ar')],
    localizationsDelegates:const [GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate],
    theme:ThemeData(colorSchemeSeed:Colors.teal,useMaterial3:true),
    home:Home(repository:widget.repository??JournalRepository(const SecureJournalStorage()),locale:locale,onLocale:(l)=>setState(()=>locale=l)),
  );
}
class Home extends StatefulWidget {
  final JournalRepository repository;final Locale locale;final ValueChanged<Locale> onLocale;
  const Home({super.key,required this.repository,required this.locale,required this.onLocale});
  @override State<Home> createState()=>_HomeState();
}
class _HomeState extends State<Home> {
  Journal journal=const Journal();bool loading=true;String? error;int tab=0;
  String t(String key)=>Words.t(context,key);
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {try{final j=await widget.repository.load();if(mounted)setState((){journal=j;loading=false;error=null;});}catch(e){if(mounted)setState((){loading=false;error='Could not read encrypted journal: $e';});}}
  Future<void> _commit(Journal next) async {try{await widget.repository.save(next);if(mounted)setState((){journal=next;error=null;});}catch(e){if(mounted)setState(()=>error='Could not save: $e');}}
  Future<bool> _ask(String message) async => await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text(t('confirm')),content:Text(message),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:Text(t('cancel'))),FilledButton(onPressed:()=>Navigator.pop(c,true),child:Text(t('confirm')))]))??false;
  Future<void> _add() async {
    final name=TextEditingController(),dose=TextEditingController(),time=TextEditingController(text:'09:00'),notes=TextEditingController();
    final result=await showDialog<Medication>(context:context,builder:(c)=>AlertDialog(title:Text(t('add')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,maxLength:100,decoration:InputDecoration(labelText:t('name'))),
      TextField(controller:dose,maxLength:100,decoration:InputDecoration(labelText:t('dose'))),
      TextField(controller:time,decoration:InputDecoration(labelText:t('time'),hintText:'09:00, 21:00')),
      TextField(controller:notes,maxLength:500,decoration:InputDecoration(labelText:t('notes'))),
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),FilledButton(onPressed:(){
      final times=time.text.split(',').map((s)=>s.trim()).toSet().toList()..sort();
      if(name.text.trim().isEmpty||dose.text.trim().isEmpty||times.isEmpty||times.length>24||times.any((s)=>!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(s))){ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(t('invalid'))));return;}
      Navigator.pop(c,Medication(id:const Uuid().v4(),name:name.text.trim(),dose:dose.text.trim(),times:times,start:DateTime.now(),notes:notes.text.trim()));
    },child:Text(t('save')))]));
    name.dispose();dose.dispose();time.dispose();notes.dispose();
    if(result!=null)await _commit(journal.add(result));
  }
  Future<void> _mark(ScheduleEntry entry,String status) async {await _commit(journal.record(DoseLog(medicationId:entry.medication.id,day:dateKey(DateTime.now()),time:entry.time,status:status,recordedAt:DateTime.now())));}
  Widget _today(){final entries=journal.schedule(DateTime.now());final start=DateTime.now().subtract(const Duration(days:6));final adherence=journal.adherence(start,DateTime.now());return ListView(children:[
    Padding(padding:const EdgeInsets.all(16),child:Text(t('warning'),style:Theme.of(context).textTheme.bodyMedium)),
    Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Text('${t('adherence')}: ${(adherence*100).toStringAsFixed(0)}%')),
    const SizedBox(height:8),
    if(entries.isEmpty)ListTile(title:Text(t('empty'))),
    for(final e in entries)Card(child:ListTile(title:Text('${e.time}  ${e.medication.name}'),subtitle:Text('${e.medication.dose} • ${t(e.log?.status??'pending')}'),isThreeLine:true,
      trailing:Wrap(spacing:4,children:[IconButton(tooltip:t('taken'),icon:const Icon(Icons.check_circle_outline),onPressed:()=>_mark(e,'taken')),IconButton(tooltip:t('skipped'),icon:const Icon(Icons.remove_circle_outline),onPressed:()=>_mark(e,'skipped'))]))),
    Padding(padding:const EdgeInsets.all(16),child:Text(t('manual'),style:Theme.of(context).textTheme.bodySmall)),
  ]);}
  Widget _medications()=>ListView(children:[for(final m in journal.medications)Card(child:ListTile(title:Text(m.name),subtitle:Text('${m.dose} • ${m.times.join(', ')}\n${m.notes}'),isThreeLine:true,
    trailing:PopupMenuButton<String>(onSelected:(action)async{if(action=='delete'){if(await _ask('${t('delete')}: ${m.name}?'))await _commit(journal.remove(m.id));}else{await _commit(journal.setActive(m.id,!m.active));}},itemBuilder:(_)=>[PopupMenuItem(value:'toggle',child:Text(m.active?t('pause'):t('resume'))),PopupMenuItem(value:'delete',child:Text(t('delete')))])))]);
  Widget _history(){final sorted=[...journal.logs]..sort((a,b)=>b.recordedAt.compareTo(a.recordedAt));return ListView(children:[if(sorted.isEmpty)ListTile(title:Text(t('empty'))),for(final l in sorted.take(500))ListTile(title:Text(journal.medications.where((m)=>m.id==l.medicationId).map((m)=>m.name).firstOrNull??l.medicationId),subtitle:Text('${l.day} ${l.time}'),trailing:Text(t(l.status)))]);}
  Future<void> _showBackup() async {final content=journal.export();await showDialog<void>(context:context,builder:(c)=>AlertDialog(title:Text(t('backup')),content:SizedBox(width:450,height:300,child:SingleChildScrollView(child:SelectableText(content))),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('confirm')))]));}
  Future<void> _importBackup() async {final ctrl=TextEditingController();final input=await showDialog<String>(context:context,builder:(c)=>AlertDialog(title:Text(t('import')),content:TextField(controller:ctrl,maxLines:8,decoration:InputDecoration(labelText:t('backup'))),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text(t('cancel'))),FilledButton(onPressed:()=>Navigator.pop(c,ctrl.text),child:Text(t('confirm')))]));ctrl.dispose();if(input==null||input.isEmpty)return;try{final candidate=Journal.import(input);if(await _ask('${t('import')}?'))await _commit(candidate);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${t('invalid')}: $e')));}}
  Widget _settings()=>ListView(children:[ListTile(title:const Text('Language / Dil / اللغة'),trailing:DropdownButton<String>(value:widget.locale.languageCode,items:const [DropdownMenuItem(value:'tr',child:Text('Türkçe')),DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'ar',child:Text('العربية'))],onChanged:(v){if(v!=null)widget.onLocale(Locale(v));})),ListTile(title:Text(t('export')),onTap:_showBackup),ListTile(title:Text(t('import')),onTap:_importBackup),ListTile(title:Text(t('erase')),onTap:()async{if(await _ask(t('erase'))){await widget.repository.erase();if(mounted)setState(()=>journal=const Journal());}}),Padding(padding:const EdgeInsets.all(16),child:Text(t('warning')))]);
  @override Widget build(BuildContext context){final titles=[t('today'),t('medications'),t('history'),t('settings')];return Scaffold(appBar:AppBar(title:Text('${t('app')} · ${titles[tab]}')),body:loading?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(error!),TextButton(onPressed:_load,child:const Text('Retry'))])):[_today(),_medications(),_history(),_settings()][tab],floatingActionButton:!loading&&error==null&&tab==1?FloatingActionButton.extended(onPressed:_add,icon:const Icon(Icons.add),label:Text(t('add'))):null,bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:[NavigationDestination(icon:const Icon(Icons.today),label:titles[0]),NavigationDestination(icon:const Icon(Icons.medication),label:titles[1]),NavigationDestination(icon:const Icon(Icons.history),label:titles[2]),NavigationDestination(icon:const Icon(Icons.settings),label:titles[3])]));}
}
