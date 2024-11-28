import 'package:flutter/material.dart';
import '../../utils/appcolors.dart';
import '../../utils/key_event_channel.dart';
import 'warehouse_relase_suggest_location_page.dart';
import 'dart:convert';
import '../../controllers/api_controller.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

class QrScanReleasePage extends StatefulWidget {
  final Map<String, dynamic> location;
  final Map<String, dynamic> box;
  final Map<String, dynamic>? productData;
  final String maPXK;

  const QrScanReleasePage({
    Key? key,
    required this.location,
    required this.box,
    required this.productData,
    required this.maPXK
  }) : super(key: key);

  @override
  State<QrScanReleasePage> createState() => _QrScanReleasePageState();
}

class _QrScanReleasePageState extends State<QrScanReleasePage> {
  // final ScanBarcodeController _barcodeController = ScanBarcodeController();
  List<String> scannedCodes = []; // Danh sách mã QR đã quét
  // final ScanBarcodeController _controller = ScanBarcodeController();
  late KeyEventChannel _keyEventChannel;
  bool _isScan = false;
  String? _selectedOption;
  final apiController = APIController();
  List<String> qrCodesToExport = []; // Khởi tạo danh sách trống để tránh lỗi
  String? maTK = '';
  // Biến để lưu thông tin `location` và `box`
  Map<String, dynamic>? location;
  Map<String, dynamic>? box;
  String loaiQRCode = '';
  String LichSanXuatQRCode = '';
  int startIndex = 0;
  int endIndex = 0;
  int SLX = 0;
  num khoiLuongXuat = 0;
  final APIController _apiController = APIController();
  late AudioPlayer _audioPlayer;
  var getResult = '';

  @override
  void initState() {
    super.initState();
    loadMaTK();
    // Khởi tạo các sự kiện liên quan đến quét mã vạch và phím
    // _controller.initPlatformState(_updateConnectionStatus, _handleScannedTags);
    // _keyEventChannel = KeyEventChannel(
    //   onKeyReceived: () => _controller.toggleBarcodeScanning(() => setState(() {})),
    // );
    // _keyEventChannel.initialize();
    _audioPlayer = AudioPlayer();

  }

  // void _updateConnectionStatus(dynamic isConnected) {
  //   setState(() {
  //     _barcodeController.updateConnectionStatus(isConnected);
  //   });
  // }

  // Future<void> _handleScannedTags(dynamic result) async {
  //   if (_isScan) {
  //     return;
  //   } else {
  //     final code = await _barcodeController.updateTags(result);
  //     if (code != null) {
  //       setState(() {
  //         scannedCodes.add(code); // Thêm mã đã quét vào danh sách
  //       });
  //       await _showQRCodeConfirmationDialog(code);
  //     }
  //   }
  // }

  // Future<void> _handleScannedTags(dynamic result) async {
  //   if (_isScan) {
  //     return;
  //   }
  //
  //   final code = await _barcodeController.updateTags(result);
  //
  //   if (code != null) {
  //     if (loaiQRCode == "LM00004") {
  //       // Nếu loại QRCode là LM00004, chỉ cho phép quét một mã và kiểm tra MaThung
  //       String? qrData = await apiController.FetchThongTinQRCode(code, {});
  //       if (qrData != null) {
  //         var qrInfo = jsonDecode(qrData)['data'][0];
  //         String fetchedMaThung = qrInfo['MaThung'] ?? '';
  //         print(fetchedMaThung);
  //         print(widget.box?['MaThung']);
  //         if (fetchedMaThung == widget.box?['MaThung']) {
  //           // Nếu MaThung trùng khớp, hỏi xác nhận trước khi thêm mã QR
  //           bool confirm = await _showQRCodeConfirmationDialog(code);
  //           if (confirm) {
  //             setState(() {
  //               scannedCodes = [code]; // Chỉ giữ lại một mã QR trong danh sách
  //             });
  //           }
  //         } else {
  //           // Nếu MaThung không trùng khớp, hiển thị thông báo và yêu cầu quét lại
  //           _showRetryScanDialog();
  //         }
  //       } else {
  //         // Nếu không lấy được dữ liệu từ QRCode, hiển thị thông báo lỗi
  //         _showErrorDialog("Không thể lấy thông tin mã QR. Vui lòng thử lại.");
  //       }
  //     } else {
  //       // Nếu loại QRCode khác LM00004, cho phép quét và hỏi xác nhận
  //       bool confirm = await _showQRCodeConfirmationDialog(code);
  //       if (confirm) {
  //         setState(() {
  //           scannedCodes.add(code); // Lưu mã QR nếu người dùng bấm OK
  //         });
  //       }
  //     }
  //   }
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
      String? qrData = await apiController.FetchThongTinQRCode(getResult, {});
      if (qrData != null) {
        var qrInfo = jsonDecode(qrData)['data'][0];
        String fetchedMaThung = qrInfo['MaThung'] ?? '';
        String fetchedLoaiQRCode = qrInfo['LoaiMaQRCode'] ?? '';

        // Cập nhật loại mã QRCode để dùng cho các thao tác tiếp theo
        loaiQRCode = fetchedLoaiQRCode;

        if (loaiQRCode == "LM00004") {
          // Trường hợp loại QRCode là "LM00004" - mã QR của Thùng
          if (fetchedMaThung == widget.box?['MaThung']) {
            // Nếu MaThung khớp với mã thùng của box hiện tại
            bool confirm = await _showQRCodeConfirmationDialog(getResult);
            if (confirm) {
              setState(() {
                scannedCodes = [getResult]; // Chỉ giữ lại một mã QR trong danh sách
                _isScan = true; // Không cho phép quét thêm mã QR mới
                startIndex = widget.box['1IĐ']; // Gán startIndex theo ID của box
                endIndex = widget.box['1IC']; // Gán endIndex theo ID của box
                SLX = widget.box['SoLuongHienCo']; // Số lượng hiện có trong thùng
              });
            }
          } else {
            // Nếu MaThung không trùng khớp, hiển thị thông báo và yêu cầu quét lại
            _showRetryScanDialog();
          }
        } else if (loaiQRCode == "LM00005") {
          // Trường hợp loại QRCode là "LM00005" - mã QR của sản phẩm
          bool confirm = await _showQRCodeConfirmationDialog(getResult);
          if (confirm) {
            setState(() {
              scannedCodes.add(getResult); // Lưu mã QR vào danh sách
              // Lấy các chỉ số theo logic bình thường cho mã QR sản phẩm
              if (SLX == 0) {
                startIndex = qrInfo['ID']; // Gán startIndex là ID của mã đầu tiên loại LM00005
              }
              endIndex = qrInfo['ID']; // Luôn cập nhật endIndex theo ID của mã QR cuối cùng loại LM00005
              // SLX++; // Tăng số lượng mã QR loại LM00005 đã quét
            });
          }
        }
      } else {
        // Nếu không lấy được dữ liệu từ QRCode, hiển thị thông báo lỗi
        _showErrorDialog("Không thể lấy thông tin mã QR. Vui lòng thử lại.");
      }
    }
  }

  // Future<void> _handleScannedTags(dynamic result) async {
  //   if (_isScan) {
  //     return;
  //   }
  //
  //   final code = await _barcodeController.updateTags(result);
  //   // final code = "TH000028";
  //
  //   if (code != null) {
  //     _playScanSound();
  //     // Gọi API để lấy dữ liệu mã QR và kiểm tra loại QRCode
  //     String? qrData = await apiController.FetchThongTinQRCode(code, {});
  //     if (qrData != null) {
  //       var qrInfo = jsonDecode(qrData)['data'][0];
  //       String fetchedMaThung = qrInfo['MaThung'] ?? '';
  //       String fetchedLoaiQRCode = qrInfo['LoaiMaQRCode'] ?? '';
  //
  //       // Cập nhật loại mã QRCode để dùng cho các thao tác tiếp theo
  //       loaiQRCode = fetchedLoaiQRCode;
  //
  //       if (loaiQRCode == "LM00004") {
  //         // Trường hợp loại QRCode là "LM00004" - mã QR của Thùng
  //         if (fetchedMaThung == widget.box?['MaThung']) {
  //           // Nếu MaThung khớp với mã thùng của box hiện tại
  //           bool confirm = await _showQRCodeConfirmationDialog(code);
  //           if (confirm) {
  //             setState(() {
  //               scannedCodes = [code]; // Chỉ giữ lại một mã QR trong danh sách
  //               _isScan = true; // Không cho phép quét thêm mã QR mới
  //               startIndex = widget.box['1IĐ']; // Gán startIndex theo ID của box
  //               endIndex = widget.box['1IC']; // Gán endIndex theo ID của box
  //               SLX = widget.box['SoLuongHienCo']; // Số lượng hiện có trong thùng
  //             });
  //           }
  //         } else {
  //           // Nếu MaThung không trùng khớp, hiển thị thông báo và yêu cầu quét lại
  //           _showRetryScanDialog();
  //         }
  //       } else if (loaiQRCode == "LM00005") {
  //         // Trường hợp loại QRCode là "LM00005" - mã QR của sản phẩm
  //         bool confirm = await _showQRCodeConfirmationDialog(code);
  //         if (confirm) {
  //           setState(() {
  //             scannedCodes.add(code); // Lưu mã QR vào danh sách
  //             // Lấy các chỉ số theo logic bình thường cho mã QR sản phẩm
  //             if (SLX == 0) {
  //               startIndex = qrInfo['ID']; // Gán startIndex là ID của mã đầu tiên loại LM00005
  //             }
  //             endIndex = qrInfo['ID']; // Luôn cập nhật endIndex theo ID của mã QR cuối cùng loại LM00005
  //             // SLX++; // Tăng số lượng mã QR loại LM00005 đã quét
  //           });
  //         }
  //       }
  //     } else {
  //       // Nếu không lấy được dữ liệu từ QRCode, hiển thị thông báo lỗi
  //       _showErrorDialog("Không thể lấy thông tin mã QR. Vui lòng thử lại.");
  //     }
  //   }
  // }



// Hàm hiển thị thông báo yêu cầu quét lại nếu MaThung không khớp
  void _showRetryScanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Mã QR không hợp lệ",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Mã Thùng không trùng khớp. Vui lòng quét lại",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 16,
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
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

// Hàm hiển thị thông báo lỗi chung
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Lỗi",
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 16,
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
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
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

  // Hiển thị hộp thoại để chọn chế độ xuất kho
  Future<void> _showExportModeDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Chọn chế độ xuất kho",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildExportOption("Xuất Xuất"),
              _buildExportOption("Xuất Giữ"),
              _buildExportOption("Xuất Đủ"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_selectedOption != null) {
                  await _exportData();
                }
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColor.borderInputColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOption(String option) {
    return ListTile(
      title: Text(
        option,
        style: TextStyle(color: AppColor.mainText),
      ),
      leading: Radio<String>(
        value: option,
        groupValue: _selectedOption,
        activeColor: AppColor.mainText, // Màu khi được chọn
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColor.mainText; // Màu khi được chọn
          }
          return AppColor.mainText; // Màu viền khi chưa chọn
        }),
        onChanged: (String? value) {
          setState(() {
            _selectedOption = value;
          });
          Navigator.of(context).pop(); // Đóng hộp thoại sau khi chọn
          _showExportModeDialog(); // Mở lại hộp thoại để cập nhật trạng thái
        },
      ),
    );
  }

  // Future<void> _exportData() async {
  //   List<String> qrCodesToSend = [];
  //   List<String> qrCodesToKeep = [];  // Danh sách các mã QR sẽ giữ lại
  //   String maThung = widget.box?['MaThung'] ?? '';
  //
  //   // Lấy mã loại QRCode cho các mã QR đã quét
  //   for (int i = 0; i < scannedCodes.length; i++) {
  //     String qrCode = scannedCodes[i];
  //     String? qrData = await apiController.FetchThongTinQRCode(qrCode, {});
  //     if (qrData != null) {
  //       var qrInfo = jsonDecode(qrData)['data'][0];
  //       String fetchedMaThung = qrInfo['MaThung'] ?? '';
  //       if (fetchedMaThung == maThung) {
  //         loaiQRCode = qrInfo['LoaiMaQRCode'];
  //
  //         // Nếu loaiQRCode là LM00005 thì thiết lập startIndex và endIndex theo yêu cầu
  //         if (loaiQRCode == "LM00005") {
  //           if (SLX == 0) {
  //             // Lấy startIndex là ID của mã QR đầu tiên có loại LM00005
  //             startIndex = qrInfo['ID'];
  //           }
  //           // Luôn cập nhật endIndex là ID của mã QR cuối cùng có loại LM00005
  //           endIndex = qrInfo['ID'];
  //           SLX++; // Tăng số lượng mã QR loại LM00005
  //         }
  //         // Cập nhật LichSanXuatQRCode nếu có
  //         LichSanXuatQRCode = qrInfo['LichSanXuatQRCode'];
  //       }
  //     }
  //   }
  //
  //   // Lấy danh sách QR code thuộc cùng MaThung
  //   String? qrListData = await apiController.FetchThongTinQRCodeThuocThung(loaiQRCode, maThung, {});
  //   if (qrListData != null) {
  //     var qrList = jsonDecode(qrListData)['data'];
  //     List<String> allQRCode = qrList
  //         .whereType<Map<String, dynamic>>()
  //         .map<String>((item) => item['MaQRCode'] as String)
  //         .toList();
  //
  //     if (_selectedOption == "Xuất Giữ") {
  //       qrCodesToSend = allQRCode.where((qr) => !scannedCodes.contains(qr)).toList();
  //       qrCodesToKeep = scannedCodes;
  //     } else if (_selectedOption == "Xuất Xuất") {
  //       qrCodesToSend = List.from(scannedCodes);
  //       qrCodesToKeep = [];
  //     } else if (_selectedOption == "Xuất Đủ") {
  //       qrCodesToSend = List.from(allQRCode);
  //       qrCodesToKeep = [];
  //     }
  //
  //     // Sau khi xử lý xong, hiển thị hộp thoại xác nhận
  //     await _showExportConfirmationDialog(
  //       maThung: maThung,
  //       exportMode: _selectedOption,
  //       totalExport: qrCodesToSend.length,
  //       totalKeep: qrCodesToKeep.length,
  //       SLX: SLX, // Số lượng mã QR loại LM00005
  //       loaiQRCode: loaiQRCode, // Truyền loaiQRCode để hiển thị đơn vị phù hợp
  //     );
  //   }
  // }
  Future<void> _exportData() async {
    List<String> qrCodesToSend = [];
    List<String> qrCodesToKeep = []; // Danh sách các mã QR sẽ giữ lại
    String maThung = widget.box?['MaThung'] ?? '';

    // Lấy mã loại QRCode cho các mã QR đã quét
    for (int i = 0; i < scannedCodes.length; i++) {
      String qrCode = scannedCodes[i];
      String? qrData = await apiController.FetchThongTinQRCode(qrCode, {});
      if (qrData != null) {
        var qrInfo = jsonDecode(qrData)['data'][0];
        String fetchedMaThung = qrInfo['MaThung'] ?? '';
        if (fetchedMaThung == maThung) {
          loaiQRCode = qrInfo['LoaiMaQRCode'];

          // Nếu loaiQRCode là LM00005 thì thiết lập startIndex và endIndex theo yêu cầu
          if (loaiQRCode == "LM00005") {
            if (SLX == 0) {
              // Lấy startIndex là ID của mã QR đầu tiên có loại LM00005
              startIndex = qrInfo['ID'];
            }
            // Luôn cập nhật endIndex là ID của mã QR cuối cùng có loại LM00005
            endIndex = qrInfo['ID'];
            SLX++; // Tăng số lượng mã QR loại LM00005
          }
          // Cập nhật LichSanXuatQRCode nếu có
          LichSanXuatQRCode = qrInfo['LichSanXuatQRCode'];
        }
      }
    }

    // Lấy danh sách QR code thuộc cùng MaThung
    String? qrListData = await apiController.FetchThongTinQRCodeThuocThung(loaiQRCode, maThung, {});
    if (qrListData != null) {
      var qrList = jsonDecode(qrListData)['data'];
      List<String> allQRCode = qrList
          .whereType<Map<String, dynamic>>()
          .map<String>((item) => item['MaQRCode'] as String)
          .toList();

      if (_selectedOption == "Xuất Giữ") {
        // Danh sách QR để xuất là các mã QR trong thùng nhưng chưa quét
        qrCodesToSend = allQRCode.where((qr) => !scannedCodes.contains(qr)).toList();
        qrCodesToKeep = scannedCodes;

        // Tính startIndex và endIndex cho mã QR chưa quét
        if (qrCodesToSend.isNotEmpty) {
          qrCodesToSend.sort((a, b) => a.compareTo(b)); // Sắp xếp mã QR để lấy ID đầu và cuối
          startIndex = qrList.firstWhere((qr) => qr['MaQRCode'] == qrCodesToSend.first)['ID'];
          endIndex = qrList.firstWhere((qr) => qr['MaQRCode'] == qrCodesToSend.last)['ID'];
          SLX = qrCodesToSend.length;
        }
      } else if (_selectedOption == "Xuất Xuất") {
        qrCodesToSend = List.from(scannedCodes);
        qrCodesToKeep = [];
      } else if (_selectedOption == "Xuất Đủ") {
        qrCodesToSend = List.from(allQRCode);
        qrCodesToKeep = [];
      }

      // Sau khi xử lý xong, hiển thị hộp thoại xác nhận
      await _showExportConfirmationDialog(
        maThung: maThung,
        exportMode: _selectedOption,
        totalExport: qrCodesToSend.length,
        totalKeep: qrCodesToKeep.length,
        loaiQRCode: loaiQRCode, // Truyền loaiQRCode để hiển thị đơn vị phù hợp
      );
    }
  }

// Hàm điều phối để đồng bộ tất cả thông tin qua các API
  Future<void> dongBoTatCaThongTin() async {
    try {
      // Gọi API postThongTinPXK
      await postThongTinPXK();

      // Gọi API capNhatThongTinThung
      await capNhatThongTinThung();

      // Gọi API capNhatThongTinTang
      await capNhatThongTinTang();

      // Gọi API capNhatQrCodeThung
      await capNhatQrCodeThung();

      // Gọi API capNhatQrCodeSanPham
      await capNhatQrCodeSanPham();

      // Hiển thị thông báo thành công sau khi tất cả API gọi thành công
      _showCompletionSyncDialog("Thành công", "Đồng bộ hoàn tất thành công.");
    } catch (e) {
      // Xử lý lỗi nếu có bất kỳ API nào không thành công
      print("Đồng bộ thất bại: $e");
      _showCompletionSyncDialog("Thât bại", " Đồng bộ thất bại. Vui lòng thử lại");
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
              onPressed: () async{
                Navigator.of(context).pop(); // Đóng dialog trước
                final maPhieuXuatKho = widget.maPXK;
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
                          maPXK: maPhieuXuatKho,
                        ),
                      ),
                    );
                  }
                }
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

// Sửa hàm hiển thị hộp thoại xác nhận xuất kho
  Future<void> _showExportConfirmationDialog({
    required String maThung,
    required String? exportMode,
    required int totalExport,
    required int totalKeep,
    required String loaiQRCode,
  }) async {
    // Thiết lập đơn vị dựa trên loaiQRCode
    String donViXuat = loaiQRCode == "LM00004" ? "thùng" : "sản phẩm";

    // Thiết lập nội dung ghi chú dựa trên chế độ xuất kho
    String ghiChu;
    if (exportMode == "Xuất Giữ") {
      ghiChu = "QRCode đã quét sẽ được giữ lại";
    } else if (exportMode == "Xuất Xuất") {
      ghiChu = "QRCode đã quét sẽ được xuất";
    } else if (exportMode == "Xuất Đủ") {
      ghiChu = "Tất cả QRCode trong thùng sẽ được xuất";
    } else {
      ghiChu = "Chế độ xuất không xác định";
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Xác Nhận Chế Độ Xuất Kho",
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
                "Bạn có đồng ý chọn chế độ \"$exportMode\" không?",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Thùng: $maThung",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "Tổng sẽ xuất: $totalExport $donViXuat", // Sử dụng đơn vị phù hợp
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "Tổng giữ: $totalKeep $donViXuat", // Sử dụng đơn vị phù hợp
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              if (loaiQRCode == "LM00005") // Chỉ hiển thị số lượng mã LM00005 nếu đúng loại
                // Text(
                //   "Số lượng mã LM00005: $SLX",
                //   style: TextStyle(
                //     color: AppColor.mainText,
                //     fontSize: 16,
                //   ),
                // ),
              SizedBox(height: 10),
              Text(
                "Lưu ý: $ghiChu",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();  // Đóng hộp thoại khi hủy
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();  // Đóng hộp thoại
                    dongBoTatCaThongTin();  // Gọi hàm đồng bộ dữ liệu
                  },
                  child: Text(
                    "Bắt đầu đồng bộ",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

// Các hàm hiển thị thông báo thành công và lỗi
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Thành công"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Phương thức gửi qrCodesToServer lên server
  Future<void> syncQRCodeToServer(List<String> qrCodes) async {
    // In ra các mã QR sẽ gửi đi trước khi thực hiện API call
    print("Đang đồng bộ các mã QR lên server: $qrCodes");

    // Gọi API để gửi qrCodes lên backend (thêm logic gửi API của bạn ở đây)
    // Ví dụ:
    // final response = await http.post(
    //   Uri.parse('YOUR_API_URL'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: json.encode({'qrCodes': qrCodes}),
    // );
    // Nếu gọi thành công, xử lý tiếp hoặc thông báo cho người dùng.
  }

  Future<void> postThongTinPXK() async {
    // Lấy các giá trị cần thiết từ widget.box hoặc các nguồn khác
    String maThung = widget.box?['MaThung'] ?? ""; // Lấy Mã thùng
    String maLenhXuathang = widget.productData?['MaLenhXuatHang'] ?? '';
    String maCTLXH = widget.productData?['MaChiTietLenhXuatHang'] ?? '';
    String maTang = widget.location['Tang']['MaTang'] ?? '';
    String maPXK = widget.maPXK;


    Map<String, dynamic> requestBody = {
      "32MT": '$maThung', // Mã thùng
      "3MLXK": "$maLenhXuathang", // Mã Lệnh xuất hàng
      "15MPXK": "$maPXK", // Mã Phiếu xuất kho
      "33MT": "$maTang", // Mã tầng
      "2SLX": SLX, // Số lượng xuất
      "48GC": "", // Ghi chú
      "8TKTB": "$maTK", // Tài khoản thiết bị
      "1MCTLXH": "$maCTLXH", // Mã chi tiết lịch xuất hàng
    };

    print('postThongTinPXK: $requestBody');

    // Gọi API để gửi thông tin
    String? response = await apiController.postThongTinPXK(requestBody);

    if (response != null) {
      // Xử lý khi API trả về dữ liệu thành công
      print("API postThongTinPXK Response: $response");
      // Thực hiện các hành động tiếp theo (ví dụ: thông báo thành công)
    } else {
      // Xử lý lỗi (ví dụ: thông báo lỗi)
      print("Không thể gửi dữ liệu, vui lòng thử lại.");
    }
  }

  Future<void> capNhatThongTinThung() async {
    String maThung = widget.box?['MaThung'] ?? ""; // Lấy Mã thùng

    Map<String, dynamic> requestBody = {
      "3SLĐN": 0,
      "11NN": "",
      "3SLĐX": SLX,
      "29MT": "",
      "5KC": 0,
      "1MCTLNK": "",
      "5MPNK": ""
    };
    print('capNhatThongTinThung: $requestBody');

    // Gọi API để gửi thông tin
    String? response = await apiController.updateThongTinThung(maThung,requestBody);

    if (response != null) {
      // Xử lý khi API trả về dữ liệu thành công
      print("API capNhatThongTinThung Response: $response");
      // Thực hiện các hành động tiếp theo (ví dụ: thông báo thành công)
    } else {
      // Xử lý lỗi (ví dụ: thông báo lỗi)
      print("Không thể gửi dữ liệu, vui lòng thử lại.");
    }
  }

  Future<void> capNhatThongTinTang() async {
    // Lấy các giá trị cần thiết từ widget.box hoặc các nguồn khác
    String maThung = widget.box?['MaThung'] ?? ""; // Lấy Mã thùng
    int soLuongDaNhap = widget.box?['3SLĐN'] ?? 0;
    String maTang = widget.location['Tang']['MaTang'] ?? '';
    num trongLuong = widget.productData?['TrongLuong'] ?? 0;
    num? khoiLuongDaXuat = SLX * trongLuong;
    Map<String, dynamic> requestBody = {
      "23MT": "$maTang",
      "4SLĐN": 0,
      "2SLĐX": SLX,
      "1KLĐN": 0,
      "1KLĐX": khoiLuongDaXuat
    };
    print('capNhatThongTinTang: $requestBody');


    // Gọi API để gửi thông tin
    String? response = await apiController.updateThongTinTang(maTang,requestBody);

    if (response != null) {
      // Xử lý khi API trả về dữ liệu thành công
      print("API capNhatThongTinTang Response: $response");
      // Thực hiện các hành động tiếp theo (ví dụ: thông báo thành công)
    } else {
      // Xử lý lỗi (ví dụ: thông báo lỗi)
      print("Không thể gửi dữ liệu, vui lòng thử lại.");
    }
  }

  Future<void> capNhatQrCodeThung() async {
    // Lấy các giá trị cần thiết từ widget.box hoặc các nguồn khác
    String maQRThung = widget.box?['7MQ'] ?? ""; // Lấy Mã thùng
    String maLenhXuathang = widget.productData?['MaLenhXuatHang'] ?? '';
    String maPXK = widget.maPXK;
    String maCTLXH = widget.productData?['MaChiTietLenhXuatHang'] ?? '';
    String maTang = widget.location['Tang']['TenTang'] ?? '';
    int? SLX = widget.productData?['SoLuongXuat'];

    Map<String, dynamic> requestBody = {
      "1LMQ": "",
      "2MPNK": "",
      "13MPXK": "$maPXK",
      "1MLXK": "$maLenhXuathang",
      "2MD": "",
      "28MK": "",
      "27MT": "",
      "28MT": "",
      "41MSP": "",
      "1MTSP": "",
      "33TT": "TT009",
      "8MLNK": ""
    };
    print('capNhatQrCodeThung: $requestBody');

    // Gọi API để gửi thông tin
    String? response = await apiController.updateThongTinQrCodeThung(maQRThung,requestBody);

    if (response != null) {
      // Xử lý khi API trả về dữ liệu thành công
      print("API capNhatQrCodeThung Response: $response");
      // Thực hiện các hành động tiếp theo (ví dụ: thông báo thành công)
    } else {
      // Xử lý lỗi (ví dụ: thông báo lỗi)
      print("Không thể gửi dữ liệu, vui lòng thử lại.");
    }
  }

  Future<void> capNhatQrCodeSanPham() async {

    String maLenhXuathang = widget.productData?['MaLenhXuatHang'] ?? '';
    String maPXK = widget.maPXK;
    String maCTLXH = widget.productData?['MaChiTietLenhXuatHang'] ?? '';
    String maTang = widget.location['Tang']['TenTang'] ?? '';
    int? SLX = widget.productData?['SoLuongXuat'];

    Map<String, dynamic> requestBody = {
      "1LMQ": "",
      "2MPNK": "",
      "13MPXK": "$maPXK",
      "1MLXK": "$maLenhXuathang",
      "2MD": "",
      "28MK": "",
      "27MT": "",
      "28MT": "",
      "41MSP": "",
      "1MTSP": "",
      "33TT": "TT009",
      "8MLNK": "",
      "indexDau": startIndex,
      "indexCuoi": endIndex
    };
    print('capNhatQrCodeSanPham: $requestBody');

    // Gọi API để gửi thông tin
    String? response = await apiController.updateQRCodeManagementTableAccordingToIndex("QR2024103100005",requestBody);

    if (response != null) {
      // Xử lý khi API trả về dữ liệu thành công
      print("API capNhatQrCodeThung Response: $response");
      // Thực hiện các hành động tiếp theo (ví dụ: thông báo thành công)
    } else {
      // Xử lý lỗi (ví dụ: thông báo lỗi)
      print("Không thể gửi dữ liệu, vui lòng thử lại.");
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return
      WillPopScope(
      onWillPop: () async {
      final maPhieuXuatKho = widget.maPXK;
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
                maPXK: widget.maPXK,
              ),
            ),
          );
          return false; // Ngăn không cho pop màn hình hiện tại
        }
      }
      return true; // Cho phép pop màn hình nếu điều kiện trên không thỏa mãn
    },
    child: Scaffold(
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
          title: Text(
            'Chi tiết Phiếu Xuất kho',
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.bold,
              color: AppColor.mainText,
            ),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thùng: ${widget.box?['MaThung'] ?? ''}",
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tên sản phẩm: ${widget.box?['16TSP'] ?? ''}",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: AppColor.mainText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Danh Sách QRCode đã quét",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: scannedCodes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      scannedCodes[index],
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: AppColor.mainText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child:  TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColor.borderInputColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
            onPressed: () {
              _showExportModeDialog();
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
      ),
    );
  }
}
