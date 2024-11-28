import 'package:flutter/material.dart';
import 'views/login_page.dart';
import 'routes/app_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: "/loginPage",
      // initialRoute: "/BarcodeScanner",
    );
  }
}
