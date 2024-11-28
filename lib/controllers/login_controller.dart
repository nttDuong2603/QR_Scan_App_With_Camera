import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_online_model.dart';
import 'package:http/http.dart' as http;
import 'api_controller.dart';

class LoginController{
  late SharedPreferences prefs;
  final APIController apiController = APIController();

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> autoAddAccounts(List<Map<String, String>> accounts) async {
    String accountsJson = jsonEncode(accounts);
    await prefs.setString('all_accounts', accountsJson);
  }

  Future<bool> getAccount(String taiKhoan, String matKhau) async {
    var jsonResponse = await apiController.fetchAccount(taiKhoan, matKhau);
    print(jsonResponse);

    if (jsonResponse != null) {
      List<UserOnlineModel> dealers = apiController.parseAccountData(jsonResponse);

      if (jsonResponse['total'] == 1 && dealers.isNotEmpty) {
        // Lấy maTK từ đối tượng UserOnlineModel đầu tiên
        String maTK = dealers[0].maTK;
        String? quyenTK = dealers[0].maQuyen;
        print('a: ${dealers[0].maQuyen}');        // Lưu maTK vào SharedPreferences
        await prefs.setString('maTK', maTK);
        await prefs.setString('quyenTK', quyenTK!);
        print('quyenTK saved: $quyenTK'); // Kiểm tra xem maTK đã được lưu hay chưa

        print('maTK saved: $maTK'); // Kiểm tra xem maTK đã được lưu hay chưa
        return true; // Đăng nhập thành công
      }
    }
    return false; // Đăng nhập thất bại
  }


  Future<bool> checkLogin(String taiKhoan, String matKhau) async {
    // Thử kiểm tra đăng nhập trực tuyến trước
    var jsonResponse = await apiController.fetchAccount(taiKhoan, matKhau); // Gọi ApiController

    if (jsonResponse != null && jsonResponse['total'] == 1) {
      final maTK = jsonResponse['data'][0]['1MTK'];
      final quyenTK = jsonResponse['data'][0]['6MQ'];

      if (maTK != null) {
        await prefs.setString('maTK', maTK);
        print('maTK saved: $maTK');
        if (quyenTK != null) {
          await prefs.setString('quyenTK', quyenTK);  // Lưu mã quyền vào SharedPreferences
        }
        print('Đăng nhập thành công với quyền: $quyenTK');
        return true;
      }
    } else {
      print("Switching to offline login.");
    }

    // Nếu không thành công trực tuyến, kiểm tra tài khoản cục bộ
    String? accountsJson = prefs.getString('all_accounts');
    if (accountsJson != null) {
      List<dynamic> accountsData = jsonDecode(accountsJson);

      // Chuyển đổi từng phần tử trong accountsData thành Map<String, String>
      List<Map<String, String>> accounts = accountsData.map((account) {
        return (account as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
      }).toList();

      for (var account in accounts) {
        if (account['username'] == taiKhoan && account['password'] == matKhau) {
          return true; // Đăng nhập cục bộ thành công
        }
      }
    }

    return false; // Không tìm thấy tài khoản hợp lệ
  }

  // Future<bool> getAccount(String taiKhoan, String matKhau) async {
  //   var url = 'http://115.78.237.91:5088/api/2A7368DFF9DE4EFB9B353522D0D0B262/$taiKhoan/$matKhau';
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       var jsonResponse = json.decode(response.body);
  //
  //       List<UserOnlineModel> dealers = [];
  //       if (jsonResponse is Map<String, dynamic> && jsonResponse['data'] is List) {
  //         List<dynamic> data = jsonResponse['data'];
  //         for (var item in data) {
  //           UserOnlineModel dealer = UserOnlineModel(
  //             maTK: item["1MTK"],
  //             maLNPP: item["1MLN"],
  //             tenLNPP: item["1TLN"],
  //             maKho: item["19MK"],
  //             tenKho: item["4TK"],
  //             maNPP: item["2MNPP"],
  //             tenNPP: item["2TNPP"],
  //             maQuyen: item["6MQ"],
  //           );
  //           dealers.add(dealer);
  //           // await _saveAccountCodeToSecureStorage(dealer.maLNPP!, dealer.tenLNPP!, dealer.maTK, dealer.maKho!, dealer.tenKho!, dealer.maNPP!, dealer.tenNPP!, dealer.maQuyen!);
  //         }
  //         print(data);
  //       }
  //       // Check the "total" field to determine if login is allowed
  //       if (jsonResponse['total'] == 1) {
  //         return true;
  //       }
  //     } else {
  //       print('Failed to load data with status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("Error fetching accounts from API: $e");
  //   }
  //   return false;  // Default to not permitting login if conditions are not met
  // }
  //
  // Future<bool> checkLogin(String taiKhoan, String matKhau) async {
  //   // Thử kiểm tra trực tuyến trước
  //   try {
  //     var url = 'http://115.78.237.91:5088/api/2A7368DFF9DE4EFB9B353522D0D0B262/$taiKhoan/$matKhau';
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       var jsonResponse = json.decode(response.body);
  //       if (jsonResponse['total'] == 1) {
  //         return true; // Đăng nhập trực tuyến thành công
  //       }
  //     } else {
  //       print('Failed to load data with status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("Error fetching accounts from API: $e");
  //     print("Switching to offline login.");
  //   }
  //
  //   // Nếu không thành công trực tuyến, kiểm tra tài khoản cục bộ
  //   String? accountsJson = prefs.getString('all_accounts');
  //   if (accountsJson != null) {
  //     List<dynamic> accountsData = jsonDecode(accountsJson);
  //
  //     // Chuyển đổi từng phần tử trong accountsData thành Map<String, String>
  //     List<Map<String, String>> accounts = accountsData.map((account) {
  //       return (account as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
  //     }).toList();
  //
  //     for (var account in accounts) {
  //       if (account['username'] == taiKhoan && account['password'] == matKhau) {
  //         return true; // Đăng nhập cục bộ thành công
  //       }
  //     }
  //   }
  //
  //   return false; // Không tìm thấy tài khoản hợp lệ
  // }
}