import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:flutter/material.dart';
import '../../controllers/api_controller.dart';
import '../../utils/app_format.dart';
import '../../utils/appcolors.dart';
import '../../utils/key_event_channel.dart';
import 'warehouse_entry_infor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/warehouse_entry_schedule.dart';

class WarehouseReceivingScanBarcodePage extends StatefulWidget {
  const WarehouseReceivingScanBarcodePage({super.key});

  @override
  State<WarehouseReceivingScanBarcodePage> createState() => _WarehouseReceivingScanBarcodePageState();
}

class _WarehouseReceivingScanBarcodePageState extends State<WarehouseReceivingScanBarcodePage> {
  // final ScanBarcodeController _controller = ScanBarcodeController();
  final APIController _apiController = APIController();
  Map<String, dynamic>? orderDetails;
  List<WarehouseEntrySchedule> _exportCodes = [];

  List<Map<String, dynamic>> items = [];
  late KeyEventChannel _keyEventChannel;
  bool _isExpanded = true;
  bool _isscan = false;
  final AppFormat appFormat = AppFormat();
  List<Map<String, dynamic>> confirmedEntries = [];
  int productTotal = 0;
  late AudioPlayer _audioPlayer;
  var getResult = '';
  String IP = "http://115.78.237.91:2002";
  // String IP = "https://admin-demo-saas.mylanhosting.com";


  @override
  void initState() {
    super.initState();
    // _controller.initPlatformState(updateConnectionStatus, handleScannedTags);
    // _keyEventChannel = KeyEventChannel(
    //   onKeyReceived: () => _controller.toggleBarcodeScanning(() => setState(() {})),
    // );
    // _keyEventChannel.initialize();
    _audioPlayer = AudioPlayer();
  }

  // Hàm cập nhật trạng thái kết nối
  // void updateConnectionStatus(dynamic isConnected) {
  //   setState(() {
  //     _controller.updateConnectionStatus(isConnected);
  //   });
  // }

  Future<void> _playScanSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/Bip.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("$e");
    }
  }

  // Trích xuất mã từ URL
  String? extractCodeFromUrl(String url) {
    try {
      // Kiểm tra xem URL có chứa "check/" không
      if (url.contains("check/")) {
        // Tìm vị trí của "check/" trong URL
        int startIndex = url.indexOf("check/") + "check/".length;
        // Tìm vị trí của "?" (nếu có) để lấy phần mã từ sau "check/" đến trước "?" hoặc đến cuối URL
        int endIndex = url.contains("?") ? url.indexOf("?") : url.length;
        // Trích xuất mã sản phẩm
        return url.substring(startIndex, endIndex);
      }
    } catch (e) {
      print("Lỗi khi phân tích URL: $e");
    }
    return null;
  }

  void scanQRCode() async {
    try {
      // Quét mã QR và nhận kết quả
      final code = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);

      // Kiểm tra nếu mã quét được là URL hợp lệ và có chứa "check/"
      if ((code.startsWith('http://') || code.startsWith('https://')) && code.contains("check/")) {
        // Trích xuất mã sản phẩm từ URL
        String? extractedCode = extractCodeFromUrl(code);
        if (extractedCode != null) {
          print("Mã QR code được quét từ URL: $extractedCode");
          _updateUIWithQRCode(extractedCode);
        } else {
          // Nếu không trích xuất được mã, có thể thông báo lỗi
          print("Không thể trích xuất mã từ URL");
        }
      } else {
        // Nếu không phải URL, lấy nguyên chuỗi mã QR
        print("Mã QR code được quét: $code");
        _updateUIWithQRCode(code);
      }

    } on PlatformException {
      print("Lỗi khi quét mã QR");
    }
  }

// Cập nhật UI với mã QR đã quét
  void _updateUIWithQRCode(String code) async{
    if (!mounted) return; // Kiểm tra xem widget có còn tồn tại trong tree không

    setState(() {
      getResult = code; // Cập nhật mã QR đã quét
    });
    print("QrCode result: --");
    print(code);

    // Hiển thị hộp thoại xác nhận mã QR
    if (getResult != null) {
      _playScanSound();
      bool isConfirmed = await _showQRCodeConfirmationDialog(getResult);
      if (isConfirmed) {
        await _fetchAndDisplayOrderDetails(getResult);
      }
    }
  }

  // Hàm xử lý sự kiện quét mã QR
  // void handleScannedTags(dynamic result) async {
  //   if(_isscan){
  //     return;
  //   }else {
  //     // final qrCode = await _controller.updateTags(result);
  //     final qrCode = await _controller.updateTags(result);
  //
  //     if (qrCode != null) {
  //       _playScanSound();
  //       bool isConfirmed = await _showQRCodeConfirmationDialog(qrCode);
  //       if (isConfirmed) {
  //         await _fetchAndDisplayOrderDetails(qrCode);
  //       }
  //     }
  //   }
  // }

  Future<void> _saveOrderToSharedPreferences(String userAccount) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderList = prefs.getStringList('warehouseEntries') ?? [];

    // Tạo một bản ghi mới cho đơn nhập kho
    final newOrder = {
      "userAccount": userAccount,
      "orderDetails": orderDetails,
      "items": items,
    };

    // Chuyển `newOrder` thành chuỗi JSON và thêm vào danh sách `orderList`
    orderList.add(json.encode(newOrder));
    await prefs.setStringList('warehouseEntries', orderList);
  }


  // Hiển thị hộp thoại xác nhận mã QR
  Future<bool> _showQRCodeConfirmationDialog(String qrCode) async {
    _isscan = true;
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận mã QR",
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
                      text: ("Bạn có muốn sử dụng mã QR này: \n"),
                      style: TextStyle(
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
                  TextSpan(
                      text: ("$qrCode?"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  )
                ]
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
                      )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    setState(() {
                      _isscan = false;
                    });
                  },
                  child: Text("Hủy",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(width: 30),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: AppColor.borderInputColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    setState(() {
                      _isscan = false;
                    });
                  },
                  child: Text("OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    ) ?? false;
  }

  // Future<void> _fetchAndDisplayOrderDetails(String qrCode) async {
  //   // Gọi API lấy thông tin đơn nhập kho
  //   final apiResponse = await _apiController.FetchWarehouseReceivingDetail(qrCode);
  //
  //   // Gọi API lấy danh sách sản phẩm đã nhập
  //   final apiListOfImportedProductsResponse = await _apiController.FetchListOfImportedProducts(qrCode);
  //
  //   if (apiResponse != null && apiListOfImportedProductsResponse != null) {
  //     try {
  //       // Giải mã kết quả trả về từ API FetchWarehouseReceivingDetail
  //       final decodedData = json.decode(apiResponse);
  //
  //       // Giải mã kết quả trả về từ API FetchListOfImportedProducts
  //       final decodedListOfImportedProductsData = json.decode(apiListOfImportedProductsResponse);
  //
  //       if (decodedData is Map<String, dynamic> &&
  //           decodedData['data'] is List &&
  //           decodedData['data'].isNotEmpty) {
  //
  //         final entry = decodedData['data'][0];
  //
  //         // Cập nhật orderDetails từ kết quả FetchWarehouseReceivingDetail
  //         setState(() {
  //           orderDetails = {
  //             "warehouseEntryCode": entry['MaPhieuNhapKho'],
  //             "expectedDeliveryDate": entry['NgayNhapKho'],
  //             "status": entry['TrangThai']
  //           };
  //
  //           // Thêm sản phẩm từ FetchWarehouseReceivingDetail vào items
  //           items = [
  //             {
  //               "description": entry['TenSanPham'],
  //               "productCode": entry['MaSanPham'],
  //               "quantity": entry['SoLuong'],
  //               "XuatXu": entry['XuatXu'],
  //               "NhaCungCap": entry['NhaCungCap'],
  //               "ThongTinSanPham": entry['ThongTinSanPham'],
  //               "NguoiTaoSanPham": entry['NguoiTaoSanPham'],
  //               "NgayTaoSanPham": entry['NgayTaoSanPham'],
  //               "MaQuyCach": entry['MaQuyCach'],
  //               "TrongLuong": entry['TrongLuong'],
  //               "GhiChuQuyCach": entry['GhiChuQuyCach'],
  //               "NguoiTaoQuyCach": entry['NguoiTaoQuyCach'],
  //               "NgayTaoQuyCach": entry['NgayTaoQuyCach'],
  //               "LoaiHang": entry['LoaiHang'],
  //               "MaPhieuNhapKho": entry['MaPhieuNhapKho'],
  //               "MaNhaCungCap": entry['MaNhaCungCap'],
  //               "NguoiLapPhieu": entry['NguoiLapPhieu'],
  //               "NgayNhapKho": entry['NgayNhapKho'],
  //               "GhiChu_PNK": entry['GhiChu_PNK'],
  //               "TrangThai": entry['TrangThai'],
  //               "NguoiTao_PNK": entry['NguoiTao_PNK'],
  //               "NgayTao_PNK": entry['NgayTao_PNK'],
  //               "MaLichNhapKho": entry['MaLichNhapKho'],
  //               "SoPhieuNhapKho": entry['SoPhieuNhapKho'],
  //               "MaLoaiHang": entry['MaLoaiHang'],
  //               "GhiChuLichNhapKho": entry['GhiChuLichNhapKho'],
  //               "NguoiTaoLichNhapKho": entry['NguoiTaoLichNhapKho'],
  //               "NgayTaoLichNhapKho": entry['NgayTaoLichNhapKho'],
  //               "SoLuongCanNhap": entry['SoLuongCanNhap'],
  //             }
  //           ];
  //
  //           // Thêm sản phẩm từ FetchListOfImportedProducts vào items
  //           if (decodedListOfImportedProductsData is List) {
  //             items.addAll(decodedListOfImportedProductsData.map((product) => {
  //               "_id": product['_id'],
  //               "TenSanPham": product['TenSanPham'],
  //               "MaQuyCach": product['MaQuyCach'],
  //               "NhaCungCap": product['NhaCungCap'],
  //               "XuatXu": product['XuatXu'],
  //               "ThongTinSanPham": product['ThongTinSanPham'],
  //               "NguoiTaoSanPham": product['NguoiTaoSanPham'],
  //               "NgayTaoSanPham": product['NgayTaoSanPham'],
  //               "TrongLuong": product['TrongLuong'],
  //               "SoLuong": product['SoLuong'],
  //               "GhiChuQuyCach": product['GhiChuQuyCach'],
  //               "NguoiTaoQuyCach": product['NguoiTaoQuyCach'],
  //               "NgayTaoQuyCach": product['NgayTaoQuyCach'],
  //               "MaChiTietLichNhapKho": product['MaChiTietLichNhapKho'],
  //               "MaLichNhapKho": product['MaLichNhapKho'],
  //               "SoLuongNhap": product['SoLuongNhap'],
  //               "GhiChuChiTietLichNhapKho": product['GhiChuChiTietLichNhapKho'],
  //               "NguoiTaoChiTietLichNhapKho": product['NguoiTaoChiTietLichNhapKho'],
  //               "NgayTaoChiTietLichNhapKho": product['NgayTaoChiTietLichNhapKho'],
  //               "MaPhieuNhapKho": product['MaPhieuNhapKho'],
  //               "MaSanPham": product['MaSanPham'],
  //             }).toList());
  //           }
  //           print(items);
  //         });
  //
  //       } else {
  //         print("API response structure mismatch.");
  //       }
  //     } catch (e) {
  //       print("Error parsing API response: $e");
  //     }
  //   }
  // }

  // Lấy thông tin nhập kho và danh sách sản phẩm từ API
  Future<void> _fetchAndDisplayOrderDetails(String qrCode) async {
    // Gọi API để lấy thông tin chi tiết phiếu nhập kho
    final apiResponse = await _apiController.FetchWarehouseReceivingDetail(qrCode);
    if (apiResponse != null) {
      final decodedData = json.decode(apiResponse);
      print("decodedData: $decodedData");
      if (decodedData is Map<String, dynamic> && decodedData["data"] is List && decodedData["data"].isNotEmpty) {
        // Truy cập phần tử đầu tiên của mảng "data" để lấy chi tiết đơn hàng
        final entry = decodedData["data"][0];
        setState(() {
          orderDetails = {
            "warehouseEntryCode": entry["MaPhieuNhapKho"],
            "expectedDeliveryDate": entry["NgayNhapKho"],
            "status": entry["TenTrangThai"]
          };
        });
      }
    }

    // Gọi API để lấy danh sách sản phẩm đã nhập kho
    final productListResponse = await _apiController.FetchListOfImportedProducts(qrCode);
    if (productListResponse != null) {
      final decodedListData = json.decode(productListResponse);
      print("decodedListData: $decodedListData");
      if (decodedListData is Map<String, dynamic> && decodedListData["data"] is List) {
        setState(() {
          items = List<Map<String, dynamic>>.from(decodedListData["data"]);
          productTotal = decodedListData["total"] ?? 0;
        });
      }
    }
  }

  Future<String?> getUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUser');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope( onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
        context,
          '/warehouse_entry'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
    child: Scaffold(
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
                'Thông tin Nhập kho',
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainText,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              // onPressed: () => _controller.toggleBarcodeScanning(() => setState(() {})),
              onPressed: (){
                scanQRCode();
              },
              icon: Icon(
                Icons.qr_code_scanner_outlined,
                color: AppColor.mainText,
                size: screenWidth * 0.12,
              ),
            ),
          ]
        ),
      ),
      body:  Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: orderDetails != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị thông tin phiếu nhập kho
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Phiếu Nhập kho: ", style: TextStyle(color: AppColor.mainText, fontSize: screenWidth * 0.05,)),
                  TextSpan(text: "${orderDetails!['warehouseEntryCode']}", style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05,)),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Ngày nhập: ", style: TextStyle(color: AppColor.mainText, fontSize: screenWidth * 0.05,)),
                  TextSpan(text: "${appFormat.formatDate(orderDetails!['expectedDeliveryDate'])}", style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05,)),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "Trạng thái: ", style: TextStyle(color: AppColor.mainText, fontSize: screenWidth * 0.05,)),
                  TextSpan(text: "${orderDetails!['status']}", style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05,)),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Danh sách sản phẩm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Danh sách sản phẩm ($productTotal):", style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: AppColor.mainText,)),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
            Divider(),

            // Phần danh sách sản phẩm có thể cuộn
            _isExpanded
                ? Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Lấy hình ảnh đầu tiên từ mảng 'HinhAnh' nếu có
                  final String? imageUrl = item['HinhAnh'] != null && item['HinhAnh'].isNotEmpty
                      ? '$IP${item['HinhAnh'][0]}'
                      : null; // Đường dẫn tới hình ảnh đầu tiên, thay thế 'https://yourserver.com' với server của bạn
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Row(
                      children: [
                        if (imageUrl != null) // Kiểm tra nếu có hình ảnh
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
                          ),
                        if (imageUrl == null)
                          Container(
                            width: 60,
                            height: 60,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(Icons.image, size: 40, color: Colors.grey), // Hiển thị biểu tượng hình ảnh mặc định
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Tên sản phẩm: ",
                                      style: TextStyle(color: AppColor.mainText),
                                    ),
                                    TextSpan(
                                      text: "${item['TenSanPham']}",
                                      style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "SKU: ",
                                      style: TextStyle(color: AppColor.mainText),
                                    ),
                                    TextSpan(
                                      text: "${item['MaSanPham']}/${item['MaChiTietLichNhapKho']}/ ${item['soLot']}",
                                      style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Số lượng: ",
                                      style: TextStyle(color: AppColor.mainText),
                                    ),
                                    TextSpan(
                                      text: "${item['SoLuongNhap']}",
                                      style: TextStyle(color: AppColor.mainText, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
        child:
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColor.borderInputColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
          ),
          onPressed: () async {
            // Lấy tài khoản hiện tại từ SharedPreferences
            final userAccount = await getUserAccount();
            print("Tài khoản hiện tại: $userAccount");

            if (userAccount != null) {
              // Lưu thông tin đơn nhập kho vào SharedPreferences cho tài khoản hiện tại
              await _saveOrderToSharedPreferences(userAccount);

              // Chuyển đến WarehouseReleaseSuggest và truyền dữ liệu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WarehouseEntryInforPage(
                    entry: {
                  "orderDetails": orderDetails,
                  "items": items,
                  },
                  ),
                ),
              );
            } else {
              // Xử lý trường hợp không có tài khoản
              print("Không tìm thấy tài khoản. Vui lòng đăng nhập.");
            }
          },
          child: Text(
            "Gán Thông Tin Sản Phẩm",
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.07,
            ),
          ),
        )
      ),
    )
    );
  }

}
