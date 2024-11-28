// import 'package:flutter/material.dart';
// import 'package:rfid_c72_plugin_example/controllers/barcode_scan_controller.dart';
// import 'package:rfid_c72_plugin_example/utils/appcolors.dart';
// import 'package:rfid_c72_plugin_example/utils/key_event_channel.dart';
//
// class SugguestQRScan extends StatefulWidget {
//   final String title;
//
//   const SugguestQRScan({required this.title, Key? key}) : super(key: key);
//
//   @override
//   State<SugguestQRScan> createState() => _SugguestQRScanState();
// }
//
// class _SugguestQRScanState extends State<SugguestQRScan> {
//   final ScanBarcodeController _barcodeController = ScanBarcodeController();
//   String? scannedCode;
//   final ScanBarcodeController _controller = ScanBarcodeController();
//   late KeyEventChannel _keyEventChannel;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _controller.initPlatformState(_updateConnectionStatus, _handleScannedTags);
//     _keyEventChannel = KeyEventChannel(
//       onKeyReceived: () => _controller.toggleBarcodeScanning(() => setState(() {})),
//     );
//     _keyEventChannel.initialize();
//   }
//
//   Future<void> _initializeScanner() async {
//     await _barcodeController.initPlatformState(
//       _updateConnectionStatus,
//       _handleScannedTags,
//     );
//     _barcodeController.toggleBarcodeScanning(() => setState(() {}));
//   }
//
//   void _updateConnectionStatus(dynamic isConnected) {
//     setState(() {
//       _barcodeController.updateConnectionStatus(isConnected);
//     });
//   }
//
//   // Future<void> _handleScannedTags(dynamic result) async {
//   //   final code = await _barcodeController.updateTags(result);
//   //   if (code != null) {
//   //     setState(() {
//   //       scannedCode = code;
//   //     });
//   //     bool confirmed = await _showQRCodeConfirmationDialog(code);
//   //     if (confirmed) {
//   //       Navigator.pop(context, code); // Trả về mã QR đã quét
//   //     }
//   //   }
//   // }
//   Future<void> _handleScannedTags(dynamic result) async {
//     final code = await _barcodeController.updateTags(result);
//     if (code != null) {
//       setState(() {
//         scannedCode = code;
//       });
//       bool confirmed = await _showQRCodeConfirmationDialog(code);
//       if (confirmed) {
//         Navigator.pop(context, code); // Trả về mã QR đã quét để so sánh
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _barcodeController.barcodeSubscription?.cancel();
//     super.dispose();
//   }
//
//
//   // Hiển thị hộp thoại xác nhận mã QR
//   Future<bool> _showQRCodeConfirmationDialog(String qrCode) async {
//     return await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Xác nhận mã QR",
//             style: TextStyle(
//               color: AppColor.mainText,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: RichText(
//             text: TextSpan(
//                 children: [
//                   TextSpan(
//                       text: ("Bạn có muốn sử dụng mã QR này: \n"),
//                       style: TextStyle(
//                         color: AppColor.mainText,
//                         fontSize: 18,
//                       )
//                   ),
//                   TextSpan(
//                       text: ("$qrCode?"),
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.mainText,
//                         fontSize: 18,
//                       )
//                   )
//                 ]
//             ),
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   style: TextButton.styleFrom(
//                       backgroundColor: AppColor.borderInputColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       )
//                   ),
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: Text("Hủy",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 30),
//                 TextButton(
//                   style: TextButton.styleFrom(
//                       backgroundColor: AppColor.borderInputColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       )
//                   ),
//                   onPressed: () => Navigator.of(context).pop(true),
//                   child: Text("OK",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         );
//       },
//     ) ?? false;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: AppColor.backgroundAppColor,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(60.0),
//         child: AppBar(
//           backgroundColor: AppColor.backgroundAppColor,
//           leading: InkWell(
//             onTap: () {},
//             child: Image.asset(
//               'assets/images/logo.png',
//               width: screenWidth * 0.2,
//               height: screenWidth * 0.2,
//             ),
//           ),
//           title: Row(
//             children: [
//               Text(
//                 'Quét vị trí nhập kho',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.065,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.mainText,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               onPressed: () => _controller.toggleBarcodeScanning(() => setState(() {})),
//               icon: Icon(
//                 Icons.qr_code_scanner_outlined,
//                 color: AppColor.mainText,
//                 size: screenWidth * 0.12,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Text(
//           scannedCode != null
//               ? "Mã đã quét: $scannedCode"
//               : "Vui lòng quét QR code",
//           style: TextStyle(fontSize: 22, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }
