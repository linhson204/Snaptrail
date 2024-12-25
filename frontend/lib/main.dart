import 'package:flutter/material.dart';
import '../NewFeed/newFeedScreen.dart';
import '../Widget/accountModel.dart';
import 'package:provider/provider.dart';

import 'Authentication/SignIn.dart'; // Import file model

Future<void> main() async {
  // Token token = await Login('linhson7a127@gmail.com', 'a1234567');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Cấp quyền truy cập cao nhất cho AccountModel
    ChangeNotifierProvider(
      create: (context) => AccountModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/start',
      routes: {
        '/start': (context) => SignIn(),
        '/feed': (context) => newFeedScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


