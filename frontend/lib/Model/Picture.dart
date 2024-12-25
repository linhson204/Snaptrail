class Picture {
  String id;
  String userId;
  String link;
  int capturedAt;

  Picture({
    required this.id,
    required this.userId,
    required this.link,
    required this.capturedAt,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'],
      userId: json['userId'],
      link: json['link'],
      capturedAt: json['capturedAt']
    );
  }
}

class CreatePicture {
  String userId;
  String link;
  DateTime capturedAt;
  bool isTakenByCamera;

  CreatePicture(
    {
      required this.userId,
      required this.link,
      required this.capturedAt,
      required this.isTakenByCamera,
    }
  );
}