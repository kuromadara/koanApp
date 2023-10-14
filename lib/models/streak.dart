class Streak {
  int? id;
  int count;

  Streak({
    this.id,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'count': count,
    };
  }

  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      id: map['id']?.toInt() ?? 0,
      count: map['count']?.toInt() ?? 0,
    );
  }
}
