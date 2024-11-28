import 'dart:convert';

import 'package:flutter/material.dart';
import '../../utils/app_format.dart';
import '../../controllers/api_controller.dart';
import '../../utils/appcolors.dart';

class WarehouseRelaseDetails extends StatefulWidget {
  const WarehouseRelaseDetails({Key? key}) : super(key: key);

  @override
  State<WarehouseRelaseDetails> createState() => _WarehouseRelaseDetailsState();
}

class _WarehouseRelaseDetailsState extends State<WarehouseRelaseDetails> {
  final AppFormat appFormat = AppFormat();
  final APIController _apiController = APIController();

  Map<String, dynamic>? release;
  Map<String, dynamic>? selectedTO;
  List<dynamic>? products;
  String trangThai = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      release = arguments['release'];
      selectedTO = arguments['selectedTO'];
      print('release: $release');
      print('selectedTO: $selectedTO');

      print('MPXK: ${release!['MaPhieuXuatKho']}');
      // Kiểm tra và lấy danh sách sản phẩm từ `ChiTietLenhXuatHang` của `selectedTO`
      if (selectedTO?['ChiTietLenhXuatHang'] is List) {
        products = selectedTO?['ChiTietLenhXuatHang'] as List<dynamic>;
      } else {
        products = [];
      }
    }
    _fetchTrangThaiPXK();
  }

  Future<void> _fetchTrangThaiPXK() async {
    String PXK = release!['MaPhieuXuatKho'];
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
    final orderDetails = release?['orderDetails'];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: AppBar(
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
        title: Text(
          'Thông tin xuất kho',
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
             _buildInfoRow("Phiếu Xuất Kho", release!['MaPhieuXuatKho'] ?? ""),
            SizedBox(height: 4),
            _buildInfoRow("Ngày Xuất", release!['NgayXuatKho'] ?? ""),
            SizedBox(height: 4),
            _buildInfoRow("Trạng Thái", trangThai),
            SizedBox(height: 4),
            if (selectedTO != null) _buildInfoRow("TO", selectedTO!['MaLenhXuatHang'] ?? ""),
            SizedBox(height: 20),

            // Danh sách sản phẩm
            Text(
              "Danh sách Sản phẩm:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
            Divider(color: Colors.grey),

            if (products != null && products!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: products!.length,
                  itemBuilder: (context, index) {
                    final productDetails = products![index] as Map<String, dynamic>?;
                    final product = productDetails?['16SP'] ?? {};  // Lấy thông tin chi tiết sản phẩm từ '16SP'

                    return Container(
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
                          // Phần hiển thị hình ảnh bên trái
                          if (product?['3HẢ'] != null && product['3HẢ'].isNotEmpty)
                            Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(right: 12),
                              child: Image.network(
                                'https://admin-demo-saas.mylanhosting.com${product['3HẢ'][0]}', // Đường dẫn ảnh đầu tiên trong danh sách
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_not_supported, size: 60, color: Colors.grey);
                                },
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(Icons.image, size: 40, color: Colors.grey),
                            ),

                          // Phần hiển thị thông tin sản phẩm bên phải
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow("Tên Sản phẩm", product?['16TSP'] ?? ""),
                                SizedBox(height: 6),
                                _buildInfoRow("SKU", product?['39MSP'] ?? ""),
                                SizedBox(height: 6),
                                _buildInfoRow("Số lượng", "${productDetails?['3SLX'] ?? ''}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (products == null || products!.isEmpty)
              Center(
                child: Text(
                  "Không có sản phẩm nào.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   child: TextButton(
      //     style: TextButton.styleFrom(
      //       backgroundColor: AppColor.borderInputColor,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(screenWidth * 0.03),
      //       ),
      //     ),
      //     onPressed: () async {
      //       // Xử lý nút xác nhận Xuất kho
      //     },
      //     child: Text(
      //       "Xuất kho",
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: screenWidth * 0.07,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    String formattedValue = value;
    if (label == "Ngày Xuất" && value.isNotEmpty) {
      try {
        formattedValue = appFormat.formatDate(value);
      } catch (e) {
        // Nếu có lỗi định dạng, bỏ qua
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
