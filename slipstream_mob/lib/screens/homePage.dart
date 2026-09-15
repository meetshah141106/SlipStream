import 'package:flutter/material.dart';
import 'package:slipstream_mob/normalComponents/button.dart';
import "package:slipstream_mob/testPages/successPage.dart";
import "package:slipstream_mob/initiateConnection/initiateConnection.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Welcome, User",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),

      body: Row(
        children: [
          MyButton(page: SuccessPage(),text: "Check button"),
          MyButton(page: InitiateConnection(), text: "Check connection")
        ],
      ),
    );
  }
}
