import 'package:flutter/material.dart';
import 'View/SignInView.dart';
import 'View/LogInView.dart';
import 'View/CalendarView.dart';
import 'View/SettingView.dart';
import 'View/AddTaskView.dart';
import 'View/HomeView.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: Scaffold(body: start())),
    ),
  );
}

class start extends StatelessWidget {
  const start({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
          SizedBox(height: 20),
          Text(
            "Organize Your Day",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Achieve clarity and accomplish your goals",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogInView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              "Get Started",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInView()),
                  );
                },
                child: Text(
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
