import 'package:flutter/material.dart';
import '../Controller/AddTaskController.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final tasknameCtrl = TextEditingController();
  final noteCtl = TextEditingController();
  final priorityCtr = TextEditingController();

  //late AddTaskController controller;

  // @override
  // void initState() {
  //   super.initState();
  //   controller = SignInController(
  //     emailCtl: emailCtl,
  //     phoneCtl: phoneCtl,
  //     passwordCtl: passwordCtl,
  //     cfPasswordCtl: cfPasswordCtl,
  //   );
  // }

  @override
  void dispose() {
    tasknameCtrl.dispose();
    noteCtl.dispose();
    priorityCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/startbg.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              
            ],
          ),
        ),
      ),
    );
  }
}
