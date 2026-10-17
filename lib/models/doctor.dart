class Doctor {
  final int id;
  final String name, spec, gov, city;
  final int fee, years, from, to;
  final List<int> days; // 1=الاثنين ... 7=الأحد
  final bool active;
  final String? photo; // رابط (http) أو صورة base64
  final String? vf, ip;
  final double? lat, lng; // مكان العيادة
  final String addr; // عنوان العيادة بالتفصيل
  final double rating; // متوسط التقييم (بيجي من السيرفر لو فيه API)
  final int ratingCount;
  Doctor(this.id, this.name, this.spec, this.gov, this.city, this.fee,
      this.years, this.days, this.from, this.to, this.active,
      {this.photo,
      this.vf,
      this.ip,
      this.lat,
      this.lng,
      this.addr = '',
      this.rating = 0,
      this.ratingCount = 0});

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
      (j['id'] as num).toInt(),
      '${j['name']}',
      '${j['spec']}',
      '${j['gov']}',
      '${j['city']}',
      (j['fee'] as num).toInt(),
      ((j['years'] ?? 0) as num).toInt(),
      (j['days'] as List).map((e) => (e as num).toInt()).toList(),
      (j['from'] as num).toInt(),
      (j['to'] as num).toInt(),
      j['active'] == true,
      photo: j['photo'],
      vf: j['vf'],
      ip: j['ip'],
      lat: (j['lat'] as num?)?.toDouble(),
      lng: (j['lng'] as num?)?.toDouble(),
      addr: j['addr'] ?? '',
      rating: ((j['rating'] ?? 0) as num).toDouble(),
      ratingCount: ((j['ratingCount'] ?? 0) as num).toInt());

  Doctor copyWith({String? photo}) => Doctor(
      id, name, spec, gov, city, fee, years, days, from, to, active,
      photo: photo ?? this.photo,
      vf: vf,
      ip: ip,
      lat: lat,
      lng: lng,
      addr: addr,
      rating: rating,
      ratingCount: ratingCount);

  String? numberFor(String k) {
    final v = k == 'vf' ? vf : ip;
    return (v == null || v.trim().isEmpty) ? null : v.trim();
  }
}
