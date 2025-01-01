import 'FeedBack.dart';

class Comment {
  String postId;
  String userId;
  String content;
  int createdAt;
  int updatedAt;
  String id;
  List<FeedBack> feedBack;

  Comment({
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.feedBack,
    required this.id,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<FeedBack> feedBackList = (json['listFeedback'] as List)
        .map((item) => FeedBack.fromJson(item as Map<String, dynamic>))
        .toList();
    return Comment(
      postId: json['postId'],
      userId: json['userId'],
      id: json['_id'],
      createdAt: json['createdAt'],
      content: json['content'],
      updatedAt: json['updatedAt'],
      feedBack: feedBackList,
    );
  }
}


class addComment {
  String postId;
  String userId;
  String content;
  int createdAt;
  int updatedAt;

  addComment({
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,

  });
}