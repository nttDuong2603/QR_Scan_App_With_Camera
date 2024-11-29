import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../utils/appcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
String? quyenTK = '';
String? role = '';

@override
void initState() {
  super.initState();
  loadMaQuyen();
}
Future<void> loadMaQuyen() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    quyenTK = prefs.getString('quyenTK');
  });
  print("Quyền tài khoản hiện tại: $quyenTK");
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
          context,
          '/loginPage'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
    child: Scaffold(
      backgroundColor: AppColor.backgroundAppColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: AppColor.backgroundAppColor,
          leading: Container(
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
              ),
            ),
          ),
          title: Row(
            children: [
              // SizedBox(width: 8),
              Text(
                'SASCO DEMO',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainText,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SingleChildScrollView(
              child:
                  Column(
                    children: [
                      // if (quyenTK == 'MQ0003' || quyenTK == 'MQ0004' || quyenTK == 'MQ0001')
                        Container(
                          padding: EdgeInsets.only(top: screenHeight * 0.06, left: screenWidth * 0.06, right: screenWidth * 0.06),
                          child:  TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/Product_Information");
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColor.borderInputColor,
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.02),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/qr_scan.png',
                                  width: screenWidth * 0.23,
                                  height: screenWidth * 0.23,
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'KIỂM TRA \nSẢN PHẨM',
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.07,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      // Padding(
                                      //   padding: EdgeInsets.only(left: screenWidth*0.06),
                                      //   child: Icon(
                                      //     Icons.arrow_forward,
                                      //     color: Colors.white,
                                      //     size: screenWidth * 0.087,
                                      //   ),
                                      // )
                                    ],
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      // if (quyenTK == 'MQ0001' || quyenTK == 'MQ0004')
                      Container(
                        padding: EdgeInsets.only(top: screenHeight * 0.06, left: screenWidth * 0.06, right: screenWidth * 0.06),
                        child:  TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/warehouse_entry");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColor.borderInputColor,
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/warehouse entry_logo.png',
                                width: screenWidth * 0.22,
                                height: screenWidth * 0.22,
                              ),
                              SizedBox(width: screenWidth * 0.06),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'NHẬP KHO',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.07,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Padding(
                                    //   padding: EdgeInsets.only(left: screenWidth*0.06),
                                    //   child: Icon(
                                    //     Icons.arrow_forward,
                                    //     color: Colors.white,
                                    //     size: screenWidth * 0.087,
                                    //   ),
                                    // )
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(top: screenWidth * 0.02, left: screenWidth * 0.06, right: screenWidth * 0.06),
                      //   child:  TextButton(
                      //     onPressed: () {
                      //       Navigator.pushNamed(context, "/packing_slip");
                      //     },
                      //     style: TextButton.styleFrom(
                      //       backgroundColor: AppColor.borderInputColor,
                      //       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.02),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/packing_slip_logo.png',
                      //           width: screenWidth * 0.23,
                      //           height: screenWidth * 0.23,
                      //         ),
                      //         SizedBox(width: screenWidth * 0.06),
                      //         Container(
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               Text(
                      //                 'SOẠN HÀNG',
                      //                 style: TextStyle(
                      //                     fontSize: screenWidth * 0.07,
                      //                     color: Colors.white,
                      //                     fontWeight: FontWeight.bold),
                      //                 textAlign: TextAlign.center,
                      //               ),
                      //               Padding(
                      //                 padding: EdgeInsets.only(left: 0),
                      //                 child: Icon(
                      //                   Icons.arrow_forward,
                      //                   color: Colors.white,
                      //                   size: screenWidth * 0.087,
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         )
                      //
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // if (quyenTK == 'MQ0003' || quyenTK == 'MQ0004')
                      Container(
                        padding: EdgeInsets.only(top: screenHeight * 0.06, left: screenWidth * 0.06, right: screenWidth * 0.06),
                        child:  TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/warehouse_relase_list_page");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColor.borderInputColor,
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/warehouse release_logo.png',
                                width: screenWidth * 0.23,
                                height: screenWidth * 0.23,
                              ),
                              SizedBox(width: screenWidth * 0.06),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'XUẤT KHO',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.07,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                       // Padding(
                                       //   padding: EdgeInsets.only(left: screenWidth*0.06),
                                       //   child: Icon(
                                       //     Icons.arrow_forward,
                                       //     color: Colors.white,
                                       //     size: screenWidth * 0.087,
                                       //   ),
                                       // )
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                    ],
                  )
            ),
            Text(
              'v1.0.0.0',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
