import 'dart:convert';

import 'package:flutter/material.dart';
import '../../views/Warehouse_Relase_Views/qr_scan_release_page.dart';
import '../../controllers/api_controller.dart';
import '../../controllers/barcode_scan_controller.dart';
import '../../utils/appcolors.dart';
import '../../utils/key_event_channel.dart';

class WarehouseReleaseSuggest extends StatefulWidget {
  final Map<String, dynamic> suggestionsData;
  final String maPXK;
  const WarehouseReleaseSuggest({Key? key, required this.suggestionsData, required this.maPXK}) : super(key: key);

  @override
  State<WarehouseReleaseSuggest> createState() => _WarehouseReleaseSuggestState();
}

class _WarehouseReleaseSuggestState extends State<WarehouseReleaseSuggest> {
  List<Map<String, dynamic>> locationsWithPositions = [];
  Set<int> expandedItems = {};
  // final ScanBarcodeController _controller = ScanBarcodeController();
  // final ScanBarcodeController _barcodeController = ScanBarcodeController();
  late KeyEventChannel _keyEventChannel;
  final APIController apiController = APIController();

  @override
  void initState() {
    super.initState();
    // if (widget.suggestionsData.containsKey("DanhSachViTri")) {
    //   locationsWithPositions = List<Map<String, dynamic>>.from(widget.suggestionsData["DanhSachViTri"]);
    // }
    if (widget.suggestionsData.containsKey("DanhSachViTri")) {
      setState(() {
        locationsWithPositions = List<Map<String, dynamic>>.from(widget.suggestionsData["DanhSachViTri"]);
      });
    } else {
      print("Không có dữ liệu DanhSachViTri.");
    }
  }

  Future<Map<String, dynamic>?> fetchProductData(Map<String, dynamic> box) async {
    try {
      // Gọi API để lấy danh sách sản phẩm theo mã phiếu xuất kho
      final response = await apiController.FetchProductListWithPXK(widget.maPXK, {});
      print('response: $response');

      if (response != null) {
        // Giải mã phản hồi JSON từ API
        final data = json.decode(response);

        // Lấy mã sản phẩm từ `box` để so sánh
        final String selectedMaSanPham = box['39MSP'] ;

        // Duyệt qua danh sách sản phẩm và tìm sản phẩm có mã trùng khớp
        for (var product in data['data']) {
          if (product['MaSanPham'] == selectedMaSanPham) {
            // Trả về thông tin chi tiết sản phẩm nếu mã trùng khớp
            print('MaPhieuXuatKho_ChiTietLenhXuatHang: ${product['MaPhieuXuatKho_ChiTietLenhXuatHang']}');
            return {
              'MaPhieuXuatKho': product['MaPhieuXuatKho_ChiTietLenhXuatHang'],
              'MaLenhXuatHang': product['MaLenhXuatHang'],
              'MaChiTietLenhXuatHang': product['MaChiTietLenhXuatHang'],
              'SoLuongXuat': product['SoLuongXuat'],
              'TrongLuong': product['TrongLuong'],
            };
          }
        }
      } else {
        print("Không nhận được dữ liệu từ API.");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
    return null;
  }


  Future<bool> _showReleaseLocationDialog(Map<String, dynamic> location, Map<String, dynamic> box) async {
    Map<String, dynamic>? productData = await fetchProductData(box);
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.backgroundAppColor,
          title: Text(
            "Di chuyển Xuất kho",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Vị trí Xuất kho:",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "- ${location['Tang']['TenTang']}\n",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Chi tiết sản phẩm:",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Mã QR Code Thùng: ${box['7MQ']}",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "Mã Thùng: ${box['MaThung']}",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "${box['16TSP'] ?? ''}",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "SKU: ${box['40MSP'] ?? ''}",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScanReleasePage(
                          location: location,
                          box: box,
                          productData: productData,
                          maPXK: widget.maPXK
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Quét QR Code",
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


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope( onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
          context,
          '/warehouse_relase_list_page'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
    child:  Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundAppColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            'assets/images/logo.png',
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
          ),
        ),
        title: Text(
          'Gợi ý Xuất kho',
          style: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: locationsWithPositions.length,
          itemBuilder: (context, index) {
            final location = locationsWithPositions[index];
            final totalBoxes = location['DanhSachThung'].length;
            final locationDescription = "${location['Tang']['TenTang']}";

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              color: AppColor.backgroundAppColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Vị trí: $locationDescription",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppColor.mainText,
                      ),
                    ),
                    subtitle: Text(
                      "Số lượng thùng sản phẩm: $totalBoxes",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: AppColor.mainText,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        expandedItems.contains(index) ? Icons.expand_less : Icons.expand_more,
                        color: AppColor.mainText,
                      ),
                      onPressed: () {
                        setState(() {
                          if (expandedItems.contains(index)) {
                            expandedItems.remove(index);
                          } else {
                            expandedItems.add(index);
                          }
                        });
                      },
                    ),
                  ),
                  if (expandedItems.contains(index))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List<Map<String, dynamic>>.from(location['DanhSachThung']).map((box) {
                          return GestureDetector(
                            onTap: () => _showReleaseLocationDialog(location, box),
                            child: Card(
                              color: AppColor.backgroundAppColor,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mã QR Code Thùng: ${box['7MQ']}",
                                          style: TextStyle(
                                              color: AppColor.mainText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(
                                          "Mã Thùng: ${box['MaThung']}",
                                          style: TextStyle(
                                            color: AppColor.mainText,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                        Text(
                                          "${box['16TSP'] ?? ''}",
                                          style: TextStyle(
                                            color: AppColor.mainText,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                        Text(
                                          "SKU: ${box['40MSP'] ?? ''}",
                                          style: TextStyle(
                                            color: AppColor.mainText,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // SizedBox(width: screenWidth *0.1),
                                    Center(
                                        child: Icon(
                                            Icons.qr_code, // Mã QR icon
                                            color: AppColor.mainText,
                                            size: 30
                                        ))
                                  ],
                                )

                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          },
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
          onPressed: () => capNhatTrangThaiPXK(),
          child: Text(
            "Hoàn thành Xuất kho",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.07,
            ),
          ),
        ),
      ),
    )
    );
  }

  Future<void> capNhatTrangThaiPXK() async {
    String maPXK = widget.maPXK;

    Map<String, dynamic> requestBody = {
      "36TT":"TT006",
    };
    print('capNhatQrCodeSanPham: $requestBody');

    // Gọi API để gửi thông tin
    String? response = await apiController.capNhatTrangThaiPXK(maPXK,requestBody);

    if (response != null) {
      // Xử lý khi API trả về dữ liệu thành công
      print("API capNhatQrCodeThung Response: $response");
      // Thực hiện các hành động tiếp theo (ví dụ: thông báo thành công)
      _showCompletionDialog();
    } else {
      // Xử lý lỗi (ví dụ: thông báo lỗi)
      print("Không thể gửi dữ liệu, vui lòng thử lại.");
    }
  }
  // Dialog to confirm completion
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Hoàn thành Xuất kho",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Quá trình Xuất kho đã hoàn tất.",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColor.borderInputColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
