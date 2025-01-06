import 'package:flutter/material.dart';
import '../Manager/CURD_comment.dart';
import '../Manager/CURD_posts.dart';
import '../Manager/Like.dart';
import '../Model/Comment.dart';
import '../Model/Like.dart';
import '../Model/PagePost.dart';
import '../Model/Posts.dart';
import '../Model/User_2.dart';
import '../NewFeed/CommentScreen.dart';
import '../NewFeed/FullScreenImageGallery.dart';
import '../NewFeed/ImageFullScreen.dart';
import '../NewFeed/PostScreen.dart';
import '../NewFeed/sreachScreen.dart';
import '../PersonalPageScreen/personalPageScreen.dart';
import '../Widget/UpdateUser.dart';
import '../Widget/accountModel.dart';
import 'package:provider/provider.dart';

import '../Widget/AutoRefreshToken.dart';

class newFeedScreen2 extends StatefulWidget {
  late String province ;
  late String district ;
  late String commune ;
  newFeedScreen2({required this.province,required this.district,required this.commune,Key? key}) : super(key: key);

  @override
  State<newFeedScreen2> createState() => _newFeedScreenState2();
}

class _newFeedScreenState2 extends State<newFeedScreen2> {
  List<bool> isLike = [];
  int count = 0;
  late Future<List<Posts>> listPost;
  late List<User?> user;
  late List<List<Like?>> like;
  late List<List<Comment>> comments;
  List<Like?> likeId = [];
  List<Posts> posts = [];
  List<String> timePost = [];
  PagePost? pagePost;
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadData = true;
  ScrollController scrollController = ScrollController();
  bool hehe = true;
  bool _showLoading = true; // Biến để kiểm soát trạng thái loading

  final TextEditingController commentController = TextEditingController();

  bool result = false;


  Future<void> getPageData() async {
    pagePost = await getInfoPosts2(1.toString(),"page",widget.province,widget.district,widget.commune);
    totalPages = pagePost!.totalPages;
  }

  @override
  void initState() {
    getPageData();
    _simulateLoading(); // Gọi hàm mô phỏng loading
    scrollController.addListener(() {
      if (scrollController.position.atEdge && scrollController.position.pixels != 0 && isLoadData) {
        currentPage++;
        // Load next page when scrolled to the bottom
        print("hehe");
        print(currentPage);
        listPost = resetData(currentPage).then((posts) async {
          user = List<User?>.generate(posts.length, (index) => null);
          like = List<List<Like?>>.generate(posts.length, (index) => []);
          comments = List<List<Comment>>.generate(posts.length, (index) => []);
          var accountModel = Provider.of<AccountModel>(context, listen: false);

          // Sử dụng Future.wait để đợi tất cả dữ liệu người dùng được tải về
          await Future.wait(posts.asMap().entries.map((entry) async {
            int index = entry.key;
            Posts post = entry.value;
            user[index] = await getUser(post.userId, accountModel.token_access);
            like[index]= await getLikePost(post.id);
            comments[index]= await getCommentPost(post.id);
            DateTime utcTime = DateTime.fromMillisecondsSinceEpoch(post.createdAt, isUtc: true);
            timePost.add(formatTimeDifference(utcTime));

            bool userLiked = like[index].any((like) => like?.userId.toString() == accountModel.idUser.toString());
            isLike.add(userLiked);

            if (userLiked) {
              like[index].forEach((like) {
                if (like?.userId.toString() == accountModel.idUser.toString() && like != null) {
                  likeId.add(like); // Thêm ID của like vào danh sách likeId
                }
              });
            } else {
              likeId.add(null);
            }

          }));
          return posts;
        });

        setState(() {
          if(currentPage == totalPages){
            isLoadData = false;
          }
        });
      }
    });
    listPost = Future.value([]);
    if(hehe) {
      initializePageData();
    }
    super.initState();
  }


  Future<void> initializePageData() async {
    // Đợi getPageData hoàn tất
    await getPageData();

    // Thực hiện các lệnh khác sau khi getPageData hoàn tất
    listPost = resetData(currentPage).then((posts) async {
      user = List<User?>.generate(posts.length, (index) => null);
      like = List<List<Like?>>.generate(posts.length, (index) => []);
      comments = List<List<Comment>>.generate(posts.length, (index) => []);
      var accountModel = Provider.of<AccountModel>(context, listen: false);

      // Đợi tất cả các tác vụ bất đồng bộ hoàn thành
      await Future.wait(posts.asMap().entries.map((entry) async {
        int index = entry.key;
        Posts post = entry.value;
        user[index] = await getUser(post.userId, accountModel.token_access);
        like[index] = await getLikePost(post.id);
        comments[index] = await getCommentPost(post.id);
        DateTime utcTime = DateTime.fromMillisecondsSinceEpoch(post.createdAt, isUtc: true);
        timePost.add(formatTimeDifference(utcTime));

        bool userLiked = like[index].any((like) => like?.userId.toString() == accountModel.idUser.toString());
        isLike.add(userLiked);

        if (userLiked) {
          like[index].forEach((like) {
            if (like?.userId.toString() == accountModel.idUser.toString() && like != null) {
              likeId.add(like); // Thêm ID của like vào danh sách likeId
            }
          });
        } else {
          likeId.add(null);
        }
      }));
      return posts;
    });
    setState(() {
      hehe = false; // Đánh dấu hoàn thành
    });
  }

  Future<List<Posts>> resetData(int page) async {
    pagePost = await getInfoPosts2(page.toString(),"page",widget.province,widget.district,widget.commune);
    posts.addAll(pagePost!.results);
    return posts;
  }

  String formatTimeDifference(DateTime postTime) {
    DateTime now = DateTime.now();
    DateTime vietnamTime = now.toUtc().add(Duration(hours: 7));
    Duration difference = vietnamTime.difference(postTime); // Tính khoảng cách thời gian
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  RichText Address(int index, Posts post) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Địa chỉ: ",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Kiểu chữ cho tên người dùng
            ),
          ),

          TextSpan(
            text: post.address,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Kiểu chữ cho địa điểm
            ),
          ),
        ],
      ),
    );
  }




  Future<User?> getUser(String userId, String token_access) async {
    try {
      return await fetchData(userId, token_access);
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  IconData getCategoryIcon(int index) {
    if (!isLike[index]) {
      return Icons.thumb_up_alt_outlined;
    } else {
      return Icons.thumb_up_alt_rounded;
    }
  }

  void showComments(BuildContext context, List<Comment> comment, Posts post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép điều chỉnh chiều cao
      backgroundColor: Colors.transparent, // Nền trong suốt
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // Bắt đầu từ 90% chiều cao màn hình
          minChildSize: 0.9, // Chiều cao tối thiểu là 90%
          maxChildSize: 1.0, // Có thể kéo lên chiếm toàn bộ màn hình
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white, // Nền màu trắng
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20), // Bo góc phía trên
                ),
              ),
              child: CommentScreen(
                listComment: comment,
                post: post,
              ),
            );
          },
        );
      },
    );
  }

  void _simulateLoading() async {
    await Future.delayed(Duration(milliseconds: 500)); // Chờ 1 giây
    setState(() {
      _showLoading = false; // Tắt trạng thái loading
    });
  }


  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: FutureBuilder<List<Posts>>(
            future: listPost,
            builder: (context, snapshot) {
              if ((snapshot.connectionState == ConnectionState.waiting && hehe) || _showLoading) {
                print("1");
                return Center(
                    child:AnimatedRotation(
                      turns: 1, // xoay một vòng
                      duration: Duration(seconds: 1),
                      child: CircularProgressIndicator(),
                  ),
                );
              }
              else if (snapshot.connectionState == ConnectionState.done) {
                print("2");
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Hiển thị thông báo khi không có dữ liệu
                  return Center(
                      child: Scaffold(
                          body: Stack(
                            children: [
                              Image.asset(
                                'assets/Image/Background.png',
                                width: screenHeight,
                                height: screenHeight,
                                fit: BoxFit.none,
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            spreadRadius: 3,
                                            blurRadius: 6,
                                            offset: Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              child: Icon(Icons.keyboard_arrow_left, size: 50, color: Colors.black),
                                            ),

                                          ),
                                          SizedBox(width: 15),
                                          Text(
                                            "Kết quả tìm kiếm",
                                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 20),
                                          Container(
                                            width: 50,
                                            height: 50,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Expanded(
                                        child: Container(
                                          color: Colors.white,
                                          child: Center(
                                            child: Text(
                                              "Không có bài viết nào phù hợp",
                                              style: TextStyle(fontSize: 25, color: Colors.grey),
                                            ),
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                      )
                  );
                }
              }

              var post = snapshot.data!; // Lấy dữ liệu từ snapshot

              if(posts.length == 0) {
                posts = post;
              }
              else {
                post.map((i) => posts.add(i));
              }

              return Consumer<AccountModel>(
                builder: (context, accountModel, child) {
                  return Stack(
                    children: [
                      Image.asset(
                        'assets/Image/Background.png',
                        width: screenHeight,
                        height: screenHeight,
                        fit: BoxFit.none,
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 3,
                                  blurRadius: 6,
                                  offset: Offset(5, 5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    child: Icon(Icons.keyboard_arrow_left, size: 50, color: Colors.black),
                                  ),

                                ),
                                SizedBox(width: 15),
                                Text(
                                  "Kết quả tìm kiếm",
                                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 20),
                                Container(
                                  width: 50,
                                  height: 50,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Expanded(
                            child: Container(
                              child: ListView.builder(
                                controller: scrollController,
                                // reverse: true,
                                itemCount: posts.length, // Dùng posts.length thay vì count
                                itemBuilder: (context, index) {
                                  var post = posts[index];
                                  var postUser = user[index];
                                  var postLike = like[index];
                                  var postComment = comments[index];
                                  if(postUser != null) {
                                    return Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            spreadRadius: 3,
                                            blurRadius: 6,
                                            offset: Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey,
                                                    image: DecorationImage(
                                                      image: NetworkImage(postUser.avatar),
                                                      fit: BoxFit.cover,
                                                    )
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: screenWidth * 3 / 5 - 10,
                                                    child: Text(postUser.username, style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                                                  ),
                                                  Container(
                                                    // height: 20,
                                                    child: Text(timePost[index],style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.grey),),
                                                  )
                                                ],
                                              ),
                                              SizedBox(width: 20),
                                              GestureDetector(
                                                onTap: () {
                                                  // Không cần xử lý ở đây vì PopupMenuButton tự động hiển thị menu
                                                },
                                                child: PopupMenuButton<String>(
                                                  color: Colors.white,
                                                  onSelected: (String value) async {
                                                    switch (value) {
                                                      case 'edit':
                                                        print("Chỉnh sửa bài viết");
                                                        break;
                                                      case 'delete':
                                                        if(post.userId == accountModel.idUser) {
                                                          // Gọi API xóa bài viết
                                                          await RemovePost(post.id);  // Xóa bài viết
                                                          setState(() {
                                                            posts.remove(post);
                                                            user.remove(postUser);
                                                            isLike.removeAt(index);
                                                            postLike.remove(postLike);
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                                content: Text("không thể xoá bài viết của người khác")),
                                                          );
                                                        }
                                                        break;
                                                      case 'hide':
                                                        print("Ẩn bài viết");
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) {
                                                    return [
                                                      PopupMenuItem<String>(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit, color: Colors.grey),
                                                            SizedBox(width: 10),
                                                            Text('Chỉnh sửa bài viết'),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem<String>(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete, color: Colors.red),
                                                            SizedBox(width: 10),
                                                            Text('Xóa bài viết'),
                                                          ],
                                                        ),
                                                      ),
                                                    ];
                                                  },
                                                  icon: Icon(
                                                    Icons.more_horiz,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Text(post.content, style: TextStyle(fontSize: 22),),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Address(index,post),
                                          ),
                                          Container(
                                            height: post.media.isNotEmpty
                                                ? ((post.media.length > 4 ? 2 : (post.media.length / (post.media.length > 1 ? 2 : 1)).ceil()) *
                                                (screenWidth / (post.media.length > 1 ? 2 : 1))) +
                                                ((post.media.length > 4 ? 1 : (post.media.length / (post.media.length > 1 ? 2 : 1)).ceil() - 1) * 5)
                                                : 0,
                                            child: GridView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: post.media.length > 1 ? 2 : 1,
                                                crossAxisSpacing: 5,
                                                mainAxisSpacing: 5,
                                                childAspectRatio: 1,
                                              ),
                                              itemCount: post.media.length > 4 ? 4 : post.media.length,
                                              itemBuilder: (context, imgIndex) {
                                                if (imgIndex == 3 && post.media.length > 4) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FullScreenImageGallery(
                                                            images: post.media, // Toàn bộ danh sách ảnh
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Stack(
                                                      alignment: Alignment.center, // Đặt Text vào giữa ảnh
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(post.media[imgIndex]['url']!),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                              color: Colors.blue, // Màu viền
                                                              width: 2, // Độ dày viền
                                                            ),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Opacity(
                                                            opacity: 0.3, // Làm ảnh thứ 3 trong suốt
                                                            child: Container(
                                                              color: Colors.black, // Nền mờ màu đen
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "+${(post.media.length - 4).toString()}",
                                                          style: const TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white, // Màu chữ hiển thị trên nền mờ
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ImageFullScreen(
                                                            image: post.media[imgIndex]['url'].toString(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Image.network(
                                                      post.media[imgIndex]['url']!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),

                                          Container(
                                            padding: EdgeInsets.all(10),
                                            height: 50,
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    Like? like;
                                                    DateTime now = DateTime.now();
                                                    DateTime vietnamTime = now.toUtc().add(Duration(hours: 7));
                                                    if(!isLike[index]) {
                                                      addLike ADDLIKE = addLike(
                                                        postId: post.id,
                                                        userId: accountModel.idUser,
                                                        createdAt: vietnamTime.millisecondsSinceEpoch,
                                                      );
                                                      like = await AddLike(ADDLIKE);
                                                    } else {
                                                      await RemoveLike(likeId[index]!.id);
                                                    }
                                                    setState(() {
                                                      if(!isLike[index]) {
                                                        postLike.add(like);
                                                        likeId[index] = like;
                                                      } else {
                                                        postLike.remove(likeId[index]);
                                                        likeId[index] = null;
                                                      }
                                                      isLike[index] = !isLike[index];
                                                    });

                                                  },
                                                  child: Container(
                                                    height: 30,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          getCategoryIcon(index),
                                                          color: Colors.blue,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(postLike.length.toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 30),
                                                GestureDetector(
                                                  onTap: () {
                                                    showComments(context,postComment,post);
                                                  },
                                                  child: Container(
                                                    height: 30,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.comment,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(postComment.length.toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );

            },
          ),
        ),
      ),
    );
  }
}
