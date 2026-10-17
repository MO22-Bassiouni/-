# عقد الـ API بين التطبيق والداشبورد

حط رابط الـ API في `apiBase` أول ملف lib/main.dart (مثال: https://your-domain.com/api).
كل الردود JSON UTF-8.

| الطلب | الغرض |
|---|---|
| GET /doctors | الدكاترة اللي active=true بس (بتظهر للمرضى) |
| POST /doctors/register | تسجيل دكتور جديد. احفظه active=false وارجع {"id": 12, "active": false} |
| GET /doctors/{id} | ارجع {"active": true/false} (التطبيق بيسأل عليه عشان يعرف حالة الاشتراك) |
| GET /doctors/{id}/bookings | حجوزات الدكتور (قايمة Booking) |
| POST /bookings | حجز جديد أو تعديل (upsert بالـ id) |
| DELETE /bookings/{id} | إلغاء حجز |
| POST /patients | تسجيل مريض {"name","phone"} |

## بيانات تسجيل الدكتور (body)
{"name","spec","gov","city","fee":300,"years":10,"days":[1,2,4],"from":10,"to":18,"vf":"01012345678","ip":"name@instapay"}
days: 1=الاثنين ... 7=الأحد، from/to ساعات 0-23.

## شكل الحجز (Booking)
{"id":1234,"docId":12,"docName":"د. أحمد","spec":"باطنة","fee":300,"day":"2026-10-12","hour":14,
 "pay":"vf","phone":"01099999999","paidAt":"9/10/2026 - 14:05","pName":"محمد علي","pPhone":"01100000000"}
pay: vf = فودافون كاش، ip = انستا باي. phone = الرقم اللي المريض حوّل منه، pPhone = رقم المريض.

## الاشتراك الشهري
زرار التفعيل عندك في الداشبورد = حقل active للدكتور. لما تقفله (انتهى الاشتراك) الدكتور بيختفي من /doctors.
