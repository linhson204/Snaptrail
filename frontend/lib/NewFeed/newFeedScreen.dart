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

class newFeedScreen extends StatefulWidget {
  newFeedScreen({Key? key}) : super(key: key);

  @override
  State<newFeedScreen> createState() => _newFeedScreenState();
}

class _newFeedScreenState extends State<newFeedScreen> {
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
  String province = '';
  String district = '';
  String commune = '';
  ScrollController scrollController = ScrollController();
  bool hehe = true;

  final TextEditingController commentController = TextEditingController();

  bool result = false;


  Future<void> getPageData() async {
    pagePost = await getInfoPosts2(1.toString(),"page",'','','');
    totalPages = pagePost!.totalPages;
  }

  void resetPage() {
    setState(() {
      // Reset các biến về trạng thái ban đầu
      isLike = [];
      count = 0;
      listPost = Future.value([]);
      user = [];
      like = [];
      comments = [];
      likeId = [];
      posts = [];
      timePost = [];
      currentPage = 1;
      totalPages = 1;
      isLoadData = true;
      province = '';
      district = '';
      commune = '';
      hehe = true;
    });

    // Gọi lại hàm khởi tạo dữ liệu
    initializePageData();
  }


  @override
  void initState() {
    var accountModel = Provider.of<AccountModel>(context, listen: false);
    getPageData();
    scrollController.addListener(() {
      if (scrollController.position.atEdge && scrollController.position.pixels != 0 && isLoadData) {
        currentPage++;
        // Load next page when scrolled to the bottom
        listPost = resetData(currentPage).then((posts) async {
          user = List<User?>.generate(posts.length, (index) => null);
          like = List<List<Like?>>.generate(posts.length, (index) => []);
          comments = List<List<Comment>>.generate(posts.length, (index) => []);
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
      if (scrollController.position.pixels <= 0) {
        // Khi cuộn đến đầu trang
        setState(() {
          resetPage();
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


  Future<List<Posts>> resetData(int page) async {
    pagePost = await getInfoPosts2(page.toString(),"page",'','','');
    posts.addAll(pagePost!.results);
    return posts;
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


  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var accountModel = Provider.of<AccountModel>(context, listen: false);
    startAutoRefreshToken(context, accountModel.token_refresh_expires,accountModel.token_refresh,accountModel.idUser);

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
              if (snapshot.connectionState == ConnectionState.waiting && hehe) {
                return Center(
                    child:AnimatedRotation(
                      turns: 1, // xoay một vòng
                      duration: Duration(seconds: 1),
                      child: CircularProgressIndicator(),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // || snapshot.data!.isEmpty
                return Center(
                    child: Scaffold(
                      body: Center(child:AnimatedRotation(
                        turns: 1, // xoay một vòng
                        duration: Duration(seconds: 1),
                        child: CircularProgressIndicator(),
                      ),),
                    )
                );
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => personalPageScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                        image: DecorationImage(
                                          image: NetworkImage(accountModel.avatar),
                                          fit: BoxFit.cover,
                                        )
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostScreen(),
                                      ),
                                    ).then((success) async {
                                      if (success != null) {
                                        User? infoUser = await getUser(success.userId, accountModel.token_access);
                                        setState(()  {
                                          posts.insert(0,success);
                                          user.insert(0,null);
                                          isLike.insert(0, false);
                                          user[0] = infoUser;
                                          like.insert(0, []);
                                          comments.insert(0, []);
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue, // Màu viền
                                        width: 2.0,
                                      )
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: Icon(Icons.add, size: 35,),
                                        ),
                                        Text("Bài viết mới   ", style: TextStyle(fontSize: 25),)
                                      ],
                                    ),
                                  )
                                ),
                                SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => sreachScreen(),
                                        )
                                    );
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    child: Icon(Icons.search, size: 40,),
                                  ),
                                ),
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
