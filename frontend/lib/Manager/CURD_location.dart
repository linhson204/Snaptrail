import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Model/Location.dart';
import '../Model/forwardGeocoding.dart';




Future<InfoVisit?> AutoLocation(double lat, double lng,String userId) async {
  final url = Uri.parse('http://10.0.2.2:3000/v1/location/reverse-geocoding?lat=$lat&lng=$lng&userId=$userId');
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
    );

    if (response.statusCode == 200) {
      // Xử lý thành công
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data);
      return InfoVisit.fromJson(data);
    } else {
      // Xử lý lỗi từ API
      print(response.statusCode);
    }
  } catch (e) {
    // Xử lý lỗi khác
    print('Error: $e');
  }
  return null;
}



Future<ForwardGeocoding?> GetLatIngbyAddress(String address) async {
  final url = Uri.parse('http://10.0.2.2:3000/v1/goong/forward-geocoding?address=$address');
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
    );

    if (response.statusCode == 200) {
      // Xử lý thành công
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // print(data);
      return ForwardGeocoding.fromJson(data);
    } else {
      // Xử lý lỗi từ API
      print(response.statusCode);
    }
  } catch (e) {
    // Xử lý lỗi khác
    print('Error: $e');
  }
  return null;
}