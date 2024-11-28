import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  var getResult = 'qrcode';

  void scanQRCode() async{
    try{
      final qrCode = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancle', true, ScanMode.BARCODE);

      if(!mounted){
        return ;
      }

      setState(() {
        getResult = qrCode;
      });
      print("QrCode result: --");
      print(qrCode);
    } on PlatformException{
      getResult = "rong";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vui long quet barcode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: (){
              scanQRCode();
            },
              child: Text('Quét QR Code'),
            ),
            SizedBox(height: 20,),
            Text('$getResult'),
          ],
        ),
      )

    );
  }
}
