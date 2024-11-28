import 'package:flutter/material.dart';
import 'package_slip_sugguest.dart';

import '../../utils/app_format.dart';
import '../../utils/appcolors.dart';

class PackingSlipList extends StatefulWidget {
  const PackingSlipList({super.key});

  @override
  State<PackingSlipList> createState() => _PackingSlipListState();
}

class _PackingSlipListState extends State<PackingSlipList> {
  final AppFormat appFormat = AppFormat();
  Map<int, bool> expandedItems = {};


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope( onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
          context,
          '/homePage'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
        child:  Scaffold(
          backgroundColor: AppColor.backgroundAppColor,
          appBar: AppBar(
            backgroundColor: AppColor.backgroundAppColor,
            leading: InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
              ),
            ),
            title: Text(
              'Danh sách Phiếu Soạn hàng',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(screenWidth * 0.02),
            itemCount: 1,
            itemBuilder: (context, index) {
              final _isExpanded = expandedItems[index] ?? false;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Bao bọc nội dung `title` bằng `GestureDetector`
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PackageSlipSugguest(),
                                  ),
                                );
                              },
                              child:
                              Padding(
                                padding: const EdgeInsets.all(8.0), // Thêm padding cho toàn bộ nội dung
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow("Mã Phiếu Soạn hàng","PSH001"),
                                    SizedBox(height: 4),
                                    _buildInfoRow("Mã Phiếu Xuất Kho","PXKTS001"),
                                    SizedBox(height: 4),
                                    _buildInfoRow("Ngày Xuất", "22/11/2024"),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Icon mở rộng
                          IconButton(
                            icon: Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: AppColor.mainText,
                            ),
                            onPressed: () {
                              setState(() {
                                setState(() {
                                  expandedItems[index] = !(expandedItems[index] ?? false);
                                });// Thay đổi trạng thái khi nhấn vào icon
                              });
                            },
                          ),
                        ],
                      ),
                      // Sử dụng `Visibility` để kiểm soát hiển thị phần mở rộng
                      Visibility(
                        visible: _isExpanded,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 9.0),
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.55,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Danh sách sản phẩm:",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.mainText,
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(

                                        child:  Container(
                                          margin: EdgeInsets.symmetric(vertical: 8),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(0.3),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "Tên sản phẩm: ",
                                                            style: TextStyle(
                                                              color: AppColor.mainText,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "Aquafina",
                                                            style: TextStyle(
                                                              color: AppColor.mainText,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "SKU: ",
                                                            style: TextStyle(
                                                              color: AppColor.mainText,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "10141864",
                                                            style: TextStyle(
                                                              color: AppColor.mainText,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "Số lượng cần xuất: ",
                                                            style: TextStyle(
                                                              color: AppColor.mainText,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "48 chai",
                                                            style: TextStyle(
                                                              color: AppColor.mainText,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Center(
                                              //     child: Icon(
                                              //         Icons.navigate_next, // Mã QR icon
                                              //         color: AppColor.mainText,
                                              //         size: 30
                                              //     ))
                                            ],
                                          ),

                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 8),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.3),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "Tên sản phẩm: ",
                                                          style: TextStyle(
                                                            color: AppColor.mainText,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "Mì Omachi Ly",
                                                          style: TextStyle(
                                                            color: AppColor.mainText,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "SKU: ",
                                                          style: TextStyle(
                                                            color: AppColor.mainText,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "10151815",
                                                          style: TextStyle(
                                                            color: AppColor.mainText,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "Số lượng cần xuất: ",
                                                          style: TextStyle(
                                                            color: AppColor.mainText,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: "24 ly",
                                                          style: TextStyle(
                                                            color: AppColor.mainText,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Center(
                                            //     child: Icon(
                                            //         Icons.navigate_next, // Mã QR icon
                                            //         color: AppColor.mainText,
                                            //         size: 30
                                            //     ))
                                          ],
                                        ),

                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColor.backgroundAppColor,
            items: [
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Mục bên trái trống
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColor.mainText,
                  size: 35,
                ),
                label: 'Tạo Lịch',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Mục bên phải trống
                label: '',
              ),
            ],
            onTap: (index) {
              if (index == 1) { // Xử lý chỉ khi chọn mục giữa
                Navigator.pushNamed(context, "/warehouse_release_ad_infor_page");
              }
            },
            selectedLabelStyle: TextStyle(
              fontSize: screenWidth * 0.055,
              color: AppColor.mainText,
            ),
            unselectedFontSize: screenWidth * 0.055,
            selectedItemColor: AppColor.mainText,
            unselectedItemColor: AppColor.mainText,
          ),
        )
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    String formattedValue = value;
    if (label == "Ngày Xuất" && value.isNotEmpty) {
      try {
        // Sử dụng phương thức formatDate của AppFormat
        formattedValue = appFormat.formatDate(value);
      } catch (e) {
        // print("Lỗi định dạng ngày: $e");
      }
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: formattedValue,
            style: TextStyle(
              color: textColor ?? AppColor.mainText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
