import 'dart:math';

import 'package:flutter/material.dart';
import 'package:calculator/controller/calc_manager.dart';
// import 'package:calculator/library/math_expression.dart';
// import 'dart:developer';

Widget ExpandedOutlinedButton({required void Function()? onPressed, required Widget child, required Color color}) {
  return Expanded(
      child: Container(
    color: color,
    margin: EdgeInsets.all(5),
    child: OutlinedButton(
      child: child,
      onPressed: onPressed,
    ),
  ));
}

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
  final random = Random.secure();
  Color specialColor = Color.fromARGB(161, 255, 64, 128);
  void randomColorMixer() {
    specialColor = Color.fromARGB(
        (random.nextDouble() * 256) as int, (random.nextDouble() * 256) as int, (random.nextDouble() * 256) as int, (random.nextDouble() * 256) as int);
  }

  CalcManager calcManager = CalcManager();

  ScrollController expressionScrollController = ScrollController();
  ScrollController resultScrollController = ScrollController();

  TextEditingController expressionTextController = TextEditingController();

  // color collection
  Color ACBracketColor = Color.fromARGB(106, 92, 163, 221);
  Color numpadDeleteColor = Color.fromARGB(120, 110, 207, 131);
  Color OperatorEqualColor = Color.fromARGB(108, 255, 226, 250);

  @override
  void initState() {
    super.initState();

    expressionTextController.addListener(onExpressionTextSelectionChanged);
    calcManager.onExpressionChanged = onExpressionChanged;
    randomColorMixer();

    //debug
    calcManager.debug();
    // debugConsole(evaluateExpression("30.").toString());
    //debug
  }

  @override
  void dispose() {
    expressionTextController.removeListener(onExpressionTextSelectionChanged);
    super.dispose();
  }

  void onExpressionChanged(String calcManagerExp) {
    var select = expressionTextController.selection;

    var text = expressionTextController.text;
    var newText = calcManagerExp.replaceAll("/", "÷");
    expressionTextController.text = newText;

    if (text.length > newText.length) {
      expressionTextController.selection = TextSelection(baseOffset: select.baseOffset - 1, extentOffset: select.extentOffset - 1);
    } else if (text.length < newText.length) {
      expressionTextController.selection = TextSelection(baseOffset: select.baseOffset + 1, extentOffset: select.extentOffset + 1);
    } else {
      expressionTextController.selection = select;
    }
  }

  void onExpressionTextSelectionChanged() {
    var select = expressionTextController.selection;
    if (select.baseOffset == select.extentOffset && select.baseOffset != -1) {
      calcManager.moveCursor(select.baseOffset);
    } else {
      calcManager.disableCursor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Calculator"),
        ),
        body: Column(
          children: [
            Flexible(
              flex: 1,
              child:
                  partLCD(calcManager.getExpression(), calcManager.getResult(), expressionScrollController, resultScrollController, expressionTextController),
            ),
            Flexible(flex: 2, child: Container(child: partButton())),
          ],
        )
        // body: Column(
        //   children: [partLCD(expressionTextController, resultTextController)],
        // ),
        );
  }

  Widget partLCD(String expressionString, String resultString, ScrollController expressionScrollController, ScrollController resultScrollController,
      TextEditingController expressionTextController) {
    return Column(
      children: [
        // the expression part
        Expanded(
          flex: 3,
          child: Scrollbar(
            controller: expressionScrollController,
            child: TextField(
              controller: expressionTextController,
              scrollController: expressionScrollController,
              maxLines: null,
              readOnly: true,
              showCursor: true,
              style: TextStyle(fontSize: 40),
              decoration: InputDecoration.collapsed(hintText: ""),
            ),
          ),
        ),
        // the result part
        Expanded(
            flex: 1,
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.bottom,
              controller: resultScrollController,
              child: SingleChildScrollView(
                controller: resultScrollController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  // color: Colors.red,
                  child: SelectableText(
                    resultString,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 20),
                    showCursor: true,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget partButton() {
    var ACBracketRow = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.initializeExpression()})
                },
            color: ACBracketColor,
            child: Text("AC")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpBracket()})
                },
            color: ACBracketColor,
            child: Text("()")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {randomColorMixer()})
                },
            color: ACBracketColor,
            child: Icon(
              Icons.bike_scooter,
              color: specialColor,
            )),
      ],
    );

    var OperatorEqual = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpDiv()})
                },
            color: OperatorEqualColor,
            child: Text("÷")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMul()})
                },
            color: OperatorEqualColor,
            child: Text("×")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMinus()})
                },
            color: OperatorEqualColor,
            child: Icon(Icons.remove)),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpPlus()})
                },
            color: OperatorEqualColor,
            child: Icon(Icons.add)),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.expressionEquals()})
                },
            color: OperatorEqualColor,
            child: Text("=")),
      ],
    );

    var numpadDelete = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp7()})
                    },
                color: numpadDeleteColor,
                child: Text("7")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp8()})
                    },
                color: numpadDeleteColor,
                child: Text("8")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp9()})
                    },
                color: numpadDeleteColor,
                child: Text("9")),
          ],
        )),
        Flexible(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp4()})
                    },
                color: numpadDeleteColor,
                child: Text("4")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp5()})
                    },
                color: numpadDeleteColor,
                child: Text("5")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp6()})
                    },
                color: numpadDeleteColor,
                child: Text("6")),
          ],
        )),
        Flexible(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp1()})
                    },
                color: numpadDeleteColor,
                child: Text("1")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp2()})
                    },
                color: numpadDeleteColor,
                child: Text("2")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp3()})
                    },
                color: numpadDeleteColor,
                child: Text("3")),
          ],
        )),
        Flexible(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp0()})
                    },
                color: numpadDeleteColor,
                child: Text("0")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExpDot()})
                    },
                color: numpadDeleteColor,
                child: Text(".")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.deleteCharExpression()})
                    },
                color: numpadDeleteColor,
                child: Icon(Icons.backspace)),
          ],
        ))
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
            flex: 3,
            child: Column(
              children: [
                Flexible(flex: 1, child: Container(child: ACBracketRow)),
                Flexible(
                  flex: 4,
                  child: Container(child: numpadDelete),
                )
              ],
            )),
        Flexible(flex: 1, child: Container(child: OperatorEqual))
      ],
    );
  }
}
