import 'package:flutter/material.dart';
import '../../utils/appcolors.dart';
import '../../utils/key_event_channel.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

class WarehouseEntryQRScan extends StatefulWidget {
  final String title;

  const WarehouseEntryQRScan({required this.title, Key? key}) : super(key: key);

  @override
  State<WarehouseEntryQRScan> createState() => _WarehouseEntryQRScanState();
}

class _WarehouseEntryQRScanState extends State<WarehouseEntryQRScan> {
  // final ScanBarcodeController _barcodeController = ScanBarcodeController();
  String? scannedCode;
  // final ScanBarcodeController _controller = ScanBarcodeController();
  // late KeyEventChannel _keyEventChannel;
  bool _isscan = false;
  late AudioPlayer _audioPlayer;
  var getResult = '';

  @override
  void initState() {
    super.initState();
    // _controller.initPlatformState(_updateConnectionStatus, _handleScannedTags);
    // _keyEventChannel = KeyEventChannel(
    //   onKeyReceived: () => _controller.toggleBarcodeScanning(() => setState(() {})),
    // );
    // _keyEventChannel.initialize();
    _audioPlayer = AudioPlayer();

  }

  // Future<void> _initializeScanner() async {
  //   await _barcodeController.initPlatformState(
  //     _updateConnectionStatus,
  //     _handleScannedTags,
  //   );
  //   _barcodeController.toggleBarcodeScanning(() => setState(() {}));
  // }
  //
  // void _updateConnectionStatus(dynamic isConnected) {
  //   setState(() {
  //     _barcodeController.updateConnectionStatus(isConnected);
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
      bool confirmed = await _showQRCodeConfirmationDialog(getResult);
      if (confirmed) {
        Navigator.pop(context, getResult); // Trả về mã QR đã quét
      }
    }
  }

  // Future<void> _handleScannedTags(dynamic result) async {
  //   if(_isscan){
  //     return;
  //   }else{
  //     final code = await _barcodeController.updateTags(result);
  //     if (code != null) {
  //       _playScanSound();
  //       setState(() {
  //         scannedCode = code;
  //       });
  //       bool confirmed = await _showQRCodeConfirmationDialog(code);
  //       if (confirmed) {
  //         Navigator.pop(context, code); // Trả về mã QR đã quét
  //       }
  //     }
  //   }
  // }

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

  // @override
  // void dispose() {
  //   _barcodeController.barcodeSubscription?.cancel();
  //   super.dispose();
  // }

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
                'Tạo Lịch Nhập kho',
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
      body: Center(
        child: Text(
          scannedCode != null
              ? "Mã đã quét: $scannedCode"
              : "Vui lòng quét QR code",
          style: TextStyle(fontSize: 22, color: Colors.grey),
        ),
      ),
    );
  }
}
