import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/user_online_model.dart';

class APIController{
  String IP = "http://192.168.19.180:2002";
  // String IP = "https://admin-demo-saas.mylanhosting.com";


  Future<String?> FetchWarehouseReceivingDetail(String qrCode) async{
    final String apiUrl = "$IP/api/B82D2154A88C45748705CB497E73D064/$qrCode";
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // print("API FetchWarehouseReceivingDetailResponse: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchListOfImportedProducts(String qrCode) async{
    final String apiUrl = "$IP/api/5901FADBB48346BDBF924301E0D12D3C/$qrCode";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchSugguestWarehouseEntry(String PNK) async{
    final String apiUrl = "$IP/api/location/stock-in/$PNK";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchQRCodeInfo(String qrCode) async{
    final String apiUrl = "$IP/api/70BCF5B68E594BE5919C2FE08C733324/$qrCode";
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchTrangThaiPNK(String PNK) async{
    final String apiUrl = "$IP/api/2892DAEF248C40F1A2E9FDF2DE158069/$PNK";
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }


  Future<Map<String, dynamic>?> fetchAccount(String taiKhoan, String matKhau) async {
    final url = '$IP/api/2A7368DFF9DE4EFB9B353522D0D0B262/$taiKhoan/$matKhau';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching accounts from API: $e");
    }
    return null; // Trả về null nếu có lỗi xảy ra
  }

  // Phương thức xử lý dữ liệu tài khoản từ JSON và chuyển đổi sang đối tượng UserOnlineModel
  List<UserOnlineModel> parseAccountData(Map<String, dynamic> jsonResponse) {
    List<UserOnlineModel> dealers = [];
    if (jsonResponse['data'] is List) {
      List<dynamic> data = jsonResponse['data'];
      for (var item in data) {
        UserOnlineModel dealer = UserOnlineModel(
          maTK: item["1MTK"],
          maLNPP: item["1MLN"],
          tenLNPP: item["1TLN"],
          maKho: item["19MK"],
          tenKho: item["4TK"],
          maNPP: item["2MNPP"],
          tenNPP: item["2TNPP"],
          maQuyen: item["6MQ"],
        );
        dealers.add(dealer);
      }
    }
    return dealers;
  }

  Future<String?> updateQRCodeManagementTableAccordingToIndex(String LSXQR, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/9838AC8511C54712A63B2CDC654D4C10/$LSXQR';
    print('updateQRCodeManagementTableAccordingToIndex: $apiUrl');
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> capnhatThongTinTang(String maTang, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/AA5FB7A997834FDDAE5AEFEC183BF6BB/$maTang';
    print('updateQRCodeManagementTableAccordingToIndex: $apiUrl');
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> updateQRCodeManagementTableAccordingToQrCode(String QRCode, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/F0A81F7818D64E029FDF52508DAB2CAE/$QRCode';
    print('updateQRCodeManagementTableAccordingToQrCode:$apiUrl');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> updateBoxInfor(String boxCode, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/0F3B9A89B7CE4486B2FBCD86B4CE5384/$boxCode';
    print('updateQRCodeManagementTableAccordingToQrCode:$apiUrl');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> postWarehouseEntryInfor(Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/B0822BC9009A47F2B4A1EC62513BF48B/';
    print('postWarehouseEntryInfor:$apiUrl');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> updateBoxQRCode(String MPNK, String MLNK, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/B0822BC9009A47F2B4A1EC62513BF48B/$MPNK/$MLNK';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> updateProductInfor(String MPNK, String MLNK, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/B0822BC9009A47F2B4A1EC62513BF48B/$MPNK/$MLNK';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> updateWarehouseEntry(String MPNK, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/6FD069511B084E108DB98E1726636C63/$MPNK/';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> postWarehouseEntryDetails(Map<String, dynamic> requestBody) async {
    final String apiUrl = "$IP/api/934EE8610F5046DFAC6F2F46B7F31D21/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print("POST API Success: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error calling POST API: $e");
      return null;
    }
  }

  //.......................//Xuất kho//.............................//
  Future<String?> FetchLXHWithPXK(String qrCodePXK) async{
    final String apiUrl = "$IP/api/F4241F1E01CA448E997455B99D8FFD2E/$qrCodePXK";
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // print("API FetchWarehouseReceivingDetailResponse: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchProductListWithPXK(String qrCodePXK, Map<String, dynamic> requestBody) async{
    final String apiUrl = "$IP/api/BCFAE70D21B245CF8DEF53E3043B7F11/$qrCodePXK";
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // print("API FetchWarehouseReceivingDetailResponse: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchSugguestWarehouseRelease(String PXK) async{
    final String apiUrl = "$IP/api/location/stock-out/$PXK";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
//1 lấy thoông tin Qr code
  Future<String?> FetchThongTinQRCode(String qrCode, Map<String, dynamic> requestBody) async{
    final String apiUrl = "$IP/api/70BCF5B68E594BE5919C2FE08C733324/$qrCode";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
//2 Lấy danh sách QR code thuộc thùng
  Future<String?> FetchThongTinQRCodeThuocThung(String loaiQRCode, String maThung, Map<String, dynamic> requestBody) async{
    final String apiUrl = "$IP/api/359AE2C42D7648939077B593BFF4C428/$loaiQRCode/$maThung";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> FetchTrangThaiPXK(String PXK) async{
    final String apiUrl = "$IP/api/ECD9727952DF49458E6F733220FBE4C0/$PXK";
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
//3 Thêm thông tin phiếu xuất kho
  Future<String?> postThongTinPXK( Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/F705B6F6266C46C7AD9046B6DCF4B95E/';
    print('postThongTinPXK: $apiUrl');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
//4 Cập nhật thông tin thùng
  Future<String?> updateThongTinThung(String maThung, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/0F3B9A89B7CE4486B2FBCD86B4CE5384/$maThung';
    print('updateThongTinThung: $apiUrl');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
//5 cập nhật thông tin tầng
  Future<String?> updateThongTinTang(String maTang, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/AA5FB7A997834FDDAE5AEFEC183BF6BB/$maTang';
    print('updateThongTinTang: $apiUrl');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  //6 Cập nhật qr code thùng
  Future<String?> updateThongTinQrCodeThung(String maThung, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/F0A81F7818D64E029FDF52508DAB2CAE/$maThung';
    print('updateThongTinQrCodeThung: $apiUrl');
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }
//6 Cập nhật qr code sản phẩm
  Future<String?> updateThongTinQrCodeSanPham(String maThung, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/9838AC8511C54712A63B2CDC654D4C10/$maThung';
    print('updateThongTinQrCodeSanPham: $apiUrl');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

  Future<String?> capNhatTrangThaiPXK(String maPXK, Map<String, dynamic> requestBody) async {
    final String apiUrl = '$IP/api/1AF9EEB83D2C4C82B2B24946A3F7ECF6/$maPXK';
    print('capNhatTrangThaiPXK: $apiUrl');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về phản hồi JSON nếu thành công
      } else {
        print("Lỗi API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      return null;
    }
  }

}

