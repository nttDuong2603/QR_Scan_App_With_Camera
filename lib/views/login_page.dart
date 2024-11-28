
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm thư viện shared_preferences
import '../utils/appcolors.dart';
import '../controllers/login_controller.dart';
import '../routes/app_route.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _passwordVisible = false;
  final loginController = LoginController();
  bool _isInitializing = true;
  String? quyenTK = '';


  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Gọi hàm tải dữ liệu đăng nhập đã lưu
    loginController.init().then((_) {
      loginController.autoAddAccounts([
        {'username': 'Admin', 'password': 'Admin@2024', 'role': 'admin'},
          {'username': 'PRPDA', 'password': 'PRPDA@2024', 'role': 'editor'},
        {'username': 'TSPDA', 'password': 'TSPDA@2024', 'role': 'viewer'},
      ]).then((_) {
        setState(() {
          _isInitializing = false;
        });
      });
    });
    loadMaTK();
  }

  Future<void> loadMaTK() async {
    final prefs = await SharedPreferences.getInstance();
    quyenTK = prefs.getString('quyenTK');
    print(quyenTK);
    if (quyenTK != null) {
      print("Loaded maTK: $quyenTK"); // Xử lý `maTK` theo nhu cầu của ứng dụng
    } else {
      print("maTK not found in SharedPreferences.");
    }
  }

  // Hàm tải thông tin đăng nhập đã lưu từ SharedPreferences
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    quyenTK = prefs.getString('quyenTK');

    setState(() {
      usernameController.text = savedUsername;
      passController.text = savedPassword;
      quyenTK = prefs.getString('quyenTK');

    });
  }

  // Hàm lưu thông tin đăng nhập vào SharedPreferences (luôn lưu mặc định)
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text);
    await prefs.setString('password', passController.text);

  }

  Future<void> saveUserAccount(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', username);
  }


  Future<void> _login() async {
    if (_isInitializing) return;

    String username = usernameController.text;
    String password = passController.text;

    bool isLoggedIn = await loginController.checkLogin(username, password);
    if (isLoggedIn) {
      await _saveCredentials(); // Luôn lưu thông tin đăng nhập nếu thành công
      await saveUserAccount(username);
      Navigator.pushNamed(context, "/homePage");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Đăng nhập thất bại'),
            content: Text('Tài khoản hoặc mật khẩu không đúng.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppColor.backgroundAppColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      body: Container(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.1, 0, screenWidth * 0.1, 0),
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, screenHeight * 0.15, 0, 0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'SASCO DEMO',
                style: TextStyle(
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainText,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.06,
                width: screenWidth * 0.01,
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      width: screenWidth * 0.8,
                      child: TextField(
                        controller: usernameController,
                        style: TextStyle(fontSize: screenWidth * 0.06),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderInputColor),
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderInputColor),
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          labelText: 'Tài khoản',
                          labelStyle: TextStyle(color: AppColor.mainText, fontSize: screenWidth * 0.06),
                          prefixIcon: Icon(
                            Icons.person_2_outlined,
                            color: AppColor.mainText,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.02),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      width: screenWidth * 0.8,
                      child: TextField(
                        controller: passController,
                        style: TextStyle(fontSize: screenWidth * 0.06),
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderInputColor),
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.borderInputColor),
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          labelText: 'Mật khẩu',
                          labelStyle: TextStyle(color: AppColor.mainText, fontSize: screenWidth * 0.06),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: AppColor.mainText,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: AppColor.mainText,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    Container(
                      child: TextButton(
                        onPressed: _login,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColor.borderInputColor,
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: screenHeight * 0.022),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          minimumSize: Size(screenWidth * 0.8, 0),
                        ),
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(fontSize: screenWidth * 0.06, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
