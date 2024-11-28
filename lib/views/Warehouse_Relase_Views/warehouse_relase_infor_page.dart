import 'dart:convert';

import 'package:flutter/material.dart';
import '../../utils/app_format.dart';
import '../../views/Warehouse_Relase_Views/warehouse_relase_details.dart';
import '../../views/Warehouse_Relase_Views/warehouse_relase_suggest_location_page.dart';
import '../../controllers/api_controller.dart';
import '../../utils/appcolors.dart';

class WarehouseRelaseInforPage extends StatefulWidget {
  const WarehouseRelaseInforPage({Key? key}) : super(key: key);

  @override
  State<WarehouseRelaseInforPage> createState() => _WarehouseRelaseInforPagesState();
}

class _WarehouseRelaseInforPagesState extends State<WarehouseRelaseInforPage> {
  Map<String, dynamic>? orderDetails;
  final APIController _apiController = APIController();
  final AppFormat appFormat = AppFormat();
  bool _isExpanded = true; // Biến trạng thái để mở rộng phần danh sách sản phẩm
  List<dynamic>? items;
  String trangThai = '';


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Lấy toàn bộ arguments được truyền từ RouteSettings
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      // Lấy orderDetails và items từ args
      orderDetails = args['orderDetails'] as Map<String, dynamic>?;
      items = args['items'] as List<dynamic>?;

      print("Order Details: $orderDetails");
      print("Items: $items");
    }
    _fetchTrangThaiPXK();

  }

  Future<void> _fetchTrangThaiPXK() async {
    String PXK = orderDetails!['MaPhieuXuatKho'];
    final apiResponse = await _apiController.FetchTrangThaiPXK(PXK);
    if (apiResponse != null) {
      final decodedData = json.decode(apiResponse);
      print("decodedData: $decodedData");
      if (decodedData is Map<String, dynamic> && decodedData["data"] is List && decodedData["data"].isNotEmpty) {
        // Cập nhật trạng thái vào Map với khóa là PNK
        setState(() {
          trangThai = decodedData["data"][0]['tenTrangThai'];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: AppColor.backgroundAppColor,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
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
                'Chi tiết Phiếu Xuất Kho',
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
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: orderDetails != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần thông tin phiếu xuất kho
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Phiếu Xuất Kho: ",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: "${orderDetails!['MaPhieuXuatKho']}",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Ngày Xuất: ",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: "${appFormat.formatDate(orderDetails!['NgayXuatKho'])}",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Trạng thái: ",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: "$trangThai",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Danh sách Lệnh Xuất Hàng:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainText,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColor.mainText,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            Divider(),

            // Danh sách lệnh xuất hàng
            _isExpanded && items != null
                ? Expanded(
              child: ListView.builder(
                itemCount: items!.length,
                itemBuilder: (context, index) {
                  final item = items![index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WarehouseRelaseDetails(),
                          settings: RouteSettings(
                            arguments: {
                              'release': orderDetails, // Truyền thông tin chung của phiếu xuất kho
                              'selectedTO': item, // Truyền TO được chọn với danh sách sản phẩm
                              'maPXK': orderDetails!['MaPhieuXuatKho'],
                              'ngayXuatKho': orderDetails!['NgayXuatKho'],
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Text and details part
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
                                SizedBox(height: 4),
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
                                SizedBox(height: 4),
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
                                        text: "${item['GhiChu_LXH'] ?? ''}",
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
                          // QR Icon part
                          Icon(
                            Icons.navigate_next, // Mã QR icon
                            color: AppColor.mainText,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )


                : SizedBox.shrink(),
          ],
        ) : Center(
          child: Text(
            "Không có dữ liệu để hiển thị",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColor.backgroundAppColor,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: trangThai == "Hoàn Thành Xuất Kho"
                ? Colors.grey.shade400  // Màu xám khi trạng thái là "Hoàn Thành Nhập Kho"
                : AppColor.borderInputColor, // Màu có thể bấm khi trạng thái khác
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
          ),
          onPressed: () async {
            if(trangThai == "Hoàn Thành Xuất Kho"){
              return;
            }else{

              // Lấy MaPhieuXuatKho từ orderDetails để gọi API gợi ý xuất kho
              final maPhieuXuatKho = orderDetails?['MaPhieuXuatKho'];
              if (maPhieuXuatKho != null) {
                final apiResponse = await _apiController.FetchSugguestWarehouseRelease(maPhieuXuatKho);
                if (apiResponse != null) {
                  // Parse JSON response thành dạng Map
                  final suggestionsData = json.decode(apiResponse);

                  // Chuyển đến WarehouseReleaseSuggest và truyền dữ liệu
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WarehouseReleaseSuggest(
                        suggestionsData: suggestionsData, // Truyền dữ liệu gợi ý qua
                        maPXK: orderDetails?['MaPhieuXuatKho'],
                      ),
                    ),
                  );
                } else {
                  print("Không thể tải dữ liệu gợi ý.");
                }
              }
            }

          },
          child: Text(
            "Xuất kho",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.07,
            ),
          ),
        ),
      ),

    );
  }
}
