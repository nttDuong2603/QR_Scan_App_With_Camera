import 'package:flutter/material.dart';
import 'package_slip_scan.dart';
import '../../utils/appcolors.dart';

class PackageSlipSugguest extends StatefulWidget {
  const PackageSlipSugguest({super.key});

  @override
  State<PackageSlipSugguest> createState() => _PackageSlipSugguestState();
}

class _PackageSlipSugguestState extends State<PackageSlipSugguest> {
  Set<int> expandedItems = {};

  Future<bool> _showPackageSlipLocationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.backgroundAppColor,
          title: Text(
            "Di chuyển Soạn hàng",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Vị trí Soạn hàng:",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "- Dãy 1, Tầng 1, Ô 1",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Chi tiết sản phẩm:",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "- Mã QR Code Thùng: TH000001",
                style: TextStyle(
                    color: AppColor.mainText,
                    fontSize: 16,
                    // fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "- Mã Thùng: THUNG162237",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "- Aquafina",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "- SKU: 10141864",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              Text(
                "- Số lượng cần xuất: 22 chai",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Gợi ý hình thức quét soạn hàng: Quét QR 2 sản phẩm cần giữ",
                style: TextStyle(
                  color: AppColor.mainText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColor.borderInputColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageSlipScan(
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Quét QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope( onWillPop: () async {
      // Thay vì chỉ pop trang hiện tại, hãy sử dụng pushAndRemoveUntil để quay trực tiếp về HomePage
      Navigator.pushNamed(
          context,
          '/warehouse_relase_list_page'
      );
      return false; // Ngăn không cho hành động pop mặc định
    },
        child:  Scaffold(
          backgroundColor: AppColor.backgroundAppColor,
          appBar: AppBar(
            backgroundColor: AppColor.backgroundAppColor,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
              ),
            ),
            title: Text(
              'Gợi ý soạn hàng',
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  color: AppColor.backgroundAppColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Vị trí: Dãy 1, Tầng 1, Ô 1",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainText,
                          ),
                        ),
                        subtitle: Text(
                          "Số lượng thùng sản phẩm: 2",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: AppColor.mainText,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            expandedItems.contains(index) ? Icons.expand_less : Icons.expand_more,
                            color: AppColor.mainText,
                          ),
                          onPressed: () {
                            setState(() {
                              if (expandedItems.contains(index)) {
                                expandedItems.remove(index);
                              } else {
                                expandedItems.add(index);
                              }
                            });
                          },
                        ),
                      ),
                      if (expandedItems.contains(index))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showPackageSlipLocationDialog();
                                },
                                child: Card(
                                  color: AppColor.backgroundAppColor,
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Mã QR Code Thùng: TH000001",
                                                style: TextStyle(
                                                    color: AppColor.mainText,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                "Mã Thùng: THUNG162237",
                                                style: TextStyle(
                                                  color: AppColor.mainText,
                                                  fontSize: screenWidth * 0.045,
                                                ),
                                              ),
                                              Text(
                                                "Aquafina",
                                                style: TextStyle(
                                                  color: AppColor.mainText,
                                                  fontSize: screenWidth * 0.045,
                                                ),
                                              ), Text(
                                                "SKU: 10141864",
                                                style: TextStyle(
                                                  color: AppColor.mainText,
                                                  fontSize: screenWidth * 0.045,
                                                ),
                                              ),
                                              Text(
                                                "Số lượng cần xuất: 22 chai",
                                                style: TextStyle(
                                                  color: AppColor.mainText,
                                                  fontSize: screenWidth * 0.045,
                                                ),
                                              ),
                                              SizedBox(height: screenWidth * 0.01,),
                                              Text(
                                                "Trạng thái: Đã lấy hàng",
                                                style: TextStyle(
                                                  color: AppColor.mainText,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: screenWidth * 0.01,),
                                              Text(
                                                "Gợi ý hình thức quét soạn hàng: \nQuét QR 2 sản phẩm cần giữ",
                                                style: TextStyle(
                                                  color: AppColor.mainText,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // SizedBox(width: screenWidth *0.1),
                                          Center(
                                              child: Icon(
                                                  Icons.qr_code, // Mã QR icon
                                                  color: AppColor.mainText,
                                                  size: 30
                                              ))
                                        ],
                                      )

                                  ),
                                ),

                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: AppColor.backgroundAppColor,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColor.borderInputColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              onPressed: () => _showCompletPackageSlipDialog(),
              child: Text(
                "Hoàn thành Soạn hàng",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.07,
                ),
              ),
            ),
          ),
        )
    );
  }

  Future<bool> _showCompletPackageSlipDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hoàn thành saạon hàng",
            style: TextStyle(
              color: AppColor.mainText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: RichText(
            text: TextSpan(
                children: [
                  TextSpan(
                      text: ("Phiếu soạn hàng đã hoàn thành"),
                      style: TextStyle(
                        color: AppColor.mainText,
                        fontSize: 18,
                      )
                  ),
                ]
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: AppColor.borderInputColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Hủy",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(width: 30),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: AppColor.borderInputColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    ) ?? false;
  }

}


