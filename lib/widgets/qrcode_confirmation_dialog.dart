import 'package:flutter/material.dart';
import '../utils/appcolors.dart';

class QRCodeConfirmationDialog extends StatefulWidget {
  final String qrCode;
  const QRCodeConfirmationDialog({Key? key, required this.qrCode}):super(key: key);

  @override
  State<QRCodeConfirmationDialog> createState() => _QRCodeConfirmationDialogState();
}

class _QRCodeConfirmationDialogState extends State<QRCodeConfirmationDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Xác nhận mã QR",
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
              text: "Bạn có muốn sử dụng mã QR này: \n",
              style: TextStyle(
                color: AppColor.mainText,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: "${widget.qrCode}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.mainText,
                fontSize: 18,
              ),
            ),
          ],
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
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Hủy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 30),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColor.borderInputColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                "OK",
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
  }
}