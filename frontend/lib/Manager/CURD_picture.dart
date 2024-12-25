import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:mapsnap_fe/Model/Picture.dart';

import 'package:mime/mime.dart';


// API để gọi tải ảnh lên Database
Future<List<Picture>?> upLoadImage(CreatePicture createPicture) async {
  if (createPicture.link == null) {
    print('Không có ảnh nào được chọn!');
    return null;
  }
  final File imgFile = File(createPicture.link);

  // Địa chỉ API
  final String url = 'http://10.0.2.2:3000/v1/pictures';

  // Tạo yêu cầu `MultipartRequest`
  final request = http.MultipartRequest('POST', Uri.parse(url));

  // Xác định loại MIME của file và thêm vào yêu cầu
  final mimeTypeData = lookupMimeType(imgFile.path)!.split('/');
  final multipartFile = await http.MultipartFile.fromPath(
    'picture',
    imgFile.path,
    contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
  );

  // Thêm file ảnh vào yêu cầu `multipart`
  request.files.add(multipartFile);
  request.fields['userId'] = createPicture.userId;
  request.fields['capturedAt'] = createPicture.capturedAt.millisecondsSinceEpoch.toString();
  request.fields['isTakenByCamera'] = createPicture.isTakenByCamera.toString();

  // Gửi yêu cầu
  final response = await request.send();

  // Xử lý phản hồi
  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    List<dynamic> data = jsonDecode(responseData);
    List<Picture> pictures = data.map((json) => Picture.fromJson(json)).toList();
    return pictures;
  } else {
    print('Lỗi: ${response.statusCode} ');
  }
}







