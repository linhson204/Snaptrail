class Posts {
  String userId;
  String content;
  List<Map<String,String>> media;
  int createdAt;
  int updatedAt;
  int commentsCount;
  int likesCount;
  String id;
  String address;
  String district;
  String commune;
  String province;

  Posts({
    required this.userId,
    required this.content,
    required this.media ,
    required this.createdAt,
    required this.updatedAt,
    required this.commentsCount,
    required this.likesCount,
    required this.id,
    required this.address,
    required this.district,
    required this.commune,
    required this.province,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> mediaList = (json['media'] as List)
        .map((item) => Map<String, String>.from(item))
        .toList();
    return Posts(
      userId: json['userId'],
      content: json['content'],
      media: mediaList,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      commentsCount: json['commentsCount'],
      likesCount: json['likesCount'],
      id: json['_id'],
      address: json['address'],
      district: json['district'],
      commune: json['commune'],
      province: json['province'],
    );
  }
}


class CreatePost {
  String userId;
  String content;
  List<Map<String,String>> media;
  int createdAt;
  int updatedAt;
  int commentsCount;
  int likesCount;
  String address;
  String district;
  String commune;
  String province;

  CreatePost({
    required this.userId,
    required this.content,
    required this.media ,
    required this.createdAt,
    required this.updatedAt,
    required this.commentsCount,
    required this.likesCount,
    required this.address,
    required this.district,
    required this.commune,
    required this.province,
  });
}