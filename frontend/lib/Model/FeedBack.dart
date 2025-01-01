class FeedBack {
  String userId;
  String content;
  int createdAt;
  int updatedAt;
  String id;

  FeedBack({
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  factory FeedBack.fromJson(Map<String, dynamic> json) {
    return FeedBack(
      userId: json['userId'],
      id: json['_id'],
      createdAt: json['createdAt'],
      content: json['content'],
      updatedAt: json['updatedAt'],
    );
  }
}
