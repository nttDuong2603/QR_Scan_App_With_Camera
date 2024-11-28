import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../controllers/barcode_scan_controller.dart';
import '../../utils/appcolors.dart';
import '../../utils/key_event_channel.dart';

class PackageSlipScan extends StatefulWidget {
  const PackageSlipScan({super.key});

  @override
  State<PackageSlipScan> createState() => _PackageSlipScanState();
}

class _PackageSlipScanState extends State<PackageSlipScan> {
  // final ScanBarcodeController _barcodeController = ScanBarcodeController();
  List<String> scannedCodes = []; // Danh sách mã QR đã quét
  // final ScanBarcodeController _controller = ScanBarcodeController();
  late KeyEventChannel _keyEventChannel;
  late AudioPlayer _audioPlayer;
  bool _isScan = false;

  @override
  void initState() {
    super.initState();

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

  Future<void> _handleScannedTags(dynamic result) async {
    if (_isScan) {
      return;
    }
    // final code = await _barcodeController.updateTags(result);
    final code = 'SP000002';
    if(code != null){
      _playScanSound();
      bool confirm = await _showQRCodeConfirmationDialog(code);
      if(confirm){
        scannedCodes.add(code);
      }
    }
  }

  Future<void> _playScanSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/Bip.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("$e");
    }
  }

  Future<bool> _showQRCodeConfirmationDialog(String qrCode) async {
    _isScan= true;
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

  Future<bool> _showConfirmSyncDialog() async {
    _isScan= true;
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận lấy hàng",
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
                      text: ("Xác nhận lấy\n"),
                      style: TextStyle(
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
                  TextSpan(
                      text: ("sản phẩm SP000001, SP000001\n"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
                  TextSpan(
                      text: ("khỏi vị trí\n"),
                      style: TextStyle(
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
                  TextSpan(
                      text: ("Dãy 1 Tầng 1 Ô 1\n"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
                  TextSpan(
                      text: ("Lưu ý, sản phẩm vừa quét sẽ được lấy ra khỏi vị trí"),
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
                    _showCompletSyncPackageSlipDialog();
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

  Future<bool> _showCompletSyncPackageSlipDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Đồng bộ thành công",
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
                      text: ("Soạn hàng thành công"),
                      style: TextStyle(
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
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
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                ),
              ),
              title: Text(
                'Chi tiết Phiếu Soạn hàng',
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainText,
                ),
              ),
              actions: [
                IconButton(
                  // onPressed: () => _controller.toggleBarcodeScanning(() => setState(() {})),
                  onPressed: (){},
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
                  "Phiếu Xuất kho: PXKTS001",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColor.mainText,
                  ),
                ),
                // SizedBox(height: 8),
                // Text(
                //   "Mã Phiếu Xuất khi: ",
                //   style: TextStyle(
                //     fontSize: screenWidth * 0.05,
                //     color: AppColor.mainText,
                //   ),
                // ),
                // SizedBox(height: 8),
                Text(
                  "TO: THUNG162237",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: AppColor.mainText,
                  ),
                ),
                // SizedBox(height: 8),
                Text(
                  "Tên sản phẩm: Aquafina",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: AppColor.mainText,
                  ),
                ),
                Text(
                  "SKU: 10141864",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: AppColor.mainText,
                  ),
                ),
                // SizedBox(height: 8),
                Text(
                  "Số lượng cần xuất: 22 chai",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: AppColor.mainText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Gợi ý hình thức quét: Quét QR 2 sản phẩm cần giữ",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: AppColor.mainText,
                    fontWeight: FontWeight.bold
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
                _showConfirmSyncDialog();
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
}
