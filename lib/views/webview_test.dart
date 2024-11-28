// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:rfid_c72_plugin/rfid_c72_plugin.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'dart:io';
// // import 'tag_epc.dart';
// // import 'model.dart';
//
// class GoodsDetail extends StatefulWidget {
//   @override
//   _GoodsDetailState createState() => new _GoodsDetailState();
// }
//
// class _GoodsDetailState extends State<GoodsDetail> {
//   String _platformVersion = 'Unknown';
//   final bool _isHaveSavedData = false;
//   final bool _isStarted = false;
//   final bool _isEmptyTags = false;
//   bool _isConnected = false;
//   bool _isLoading = true;
//   int _totalEPC = 0, _invalidEPC = 0, _scannedEPC = 0;
//   final GlobalKey webViewKey = GlobalKey();
//   bool isLoadingAboutBlank = false;
//
//
//   InAppWebViewController? webViewController;
//   InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
//     crossPlatform: InAppWebViewOptions(
//       useShouldOverrideUrlLoading: true,
//       mediaPlaybackRequiresUserGesture: false,
//       javaScriptEnabled: true,
//       supportZoom: true,
//     ),
//     android: AndroidInAppWebViewOptions(
//       useHybridComposition: true,
//       domStorageEnabled: true,
//     ),
//     ios: IOSInAppWebViewOptions(
//       allowsInlineMediaPlayback: true,
//       sharedCookiesEnabled: true,
//     ),
//   );
//
//   late PullToRefreshController pullToRefreshController;
//   String url = "";
//   double progress = 0;
//   final urlController = TextEditingController();
//   String defaultUrl = "about:blank";
//   String? _lastScannedCode;
//
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     pullToRefreshController = PullToRefreshController(
//       options: PullToRefreshOptions(
//         color: Colors.blue,
//       ),
//       onRefresh: () async {
//         if (Platform.isAndroid) {
//           webViewController?.reload();
//         } else if (Platform.isIOS) {
//           webViewController?.loadUrl(
//               urlRequest: URLRequest(url: await webViewController?.getUrl()));
//         }
//       },
//     );
//     KeyEventChannel(
//       onKeyReceived: scanSingleTagAndUpdateWebView,
//     ).initialize();
//   }
//
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     print('StrDebug: initPlatformState');
//     try {
//       platformVersion = (await RfidC72Plugin.platformVersion)!;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//     RfidC72Plugin.connectedStatusStream
//         .receiveBroadcastStream()
//         .listen(updateIsConnected);
//     RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(updateTags);
//     await RfidC72Plugin.connect;
//     if (!mounted) return;
//     setState(() {
//       _platformVersion = platformVersion;
//       print('Connection successful');
//       _isLoading = false;
//     });
//   }
//
//   void updateIsConnected(dynamic isConnected) {
//     _isConnected = isConnected;
//   }
//
//   List<TagEpc> _data = [];
//   final List<String> _EPC = [];
//   bool _is2dscanCall = false;
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   String hexToString(String hex) {
//     String result = '';
//     for (int i = 0; i < hex.length; i += 2) {
//       String part = hex.substring(i, i + 2);
//       int charCode = int.parse(part, radix: 16);
//       result += String.fromCharCode(charCode);
//     }
//     return result;
//   }
//
//
//
//   void updateTags(dynamic result) {
//     setState(() {
//       _data = TagEpc.parseTags(result);
//       _totalEPC = _data.toSet().toList().length;
//       if (_data.isNotEmpty) {
//
//       }
//     });
//   }
//
//   // void scanSingleTagAndUpdateWebView() async {
//   //   try {
//   //     await RfidC72Plugin.startSingle; // Bắt đầu quét thẻ RFID
//   //
//   //     // Đảm bảo rằng có dữ liệu từ các thẻ RFID
//   //     if (_data.isNotEmpty) {
//   //       for (var tag in _data) {
//   //         String scannedCode = hexToString(tag.epc);
//   //         String urlToLoad = "https://jvf.rynansaas.com/check/$scannedCode";  // Gắn kết quả quét vào URL
//   //         print('URL to load: $urlToLoad');
//   //         // Tải URL cho mỗi thẻ RFID vào WebView
//   //         // Lưu ý: Hành động này có thể không mong muốn nếu bạn không muốn ghi đè các tải trước đó
//   //         if (webViewController != null) {
//   //           print('Loading URL in WebView');
//   //           await webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(urlToLoad)));
//   //         }
//   //       }
//   //     } else {
//   //       print("No RFID tag data available to load in WebView.");
//   //     }
//   //
//   //   } catch (e) {
//   //     print("Error when scanning RFID: $e");
//   //   }
//   // }
//   void scanSingleTagAndUpdateWebView() async {
//     StreamSubscription<dynamic>? subscription;
//     try {
//       // Tạo một biến để lắng nghe kết quả quét
//       StreamSubscription<dynamic>? subscription = RfidC72Plugin.tagsStatusStream.receiveBroadcastStream().listen(null);
//
//       // Đăng ký nghe kết quả từ luồng
//       subscription.onData((result) async {
//         if (result.isNotEmpty) {
//           // Lấy dữ liệu từ thẻ đầu tiên được quét
//           String rawScannedCode = TagEpc.parseTags(result).first.epc;
//           String scannedCode = hexToString(rawScannedCode);
//           // String urlToLoad = "https://jvf.rynansaas.com/check/$scannedCode"; // Sử dụng mã quét để tạo URL
//           String urlToLoad = "https://jvf.rynansaas.com/check/RJVD2400005GNCML"; // Sử dụng mã quét để tạo URL
//           // print('URL to load: $urlToLoad');
//
//           if (webViewController != null) {
//             // print('Loading URL in WebView');
//             await webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(urlToLoad)));
//           }
//
//           // Hủy đăng ký sau khi xử lý kết quả đầu tiên
//           subscription.cancel();
//         }
//       });
//
//       // Bắt đầu quét một thẻ RFID
//       await RfidC72Plugin.startSingle;
//
//     } catch (e) {
//       print("Error when scanning RFID: $e");
//       subscription?.cancel(); // Đảm bảo hủy đăng ký nếu có lỗi
//     }
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return
//       Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "Thông tin sản phẩm",
//             style: TextStyle(
//               color: Color(0xFF097746), // Đặt màu văn bản là màu xanh lá cây
//               fontWeight: FontWeight.bold, // Có thể đặt các thuộc tính văn bản khác tại đây
//               fontSize: screenWidth * 0.07, // Cỡ chữ 20
//             ),
//           ),
//
//           actions: [
//             // IconButton(
//             //   icon: Image.asset('assets/image/scan_noBG.png'), // Sử dụng hình ảnh từ assets
//             //   onPressed: scanSingleTagAndUpdateWebView, // Gọi hàm quét mã vạch
//             // ),
//             IconButton(
//               icon: Image.asset('assets/image/scan_noBG.png'),
//               onPressed: () {
//                 // Hiển thị chỉ báo tải hoặc thay đổi trạng thái
//                 setState(() {
//                   _isLoading = true; // Giả sử bạn có một cờ trạng thái isLoading
//                 });
//                 scanSingleTagAndUpdateWebView();
//                 // Đặt thời gian chờ hoặc cơ chế khác để ẩn chỉ báo tải
//                 Future.delayed(Duration(seconds: 1), () {
//                   setState(() {
//                     _isLoading = false;
//                   });
//                 });
//               },
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: Column(
//             children: <Widget>[
//
//               Expanded(
//                 child: Stack(
//                   children: [
//                     InAppWebView(
//                       key: webViewKey,
//                       // initialUrlRequest: URLRequest(url: Uri.parse(defaultUrl)),
//                       initialOptions: options,
//                       pullToRefreshController: pullToRefreshController,
//                       onWebViewCreated: (controller) {
//                         webViewController = controller;
//                       },
//                       // Bỏ qua xác minh ssl ở đây
//                       onReceivedServerTrustAuthRequest: (controller, challenge) async {
//                         return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
//                       },
//                       onLoadStart: (controller, url) {
//                         setState(() {
//                           this.url = url.toString();
//                           urlController.text = this.url;
//                         });
//                       // },
//                       androidOnPermissionRequest: (controller, origin, resources) async {
//                         return PermissionRequestResponse(
//                           resources: resources,
//                           action: PermissionRequestResponseAction.GRANT,
//                         );
//                       },
//                       shouldOverrideUrlLoading: (controller, navigationAction) async {
//                         var uri = navigationAction.request.url!;
//                         if (![ "http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
//                           if (await canLaunch(uri.toString())) {
//                             await launch(uri.toString());
//                             return NavigationActionPolicy.CANCEL;
//                           }
//                         }
//                         return NavigationActionPolicy.ALLOW;
//                       },
//                       onLoadStop: (controller, url) async {
//                         pullToRefreshController.endRefreshing();
//                         setState(() {
//                           this.url = url.toString();
//                           urlController.text = this.url;
//                         });
//                       },
//                       onLoadError: (controller, url, code, message) {
//                         pullToRefreshController.endRefreshing();
//                       },
//                       onProgressChanged: (controller, progress) {
//                         if (progress == 100) {
//                           pullToRefreshController.endRefreshing();
//                         }
//                         setState(() {
//                           this.progress = progress / 100;
//                           urlController.text = this.url;
//                         });
//                       },
//                       onUpdateVisitedHistory: (controller, url, androidIsReload) {
//                         setState(() {
//                           this.url = url.toString();
//                           urlController.text = this.url;
//                         });
//                       },
//                       // onConsoleMessage: (controller, consoleMessage) {
//                       //   print(consoleMessage);
//                       // },
//                       onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
//                         print("Console message: ${consoleMessage.message}");
//                       },
//                     ),
//                     if( progress < 1.0)
//                       LinearProgressIndicator(
//                         value: progress,
//                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF097746)), // Thiết lập màu cho LinearProgressIndicator
//                         backgroundColor: Colors.grey[200], // Màu nền của thanh tiến trình, nếu bạn muốn thiết lập
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // )
//         // )
//       );
//   }
// }
//
