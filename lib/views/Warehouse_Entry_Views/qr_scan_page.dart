import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import '../../controllers/barcode_scanner_in_phone_controller.dart';
import '../../widgets/qrcode_confirmation_dialog.dart';
import '../../utils/appcolors.dart';

class QrScanPage extends StatefulWidget {
  final String title;

  const QrScanPage({required this.title, Key? key}) : super(key: key);

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  BarcodeScannerInPhoneController _barcodeScannerInPhoneController = BarcodeScannerInPhoneController();
  var getResult = '';
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

  }

  Future<void> _playScanSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/Bip.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("$e");
    }
  }

  void scanQRCode() async {
    // Gọi phương thức quét mã QR từ BarcodeScannerInPhoneController
    String? code = await _barcodeScannerInPhoneController.scanQRCode();
    if (code != null) {
      print("Mã QR code quét được: $code");
      // Kiểm tra xem có phải URL chứa "check/"
      if (code.startsWith('http://') || code.startsWith('https://')) {
        // Trích xuất mã từ URL
        String? extractedCode = _barcodeScannerInPhoneController.extractCodeFromUrl(code);
        if (extractedCode != null) {
          print("Mã sản phẩm trích xuất từ URL: $extractedCode");
          _updateUIWithQRCode(extractedCode);
        } else {
          print("Không thể trích xuất mã từ URL");
        }
      } else {
        // Cập nhật giao diện với mã QR nếu không phải URL
        _updateUIWithQRCode(code);
      }
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

    if (getResult != null) {
      _playScanSound();
      bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context){
            return QRCodeConfirmationDialog(qrCode: getResult);
          });

      if (confirmed) {
        Navigator.pop(context, getResult); // Trả về mã QR đã quét
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
                'Kích hoạt sản phẩm',
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
          getResult != null
              ? "Mã đã quét: $getResult"
              : "Vui lòng quét QR code",
          style: TextStyle(fontSize: 22, color: Colors.grey),
        ),
      ),
    );
  }
}
