import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mapsnap_fe/Manager/CURD_comment.dart';
import 'package:mapsnap_fe/Model/Comment.dart';

import 'package:mapsnap_fe/Model/Posts.dart';
import 'package:mapsnap_fe/Model/User_2.dart';
import 'package:mapsnap_fe/Widget/UpdateUser.dart';
import 'package:mapsnap_fe/Widget/accountModel.dart';
import 'package:provider/provider.dart';

import '../Model/FeedBack.dart';

class CommentScreen extends StatefulWidget {
  final List<Comment> listComment;
  final Posts post;

  CommentScreen({
    Key? key,
    required this.listComment,
    required this.post,
  }) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> with WidgetsBindingObserver {
  final TextEditingController commentController = TextEditingController();
  String? editingCommentId;
  String? FeedBackId;
  double keyboardHeight = 0;
  int commentIndex = 0;
  int FeedBackIndex = 0;
  List<User?> listUser = [];
  Map<String,List<FeedBack?>> FeedBacks = {};
  Map<String,List<User?>> userFeedBacks= {};
  bool isLoading = true;
  List<bool> isExpanded = [];
  static const int maxLinesCollapsed = 3; // Số dòng tối đa khi thu gọn
  bool isFeedBack = false;
  bool addFeedBack = false;
  Map<String,int> countFeedBackComment = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadAllUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardVisibility = MediaQuery.of(context).viewInsets.bottom;
      if (keyboardVisibility != keyboardHeight) {
        setState(() {
          keyboardHeight = keyboardVisibility;
        });
      }
    });
  }

  Future<void> loadAllUsers() async {
    try {
      var accountModel = Provider.of<AccountModel>(context, listen: false);
      listUser = await Future.wait(
        widget.listComment.map((comment) async {
          isExpanded.add(false);
          countFeedBackComment[comment.id] = comment.feedBack.length;
          print(countFeedBackComment[comment.id]);
          if(comment.feedBack.length > 0) {
            for (var feedback in comment.feedBack) {
              // Khởi tạo danh sách nếu chưa có
              FeedBacks[comment.id] ??= [];
              userFeedBacks[comment.id] ??= [];

              // Thêm dữ liệu vào map
              FeedBacks[comment.id]!.add(feedback);
              print(feedback.content);
              var user = await fetchData(feedback.userId, accountModel.token_access);
              userFeedBacks[comment.id]!.add(user);
            }
          } else {
            FeedBacks[comment.id] = [];
            userFeedBacks[comment.id] = [];
          }
          return await fetchData(comment.userId, accountModel.token_access);
        }).toList(),
      );
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("Error loading users: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _deleteComment(Comment comment, int index) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa bình luận này?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Hành động hủy
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white12), // Màu nền cho nút
                ),
                child: const Text("Hủy", style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () async {
                  await RemoveComments(comment.id);
                  setState(() {
                    widget.listComment.removeAt(index);
                    listUser.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Màu nền cho nút
                ),
                child: const Text("Xóa", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _deleteFeedback(Comment comment, int index) {
    showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa bình luận này?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Hành động hủy
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white12), // Màu nền cho nút
                ),
                child: const Text("Hủy", style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () async {
                  await RemoveFeedback(comment.id,comment.feedBack[index].id);
                  setState(() {
                    FeedBacks[comment.id]!.removeAt(index);
                    userFeedBacks[comment.id]!.removeAt(index);
                    countFeedBackComment[comment.id] = countFeedBackComment[comment.id]! - 1;
                    widget.listComment;
                  });
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Màu nền cho nút
                ),
                child: const Text("Xóa", style: TextStyle(color: Colors.white)),
              ),
            ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var accountModel = Provider.of<AccountModel>(context, listen: false);


    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 1,
          minChildSize: 1,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return buildCommentList(scrollController, accountModel);
          },
        ),
      ),
    );
  }

  Widget buildCommentList(ScrollController scrollController, AccountModel accountModel) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bình luận",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: widget.listComment.length,
              itemBuilder: (context, index) {
                var comment = widget.listComment[index];
                var user = listUser[index];
                return buildCommentTile(comment, user, accountModel, index);
              },
            ),
          ),
          buildCommentInput(accountModel),
          if (keyboardHeight > 0)
            Container(
              color: Colors.blue,
              height: keyboardHeight,
            ),
        ],
      ),
    );
  }

  Widget buildCommentTile(Comment comment, User? user, AccountModel accountModel, int index) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
              image: user != null
                  ? DecorationImage(
                image: NetworkImage(user.avatar),
                fit: BoxFit.cover,
              )
                  : null,
            ),
          ),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Chỉnh sửa'),
                            onTap: () {
                              Navigator.pop(context);
                              if(accountModel.idUser == comment.userId) {
                                commentController.text = comment.content;
                                setState(() {
                                  editingCommentId = comment.id;
                                  commentIndex = index;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("không thể chỉnh sửa comment của người khác")),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Xóa'),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteComment(comment, index);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFE1E1E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(12, 5, 12, 0),
                        child: Text(
                          user?.username ?? "Unknown",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 5),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Xác định nếu cần thu gọn dựa trên chiều dài nội dung
                            final textPainter = TextPainter(
                              text: TextSpan(
                                text: comment.content,
                                style: TextStyle(fontSize: 19),
                              ),
                              maxLines: maxLinesCollapsed,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            final isOverflow = textPainter.didExceedMaxLines;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.content,
                                  maxLines: isExpanded[index] ? null : maxLinesCollapsed,
                                  overflow: isExpanded[index]  ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 19),
                                  softWrap: true,
                                ),
                                if (isOverflow)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isExpanded[index]  = !isExpanded[index] ;
                                      });
                                    },
                                    child: Text(
                                      isExpanded[index]  ? "Ẩn bớt" : "Xem thêm",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3,),
              GestureDetector(
                onTap: () {
                  commentController.text = user!.username;
                  setState(() {
                    print("Phản hồi");
                    editingCommentId = comment.id;
                    print(comment.id);
                    FeedBackIndex = comment.feedBack.length;
                    addFeedBack = true;
                  });
                },
                child: Container(
                  child: Text("Phản hồi", style: TextStyle(color: Colors.grey),),
                ),
              ),
              SizedBox(height: 5,),
              if(countFeedBackComment[comment.id]! > 0) ...[
                for(int k = 0; k < countFeedBackComment[comment.id]!; k++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          image: user != null
                              ? DecorationImage(
                            image: NetworkImage(userFeedBacks[comment.id]![k]!.avatar),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                      ),
                      SizedBox( width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.white,
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Chỉnh sửa'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          if(accountModel.idUser == comment.feedBack[k].userId) {
                                            commentController.text = FeedBacks[comment.id]![k]!.content;
                                            setState(() {
                                              editingCommentId = comment.id;
                                              commentIndex = index;
                                              FeedBackIndex = k;
                                              FeedBackId = FeedBacks[comment.id]![k]!.id;
                                              isFeedBack = true;
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text("không thể chỉnh sửa comment của người khác")),
                                            );
                                          }
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Xóa'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _deleteFeedback(comment, k);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth - 142,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(12, 5, 12, 0),
                                    child: Text(
                                      userFeedBacks[comment.id]![k]!.username,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    // ,
                                    padding: EdgeInsets.fromLTRB(12, 0, 12, 5),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Xác định nếu cần thu gọn dựa trên chiều dài nội dung
                                        final textPainter = TextPainter(
                                          text: TextSpan(
                                            text: FeedBacks[comment.id]![k]!.content,
                                            style: TextStyle(fontSize: 19),
                                          ),
                                          maxLines: maxLinesCollapsed,
                                          textDirection: TextDirection.ltr,
                                        )..layout(maxWidth: constraints.maxWidth);

                                        final isOverflow = textPainter.didExceedMaxLines;

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              FeedBacks[comment.id]![k]!.content,
                                              maxLines: isExpanded[index] ? null : maxLinesCollapsed,
                                              overflow: isExpanded[index]  ? TextOverflow.visible : TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 19),
                                              softWrap: true,
                                            ),
                                            if (isOverflow)
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isExpanded[index]  = !isExpanded[index] ;
                                                  });
                                                },
                                                child: Text(
                                                  isExpanded[index]  ? "Ẩn bớt" : "Xem thêm",
                                                  style: TextStyle(color: Colors.blue),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 3,),
                          GestureDetector(
                            onTap: () {
                              print(comment.feedBack.length);
                              print("Phản hồi");
                              commentController.text = user!.username;
                              setState(() {
                                // commentIndex = index;
                              });
                            },
                            child: Container(
                              child: Text("Phản hồi", style: TextStyle(color: Colors.grey),),
                            ),
                          ),
                          SizedBox(height: 8,),
                        ],
                      ),
                    ],
                  )
                ]
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCommentInput(AccountModel accountModel) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: editingCommentId == null
                  ? "Viết bình luận..."
                  : "Chỉnh sửa bình luận...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () async {
            if (commentController.text.isNotEmpty) {
              DateTime now = DateTime.now();
              DateTime vietnamTime = now.toUtc().add(Duration(hours: 7));
              Comment? comment;

              if (editingCommentId == null && !isFeedBack) {
                addComment addcomment = addComment(
                  postId: widget.post.id,
                  userId: accountModel.idUser,
                  content: commentController.text,
                  createdAt: vietnamTime.millisecondsSinceEpoch,
                  updatedAt: vietnamTime.millisecondsSinceEpoch,
                );
                comment = await AddComment(addcomment);
                User? user = await fetchData(comment!.userId, accountModel.token_access);
                setState(() {
                  widget.listComment.insert(0, comment!);
                  listUser.insert(0, user);
                  isExpanded.insert(0,false);
                  widget.listComment[commentIndex] = comment;
                  countFeedBackComment[comment.id] = 0;
                });
              } else if (editingCommentId != null && !isFeedBack && addFeedBack) {
                addComment addcomment = addComment(
                  postId: widget.post.id,
                  userId: accountModel.idUser,
                  content: commentController.text,
                  createdAt: vietnamTime.millisecondsSinceEpoch,
                  updatedAt: vietnamTime.millisecondsSinceEpoch,
                );
                comment = await AddFeedback(addcomment,editingCommentId!);
                User? user = await fetchData(accountModel.idUser, accountModel.token_access);
                setState(() {
                  userFeedBacks[comment!.id]!.add(user);
                  FeedBacks[comment.id]!.add(comment.feedBack[FeedBackIndex]);
                  countFeedBackComment[comment.id] = countFeedBackComment[comment.id]! + 1;
                  print("Thêm thành công");
                  addFeedBack = false;
                  widget.listComment[commentIndex] = comment;
                });
              } else if(editingCommentId != null && !isFeedBack && !addFeedBack) {
                addComment addcomment = addComment(
                  postId: widget.post.id,
                  userId: accountModel.idUser,
                  content: commentController.text,
                  createdAt: vietnamTime.millisecondsSinceEpoch,
                  updatedAt: vietnamTime.millisecondsSinceEpoch,
                );
                comment = await updateComment(addcomment, editingCommentId!);
                setState(() {
                  widget.listComment[commentIndex] = comment!;
                });
              } else if(editingCommentId != null && isFeedBack && !addFeedBack) {
                comment = await updateFeedback(commentController.text, editingCommentId!, FeedBackId!);
                setState(() {
                  FeedBacks[editingCommentId!]![FeedBackIndex] = comment!.feedBack[FeedBackIndex];
                  widget.listComment[commentIndex] = comment;
                  isFeedBack = false;
                });
              }
              commentController.clear();
              setState(() {
                editingCommentId = null;
              });
            }
          },
        ),
      ],
    );
  }
}
