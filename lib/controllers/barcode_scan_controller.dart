// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
// import 'package:just_audio/just_audio.dart';
// import '../models/tag_epc.dart';
//
// class ScanBarcodeController {
//   StreamSubscription? barcodeSubscription;
//   String platformVersion = 'Unknown';
//   bool is2dscanCall = false;
//   bool isConnected = false;
//   bool isLoading = true;
//   bool isScanning = false;
//   List<TagEpc> data = [];
//
//
//   Future<void> initPlatformState(Function(dynamic) updateConnection, Function(dynamic) updateTags) async {
//     try {
//       platformVersion = (await RfidC72Plugin.platformVersion)!;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//
//     RfidC72Plugin.connectedStatusStream.receiveBroadcastStream().listen(updateConnection);
//     await RfidC72Plugin.connectBarcode;
//     RfidC72Plugin.barcodeStatusStream.receiveBroadcastStream().listen(updateTags);
//   }
//
//   void updateConnectionStatus(dynamic connectionStatus) {
//     isConnected = connectionStatus;
//   }
//
//   Future<String?> updateTags(dynamic result) async {
//     String resultString = result.toString();
//
//     String? code;
//     // Kiểm tra nếu kết quả là một URL bắt đầu với http hoặc https và chứa "check/"
//     if ((resultString.startsWith('http://') || resultString.startsWith('https://')) && resultString.contains("check/")) {
//       code = extractCodeFromUrl(resultString);
//       print("Mã QR code được quét từ URL: $code");
//     } else {
//       // Nếu không phải URL, lấy nguyên chuỗi mã
//       code = resultString;
//       print("Mã QR code được quét: $code");
//     }
//
//     // Thêm mã vào danh sách dữ liệu nếu không null
//     if (code != null) {
//       data.add(TagEpc(epc: code));
//     }
//
//     // Dừng quét và trả về mã đã xử lý
//     isScanning = false;
//     await RfidC72Plugin.stop;
//     return code;
//   }
//
//   String? extractCodeFromUrl(String url) {
//     try {
//       // Kiểm tra xem URL có chứa "check/" không
//       if (url.contains("check/")) {
//         // Tìm vị trí của "check/" trong URL
//         int startIndex = url.indexOf("check/") + "check/".length;
//         // Tìm vị trí của "?" để lấy phần mã từ sau "check/" cho đến trước "?" (nếu có)
//         int endIndex = url.contains("?") ? url.indexOf("?") : url.length;
//         // Trích xuất mã
//         return url.substring(startIndex, endIndex);
//       }
//     } catch (e) {
//       print("Lỗi khi phân tích URL: $e");
//     }
//     return null;
//   }
//
//
//
//   // Future<String?> updateTags(dynamic result) async {
//   //   if (result.toString().startsWith('http') || result.toString().contains('://')) {
//   //     String? code = extractCodeFromUrl(result);
//   //     print("Mã QRR code được quét: $code");
//   //     if (code != null) {
//   //       data.add(TagEpc(epc: code));
//   //       isScanning = false;
//   //       await RfidC72Plugin.stop;
//   //       return code;
//   //     }
//   //   }
//   //   return null;
//   // }
//   // String? extractCodeFromUrl(String url) {
//   //   try {
//   //     // Kiểm tra xem URL có chứa "check/" không
//   //     if (url.contains("check/")) {
//   //       // Tìm vị trí của "check/" trong URL
//   //       int startIndex = url.indexOf("check/") + "check/".length;
//   //       // Tìm vị trí của "?" để lấy phần mã từ sau "check/" cho đến trước "?"
//   //       int endIndex = url.contains("?") ? url.indexOf("?") : url.length;
//   //       // Trích xuất mã
//   //       return url.substring(startIndex, endIndex);
//   //     }
//   //   } catch (e) {
//   //     print("Error parsing URL: $e");
//   //   }
//   //   return null;
//   // }
//
//
//   // String? extractCodeFromUrl(String url) {
//   //   try {
//   //     Uri uri = Uri.parse(url);
//   //     return uri.queryParameters['id'];
//   //   } catch (e) {
//   //     print("Error parsing URL: $e");
//   //     return null;
//   //   }
//   // }
//
//   Future<void> toggleBarcodeScanning(Function setStateCallback) async {
//     setStateCallback();  // Không truyền bất kỳ đối số nào
//
//     is2dscanCall = !is2dscanCall;
//
//     if (is2dscanCall) {
//       await RfidC72Plugin.connectBarcode; // Kết nối Barcode scanner
//       await RfidC72Plugin.scanBarcode;    // Bắt đầu quét mã QR
//
//       if (data.isNotEmpty) {
//         await RfidC72Plugin.stopScan;
//         await RfidC72Plugin.closeScan;
//         barcodeSubscription?.cancel();
//       }
//     } else {
//       await RfidC72Plugin.stopScan;
//       barcodeSubscription?.cancel();
//     }
//   }
//
// }
//
//
//
//
