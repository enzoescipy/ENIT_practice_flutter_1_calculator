import 'package:flutter/material.dart';
import 'package:calculator/controller/calc_manager.dart';
import 'package:calculator/library/math_expression.dart';
import 'dart:developer';

Widget FlexibleOutlinedButton({required void Function()? onPressed, required Widget child}) {
  return Flexible(
      child: OutlinedButton(
    child: child,
    onPressed: onPressed,
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
  CalcManager calcManager = CalcManager();

  ScrollController expressionScrollController = ScrollController();
  ScrollController resultScrollController = ScrollController();

  TextEditingController expressionTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    expressionTextController.addListener(onExpressionTextSelectionChanged);
    calcManager.onExpressionChanged = onExpressionChanged;

    //debug
    calcManager.debug();
    // log(evaluateExpression("30.").toString());
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
      expressionTextController.selection = TextSelection(
          baseOffset: select.baseOffset - 1,
          extentOffset: select.extentOffset - 1);
    } else if (text.length < newText.length) {
      expressionTextController.selection = TextSelection(
          baseOffset: select.baseOffset + 1,
          extentOffset: select.extentOffset + 1);
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
                child: partLCD(
                    calcManager.getExpression(),
                    calcManager.getResult(),
                    expressionScrollController,
                    resultScrollController,
                    expressionTextController),
                flex: 1),
            Flexible(child: partButton()),
          ],
        )
        // body: Column(
        //   children: [partLCD(expressionTextController, resultTextController)],
        // ),
        );
  }

  Widget partLCD(
      String expressionString,
      String resultString,
      ScrollController expressionScrollController,
      ScrollController resultScrollController,
      TextEditingController expressionTextController) {
    return Column(
      children: [
        // the expression part
        Flexible(
          flex: 1,
          child: Scrollbar(
            controller: expressionScrollController,
            child: TextField(
              controller: expressionTextController,
              scrollController: expressionScrollController,
              maxLines: null,
              readOnly: true,
              showCursor: true,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration.collapsed(hintText: ""),
            ),
          ),
        ),
        // the result part
        Flexible(
            flex: 3,
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
      children: [
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.initializeExpression()})
                },
            child: Text("AC")),
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpLeftBracket()})
                },
            child: Text("(")),
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpRightBracket()})
                },
            child: Text(")")),
      ],
    );

    var OperatorEqual = Column(
      children: [
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpDiv()})
                },
            child: Text("÷")),
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMul()})
                },
            child: Text("×")),
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMinus()})
                },
            child: Icon(Icons.remove)),
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpPlus()})
                },
            child: Icon(Icons.add)),
        FlexibleOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.expressionEquals()})
                },
            child: Text("=")),
      ],
    );

    var numpadDelete = Column(
      children: [
        Flexible(
            child: Row(
          children: [
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp7()})
                    },
                child: Text("7")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp8()})
                    },
                child: Text("8")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp9()})
                    },
                child: Text("9")),
          ],
        )),
        Flexible(
            child: Row(
          children: [
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp4()})
                    },
                child: Text("4")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp5()})
                    },
                child: Text("5")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp6()})
                    },
                child: Text("6")),
          ],
        )),
        Flexible(
            child: Row(
          children: [
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp1()})
                    },
                child: Text("1")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp2()})
                    },
                child: Text("2")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp3()})
                    },
                child: Text("3")),
          ],
        )),
        Flexible(
            child: Row(
          children: [
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp0()})
                    },
                child: Text("0")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExpDot()})
                    },
                child: Text(".")),
            FlexibleOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.deleteCharExpression()})
                    },
                child: Icon(Icons.backspace)),
          ],
        ))
      ],
    );

    return Row(
      children: [
        Flexible(
            child: Column(
          children: [
            Flexible(child: ACBracketRow),
            Flexible(
              child: numpadDelete,
            )
          ],
        )),
        Flexible(child: OperatorEqual)
      ],
    );
  }
}
