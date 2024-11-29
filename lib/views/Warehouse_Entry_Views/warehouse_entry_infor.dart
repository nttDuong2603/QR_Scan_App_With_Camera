import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/app_format.dart';
import '../../controllers/api_controller.dart';
import '../../utils/appcolors.dart';
import 'suggested_location_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseEntryInforPage extends StatefulWidget {
  final Map<String, dynamic> entry; // Nhận dữ liệu phiếu nhập kho

  const WarehouseEntryInforPage({Key? key, required this.entry}) : super(key: key);

  @override
  State<WarehouseEntryInforPage> createState() => _WarehouseEntryInforPageState();
}

class _WarehouseEntryInforPageState extends State<WarehouseEntryInforPage> {
  bool _isExpanded = true; // Biến kiểm soát trạng thái mở rộng
  List<Map<String, dynamic>> deletedItems = [];
  bool _isComplet = false;
  final AppFormat appFormat = AppFormat();
  final APIController _apiController = APIController();
  String trangThai = ''; // Lưu trạng thái với mã PNK làm khóa
  String IP = "http://115.78.237.91:2002";
  // String IP = "https://admin-demo-saas.mylanhosting.com";

  @override
  void initState() {
    super.initState();
    _fetchTrangThaiPNK();
  }



  // Future<void> handleItemTap(BuildContext context, Map<String, dynamic> item) async {
  //   // Điều hướng đến WarehouseBoxPage thay vì WarehouseEntryDetailsPage
  //  final updatedData = Navigator.pushNamed(
  //     context,
  //     '/warehouse_entry_box_details',
  //     arguments: item,
  //   );
  //   // Nếu có dữ liệu trả về, cập nhật trạng thái trong danh sách
  //   if (updatedData != null && updatedData is Map<String, dynamic>) {
  //     deletedItems.add(item);
  //     final prefs = await SharedPreferences.getInstance();
  //     // Cập nhật lại SharedPreferences với các mục đã đồng bộ
  //     List<String> deletedList = deletedItems.map((item) => json.encode(item)).toList();
  //     await prefs.setStringList('deletedWarehouseEntries', deletedList);
  //     setState(() {
  //       // Tìm item tương ứng và cập nhật lại trạng thái
  //       final itemIndex = widget.entry['items'].indexWhere((i) => i['MaSanPham'] == item['MaSanPham']);
  //       if (itemIndex != -1) {
  //         widget.entry['items'][itemIndex] = updatedData;
  //         }
  //     });
  //
  //   }
  // }

  Future<void> handleItemTap(BuildContext context, Map<String, dynamic> item) async {
    // Điều hướng đến WarehouseBoxPage và chờ dữ liệu trả về
    final updatedData = await Navigator.pushNamed(
      context,
      '/warehouse_entry_box_details',
      arguments: item,
    );

    if (updatedData != null && updatedData is Map<String, dynamic>) {
      // Lưu vào danh sách deletedItems nếu cần thiết
      setState(() {
        // Cập nhật dữ liệu sản phẩm với mã QR của thùng
        item['boxQRCode'] = updatedData['boxQRCode']; // Lưu mã QR của thùng vào sản phẩm
      });
      await _saveEntryDataToPreferences(); // Lưu dữ liệu vào SharedPreferences
      deletedItems.add(updatedData);

      final prefs = await SharedPreferences.getInstance();

      // Cập nhật lại SharedPreferences
      List<String> deletedList = deletedItems.map((item) => json.encode(item)).toList();
      await prefs.setStringList('deletedWarehouseEntries', deletedList);

      setState(() {
        // Cập nhật lại trạng thái của item trong danh sách
        final itemIndex = widget.entry['items'].indexWhere((i) => i['MaSanPham'] == item['MaSanPham']);
        if (itemIndex != -1) {
          widget.entry['items'][itemIndex] = updatedData;
        }
      });

      // Sau khi cập nhật xong, trả về dữ liệu cập nhật về WarehouseEntryPage
      Navigator.pop(context, widget.entry);
    }
  }

  Future<void> _saveEntryDataToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String entryKey = 'warehouse_entry_${widget.entry['orderDetails']['warehouseEntryCode']}';
    String entryData = json.encode(widget.entry);
    await prefs.setString(entryKey, entryData);
  }

  Future<void> _fetchTrangThaiPNK() async {
    String PNK = widget.entry['orderDetails']['warehouseEntryCode'];
    final apiResponse = await _apiController.FetchTrangThaiPNK(PNK);
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
    final orderDetails = widget.entry['orderDetails'];
    final items = widget.entry['items'];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
          'Thông tin nhập kho',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Phiếu Nhập Kho", orderDetails['warehouseEntryCode']),
            SizedBox(height: 4),
            _buildInfoRow("Ngày Nhập", orderDetails['expectedDeliveryDate']),
            SizedBox(height: 4),
            _buildInfoRow("Trạng Thái",  trangThai),
            SizedBox(height: 20),

            // Phần mở rộng danh sách sản phẩm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Danh sách sản phẩm:",
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
                      _isExpanded = !_isExpanded; // Đổi trạng thái mở rộng
                    });
                  },
                ),
              ],
            ),
            Divider(color: Colors.grey),
            // Hiển thị danh sách sản phẩm nếu được mở rộng
            _isExpanded
                ? Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final imageUrl = item['HinhAnh'] != null && item['HinhAnh'].isNotEmpty
                      ? '$IP${item['HinhAnh'][0]}'
                      : null; // Đường dẫn tới hình ảnh đầu tiên, thay thế 'https://yourserver.com' với URL server của bạn

                  return GestureDetector(
                    onTap: () {
                      if (trangThai != "Hoàn Thành Nhập Kho"){
                        handleItemTap(context, item);
                      }
                      else{
                        return;
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
                          if (imageUrl != null)
                            Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(right: 10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_not_supported, size: 60);
                                },
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                          // Nội dung thông tin sản phẩm
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow("Tên sản phẩm:", item['TenSanPham']),
                                SizedBox(height: 6),
                                _buildInfoRow("SKU:", item['MaSanPham']),
                                SizedBox(height: 6),
                                _buildInfoRow(
                                  "Số lượng:",
                                  "${item['SoLuongNhap']}"
                                ),
                                SizedBox(height: 6),
                                _buildInfoRow(
                                  "Trạng thái", ((item['boxQRCode'] != null && item['boxQRCode'].isNotEmpty) || trangThai == "Hoàn Thành Nhập Kho"
                                          ? "Đã gán QR Code"
                                          : "Chưa gán QR Code"),
                                )
                              ],
                            ),
                          ),
                          if(trangThai != "Hoàn Thành Nhập Kho")
                          Center(
                            child: Icon(
                              Icons.navigate_next,
                              color: AppColor.mainText,
                            ),
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
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child:TextButton(
            style: TextButton.styleFrom(
              backgroundColor: trangThai == "Hoàn Thành Nhập Kho"
                  ? Colors.grey.shade400  // Màu xám khi trạng thái là "Hoàn Thành Nhập Kho"
                  : AppColor.borderInputColor, // Màu có thể bấm khi trạng thái khác
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
            onPressed: () async {
              if(trangThai != 'Hoàn Thành Nhập Kho'){

                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => SuggestedLocationPage(
                data: widget.entry['orderDetails'], // Truyền mã phiếu nhập kho

                ),
                ),
                );
              }else{
                return;
    }
            },
            child: Text(
              "Nhập kho",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.07,
              ),
            ),
          )
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            text: "$label ",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: formattedValue,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
