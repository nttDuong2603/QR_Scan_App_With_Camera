import 'dart:convert';

import 'package:flutter/material.dart';
import '../../controllers/api_controller.dart';
import '../../utils/app_format.dart';
import '../../views/Warehouse_Relase_Views/warehouse_relase_details.dart';
import '../../views/Warehouse_Relase_Views/warehouse_relase_infor_page.dart';

import '../../utils/appcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseReleaseListPage extends StatefulWidget {
  const WarehouseReleaseListPage({super.key});

  @override
  State<WarehouseReleaseListPage> createState() => _WarehouseReleaseListPageState();
}

class _WarehouseReleaseListPageState extends State<WarehouseReleaseListPage> {
  bool _isExpanded = false;
  List<Map<String, dynamic>> confirmedReleses = [];
  final AppFormat appFormat = AppFormat();
  Map<int, bool> expandedItems = {};
  final APIController _apiController = APIController();
  Map<String, String> trangThaiMap = {}; // Lưu trạng thái với mã PNK làm khóa

  @override
  initState(){
    super.initState();
    _loadWarehoseReleaseFromSharedPreferences();
  }

  Future<void> _fetchTrangThaiPXK(String PXK) async {
    final apiResponse = await _apiController.FetchTrangThaiPXK(PXK);
    if (apiResponse != null) {
      final decodedData = json.decode(apiResponse);
      print("decodedData: $decodedData");
      if (decodedData is Map<String, dynamic> && decodedData["data"] is List && decodedData["data"].isNotEmpty) {
        // Cập nhật trạng thái vào Map với khóa là PNK
        setState(() {
          trangThaiMap[PXK] = decodedData["data"][0]['tenTrangThai'];
        });
      }
    }
  }

  Future<void> _loadWarehoseReleaseFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy tài khoản người dùng hiện tại từ SharedPreferences
    String? currentUser = prefs.getString('currentUser'); // Đảm bảo giá trị này được set sau khi đăng nhập thành công

    if (currentUser != null) {
      // Lấy danh sách lịch nhập kho đã lưu
      List<String> orderList = prefs.getStringList('warehouseReleases') ?? [];
      // print("Order list from SharedPreferences: $orderList");

      // Chuyển đổi từng mục thành Map và lọc theo tài khoản người dùng hiện tại
      setState(() {
        confirmedReleses = orderList
            .map((order) => json.decode(order) as Map<String, dynamic>)
            .where((entry) => entry['userAccount'] == currentUser) // Chỉ lấy các mục có userAccount khớp với tài khoản hiện tại
            .toList();
      });
      print('list phiếu: $confirmedReleses');
    } else {
      print("No current user found.");
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundAppColor,
        leading:
        InkWell(
          onTap: () {},
          child:
          Image.asset(
            'assets/images/logo.png',
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
          ),
        ),
        title: Text(
          'Danh sách Phiếu Xuất kho',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.02),
        itemCount: confirmedReleses.length,
        itemBuilder: (context, index) {
          final release = confirmedReleses[index];
          final orderDetails = release['orderDetails'];
          final PXK = orderDetails['MaPhieuXuatKho'];
          final items = release['items'];
          final _isExpanded = expandedItems[index] ?? false;
          if (!trangThaiMap.containsKey(PXK)) {
            _fetchTrangThaiPXK(PXK);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Bao bọc nội dung `title` bằng `GestureDetector`
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WarehouseRelaseInforPage(),
                                settings: RouteSettings(
                                  arguments: {
                                    'orderDetails':orderDetails,
                                    'items': release['items']}   // Truyền orderDetails sang trang chi tiết
                                ),
                              ),
                            );
                          },
                          child:
                          Padding(
                            padding: const EdgeInsets.all(8.0), // Thêm padding cho toàn bộ nội dung
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow("Phiếu Xuất Kho", orderDetails['MaPhieuXuatKho']),
                                SizedBox(height: 4),
                                _buildInfoRow("Ngày Xuất", orderDetails['NgayXuatKho']),
                                SizedBox(height: 4),
                                _buildInfoRow(
                                  "Trạng Thái",
                                  trangThaiMap[PXK] ?? "",
                                  textColor: (trangThaiMap[PXK] == "Hoàn Thành Xuất Kho") ? Colors.green : AppColor.mainText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Icon mở rộng
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColor.mainText,
                        ),
                        onPressed: () {
                          setState(() {
                            setState(() {
                              expandedItems[index] = !(expandedItems[index] ?? false);
                            });// Thay đổi trạng thái khi nhấn vào icon
                          });
                        },
                      ),
                    ],
                  ),
                  // Sử dụng `Visibility` để kiểm soát hiển thị phần mở rộng
                  Visibility(
                    visible: _isExpanded,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 9.0),
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.55,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Danh sách Lệnh Xuất Hàng :",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.mainText,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: items.map<Widget>((item) {
                                  return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WarehouseRelaseDetails(),
                                            settings: RouteSettings(
                                              arguments: {
                                                'release': release,
                                                'selectedTO': item,  // Lấy sản phẩm từ `selectedTO` trong `WarehouseRelaseDetails`
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "TO: ",
                                                        style: TextStyle(
                                                          color: AppColor.mainText,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "${item['MaLenhXuatHang']}",
                                                        style: TextStyle(
                                                          color: AppColor.mainText,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Cửa hàng: ",
                                                        style: TextStyle(
                                                          color: AppColor.mainText,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "${orderDetails!['TenCuaHang']}",
                                                        style: TextStyle(
                                                          color: AppColor.mainText,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Ghi chú: ",
                                                        style: TextStyle(
                                                          color: AppColor.mainText,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "${item!['GhiChu_LXH'] ?? ''} ",
                                                        style: TextStyle(
                                                          color: AppColor.mainText,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Icon(
                                              Icons.navigate_next, // Mã QR icon
                                              color: AppColor.mainText,
                                              size: 30
                                          ))
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.backgroundAppColor,
        items: [
          BottomNavigationBarItem(
            icon: SizedBox.shrink(), // Mục bên trái trống
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColor.mainText,
              size: 35,
            ),
            label: 'Tạo Lịch',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(), // Mục bên phải trống
            label: '',
          ),
        ],
        onTap: (index) {
          if (index == 1) { // Xử lý chỉ khi chọn mục giữa
            Navigator.pushNamed(context, "/warehouse_release_ad_infor_page");
          }
        },
        selectedLabelStyle: TextStyle(
          fontSize: screenWidth * 0.055,
          color: AppColor.mainText,
        ),
        unselectedFontSize: screenWidth * 0.055,
        selectedItemColor: AppColor.mainText,
        unselectedItemColor: AppColor.mainText,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    String formattedValue = value;
    if (label == "Ngày Xuất" && value.isNotEmpty) {
      try {
        // Sử dụng phương thức formatDate của AppFormat
        formattedValue = appFormat.formatDate(value);
      } catch (e) {
        // print("Lỗi định dạng ngày: $e");
      }
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: formattedValue,
            style: TextStyle(
              color: textColor ?? AppColor.mainText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
