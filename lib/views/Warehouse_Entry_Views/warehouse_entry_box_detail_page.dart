import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../utils/appcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseEntryBoxDetailsPage extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const WarehouseEntryBoxDetailsPage({required this.itemData, Key? key}) : super(key: key);

  @override
  State<WarehouseEntryBoxDetailsPage> createState() => _WarehouseEntryBoxDetailsPageState();
}

class _WarehouseEntryBoxDetailsPageState extends State<WarehouseEntryBoxDetailsPage> {
  List<Map<String, dynamic>> deletedItems = [];
  Map<int, String> boxCodes = {};
  Map<int, int> sucChua = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra và đảm bảo `MaSanPham` có sẵn trước khi gọi `_loadBoxCodesFromPreferences`
    if (widget.itemData['MaSanPham'] != null && widget.itemData['MaSanPham'].isNotEmpty) {
      _loadBoxCodesFromPreferences();
    } else {
      print("Error: MaSanPham is not available.");
    }
  }

  Future<void> _loadBoxCodesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? productCode = widget.itemData['MaSanPham'];

    if (productCode != null && productCode.isNotEmpty) {
      String key = 'warehouseEntry_$productCode';
      String? savedBoxCodes = prefs.getString('boxCodes_$key');
      String? savedSucChua = prefs.getString('sucChua_$key');

      // In ra console để kiểm tra dữ liệu tải về
      print("Loading data from SharedPreferences with key: $key");
      print("Loaded boxCodes: $savedBoxCodes");
      print("Loaded sucChua: $savedSucChua");

      // Kiểm tra nếu dữ liệu tồn tại, tiến hành cập nhật `boxCodes` và `sucChua`
      if (savedBoxCodes != null && savedSucChua != null) {
        setState(() {
          // Parse dữ liệu từ JSON và cập nhật các Map
          Map<String, String> boxCodesStringKey = Map<String, String>.from(json.decode(savedBoxCodes));
          boxCodes = boxCodesStringKey.map((key, value) => MapEntry(int.parse(key), value));

          Map<String, int> sucChuaStringKey = Map<String, int>.from(json.decode(savedSucChua));
          sucChua = sucChuaStringKey.map((key, value) => MapEntry(int.parse(key), value));

          isDataLoaded = true; // Cập nhật trạng thái khi có dữ liệu
        });
      } else {
        print("No data found for key: $key");
      }
    } else {
      print("Error: MaSanPham is not available.");
    }
  }

  Future<void> _saveBoxCodesToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? productCode = widget.itemData['MaSanPham'];

    if (productCode != null && productCode.isNotEmpty) {
      String key = 'warehouseEntry_$productCode';

      Map<String, String> boxCodesStringKey = boxCodes.map((key, value) => MapEntry(key.toString(), value));
      Map<String, int> sucChuaStringKey = sucChua.map((key, value) => MapEntry(key.toString(), value));

      String boxCodesJson = json.encode(boxCodesStringKey);
      String sucChuaJson = json.encode(sucChuaStringKey);

      // Print để kiểm tra dữ liệu lưu trữ
      print("Saving data to SharedPreferences with key: $key");
      print("boxCodes: $boxCodesJson");
      print("sucChua: $sucChuaJson");

      await prefs.setString('boxCodes_$key', boxCodesJson);
      await prefs.setString('sucChua_$key', sucChuaJson);
    } else {
      print("Error: MaSanPham is not available.");
    }
  }

  Future<void> _navigateToWarehouseEntryDetails(BuildContext context, Map<String, dynamic> data, int index) async {
    // Điều hướng đến WarehouseBoxPage thay vì WarehouseEntryDetailsPage
    final result = await Navigator.pushNamed(
      context,
      '/warehouse_entry_detail',
      arguments: data, // Đảm bảo item là Map<String, dynamic>
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // Cập nhật trạng thái của sản phẩm thành "đã gán sản phẩm"
        data['status'] = result['status'];
        boxCodes[index] = result['boxQRCode'];
        sucChua[index]=result['sucChua'];
        print(sucChua[index]);
        // print('max thungf: $boxCode');
      });
      await _saveBoxCodesToPreferences();
      // Kiểm tra nếu tất cả các thùng đã có mã QR
      bool allBoxesHaveCodes = widget.itemData['boxes'].asMap().keys.every((i) => boxCodes[i]?.isNotEmpty ?? false);
      // Nếu tất cả các thùng đã có mã QR, hiển thị thông báo
      if (allBoxesHaveCodes) {
        // _showAllBoxesAssignedDialog();
        deletedItems.add(data);
        final prefs = await SharedPreferences.getInstance();
        List<String> deletedList = deletedItems.map((item) => json.encode(item)).toList();
        await prefs.setStringList('deletedWarehouseEntries', deletedList);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxes = widget.itemData['boxes'] ?? [];

    return Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: AppColor.backgroundAppColor,
          leading: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/homePage');
            },
            child: Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
            ),
          ),
          title: Row(
            children: [
              Text(
                'Chi tiết Phiếu Nhập kho',
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainText,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Phần thông tin sản phẩm cố định
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần hình ảnh sản phẩm
                if (widget.itemData['HinhAnh'] != null && widget.itemData['HinhAnh'].isNotEmpty)
                  Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 16.0),
                    child: Image.network(
                      'https://admin-demo-saas.mylanhosting.com${widget.itemData['HinhAnh'][0]}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                // Phần thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị tên, mã sản phẩm và số lượng
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Tên sản phẩm: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.normal,
                                color: AppColor.mainText,
                              ),
                            ),
                            TextSpan(
                              text: "${widget.itemData['TenSanPham'] ?? ''}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: AppColor.mainText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Mã PO: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.normal,
                                color: AppColor.mainText,
                              ),
                            ),
                            TextSpan(
                              text: "${widget.itemData['MaSanPham'] ?? ' '}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: AppColor.mainText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Số lượng nhập: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.normal,
                                color: AppColor.mainText,
                              ),
                            ),
                            TextSpan(
                              text: "${widget.itemData['SoLuongNhap'] ?? ' '}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: AppColor.mainText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Kiểm tra `isDataLoaded` để xác định hiển thị dữ liệu
          if (isDataLoaded)
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: boxes.asMap().entries.map<Widget>((entry) {
                      int index = entry.key;
                      final box = entry.value;
                      return GestureDetector(
                        onTap: () {
                          _navigateToWarehouseEntryDetails(context, widget.itemData, index);
                        },
                        child: _buildScanRow(
                          context,
                          "Thùng ${index + 1}",
                          "Số lượng: ${sucChua[index] ?? ''}",
                          "${boxCodes[index] ?? ''}", // Truyền mã QR vào đây
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0), // Căn lề cho các nút
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Chia đều các nút
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.borderInputColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                onPressed: () async {
                  // Điều hướng sang WarehouseEntryDetailsPage và đợi dữ liệu trả về
                  final newBoxData = await Navigator.pushNamed(
                    context,
                    "/warehouse_entry_detail",
                    arguments: widget.itemData,
                  );

                  // Kiểm tra nếu dữ liệu trả về không rỗng, cập nhật danh sách thùng
                  if (newBoxData != null && newBoxData is Map<String, dynamic>) {
                    setState(() {
                      // Khởi tạo boxes nếu là null
                      widget.itemData['boxes'] ??= [];

                      // Thêm dữ liệu thùng mới vào danh sách boxes của widget.itemData
                      widget.itemData['boxes'].add(newBoxData);

                      int newIndex = widget.itemData['boxes'].length - 1;
                      boxCodes[newIndex] = newBoxData['boxQRCode']; // Cập nhật mã QR
                      sucChua[newIndex] = newBoxData['sucChua'];
                    });
                    // Lưu lại mã QR mới vào SharedPreferences nếu cần
                    await _saveBoxCodesToPreferences();
                  }
                },
                child: Text(
                  "Thêm Thùng",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.borderInputColor, // Màu nền cho nút thứ hai
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                onPressed: () {
                  // Tính tổng sức chứa của các thùng
                  int totalSucChua = sucChua.values.fold(0, (sum, quantity) => sum + quantity);
                  int soLuongNhap = widget.itemData['SoLuongNhap'] ?? 0;

                  // Xác định nội dung và màu sắc thông báo
                  String message;
                  Color messageColor;

                  if (totalSucChua > soLuongNhap) {
                    message = "Tổng số lượng các thùng lớn hơn số lượng nhập.";
                    messageColor = Colors.red; // Màu đỏ cho cảnh báo lớn hơn
                  } else if (totalSucChua < soLuongNhap) {
                    message = "Tổng số lượng các thùng nhỏ hơn số lượng nhập.";
                    messageColor = Colors.deepOrangeAccent; // Màu cam cho cảnh báo nhỏ hơn
                  } else {
                    message = "Tổng số lượng các thùng bằng với số lượng nhập.";
                    messageColor = Colors.green; // Màu xanh cho thông báo hợp lệ
                  }

                  // Hiển thị dialog xác nhận
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Xác nhận gán sản phẩm",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainText,
                          ),
                        ),
                        content: Text(
                          message,
                          style: TextStyle(
                            fontSize: 18,
                            color: messageColor, // Áp dụng màu cảnh báo
                          ),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColor.borderInputColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Đóng dialog
                            },
                            child: Text(
                              "Hủy",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColor.borderInputColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // Cập nhật trạng thái "Đã đồng bộ" và quay lại trang trước với dữ liệu đã cập nhật
                              setState(() {
                                widget.itemData['status'] = "Đã đồng bộ";
                              });
                              Navigator.of(context).pop(); // Đóng dialog
                              Navigator.pop(context, widget.itemData); // Quay lại với dữ liệu
                            },
                            child: Text(
                              "Xác nhận",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Gán sản phẩm",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  // Xây dựng giao diện cho hàng thông tin thùng
  Widget _buildScanRow(BuildContext context, String label, String value, String boxCode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.08),
                child: Text(label, style: TextStyle(fontSize: screenWidth * 0.045, color: AppColor.mainText)),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.08, right: screenWidth * 0.08),
                child: Text(value, style: TextStyle(fontSize: screenWidth * 0.045, color: AppColor.borderInputColor)),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.08),
                child: Icon(Icons.inventory_2_outlined, color: AppColor.mainText),
              ),
            ],
          ),
          // Điều kiện hiển thị mã thùng theo index
          if (boxCode.isNotEmpty) // Chỉ hiển thị mã thùng nếu mã không rỗng
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Mã thùng: $boxCode", style: TextStyle(fontSize: screenWidth * 0.045, color: AppColor.mainText)),
            ),
        ],
      ),
    );
  }
}