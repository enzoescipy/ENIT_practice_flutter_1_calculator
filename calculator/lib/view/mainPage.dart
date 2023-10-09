import 'package:flutter/material.dart';
import 'package:calculator/controller/calc_manager.dart';
import 'dart:developer';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController expressionTextController = TextEditingController();
  TextEditingController resultTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // //debug
    // var testTree = BracketExpressionTree();
    // testTree.parseExpression("(1+3*(3+6)/(2)*7/(-0))");
    // log(testTree.evaluate().toString());
    // //debug

    expressionTextController.text = "hello, expressionTextController!";
    resultTextController.text = "hello, resultTextController!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Calculator"),
        ),
        body: Column(
          children: [
            Expanded(
                child: partLCD(expressionTextController, resultTextController))
          ],
        )
        // body: Column(
        //   children: [partLCD(expressionTextController, resultTextController)],
        // ),
        );
  }
}

Widget partLCD(TextEditingController expressionTextController,
    TextEditingController resultTextController) {
  return Column(
    children: [
      // the expression part
      Expanded(
          flex: 3,
          child: TextField(
            controller: expressionTextController,
            enabled: false,
          )),
      // the result part
      Expanded(
          flex: 1,
          child: TextField(
            controller: expressionTextController,
            enabled: false,
          )),
    ],
  );
}
