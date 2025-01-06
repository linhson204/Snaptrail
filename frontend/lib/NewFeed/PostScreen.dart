

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapsnap_fe/Model/Picture.dart';
import 'package:provider/provider.dart';

import '../Manager/CURD_location.dart';
import '../Manager/CURD_picture.dart';
import '../Manager/CURD_posts.dart';
import '../Model/Location.dart';
import '../Model/Posts.dart';
import '../Model/forwardGeocoding.dart';
import '../Widget/accountModel.dart';
import '../Widget/text_field_input.dart';
import 'FullScreenImageGallery.dart';
import 'ImageFullScreen.dart';

class PostScreen extends StatefulWidget {
  PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController postContentController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<XFile>? images = [];
  List<Map<String, String>> listMedia = [];
  List<String> imageULR = [];
  Location? location;
  List<Location> listLocation = [];
  bool isCurrentLocationSelected = false;
  String address = "Một nơi nào đó";
  String district = "...";
  String commune = "...";
  String province = "...";
  late TextEditingController addressController = TextEditingController();



  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    var accountModel = Provider.of<AccountModel>(context, listen: false);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Bài viết mới"),
          actions: [
            IconButton(
              onPressed: () async {
                final pickedFiles = await picker.pickMultiImage();
                if (pickedFiles != null) {
                  setState(() {
                    images = pickedFiles; // Lưu danh sách ảnh được chọn
                  });
                  DateTime now = DateTime.now();
                  DateTime vietnamTime = now.toUtc().add(Duration(hours: 7));
                  List<Future<void>> uploadTasks = images!.map((file) async {
                    CreatePicture createPicture = CreatePicture(
                      userId: accountModel.idUser,
                      link: file.path,
                      capturedAt: vietnamTime,
                      isTakenByCamera: false,
                    );
                    List<Picture>? picture = await upLoadImage(createPicture);
                    print("Server link: ${picture![0].link}");
                    imageULR.add(picture[0].link);
                  }).toList();
                  await Future.wait(uploadTasks);
                  setState(() {
                  });
                }
              },
              icon: Icon(Icons.phone_android, size: 30),
            ),
          ],
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Nội dung bài viết
                  TextField(
                    controller: postContentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Nội dung bài viết...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
            
                  Container(
                    height: imageULR.isNotEmpty
                        ? ((imageULR.length > 4 ? 2 : (imageULR.length / (imageULR.length > 1 ? 2 : 1)).ceil()) *
                        (screenWidth / (imageULR.length > 1 ? 2 : 1))) +
                        ((imageULR.length > 4 ? 1 : (imageULR.length / (imageULR.length > 1 ? 2 : 1)).ceil() - 1) * 5)
                        : 0,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: imageULR.length > 1 ? 2 : 1,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1,
                      ),
                      itemCount: imageULR.length > 4 ? 4 : imageULR.length,
                      itemBuilder: (context, imgIndex) {
                        if (imgIndex == 3 && imageULR.length > 4) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageGallery(
                                    images: listMedia, // Toàn bộ danh sách ảnh
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
                                      image: NetworkImage(imageULR[imgIndex]),
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
                                  "+${(imageULR.length - 4).toString()}",
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
                                    image: imageULR[imgIndex],
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              imageULR[imgIndex],
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      },
                    ),
                  ),
            
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Địa điểm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
            
                      // Nút chọn "Vị trí hiện tại"
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (!isCurrentLocationSelected) {
                                try {
                                  Map<String, double> coordinates = randomVietnamCoordinates();
                                  InfoVisit? infoLocation = await AutoLocation(coordinates['latitude']!,coordinates['longitude']!,accountModel.idUser);
                                  // Cập nhật trạng thái
                                  setState(() {
                                    address = infoLocation!.address;
                                    province = infoLocation.province;
                                    commune = infoLocation.commune;
                                    district = infoLocation.district;
                                    isCurrentLocationSelected = true;
                                    addressController.clear();
                                  });
                                } catch (e) {
                                  print("Không thể lấy vị trí hiện tại: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Không thể lấy vị trí hiện tại!")),
                                  );
                                }
                              } else {
                                setState(() {
                                  isCurrentLocationSelected = false;
                                  location = null;
                                  addressController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrentLocationSelected ? Colors.red : Colors.blue,
                            ),
                            icon: Icon(
                              isCurrentLocationSelected ? Icons.close : Icons.my_location,
                            ),
                            label: Text(
                              isCurrentLocationSelected ? "Hủy vị trí hiện tại" : "Chọn vị trí hiện tại",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isCurrentLocationSelected)
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                        ],
                      ),

                      SizedBox(height: 15,),
                      TextFieldInput(
                        textEditingController: addressController,
                        hintText: "Nhập địa điểm",
                        textInputType: TextInputType.text,
                        isEnabled: !isCurrentLocationSelected,
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
            
                  SizedBox(height: 50),
                  // Nút đăng bài
                  ElevatedButton.icon(
                    onPressed: () async {
                      String content = postContentController.text.trim();
                      for (int i = 0; i < imageULR.length; i++) {
                        listMedia.add({
                          "type": "image",
                          "url": imageULR[i],
                        });
                      }
                      if (content.isNotEmpty) {
                        var accountModel = Provider.of<AccountModel>(context, listen: false);
                        DateTime now = DateTime.now();
                        DateTime vietnamTime = now.toUtc().add(Duration(hours: 7));
                        if(!isCurrentLocationSelected) {
                          ForwardGeocoding? infoLocation = await GetLatIngbyAddress(addressController.text);
                          address = infoLocation!.formatted_address;
                          province = infoLocation.province;
                          commune = infoLocation.commune;
                          district = infoLocation.district;
                        }
                        CreatePost createPost = CreatePost(
                          userId: accountModel.idUser,
                          content: postContentController.text,
                          media: listMedia,
                          createdAt: vietnamTime.millisecondsSinceEpoch,
                          updatedAt: vietnamTime.millisecondsSinceEpoch,
                          commentsCount: 0,
                          likesCount: 0,
                          district: district,
                          commune: commune,
                          province: province,
                          address: address,
                        );
                        Posts? posts = await upLoadPost(createPost);
                        Navigator.pop(context, posts);// Quay lại màn hình chính
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Vui lòng nhập nội dung bài viết!")),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue), // Màu nền
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white), // Màu chữ
                    ),
                    icon: Icon(Icons.post_add_outlined,size: 35,),
                    label: Text("Đăng bài", style: TextStyle(fontSize: 25),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String hintText, TextInputType inputType, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        TextFieldInput(
          textEditingController: controller,
          hintText: hintText,
          textInputType: inputType,
          isEnabled: enabled,
        ),
      ],
    );
  }
}

Map<String, double> randomVietnamCoordinates() {
  final random = Random();

  // Giới hạn Latitude và Longitude trong phạm vi Việt Nam
  double minLat = 8.179;
  double maxLat = 23.392;
  double minLng = 102.144;
  double maxLng = 109.464;

  // Random tọa độ
  double randomLat = minLat + (maxLat - minLat) * random.nextDouble();
  double randomLng = minLng + (maxLng - minLng) * random.nextDouble();

  return {
    'latitude': randomLat,
    'longitude': randomLng,
  };
}

