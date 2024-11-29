import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'package:sasco_demo_app/widgets/qrcode_confirmation_dialog.dart';
import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/barcode_scanner_in_phone_controller.dart';
import '../../utils/appcolors.dart';
import '../../utils/app_config.dart';



class ProductInformation extends StatefulWidget {
  const ProductInformation({Key? key}) : super(key: key);

  @override
  _ProductInformationState createState() => _ProductInformationState();
}

class _ProductInformationState extends State<ProductInformation> {
  final GlobalKey webViewKey = GlobalKey();
  BarcodeScannerInPhoneController _barcodeScannerInPhoneController = BarcodeScannerInPhoneController();
  bool isLoadingAboutBlank = false;
  var getResult = '';


  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      javaScriptEnabled: true,
      supportZoom: true,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      domStorageEnabled: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
      sharedCookiesEnabled: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  String defaultUrl = "about:blank";
  String? scannedCodeCheck;
  // String IP ='https://demo-saas.mylanhosting.com';
  // String IP ='http://192.168.19.180:2002';


  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
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
    // Kiểm tra xem widget có còn tồn tại trong tree không
    if (!mounted) return;
    setState(() {
      getResult = code; // Cập nhật mã QR đã quét
    });
    print("QrCode result: -- $code");
    // Hiển thị hộp thoại xác nhận mã QR
    // bool confirmed = await _showQRCodeConfirmationDialog(code);
    bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext context){
          return QRCodeConfirmationDialog(qrCode: getResult);
    });
    if (confirmed) {
      // Tạo URL mới từ mã sản phẩm và cập nhật WebView
      final qrUrl = "${AppConfig.IP}/check/$code";
      setState(() {
        defaultUrl = qrUrl; // Cập nhật URL với mã QR đã quét
      });
      if (webViewController != null) {
        // Load URL vào WebView
        await webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(qrUrl)));
    }
    }
  }

  // Future<bool> _showQRCodeConfirmationDialog(String qrCode) async {
  //   return await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Xác nhận mã QR",
  //           style: TextStyle(
  //             color: AppColor.mainText,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: RichText(
  //           text: TextSpan(
  //               children: [
  //                 TextSpan(
  //                     text: ("Bạn có muốn sử dụng mã QR này: \n"),
  //                     style: TextStyle(
  //                       color: AppColor.mainText,
  //                       fontSize: 18,
  //                     )
  //                 ),
  //                 TextSpan(
  //                     text: ("$qrCode?"),
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColor.mainText,
  //                       fontSize: 18,
  //                     )
  //                 )
  //               ]
  //           ),
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               TextButton(
  //                 style: TextButton.styleFrom(
  //                     backgroundColor: AppColor.borderInputColor,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     )
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).pop(false);
  //                 },
  //                 child: Text("Hủy",
  //                   style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(width: 30),
  //               TextButton(
  //                 style: TextButton.styleFrom(
  //                     backgroundColor: AppColor.borderInputColor,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     )
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).pop(true);
  //                 },
  //                 child: Text("OK",
  //                   style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           )
  //         ],
  //       );
  //     },
  //   ) ?? false;
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
                'Kiểm tra sản phẩm',
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
        body: SafeArea(
          child: Column(
            children: <Widget>[

              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      // initialUrlRequest: URLRequest(url: Uri.parse(defaultUrl)),
                      initialOptions: options,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      // Bỏ qua xác minh ssl ở đây
                      onReceivedServerTrustAuthRequest: (controller, challenge) async {
                        return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      androidOnPermissionRequest: (controller, origin, resources) async {
                        return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT,
                        );
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;
                        if (![ "http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                          if (await canLaunch(uri.toString())) {
                            await launch(uri.toString());
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController.endRefreshing();
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      onLoadError: (controller, url, code, message) {
                        pullToRefreshController.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = this.url;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                          urlController.text = this.url;
                        });
                      },
                      // onConsoleMessage: (controller, consoleMessage) {
                      //   print(consoleMessage);
                      // },
                      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
                        print("Console message: ${consoleMessage.message}");
                      },
                    ),
                    if( progress < 1.0)
                      LinearProgressIndicator(
                        value: progress,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.mainText), // Thiết lập màu cho LinearProgressIndicator
                        backgroundColor: Colors.grey[200], // Màu nền của thanh tiến trình
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // )
        // )
      );
  }
}


