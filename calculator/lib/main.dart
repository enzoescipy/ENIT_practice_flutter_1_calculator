import 'package:flutter/material.dart';

import 'view/mainPage.dart';

import 'package:calculator/library/math_expression.dart';
import 'dart:developer';

void main() {
  // runApp(const MaterialApp(home: MyHomePage()));
  var testTree = BracketExpressionTree();
  // final testString = "12+34+(5.6*7.8)/9";
  final testString = "12+34+5.6*7.8/9";
  for (int i = 0; i < testString.length; i++) {
    var tester = testString[i];
    BracketExpressionTree.magicalInsert(testTree, i, tester);
  }
  log(testTree.toString());
}
