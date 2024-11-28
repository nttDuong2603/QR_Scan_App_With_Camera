// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:rfid_c72_plugin_example/utils/appcolors.dart';
//
// class BarcodeScannerListView extends StatefulWidget {
//   const BarcodeScannerListView({super.key});
//
//   @override
//   State<BarcodeScannerListView> createState() => _BarcodeScannerListViewState();
// }
//
// class _BarcodeScannerListViewState extends State<BarcodeScannerListView> {
//   final MobileScannerController controller = MobileScannerController(torchEnabled: true);
//
//   Widget _buildBarcodeListView(){
//     if(barcodes == null || barcodes.isEmpty){
//       return Center(child: Text(
//         'Vui long quet barcode',
//         overflow: TextOverflow.fade,
//         style: TextStyle(
//           color: AppColor.mainText,
//         ),
//       )
//       );
//     }
//     return ListView.builder(
//       itemCount: barcodes.length,
//         itemBuilder:(context, index){
//         return Padding(padding: EdgeInsets.all(8.0),
//           child: Text(
//               barcodes[index].rawValue ?? "No value",
//             overflow: TextOverflow.fade,
//             style: TextStyle(
//               color: AppColor.mainText,
//             ),
//           ),
//           );
//         }
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('List barcode'),
//       ),
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: controller,
//             errorBuilder: (context, error, child){
//               return ScanErrorWidget(error: error);
//             },
//             fit: BoxFit.contain,
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: 100,
//               alignment: Alignment.bottomCenter,
//               color: Colors.black.withOpacity(0.4),
//               child: Column(
//                 children: [
//                   Expanded(child: _buildBarcodeListView()),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ToggleFlashlightButton(controller: controller),
//                       StartStopMobileScannerButton(controller: controller),
//                       const Spacer(),
//                       SwitchCameraButton(controller: controller),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
