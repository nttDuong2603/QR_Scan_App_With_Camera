import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../controllers/api_controller.dart';
import '../../utils/appcolors.dart';

class SuggestedLocationPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const SuggestedLocationPage({Key? key, required this.data}) : super(key: key);

  @override
  State<SuggestedLocationPage> createState() => _SuggestedLocationPageState();
}

class _SuggestedLocationPageState extends State<SuggestedLocationPage> {
  // final ScanBarcodeController _controller = ScanBarcodeController();
  // final ScanBarcodeController _barcodeController = ScanBarcodeController();
  // late KeyEventChannel _keyEventChannel;
  List<Map<String, dynamic>> syncItems = [];
  Set<int> expandedItems = {};
  Set<int> expandedIndexes = {};
  Set<int> selectedItems = {};
  int? expandedIndex;
  String? scannedCode;
  String? maTK = '';
  String? maLichNhapKho; // Biến để lưu MaLichNhapKho
  bool _isScan = false;
  bool _isComplet = false;
  Set<int> syncedIndexes = {};
  late AudioPlayer _audioPlayer;
  final APIController _apiController = APIController();
  String trangThai = ''; // Lưu trạng thái với mã PNK làm khóa
  var getResult= '';
  String IP = "http://192.168.19.180:2002";
  // String IP = "https://admin-demo-saas.mylanhosting.com";


  @override
  void initState() {
    super.initState();
    // _loadEntriesSyncFromSharedPreferences();
    _fetchSuggestedLocations(widget.data['warehouseEntryCode']);
    // _controller.initPlatformState(_updateConnectionStatus, _handleScannedTags);
    // _keyEventChannel = KeyEventChannel(
    //   onKeyReceived: () => _controller.toggleBarcodeScanning(() => setState(() {})),
    // );
    // _keyEventChannel.initialize();
    loadMaTK();
    _loadCompletionStatus();
    _audioPlayer = AudioPlayer();

  }

  // void _updateConnectionStatus(dynamic isConnected) {
  //   setState(() {
  //     _barcodeController.updateConnectionStatus(isConnected);
  //   });
  // }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final maPNK = widget.data['warehouseEntryCode'];
    setState(() {
      _isComplet = prefs.getBool('isComplet_$maPNK') ?? false;
    });
  }

  Future<void> _loadEntriesSyncFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderList = prefs.getStringList('deletedWarehouseEntries') ?? [];
    setState(() {
      syncItems = orderList
          .map((order) => json.decode(order))
          .where((item) => item['status'] == "Đã đồng bộ")
          .toList()
          .cast<Map<String, dynamic>>();
      _sortItemsByDistance(); // Sắp xếp các mục theo khoảng cách
    });
  }

  Future<void> loadMaTK() async {
    final prefs = await SharedPreferences.getInstance();
     maTK = prefs.getString('maTK');
     print(maTK);
    if (maTK != null) {
      print("Loaded maTK: $maTK"); // Xử lý `maTK` theo nhu cầu của ứng dụng
    } else {
      print("maTK not found in SharedPreferences.");
    }
  }

  Future<void> _playScanSound() async {
    try {
      await _audioPlayer.setAsset('assets/sound/Bip.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("$e");
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
          trangThai = decodedData["data"][0]['tenTrangThai'];
        });
      }
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
      bool confirmed = await _showQRCodeConfirmationDialog(getResult);
      if (confirmed) {
        Navigator.pop(context, getResult); // Trả về mã QR đã quét để so sánh
      }
    }
  }


  void _toggleExpansion(int index) {
    setState(() {
      if (expandedIndexes.contains(index)) {
        expandedIndexes.remove(index);
      } else {
        expandedIndexes.add(index);
      }
    });
  }

  Future<void> _fetchSuggestedLocations(String warehouseEntryCode) async {
    final apiController = APIController();
    final response = await apiController.FetchSugguestWarehouseEntry(warehouseEntryCode);

    if (response != null) {
      final data = json.decode(response);
      setState(() {
        // Explicitly cast each item to `Map<String, dynamic>`
        syncItems = (data['DanhSachViTri'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      });
    } else {
      print("Error: Unable to fetch data from API.");
    }
  }


  // Sắp xếp theo vị trí gợi ý
  void _sortItemsByDistance() {
    syncItems.sort((a, b) {
      return (a['suggestedDistance'] ?? 0).compareTo(b['suggestedDistance'] ?? 0);
    });
  }

  Future<String?> _navigateToSugguestQrScan(BuildContext context, String scanTitle) async {
    final scannedCode = await Navigator.pushNamed(
      context,
      '/sugguest_qr_scan',
      arguments: scanTitle,
    );
    if (scannedCode != null && scannedCode is String) {
      return scannedCode; // Trả về mã QR đã quét
    }
    return null;
  }

  Future<void> _showResultDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: message.contains("Lỗi") ? Colors.red : AppColor.mainText, // Kiểm tra nội dung có từ "Lỗi"
              fontSize: 18,
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
                Navigator.pop(context, true);
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
        );
      },
    );
  }
  Future<void> _showResultErrrDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.red ,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color:  Colors.red , // Kiểm tra nội dung có từ "Lỗi"
              fontSize: 18,
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
                Navigator.pop(context, true);
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
        );
      },
    );
  }
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
                    text: "Bạn có muốn sử dụng mã QR này: \n",
                    style: TextStyle(
                      color: AppColor.mainText,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: "$qrCode?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainText,
                      fontSize: 18,
                    ),
                  )
                ]
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: AppColor.borderInputColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
              ),
              onPressed: ()  {
                setState(() {
                  Navigator.of(context).pop();
                  _isScan = false;
                });
              },
              child: Text(
                "Hủy",
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
              onPressed: (){
                _checkQRCodeLocation(qrCode);
                Navigator.of(context).pop();
                setState(() {
                  _isScan = false;
                });
              },
              child: Text(
                "OK",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      }
    )??false;
  }

  Future<void> _checkQRCodeLocation(String qrCode) async {
    // qrCode = 'TA000001';
    final apiController = APIController();
    final response = await apiController.FetchQRCodeInfo(qrCode);

    if (response != null) {
      final decodedResponse = json.decode(response);
      if (decodedResponse['success'] == true && (decodedResponse['data'] as List).isNotEmpty) {
        final data = decodedResponse['data'][0];  // Lấy phần tử đầu tiên của danh sách

        // Extract required fields from the first item in the response list
        final apiMaThung = data['MaThung'];
        final apiMaTang = data['MaTang'];
        final apiMaKe = data['MaKe'];
        final apiMaDay = data['MaDay'];

        print("Mã QR được quét: $qrCode");
        print("Thông tin từ API mã QR:");
        print(" - MaThung: $apiMaThung");
        print(" - MaTang: $apiMaTang");
        print(" - MaKe: $apiMaKe");
        print(" - MaDay: $apiMaDay");

        // Check if there is a matching location in syncItems
        bool locationMatched = false;
        Map<String, dynamic>? matchedBox; // This will store the matching box if found

        for (var location in syncItems) {
          print("\nĐang kiểm tra vị trí gợi ý:");
          print(" - Tang: ${location['Tang']['MaTang']}");
          print(" - Ke: ${location['Ke']['MaKe']}");
          print(" - Day: ${location['Day']['MaDay']}");

          if (location['Tang']['MaTang'] == apiMaTang )
          // &&
              // location['Ke']['MaKe'] == apiMaKe &&
              // location['Day']['MaDay'] == apiMaDay)
          {
            locationMatched = true;
            matchedBox = location; // Assign the matching location to matchedBox
            print("Vị trí đã khớp với mã QR!");
            break;
          } else {
            print("Vị trí không khớp với mã QR");
          }
        }

        if (locationMatched && matchedBox != null) {
          // Show success dialog with matchedBox data if location matches
          _showSuccessResultDialog("Đúng vị trí", "Bạn đã quét đúng vị trí gợi ý. Đồng bộ ngay.", data, matchedBox);
        } else {
          // Show error dialog if the location does not match
          _showResultErrrDialog("Lỗi", "Vị trí không khớp. Vui lòng quét lại.");
        }
      } else {
        print("Lỗi: Không tìm thấy dữ liệu mã QR hợp lệ trong phản hồi từ API.");
        _showResultErrrDialog("Lỗi", "Không thể lấy thông tin mã QR.");
      }
    } else {
      // Show error dialog if there was an issue with the API call
      _showResultErrrDialog("Lỗi", "Không thể lấy thông tin mã QR.");
    }
  }

  void _showCompletionSyncDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 18,
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
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng khi chạm ngoài dialog
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Biểu tượng loading
              SizedBox(height: 10),
              Text(
                "Đang đồng bộ...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _startSyncProcess(
      BuildContext context, {
        required Map<String, dynamic> data,
        required Map<String, dynamic> location,
      }) async {
    showLoadingDialog(context); // Hiển thị dialog đang đồng bộ
    final apiController = APIController();
    final apiMaTang = location['Tang']['MaTang'];
    final apiMaKe = location['Ke']['MaKe'];
    final apiMaDay = location['Day']['MaDay'];
    final tenKe = location['Ke']['TenKe'];
    final tenDay = location['Day']['TenDay'];

    int soLuongThung = location['DanhSachThung']?.length ?? 0;

    for (var box in location['DanhSachThung']) {
      print('danh sách thùng: ${location['DanhSachThung']}');
      print('maThung: ${box['MaThung']}');
      final String maThung = box['MaThung'];
      final int startIndex = box['IndexDau'];
      final int endIndex = box['IndexCuoi'];
      final String? maLichNhapKho = box['MaLichNhapKho'];
      final String QRCodeThung = box['MaQRCode'];
      final String? maChiTietLichNhapKho = box['MaChiTietLichNhapKho'];
      print('mã chi tiết lịch nhập kho: $maChiTietLichNhapKho');
      final int? sucChua = box['SucChua'];
      final num? khoLuongThung = box['KhoiLuongThung'];

      final warehouseEntryInfoRequest = {
        "30MT": "$maThung",
        "5MLNK": "$maLichNhapKho",
        "3MPNK": "${widget.data['warehouseEntryCode']}",
        "31MT": "$apiMaTang",
        "44GC": "",
        "6TKTB": "$maTK",
        "15TK": "$tenKe",
        "4MD": "$apiMaDay",
        "3TD": "$tenDay",
        "2SLT": soLuongThung,
        "1SLSP": sucChua,
        "2MCTLNK": "$maChiTietLichNhapKho"
      };


      print('warehouseEntryInfoRequest: $warehouseEntryInfoRequest');

      final boxUpdateInForRequest = {
        "3SLĐN": sucChua,
        "11NN": "",
        "3SLĐX": 0,
        "29MT": "$apiMaTang",
        "5KC": "",
        "1MCTLNK": "$maChiTietLichNhapKho",
        "5MPNK": "${widget.data['warehouseEntryCode']}",
        "9MLNK": "$maLichNhapKho"
      };
      print('boxUpdateInForRequest: $boxUpdateInForRequest');

      final boxQRCodeRequest = {
        "1LMQ": "",
        "2MPNK": "${widget.data['warehouseEntryCode']}",
        "13MPXK": "",
        "1MLXK": "",
        "8MLNK": "$maLichNhapKho",
        "2MD": "",
        "28MK": "",
        "27MT": "$apiMaTang",
        "28MT": "",
        "41MSP": "",
        "1MTSP": "$maThung",
        "33TT": "TT008",
      };

      final productInfoRequest = {
        "1LMQ": "",
        "2MPNK": "${widget.data['warehouseEntryCode']}",
        "13MPXK": "",
        "1MLXK": "",
        "2MD": "",
        "28MK": "",
        "27MT": "",
        "28MT": "",
        "41MSP": "",
        "1MTSP": "$maThung",
        "33TT": "TT008",
        "8MLNK": "$maLichNhapKho",
        "indexDau": startIndex,
        "indexCuoi": endIndex
      };

      final capNhatThongTinTangRequest = {
        "4SLĐN": sucChua,
        "2SLĐX": 0,
        "1KLĐN": khoLuongThung,
        "1KLĐX": 0,
        "23MT": "$apiMaTang"
      };
      print("capNhatThongTinTangRequest: $capNhatThongTinTangRequest");
      try {
        // Thực hiện các yêu cầu API
        final warehouseEntryResponse = await apiController.postWarehouseEntryInfor(warehouseEntryInfoRequest);
        print('warehouseEntryResponse: $warehouseEntryResponse');

        final boxQRCodeResponse = await apiController.updateQRCodeManagementTableAccordingToQrCode(QRCodeThung, boxQRCodeRequest);
        print('boxQRCodeResponse: $boxQRCodeResponse');

        final boxUpdateInForResponse = await apiController.updateBoxInfor(maThung, boxUpdateInForRequest);
        print('boxUpdateInForResponse: $boxUpdateInForResponse');

        final productInfoResponse = await apiController.updateQRCodeManagementTableAccordingToIndex("QR2024103100005", productInfoRequest);
        print('productInfoResponse: $productInfoResponse');

        final capNhatThongTinTangResponse = await apiController.capnhatThongTinTang(apiMaTang, capNhatThongTinTangRequest);
        print('capNhatThongTinTangResponse: $capNhatThongTinTangResponse');

      } catch (e) {
        print("Lỗi khi gọi API cho thùng $maThung: $e");
      }
    }

    Navigator.pop(context); // Đóng dialog sau khi hoàn tất vòng lặp
    setState(() {
      syncedIndexes.add(location.hashCode); // Đánh dấu vị trí đã đồng bộ
    });
    // Hiển thị dialog đồng bộ thành công sau khi hoàn tất toàn bộ vòng lặp
    _showCompletionSyncDialog("Thành công", "Đồng bộ hoàn tất thành công.");
  }





// Điều chỉnh lời gọi _startSyncProcess để không truyền thừa tham số trong dialog
  Future<void> _showSuccessResultDialog(
      String title, String message, Map<String, dynamic> data, Map<String, dynamic> box) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 18,
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async{
                    _startSyncProcess(
                      context,
                      data: data,
                      location: box,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Bắt đầu đồng bộ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<bool> _showEntryLocationDialog(Map<String, dynamic> location) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.backgroundAppColor,
          title: Text(
            "Di chuyển Nhập kho",
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
                "Vị trí nhập kho:",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                // "- Dãy: ${location['Day']['TenDay']}\n"
                //     "- Kệ: ${location['Ke']['TenKe']}\n"
                    "-${location['Tang']['TenTang']}\n",
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
              // Display each box's details in a scrollable section
              SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (location['DanhSachThung'] as List)
                        .map<Widget>((box) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Mã QR Code Thùng: ${box['MaQRCode']}",
                          //   style: TextStyle(
                          //     color: AppColor.mainText,
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          Text(
                            "Mã Thùng: ${box['MaThung']}",
                            style: TextStyle(
                              color: AppColor.mainText,
                              fontSize: 16,
                            ),
                          ),

                          Text(
                            "${box['TenSanPham']}",
                            style: TextStyle(
                              color: AppColor.mainText,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "SKU: ${box['MaSanPham']}",
                            style: TextStyle(
                              color: AppColor.mainText,
                              fontSize: 16,
                            ),
                          ),
                          Divider(color: Colors.grey), // Divider between boxes
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
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
                    // _controller.toggleBarcodeScanning(() => setState(() {}));
                    scanQRCode();
                    Navigator.pop(context, true); // Close the dialog first
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
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Hoàn thành Nhập kho",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Quá trình nhập kho đã được hoàn tất.",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 18,
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
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Đóng dialog
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmWarehouseCompletion() async {
    final apiController = APIController();
    final String maPNK = widget.data['warehouseEntryCode'];
    // Dữ liệu JSON để cập nhật trạng thái hoàn thành nhập kho
    final requestBody = {
      "34TT": "TT004",
    };

    try {
      // Gọi API updateWarehouseEntry với mã phiếu nhập kho (MPNK) và requestBody
      final response = await apiController.updateWarehouseEntry(maPNK, requestBody);

      // Kiểm tra phản hồi từ API
      if (response != null) {
        final responseData = json.decode(response);

        // Kiểm tra nếu phản hồi có kết quả cập nhật
        if (responseData["success"] == true && responseData["results_of_update"] != null) {
          final updatedStatus = responseData["results_of_update"][0]["34TT"];
          // Đặt _isComplet thành true và lưu vào SharedPreferences
          setState(() {
            _isComplet = true;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isComplet_$maPNK', true);
          // Cập nhật trạng thái của các mục trong danh sách `syncItems`
          setState(() {
            for (var item in syncItems) {
              if (item["MPNK"] == "Mã Phiếu Nhập Kho") { // Kiểm tra để cập nhật đúng mục
                item["status"] = updatedStatus; // Cập nhật trạng thái
              }
            }
          });

          // Nếu thành công, hiển thị hộp thoại hoàn thành
          _showCompletionDialog();
        } else {
          // Nếu không thành công, hiển thị thông báo lỗi
          _showResultErrrDialog("Lỗi", "Cập nhật trạng thái nhập kho thất bại.");
        }
      } else {
        _showResultErrrDialog("Lỗi", "Không thể kết nối với API.");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      _showResultErrrDialog("Lỗi", "Có lỗi xảy ra trong quá trình cập nhật trạng thái nhập kho.");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Gợi ý Nhập kho',
          style: TextStyle(
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
            color: AppColor.mainText,
          ),
        ),
      ),
      body: syncItems.isNotEmpty
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: syncItems.map((location) {
            return Card(
              color: AppColor.backgroundAppColor,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Vị trí: ${location['Tang']['TenTang']}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: AppColor.mainText,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Khoảng cách: ${location['KhoangCach']} mét",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: AppColor.mainText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          // Kiểm tra nếu vị trí nằm trong syncedIndexes
                          "Trạng thái: ${syncedIndexes.contains(location.hashCode) ? "Đã nhập" : "Đang nhập kho"}",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: AppColor.mainText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        expandedIndexes.contains(location.hashCode)
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColor.mainText,
                        size: 30,
                      ),
                      onPressed: () => _toggleExpansion(location.hashCode),
                    ),
                    onTap:() => _showEntryLocationDialog(location),
                  ),
                  if (expandedIndexes.contains(location.hashCode))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (location['DanhSachThung'] as List).map<Widget>((box) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   "Mã QR Code Thùng: ${box['MaQRCode']}",
                              //   style: TextStyle(
                              //     color: AppColor.mainText,
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.bold
                              //   ),
                              // ),
                              Text(
                                "Mã Thùng: ${box['MaThung']}",
                                style: TextStyle(
                                  color: AppColor.mainText,
                                  fontSize: 16,
                                ),
                              ),

                              Text(
                                "${box['TenSanPham']}",
                                style: TextStyle(
                                  color: AppColor.mainText,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "SKU: ${box['MaSanPham']}",
                                style: TextStyle(
                                  color: AppColor.mainText,
                                  fontSize: 16,
                                ),
                              ),
                              Divider(color: Colors.grey),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      )
          : Center(
        child: Text(
          "Chưa có sản phẩm đồng bộ.",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            color: AppColor.mainText,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColor.backgroundAppColor,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: _isComplet == false
                ? AppColor.borderInputColor // Màu khi nút có thể bấm (đã hoàn thành)
                : Colors.grey.shade400,  // Màu xám nhạt khi nút không thể bấm
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
          ),
          onPressed:
              () async {
                if(_isComplet == false){
                  await _confirmWarehouseCompletion();
                }else{
                  return;
                }
          },
              // : null, // onPressed là null khi nút không thể bấm
          child: Text(
            "Hoàn thành Nhập kho",
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
