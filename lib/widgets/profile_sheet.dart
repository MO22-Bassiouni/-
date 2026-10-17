import 'package:flutter/material.dart';
import '../core.dart';
import '../screens/ratings_screen.dart';
import '../screens/welcome_screen.dart';

/// البروفايل (للمريض والدكتور): الصورة + البيانات + تغيير الصورة من الجهاز + تسجيل الخروج
void profileSheet(BuildContext c) {
  showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      builder: (_) => const ProfileSheet());
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});
  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  bool busy = false;
  Future<List<Rating>>? rf;

  bool get isDoc => app.role == 'doctor';
  String get photo => isDoc ? '${app.myDoc?['photo'] ?? ''}' : app.userPhoto;
  int get docId => (app.myDoc?['id'] as num?)?.toInt() ?? 0;

  @override
  void initState() {
    super.initState();
    if (isDoc) rf = Repo.ratingsFor(docId);
  }

  Future<void> save(String value) async {
    if (isDoc) {
      await app.setDoctorPhoto(value);
    } else {
      await app.setPatientPhoto(value);
    }
  }

  Future<void> change() async {
    final m = ScaffoldMessenger.of(context);
    setState(() => busy = true);
    final p = await pickPhoto();
    if (p != null) await save(p);
    if (!mounted) return;
    setState(() => busy = false);
    if (p != null) {
      m.showSnackBar(const SnackBar(content: Text('تم تحديث الصورة ✅')));
    }
  }

  Future<void> remove() async {
    setState(() => busy = true);
    await save('');
    if (!mounted) return;
    setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final pr = Theme.of(context).colorScheme.primary;
    final d = app.myDoc;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 124,
            height: 124,
            child: Stack(children: [
              Center(child: UserAvatar(photo, 112, circle: true)),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: pr,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: busy ? null : change,
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Text(isDoc ? '${d?['name']}' : app.userName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          if (!isDoc)
            Text(app.userPhone, style: TextStyle(color: Colors.grey.shade600)),
          if (isDoc) ...[
            Text('${d?['spec']} • ${d?['city']}',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            FutureBuilder<List<Rating>>(
              future: rf,
              builder: (c, snap) {
                final (avg, n) = Repo.summarize(snap.data ?? const <Rating>[]);
                return n == 0
                    ? Text('لا توجد تقييمات بعد',
                        style: TextStyle(color: Colors.grey.shade600))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        StarsRow(avg, size: 20),
                        Text('  ${avg.toStringAsFixed(1)} ($n تقييم)',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ]);
              },
            ),
          ],
          const SizedBox(height: 16),
          BigBtn(photo.isEmpty ? 'إضافة صورة' : 'تغيير الصورة',
              busy ? null : change,
              outline: true),
          if (photo.isNotEmpty)
            TextButton(
                onPressed: busy ? null : remove,
                child: const Text('حذف الصورة')),
          if (isDoc) ...[
            const SizedBox(height: 10),
            BigBtn('عرض تقييماتي', () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(MaterialPageRoute(
                  builder: (_) =>
                      RatingsScreen(docId: docId, docName: '${d?['name']}')));
            }, outline: true),
          ],
          const SizedBox(height: 10),
          BigBtn('تسجيل الخروج', () {
            app.logout();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (r) => false);
          }, outline: true, color: Colors.red),
        ]),
      ),
    );
  }
}
