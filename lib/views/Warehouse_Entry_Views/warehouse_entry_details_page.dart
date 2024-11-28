import 'dart:convert';

import 'package:flutter/material.dart';
import '../../utils/appcolors.dart';
import '../../controllers/api_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseEntryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const WarehouseEntryDetailsPage({required this.data, Key? key}) : super(key: key);

  @override
  State<WarehouseEntryDetailsPage> createState() => _WarehouseEntryDetailsPageState();
}

class _WarehouseEntryDetailsPageState extends State<WarehouseEntryDetailsPage> {
  final apiController = APIController();
  String? startIndex;
  String? endIndex;
  String? boxQRCode;
  int? startIndexId;
  int? endIndexId;
  String? LSXQR;
  String boxCode = '';
  bool _isSync = false;
  String IP = "http://192.168.19.180:2002";
  // String IP = "https://admin-demo-saas.mylanhosting.com";

  Future<void> _navigateToQrScan(BuildContext context, String scanTitle, ValueSetter<String?> onScanned) async {
    final scannedCode = await Navigator.pushNamed(
      context,
      '/qr_scan',
      arguments: scanTitle,
    );
    if (scannedCode != null && scannedCode is String) {
      print(scannedCode);
      setState(() {
        onScanned(scannedCode);
        if (scanTitle == "Quét Index đầu") {
          _fetchQRCodeInfoForStartIndex(scannedCode); // Gọi API cho Index đầu
        } else if (scanTitle == "Quét Index cuối") {
          _fetchQRCodeInfoForEndIndex(scannedCode); // Gọi API cho Index cuối
          _fetchQRCodeInfoForBoxQR(scannedCode);
        }
      });
    }
  }

  // Hàm gọi API FetchQRCodeInfo cho startIndex và lưu ID vào startIndexId
  // Hàm gọi API FetchQRCodeInfo cho startIndex và lưu ID vào startIndexId
  Future<void> _fetchQRCodeInfoForStartIndex(String qrCode) async {
    final response = await apiController.FetchQRCodeInfo(qrCode);
    if (response != null) {
      final responseData = json.decode(response);

      // Lấy ID từ đối tượng đầu tiên trong "data" và lưu vào startIndexId
      setState(() {
        startIndexId = responseData["data"] != null && responseData["data"].isNotEmpty
            ? responseData["data"][0]["ID"]
            : null; // Nếu không có ID, set null để dễ kiểm soát
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy thông tin cho mã QR đã quét.")),
      );
    }
  }

  // Hàm gọi API FetchQRCodeInfo cho endIndex và lưu ID vào endIndexId
  Future<void> _fetchQRCodeInfoForEndIndex(String qrCode) async {
    final response = await apiController.FetchQRCodeInfo(qrCode);
    if (response != null) {
      final responseData = json.decode(response);

      // Lấy ID từ đối tượng đầu tiên trong "data" và lưu vào endIndexId
      setState(() {
        endIndexId = responseData["data"] != null && responseData["data"].isNotEmpty
            ? responseData["data"][0]["ID"]
            : null; // Nếu không có ID, set null để dễ kiểm soát
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy thông tin cho mã QR đã quét.")),
      );
    }
  }

  Future<void> _fetchQRCodeInfoForBoxQR(String qrCode) async {
    final response = await apiController.FetchQRCodeInfo(qrCode);

    if (response != null) {
      final responseData = json.decode(response);

      // Kiểm tra và in ra toàn bộ phản hồi để đảm bảo cấu trúc
      print("API Response Data: $responseData");

      // Kiểm tra và lấy giá trị `LichSanXuatQRCode` từ đối tượng đầu tiên trong `data`
      setState(() {
        LSXQR = responseData["data"] != null && responseData["data"].isNotEmpty
            ? responseData["data"][0]["LichSanXuatQRCode"]
            : null; // Nếu không có ID, set null để dễ kiểm soát
      });

      // Kiểm tra kết quả cuối cùng của `LSXQR`
      print("LSXQR: $LSXQR");

      // Thông báo nếu không tìm thấy giá trị `LichSanXuatQRCode`
      if (LSXQR == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không tìm thấy Lịch Sản Xuất QRCode từ mã QR đã quét.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy thông tin cho mã QR đã quét.")),
      );
    }
  }

  // Hiển thị hộp thoại xác nhận mã QR
  Future<bool> _showSyncCompleDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Đồng bộ thành công!",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Gán thông tin sản phẩm thành công.\nChọn OK để gán thông tin sản phẩm kế tiếp",
                  style: TextStyle(
                    color: AppColor.mainText,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Trả về `true` để chỉ rằng đã hoàn tất đồng bộ
                  onPressed: (){
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
  }
  Future<void> handleSync() async {
    // Kiểm tra các trường mã QR đã được quét đầy đủ
    if (startIndex != null && endIndex != null && boxQRCode != null) {
      // Xác nhận đồng bộ thành công
      bool syncComplete = await _showSyncCompleDialog();
      int sucChua = (endIndexId ?? 0) - (startIndexId ?? 0) + 1;
      if (syncComplete) {
        final DateTime now = DateTime.now();
        boxCode = 'THUNG${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
            // Tạo JSON request body với các dữ liệu đã quét
            Map<String, dynamic> requestBody = {
              "25MT": "${boxCode}",
              "40MSP": "${widget.data['MaSanPham']}",
              "7MQC": "${widget.data['MaQuyCach']}",
              "3SLĐN": "",
              "1IĐ": startIndexId,  // Gắn ID từ Index đầu vào "1IĐ"
              "1IC": endIndexId,    // Gắn ID từ Index cuối vào "1IC"
              "37GC": "",
              "7MQ": "$boxQRCode",
              "3SC": sucChua,
              "3SLĐX": "",
              "29MT": "",
              "5KC": "",
              "21M": "${widget.data['MaLoaiHang']}",
              "1MCTLNK": "${widget.data['MaChiTietLichNhapKho']}",
              "5MPNK":"${widget.data['MaPhieuNhapKho']}",
              "9MLNK":"${widget.data['MaLichNhapKho']}",
              "3SLĐX": 0,
              "3SLĐN":0
            };
            print('requestBody: $requestBody');
            // Gọi hàm POST của APIController
            final result = await apiController.postWarehouseEntryDetails(requestBody);

            // Kiểm tra phản hồi của API
            if (result != null) {
              widget.data['boxQRCode'] = boxQRCode;
              widget.data['startIndex'] = startIndex;
              widget.data['endIndex'] = endIndex;
              widget.data['sucChua'] = sucChua;
              widget.data['status'] = "Đã đồng bộ";
              if (LSXQR != null) {
                await UpdateQRCodeManagement();  // Chỉ gọi nếu LSXQR có giá trị
                await UpdateBoxQRCodeManagement();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("LSXQR không có giá trị. Vui lòng quét lại QRCode thùng.")),
                );
              }
              Navigator.pop(context, widget.data);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi đồng bộ dữ liệu"))
              );
            }
      }
    } else {
      // Hiển thị thông báo nếu mã QR chưa được quét đầy đủ
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vui lòng quét đầy đủ các mã QR"))
      );
    }
  }

  Future<void> UpdateQRCodeManagement() async {
    if (startIndex != null && endIndex != null && boxQRCode != null && LSXQR != null) {
      final Map<String, dynamic> requestBodyForQRCodeUpdate = {
        "1LMQ": "",
        "2MPNK": "${widget.data['MaPhieuNhapKho']}",
        "13MPXK": "",
        "1MLXK": "",
        "2MD": "",
        "28MK": "",
        "27MT": "",
        "28MT": "$boxCode",
        "41MSP": "${widget.data['MaSanPham']}",
        "1MTSP": "$boxCode",
        "33TT": "TT007",
        "8MLNK": "${widget.data['MaLichNhapKho']}",
        "indexDau": startIndexId,
        "indexCuoi": endIndexId
      };
      print('index: $requestBodyForQRCodeUpdate');

      final qrCodeUpdateResult = await apiController.updateQRCodeManagementTableAccordingToIndex(
          LSXQR!, requestBodyForQRCodeUpdate);
      // print(qrCodeUpdateResult);


      if (qrCodeUpdateResult != null) {
        print("QRCode management updated successfully: $qrCodeUpdateResult.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi cập nhật QRCode quản lý. Vui lòng thử lại.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng quét đầy đủ các mã QR trước khi cập nhật")),
      );
    }
  }

  Future<void> UpdateBoxQRCodeManagement() async {
    if (startIndex != null && endIndex != null && boxQRCode != null && LSXQR != null) {
      final Map<String, dynamic> requestBodyForBoxQRCodeUpdate = {
        "1LMQ": "",
        "2MPNK": "${widget.data['MaPhieuNhapKho']}",
        "13MPXK": "",
        "1MLXK": "",
        "8MLNK": "${widget.data['MaLichNhapKho']}",
        "2MD": "",
        "28MK": "",
        "27MT": "",
        "28MT": "$boxCode",
        "41MSP": "${widget.data['MaSanPham']}",
        "1MTSP": "",
        "33TT": "TT007"
      };
      print('requestBodyForQRCodeBoxUpdate: $requestBodyForBoxQRCodeUpdate');

      final qrCodeUpdateResult = await apiController.updateQRCodeManagementTableAccordingToQrCode(
          boxQRCode!, requestBodyForBoxQRCodeUpdate);
      print(qrCodeUpdateResult);


      if (qrCodeUpdateResult != null) {
        print("QRCode management updated successfully.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi cập nhật QRCode quản lý. Vui lòng thử lại.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng quét đầy đủ các mã QR trước khi cập nhật")),
      );
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
      body: SingleChildScrollView(
        child:  Padding(
          padding: EdgeInsets.all(16.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      text: "${widget.data['TenSanPham'] ?? ''}",
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
                      text: "${widget.data['MaSanPham'] ?? ' '}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColor.mainText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Index đầu
              GestureDetector(
                onTap: () => _navigateToQrScan(context, "Quét Index đầu", (code) => startIndex = code),
                child: _buildScanRow("Index đầu", startIndexId?.toString()),
              ),
              SizedBox(height: 10),

              // Index cuối
              GestureDetector(
                onTap: () => _navigateToQrScan(context, "Quét Index cuối", (code) => endIndex = code),
                child: _buildScanRow("Index cuối", endIndexId?.toString()),
              ),
              SizedBox(height: 10),

              // QRCode thùng
              GestureDetector(
                onTap: () => _navigateToQrScan(context, "Quét QRCode thùng", (code) => boxQRCode = code),
                child: _buildScanRow("QRCode thùng", boxQRCode),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColor.backgroundAppColor,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColor.borderInputColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
          ),
          onPressed: () async {
            handleSync();
            setState(() {
              _isSync = true;
            });
          },
          child: Text(
            "Đồng bộ",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.07,
            ),
          ),
        ),
      ),

    );
  }

  // Xây dựng giao diện cho hàng quét mã QR với mã đã quét
  Widget _buildScanRow(String label, String? value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: screenWidth * 0.045, color: AppColor.mainText)),
          Text(value ?? "", style: TextStyle(fontSize: screenWidth * 0.045, color:  AppColor.borderInputColor)),
          Icon(Icons.qr_code_scanner, color: AppColor.mainText),
        ],
      ),
    );
  }
}
