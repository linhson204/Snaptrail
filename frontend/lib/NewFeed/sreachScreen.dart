import 'package:flutter/material.dart';
import '../Widget/text_field_input.dart';
import 'newFeedScreen2.dart';

class sreachScreen extends StatefulWidget {
  @override
  _sreachScreenState createState() => _sreachScreenState();
}

class _sreachScreenState extends State<sreachScreen> {
  final TextEditingController selectedCommune = TextEditingController();
  final TextEditingController selectedDistrict = TextEditingController();
  final TextEditingController selectedProvince = TextEditingController();
  bool isSearch = true;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi
    selectedProvince.addListener(_onProvinceChange);
    selectedDistrict.addListener(_onDistrictChange);

  }

  void _onProvinceChange() {
    if (selectedProvince.text == '') {
      print("Xóa huyện và xã");
      selectedDistrict.clear();
      selectedCommune.clear();
    }
    setState(() {});
  }


  void _onDistrictChange() {
    if (selectedDistrict.text.isEmpty) {
      selectedCommune.clear();
    }
    setState(() {});
  }

  @override
  void dispose() {
    // Dọn dẹp bộ nhớ
    selectedCommune.dispose();
    selectedDistrict.dispose();
    selectedProvince.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.keyboard_arrow_left, size: 50, color: Colors.black),
                    ),
                    Text(
                      "Tìm kiếm",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                    )
                  ],
                ),
                SizedBox(height: 15),

                // Search Form
                Column(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tỉnh/thành phố", style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
                          SizedBox(height: 5,),
                          TextFieldInput(
                            textEditingController: selectedProvince,
                            hintText: "Nhập tỉnh/thành phố",
                            textInputType: TextInputType.text,
                            isEnabled: true,
                          ),
                        ],
                      )
                    ),
                    SizedBox(height: 15),
                    Visibility(
                      visible: selectedProvince.text.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Huyện/quận", style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            TextFieldInput(
                              textEditingController: selectedDistrict,
                              hintText: "Nhập huyện/quận",
                              textInputType: TextInputType.text,
                              isEnabled: true,
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 15),
                    Visibility(
                        visible: selectedProvince.text.isNotEmpty && selectedDistrict.text.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Xã/phường", style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            TextFieldInput(
                              textEditingController: selectedCommune,
                              hintText: "Nhập xã/phường",
                              textInputType: TextInputType.text,
                              isEnabled: true,
                            ),
                          ],
                        )
                    ),

                    SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        if(selectedProvince.text.isNotEmpty && selectedDistrict.text.isNotEmpty && selectedCommune.text.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => newFeedScreen2(province: selectedProvince.text, district: selectedDistrict.text, commune: selectedCommune.text,),

                            ),
                          );
                        } else if(selectedProvince.text.isNotEmpty && selectedDistrict.text.isNotEmpty && selectedCommune.text.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => newFeedScreen2(province: selectedProvince.text, district: selectedDistrict.text, commune: '',),
                            ),
                          );
                        } else if(selectedProvince.text.isNotEmpty && selectedDistrict.text.isEmpty && selectedCommune.text.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => newFeedScreen2(province: selectedProvince.text, district: '', commune: '',),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Màu nền cho nút
                      ),
                      child: Text(' Xác nhận ', style: TextStyle(fontSize: 22, color: Colors.white),),
                    ),
                  ],
                ),

                SizedBox(height: 10),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
