import 'package:flutter/material.dart';
import 'View/SignInView.dart';
import 'View/LogInView.dart';
import 'Controller/NotificationsController.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'Controller/ThemeProvider.dart';
import 'Model/UserDatabase.dart';
import 'Model/TaskDatabase.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsController().init(); 
  await initializeDateFormatting('vi_VN', null);

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme(); 

  await UserDatabase.instance.database;
  await TaskDatabase.instance.database;
  
 runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      locale: const Locale('vi', 'VN'),
      
      themeMode: themeProvider.themeMode, 
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F5F9), 
        appBarTheme: const AppBarThemeData(
          backgroundColor: const Color(0xFFF0F5F9),
          foregroundColor: Colors.black,
        ),
        bottomAppBarTheme: const BottomAppBarThemeData( 
          color: Colors.white,
          elevation: 5.0
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
          titleMedium: TextStyle(color: Colors.black),
        ),
      ),
      
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212), 
        appBarTheme: const AppBarThemeData(
          backgroundColor: const Color(0xFF1F1F1F),
          foregroundColor: Colors.white, 
        ),
        bottomAppBarTheme: const BottomAppBarThemeData( 
          color: const Color(0xFF1F1F1F),
          elevation: 5.0
        ),
        textTheme: const TextTheme( 
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
          titleMedium: TextStyle(color: Colors.white),
        ),
      ),

      home: SafeArea(child: Scaffold(body: const start())),
    );
  }
}

class start extends StatelessWidget {
  const start({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration( 
        image: DecorationImage(
          image: AssetImage("assets/img/startbg.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/img/logo.png", width: 200, height: 200),
          ),
          const SizedBox(height: 20),
          const Text(
            "Organize Your Day",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Achieve clarity and accomplish your goals",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LogInView()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account?",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInView()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 55, 101, 255),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}