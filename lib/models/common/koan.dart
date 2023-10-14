class Koan {
  int? id;
  int? serverId;
  String title;
  String koan;
  int? status;
  String? date;

  Koan({
    this.id,
    this.serverId,
    required this.title,
    required this.koan,
    this.status,
    this.date,
  });

  factory Koan.fromJson(Map<String, dynamic> json) {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return Koan(
      id: json['id'],
      title: json['title'],
      koan: json['koan'],
      status: 1,
      date: formattedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'title': title,
      'koan': koan,
      'status': status,
      'date': date,
    };
  }

  factory Koan.fromMap(Map<String, dynamic> map) {
    return Koan(
      id: map['id']?.toInt() ?? 0,
      serverId: map['server_id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      koan: map['koan']?.toInt() ?? 0,
      status: map['status'],
      date: map['date']?.toDate() ?? 0,
    );
  }
}
