class Rating {
  final int id, docId, stars; // stars من 1 إلى 5
  final String pName, pPhone, comment, at;
  Rating(this.id, this.docId, this.stars, this.pName, this.pPhone,
      this.comment, this.at);

  Map<String, dynamic> toJson() => {
        'id': id,
        'docId': docId,
        'stars': stars,
        'pName': pName,
        'pPhone': pPhone,
        'comment': comment,
        'at': at,
      };

  factory Rating.fromJson(Map<String, dynamic> j) => Rating(
      (j['id'] as num).toInt(),
      (j['docId'] as num).toInt(),
      (j['stars'] as num).toInt(),
      '${j['pName'] ?? ''}',
      '${j['pPhone'] ?? ''}',
      '${j['comment'] ?? ''}',
      '${j['at'] ?? ''}');
}
