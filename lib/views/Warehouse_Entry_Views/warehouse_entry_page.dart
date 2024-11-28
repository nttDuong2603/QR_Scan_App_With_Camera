import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/app_format.dart';
import '../../utils/appcolors.dart';
import 'warehouse_entry_infor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/api_controller.dart';

class WarehouseEntryPage extends StatefulWidget {
  const WarehouseEntryPage({super.key});

  @override
  State<WarehouseEntryPage> createState() => _WarehouseEntryPageState();
}

class _WarehouseEntryPageState extends State<WarehouseEntryPage> {
  final AppFormat appFormat = AppFormat();
  List<Map<String, dynamic>> confirmedEntries = [];
  List<Map<String, dynamic>> deletedItems = []; // Danh sách lưu các item đã bị xóa
  Map<int, bool> expandedItems = {};
  final APIController _apiController = APIController();
  Map<String, String> trangThaiMap = {}; // Lưu trạng thái với mã PNK làm khóa


  @override
  void initState() {
    super.initState();
    _loadEntriesFromSharedPreferences();
  }

  Future<void> _loadEntriesFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentUser = prefs.getString('currentUser');

    if (currentUser != null) {
      List<String> orderList = prefs.getStringList('warehouseEntries') ?? [];
      setState(() {
        confirmedEntries = orderList
            .map((order) => json.decode(order) as Map<String, dynamic>)
            .where((entry) => entry['userAccount'] == currentUser)
            .toList();
      });
    }
  }

  Future<void> _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      confirmedEntries.removeAt(index); // Remove entry from list
    });
    List<String> updatedList = confirmedEntries.map((entry) => json.encode(entry)).toList();
    await prefs.setStringList('warehouseEntries', updatedList);
  }

  void _navigateToWarehouseEntryInfor(BuildContext context, Map<String, dynamic> entry) async {
    final updatedEntry = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WarehouseEntryInforPage(entry: entry),
      ),
    );

    // Kiểm tra nếu có dữ liệu trả về, cập nhật danh sách phiếu nhập kho
    if (updatedEntry != null && updatedEntry is Map<String, dynamic>) {
      setState(() {
        // Tìm entry tương ứng và cập nhật lại
        final entryIndex = confirmedEntries.indexWhere((e) => e['orderDetails']['warehouseEntryCode'] == updatedEntry['orderDetails']['warehouseEntryCode']);
        if (entryIndex != -1) {
          confirmedEntries[entryIndex] = updatedEntry;
        }
      });

      // Lưu lại vào SharedPreferences nếu cần
      final prefs = await SharedPreferences.getInstance();
      List<String> updatedEntries = confirmedEntries.map((entry) => json.encode(entry)).toList();
      await prefs.setStringList('warehouseEntries', updatedEntries);
    }
  }

  Future<void> _fetchTrangThaiPNK(String PNK) async {
    final apiResponse = await _apiController.FetchTrangThaiPNK(PNK);
    if (apiResponse != null) {
      final decodedData = json.decode(apiResponse);
      print("decodedData: $decodedData");
      if (decodedData is Map<String, dynamic> && decodedData["data"] is List && decodedData["data"].isNotEmpty) {
        // Cập nhật trạng thái vào Map với khóa là PNK
        setState(() {
          trangThaiMap[PNK] = decodedData["data"][0]['tenTrangThai'];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope( onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
          context,
          '/homePage'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
        child: Scaffold(
          backgroundColor: AppColor.backgroundAppColor,
          appBar: AppBar(
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
            title: Text(
              'Danh sách Phiếu Nhập kho',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(screenWidth * 0.02),
            itemCount: confirmedEntries.length,
            itemBuilder: (context, index) {
              final entry = confirmedEntries[index];
              final orderDetails = entry['orderDetails'];
              final PNK = orderDetails['warehouseEntryCode']; // Lấy mã PNK
              final items = entry['items'];
              final isExpanded = expandedItems[index] ?? false;
              // Gọi _fetchTrangThaiPNK nếu chưa có trạng thái cho mã PNK này
              if (!trangThaiMap.containsKey(PNK)) {
                _fetchTrangThaiPNK(PNK);
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _navigateToWarehouseEntryInfor(context, entry);
                              },
                              child:
                              Padding(
                                padding: const EdgeInsets.all(8.0), // Thêm padding cho toàn bộ nội dung
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow("Phiếu Nhập Kho", orderDetails['warehouseEntryCode']),
                                    SizedBox(height: 4),
                                    _buildInfoRow("Ngày Nhập", orderDetails['expectedDeliveryDate']),
                                    SizedBox(height: 4),
                                _buildInfoRow(
                                  "Trạng Thái",
                                  trangThaiMap[PNK] ?? "",
                                  textColor: (trangThaiMap[PNK] == "Hoàn Thành Nhập Kho") ? Colors.green : AppColor.mainText,
                                ),
                                  ],),
                              ),
                            ),
                          ),
                          // Icon mở rộng
                          IconButton(
                            icon: Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: AppColor.mainText,
                            ),
                            onPressed: () {
                              setState(() {
                                expandedItems[index] = !(expandedItems[index] ?? false);
                              });
                            },
                          ),
                        ],
                      ),
                      Visibility(
                        visible: isExpanded,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 9.0),
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.55,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Danh sách sản phẩm:",
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
                                              children: [
                                                // Hình ảnh bên trái
                                                if (item['HinhAnh'] != null && item['HinhAnh'].isNotEmpty)
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    margin: EdgeInsets.only(right: 10), // Khoảng cách với văn bản bên phải
                                                    child: Image.network(
                                                      'https://admin-demo-saas.mylanhosting.com${item['HinhAnh'][0]}', // Thay thế bằng URL của server của bạn
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.image_not_supported, size: 60);
                                                      },
                                                    ),
                                                  ),
                                                // Nếu không có hình ảnh, hiển thị biểu tượng mặc định
                                                if (item['HinhAnh'] == null || item['HinhAnh'].isEmpty)
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    margin: EdgeInsets.only(right: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Icon(Icons.image, size: 40, color: Colors.grey), // Biểu tượng mặc định
                                                  ),
                                                // Thông tin chi tiết sản phẩm
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Tên sản phẩm: ",
                                                              style: TextStyle(
                                                                color: AppColor.mainText,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.normal,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: "${item['TenSanPham']}",
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
                                                              text: "SKU: ",
                                                              style: TextStyle(
                                                                color: AppColor.mainText,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.normal,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: "${item['MaSanPham']}",
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
                                                              text: "Số lượng: ",
                                                              style: TextStyle(
                                                                color: AppColor.mainText,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.normal,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: "${item['SoLuongNhap']}",
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
                                              ],
                                            ),
                                          )
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
                Navigator.pushNamed(context, "/warehouse_receiving_scan_barcode");
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
        )
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    // Kiểm tra và định dạng ngày nếu là expectedDeliveryDate
    String formattedValue = value;
    if (label == "Ngày Nhập" && value.isNotEmpty) {
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