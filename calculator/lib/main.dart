import 'package:flutter/material.dart';

import 'view/mainPage.dart';

import 'package:calculator/library/math_expression.dart';
import 'dart:developer';

import 'package:calculator/library/debugConsole.dart';

void main() {
  enableDebug();
  // enableCount();
  runApp(MaterialApp(home: MyHomePage()));
  // DEBUG();
}

void DEBUG() {
  runApp(const MaterialApp());
  var testTree = BracketExpressionTree();
  List<dynamic> tester1 = ["12/34*((6+3/4-9", "/(7-9", 2]; // "12/34*((6+3/4-9))/(7-9)" 0.39
  List<dynamic> tester2 = ["12*34*(5.6*7.8", "/9", 1]; // "12*34*(5.6*7.8)/9" 1980
  List<dynamic> tester3 = ["12+34+(5.6*7.8", "/9", 1]; // "12+34+(5.6*7.8)/9" 50.85
  List<dynamic> tester4 = ["12/34*((6+3/4-9", "/(7*0", 2]; // "12/34*((6+3/4-9))/(7-9)" nan

  String testString = tester3[0];

  for (int i = 0; i < testString.length; i++) {
    // debugConsoleNoTrace("");
    // debugConsoleNoTrace("   $i stage  ");
    // debugConsoleNoTrace("");
    var tester = testString[i];
    BracketExpressionTree.magicalInsert(testTree, i, tester);
  }

  int start = testString.length + tester3[2] as int;
  testString = tester3[1];
  for (int i = 0; i < testString.length; i++) {
    // debugConsoleNoTrace("");
    // debugConsoleNoTrace("   $i stage  ");
    // debugConsoleNoTrace("");
    int index = start + i;
    var tester = testString[i];
    BracketExpressionTree.magicalInsert(testTree, index, tester);
  }
  // debugConsole(["tree toString", testTree.toString()]);
  // debugConsole(["tree length", testTree.length]);
  // debugConsole(["tree doubleValue", testTree.evaluate()]);
}
