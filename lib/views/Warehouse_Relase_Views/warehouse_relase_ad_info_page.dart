import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_format.dart';
import '../../utils/appcolors.dart';
import '../../views/Warehouse_Relase_Views/warehouse_relase_details.dart';
import '../../views/Warehouse_Relase_Views/warehouse_relase_suggest_location_page.dart';

import '../../controllers/api_controller.dart';
import '../../controllers/barcode_scan_controller.dart';
import '../../utils/key_event_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:just_audio/just_audio.dart';

class WarehouseReleaseAdInforPage extends StatefulWidget {

  const WarehouseReleaseAdInforPage({super.key});

  @override
  State<WarehouseReleaseAdInforPage> createState() => _WarehouseReleaseAdInforPageState();
}

class _WarehouseReleaseAdInforPageState extends State<WarehouseReleaseAdInforPage> {
  // final ScanBarcodeController _controller = ScanBarcodeController();
  final APIController _apiController = APIController();
  Map<String, dynamic>? orderDetails;
  List<Map<String, dynamic>>? items;
  late KeyEventChannel _keyEventChannel;
  bool _isExpanded = true;
  final AppFormat appFormat = AppFormat();
  int? expandedTOIndex;
  String? selectedTOCode;
  bool _isScan = false;
  late AudioPlayer _audioPlayer;
  var getResult = '';


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
        await _fetchAndDisplayLXHWithPXK(getResult);
      }
    }
  }
  // Hàm xử lý sự kiện quét mã QR
  // void handleScannedTags(dynamic result) async {
  //   if(_isScan) {
  //     return;
  //   }else{
  //     final qrCode = await _controller.updateTags(result);
  //     // final qrCode = 'PXK0002';
  //
  //     if (qrCode != null) {
  //       _playScanSound();
  //       bool isConfirmed = await _showQRCodeConfirmationDialog(qrCode);
  //       if (isConfirmed) {
  //         await _fetchAndDisplayLXHWithPXK(qrCode);
  //       }
  //     }
  //   }
  //
  // }

  // Gọi API để lấy và hiển thị thông tin LXH theo PXK
  Future<void> _fetchAndDisplayLXHWithPXK(String qrCodePXK) async {
    // Gọi API để lấy thông tin chi tiết phiếu nhập kho
    final apiResponse = await _apiController.FetchLXHWithPXK(qrCodePXK);
    if (apiResponse != null) {
      final decodedData = json.decode(apiResponse);
      print("decodedData: $decodedData");
      if (decodedData is Map<String, dynamic> && decodedData["data"] is List && decodedData["data"].isNotEmpty) {
        // Gán danh sách `LXH` vào `items`
        setState(() {
          items = List<Map<String, dynamic>>.from(decodedData["data"][0]["LXH"]);
          print('items: $items');
          orderDetails = {
            "MaPhieuXuatKho": decodedData["data"][0]["MaPhieuXuatKho"],
            "NgayXuatKho": decodedData["data"][0]["NgayXuatKho"],
            "TenTrangThai_PXK": decodedData["data"][0]["TenTrangThai_PXK"],
            "TenCuaHang":decodedData["data"][0]["TenCuaHang"],
          };
        });
      }
    }
  }

  // Hiển thị hộp thoại xác nhận mã QR
  Future<bool> _showQRCodeConfirmationDialog(String qrCode) async {
    _isScan = true;
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
                      _isScan = false;
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
                      _isScan = false;
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

  Future<String?> getUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUser');
  }

  Future<void> _saveOrderToSharedPreferences(String userAccount) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing entries
    List<String> orderList = prefs.getStringList('warehouseReleases') ?? [];

    // Create new order entry with userAccount field
    final newOrder = {
      "userAccount": userAccount,
      "items": items,
      "orderDetails":orderDetails,
    };

    // Add new order to the list and save
    orderList.add(json.encode(newOrder));
    await prefs.setStringList('warehouseReleases', orderList);

    print("Saved order list: $orderList"); // Verify saved data
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope( onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
          context,
          '/homePage'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
    child:  Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: AppColor.backgroundAppColor,
          leading: InkWell(
            onTap: () {},
            child: Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
            ),
          ),
          title: Row(
            children: [
              Text(
                'Thông tin Xuất kho',
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
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: orderDetails != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần thông tin cố định của phiếu xuất kho
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Phiếu Xuất kho: ",
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
                    text: "${orderDetails!['TenTrangThai_PXK']}",
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

            // Tiêu đề và nút mở rộng danh sách lệnh xuất hàng
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
            backgroundColor: AppColor.borderInputColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
          ),
          onPressed: () async {
            final userAccount = await getUserAccount();
            print("Tài khoản tạo lịch: $userAccount");

            if (userAccount != null) {
              await _saveOrderToSharedPreferences(userAccount);

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
            } else {
              print("Không tìm thấy tài khoản. Vui lòng đăng nhập.");
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
    )
    );
  }
}
