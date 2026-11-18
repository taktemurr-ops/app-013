import 'package:flutter/widgets.dart';
class Words {
  static const values=<String,Map<String,String>>{
    'app':{'tr':'İlaç 360','en':'Medication 360','ar':'الأدوية 360'},
    'today':{'tr':'Bugün','en':'Today','ar':'اليوم'},
    'medications':{'tr':'İlaçlar','en':'Medications','ar':'الأدوية'},
    'history':{'tr':'Geçmiş','en':'History','ar':'السجل'},
    'settings':{'tr':'Ayarlar','en':'Settings','ar':'الإعدادات'},
    'add':{'tr':'İlaç ekle','en':'Add medication','ar':'إضافة دواء'},
    'name':{'tr':'İlaç adı','en':'Medication name','ar':'اسم الدواء'},
    'dose':{'tr':'Doz açıklaması','en':'Dose description','ar':'وصف الجرعة'},
    'time':{'tr':'Saat (SS:DD)','en':'Time (HH:MM)','ar':'الوقت'},
    'notes':{'tr':'Notlar','en':'Notes','ar':'ملاحظات'},
    'save':{'tr':'Kaydet','en':'Save','ar':'حفظ'},
    'taken':{'tr':'Alındı','en':'Taken','ar':'تم التناول'},
    'skipped':{'tr':'Atlandı','en':'Skipped','ar':'تم التخطي'},
    'pending':{'tr':'Bekliyor','en':'Pending','ar':'معلق'},
    'delete':{'tr':'Sil','en':'Delete','ar':'حذف'},
    'pause':{'tr':'Duraklat','en':'Pause','ar':'إيقاف مؤقت'},
    'resume':{'tr':'Etkinleştir','en':'Resume','ar':'استئناف'},
    'empty':{'tr':'Henüz kayıt yok','en':'No records yet','ar':'لا توجد سجلات'},
    'export':{'tr':'Yedek metnini göster','en':'Show backup text','ar':'عرض النسخة الاحتياطية'},
    'import':{'tr':'Yedek yükle','en':'Import backup','ar':'استيراد نسخة'},
    'erase':{'tr':'Tüm verileri sil','en':'Delete all data','ar':'حذف جميع البيانات'},
    'confirm':{'tr':'Onayla','en':'Confirm','ar':'تأكيد'},
    'cancel':{'tr':'Vazgeç','en':'Cancel','ar':'إلغاء'},
    'invalid':{'tr':'Geçersiz bilgi','en':'Invalid input','ar':'إدخال غير صالح'},
    'warning':{'tr':'Bu uygulama tıbbi tavsiye vermez. Reçetenizi değiştirmeyin.','en':'Not medical advice. Do not change your prescription.','ar':'ليست نصيحة طبية. لا تغير الوصفة الطبية.'},
    'manual':{'tr':'Bildirimler henüz etkin değil; uygulamayı açarak kontrol edin.','en':'Notifications are not enabled; check the app manually.','ar':'الإشعارات غير مفعلة؛ تحقق من التطبيق يدويا.'},
    'backup':{'tr':'Yedek JSON metni','en':'Backup JSON text','ar':'نص النسخة الاحتياطية'},
    'adherence':{'tr':'Son 7 gün uyum','en':'7-day adherence','ar':'الالتزام لسبعة أيام'},
  };
  static String t(BuildContext context,String key) {final code=Localizations.localeOf(context).languageCode;return values[key]?[code]??values[key]?['en']??key;}
}
