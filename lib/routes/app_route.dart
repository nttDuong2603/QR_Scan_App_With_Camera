import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../views/Packing_Slip/packing_slip_list.dart';
import '../views/login_page.dart';
import '../views/home_page.dart';
import '../views/Warehouse_Entry_Views/warehouse_entry_page.dart';
import '../views/Warehouse_Entry_Views/warehouse_receiving_scan_barcode_page.dart';
import '../views/Warehouse_Entry_Views/warehouse_entry_details_page.dart';
import '../views/Warehouse_Entry_Views/qr_scan_page.dart';
import '../views/Warehouse_Entry_Views/suggested_location_page.dart';
import '../views/Warehouse_Entry_Views/warehouse_entry_infor.dart';
import '../views/Warehouse_Entry_Views/warehouse_entry_box_detail_page.dart';
import '../views/Warehouse_Entry_Views/sugguest_qr_scan.dart';
import '../views/Warehouse_Relase_Views/warehouse_relase_list_page.dart';
import '../views/Warehouse_Relase_Views/warehouse_relase_ad_info_page.dart';
import '../views/Warehouse_Relase_Views/warehouse_relase_details.dart';

import '../views/Check_Product_Infor/barcode_scanner.dart';
import '../views/Check_Product_Infor/check_product_infor_webview.dart';
import '../views/Warehouse_Relase_Views/qr_scan_release_page.dart';
import '../views/Warehouse_Relase_Views/warehouse_relase_suggest_location_page.dart';


class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/loginPage':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/homePage':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/warehouse_entry':
        return MaterialPageRoute(builder: (_) => WarehouseEntryPage());
      case '/warehouse_receiving_scan_barcode':
        return MaterialPageRoute(builder: (_) => WarehouseReceivingScanBarcodePage());
      case '/warehouse_entry_detail':
        final data = settings.arguments as Map<String, dynamic>; // Lấy dữ liệu từ arguments
        return MaterialPageRoute(
          builder: (_) => WarehouseEntryDetailsPage(data: data),
        );
      case '/qr_scan':
        final title = settings.arguments as String; // Lấy tiêu đề từ arguments
        return MaterialPageRoute(
          builder: (_) => QrScanPage(title: title),
        );
      case '/guggested_location_page':
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SuggestedLocationPage(data:data),
        );
      case '/warehouse_entry_qr_scan':
        final title = settings.arguments as String; // Lấy tiêu đề từ arguments
        return MaterialPageRoute(
          builder: (_) => QrScanPage(title: title),
        );
      case '/warehouse_entry_infor':
        final entry = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WarehouseEntryInforPage(entry: entry),
        );
      case '/warehouse_entry_box_details':
        final itemData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WarehouseEntryBoxDetailsPage(itemData: itemData),
        );
      // case '/sugguest_qr_scan':
      //   final title = settings.arguments as String; // Lấy tiêu đề từ arguments
      //   return MaterialPageRoute(
      //     builder: (_) => SugguestQRScan(title: title),
      //   );
      case '/warehouse_relase_list_page':
        return MaterialPageRoute(builder: (_) => WarehouseReleaseListPage());
      case '/warehouse_release_ad_infor_page':
        return MaterialPageRoute(
          builder: (_) => WarehouseReleaseAdInforPage(),
        );
      case '/warehouse_relase_details':
        return MaterialPageRoute(
          builder: (_) => WarehouseRelaseDetails(),
        );
      case '/warehouse_relase_sugguest':
        final suggestionsData = settings.arguments as Map<String, dynamic>;
        final maPXK =  settings.arguments as String ;
        return MaterialPageRoute(
          builder: (_) => WarehouseReleaseSuggest(suggestionsData: suggestionsData, maPXK: maPXK,),
        );
      case '/Product_Information':
        return MaterialPageRoute(
          builder: (_) => ProductInformation(),
        );
      case '/BarcodeScanner':
        return MaterialPageRoute(
          builder: (_) => BarcodeScanner(),
        );
      case '/packing_slip':
        return MaterialPageRoute(builder: (_) => PackingSlipList());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

