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
  CalcManager calcManager = CalcManager();

  ScrollController expressionScrollController = ScrollController();
  ScrollController resultScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    //debug
    calcManager.debug();
    //debug

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
                    resultScrollController
                    ),
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
      ScrollController resultScrollController) {
        
    void selectionChangedThen(
        TextSelection select, SelectionChangedCause? cause) {
      if (select.baseOffset == select.extentOffset) {
        calcManager.moveCursor(select.baseOffset);
      } else {
        calcManager.disableCursor();
      }
    }

    return Column(
      children: [
        // the expression part
        Flexible(
            flex: 3,
            child: Scrollbar(
                controller: expressionScrollController,
                child: SingleChildScrollView(
                  controller: expressionScrollController,
                  scrollDirection: Axis.vertical,
                  child: Container(
                      // color: Colors.green,
                      child: SelectableText(
                    expressionString,
                    onSelectionChanged: selectionChangedThen,
                    style: const TextStyle(fontSize: 20),
                    showCursor: true,
                  )),
                ))),
        // the result part
        Flexible(
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
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.initializeExpression()})
                },
            child: Text("AC")),
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpLeftBracket()})
                },
            child: Text("(")),
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpRightBracket()})
                },
            child: Text(")")),
      ],
    );

    var OperatorEqual = Column(
      children: [
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpDiv()})
                },
            child: Text("÷")),
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMul()})
                },
            child: Text("×")),
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMinus()})
                },
            child: Icon(Icons.remove)),
        OutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpPlus()})
                },
            child: Icon(Icons.add)),
        OutlinedButton(
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
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp7()})
                    },
                child: Text("7")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp8()})
                    },
                child: Text("8")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp9()})
                    },
                child: Text("9")),
          ],
        )),
        Flexible(
            child: Row(
          children: [
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp4()})
                    },
                child: Text("4")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp5()})
                    },
                child: Text("5")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp6()})
                    },
                child: Text("6")),
          ],
        )),
        Flexible(
            child: Row(
          children: [
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp1()})
                    },
                child: Text("1")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp2()})
                    },
                child: Text("2")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp3()})
                    },
                child: Text("3")),
          ],
        )),
        Flexible(
            child: Row(
          children: [
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp0()})
                    },
                child: Text("0")),
            OutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExpDot()})
                    },
                child: Text(".")),
            OutlinedButton(
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
