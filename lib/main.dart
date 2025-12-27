import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: 'AIzaSyD3TBE7xzPT7SVUvd04CxLDuc233TCYkQE',
        appId: '1:557847208348:web:a3b37d55c823d5588fe859', messagingSenderId: '557847208348', projectId: 'midterm-test-67f85')
  ); // Nhớ config file json trước
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Exam 2351060455',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}