import 'dart:math';

import 'package:calculator/library/debugConsole.dart';
import 'package:flutter/material.dart';
import 'package:calculator/controller/calc_manager.dart';
// import 'package:calculator/library/math_expression.dart';
// import 'dart:developer';

Widget ExpandedOutlinedButton({required void Function()? onPressed, required Widget child, required Color color}) {
  return Expanded(
      child: Container(
    margin: EdgeInsets.all(5),
    child: OutlinedButton(
      child: child,
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    ),
  ));
}

final commonColor = Color.fromARGB(255, 27, 35, 78);

Widget TextTemplet(String data) {
  return Text(
    data,
    style: TextStyle(fontSize: 30, color: commonColor, fontFamily: 'Tmoney'),
  );
}

Widget IconTemplet(IconData icon) {
  return Icon(
    icon,
    color: commonColor,
  );
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
        (random.nextDouble() * 256).toInt(), (random.nextDouble() * 256).toInt(), (random.nextDouble() * 256).toInt(), (random.nextDouble() * 256).toInt());
  }

  CalcManager calcManager = CalcManager();

  ScrollController expressionScrollController = ScrollController();
  ScrollController resultScrollController = ScrollController();

  TextEditingController expressionTextController = TextEditingController();
  FocusNode expressionFocusControll = FocusNode();

  // color collection
  Color ACBracketColor = Color.fromARGB(106, 92, 163, 221);
  Color numpadDeleteColor = Color.fromARGB(120, 110, 207, 131);
  Color OperatorEqualColor = Color.fromARGB(108, 255, 226, 250);

  @override
  void initState() {
    super.initState();

    expressionTextController.addListener(onExpressionTextSelectionChanged);
    calcManager.onExpressionChanged = onExpressionChanged;
    calcManager.onInvalidRequest = onInvalidRequest;
    // randomColorMixer();

    //debug
    calcManager.debug();
    // // debugConsole(evaluateExpression("30.").toString());
    //debug
  }

  @override
  void dispose() {
    expressionTextController.removeListener(onExpressionTextSelectionChanged);
    super.dispose();
  }

  void onInvalidRequest(ExpFault fault) {
    String faultString;
    if (fault == ExpFault.abnormal) {
      faultString = "계산 결과가 실수가 아닙니다. (너무 큰 값을 곱하거나, 0으로 나누는 식이 있나요?)";
    } else {
      faultString = "올바르지 않은 수식입니다.";
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(faultString)));
  }

  void onExpressionChanged(String calcManagerExp, int state) {
    // debugConsole(state);
    var select = expressionTextController.selection;

    var oldText = expressionTextController.text;
    var newText = calcManagerExp.replaceAll("/", "÷");
    expressionTextController.text = newText;

    if (state == -1) {
      final diff = oldText.length - newText.length;
      String deleted = "";
      if (select.baseOffset > 0) {
        deleted = oldText[select.baseOffset - 1];
      }

      if (deleted == "(") {
        expressionTextController.selection = TextSelection(baseOffset: select.baseOffset - 1, extentOffset: select.extentOffset - 1);
      } else {
        expressionTextController.selection = TextSelection(baseOffset: select.baseOffset - diff, extentOffset: select.extentOffset - diff);
      }
    } else if (state == 0 || state == 2) {
      expressionTextController.selection = TextSelection(baseOffset: select.baseOffset + 1, extentOffset: select.extentOffset + 1);
    } else if (state == 1) {
      expressionTextController.selection = TextSelection(baseOffset: newText.length, extentOffset: newText.length);
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
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Calculator"),
          ),
          body: Column(
            children: [
              Flexible(
                flex: 1,
                child: partLCD(calcManager.getResult(), expressionScrollController, resultScrollController, expressionTextController, expressionFocusControll),
              ),
              Flexible(flex: 2, child: Container(margin: EdgeInsets.all(10), child: partButton())),
            ],
          )
          // body: Column(
          //   children: [partLCD(expressionTextController, resultTextController)],
          // ),
          ),
    );
  }

  Widget partLCD(String resultString, ScrollController expressionScrollController, ScrollController resultScrollController,
      TextEditingController expressionTextController, FocusNode expressionFocusControll) {
    return Column(
      children: [
        // the expression part
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Scrollbar(
              controller: expressionScrollController,
              child: TextField(
                controller: expressionTextController,
                scrollController: expressionScrollController,
                focusNode: expressionFocusControll,
                maxLines: null,
                readOnly: true,
                showCursor: true,
                autofocus: true,
                style: TextStyle(fontSize: 40),
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
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
            onPressed: () {
              setState(() => {calcManager.initializeExpression()});
              expressionFocusControll.unfocus();
            },
            color: ACBracketColor,
            child: TextTemplet("AC")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpBracket()})
                },
            color: ACBracketColor,
            child: TextTemplet("()")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {randomColorMixer()})
                },
            color: ACBracketColor,
            child: Icon(
              Icons.bike_scooter,
              color: specialColor,
              size: 40,
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
            child: TextTemplet("÷")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMul()})
                },
            color: OperatorEqualColor,
            child: TextTemplet("×")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpMinus()})
                },
            color: OperatorEqualColor,
            child: TextTemplet("-")),
        ExpandedOutlinedButton(
            onPressed: () => {
                  setState(() => {calcManager.addExpPlus()})
                },
            color: OperatorEqualColor,
            child: TextTemplet("+")),
        ExpandedOutlinedButton(
            onPressed: () {
              setState(() => {calcManager.expressionEquals()});
              expressionFocusControll.unfocus();
            },
            color: OperatorEqualColor,
            child: TextTemplet("=")),
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
                child: TextTemplet("7")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp8()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet("8")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp9()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet("9")),
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
                child: TextTemplet("4")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp5()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet("5")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp6()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet("6")),
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
                child: TextTemplet("1")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp2()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet("2")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExp3()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet("3")),
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
                child: TextTemplet("0")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.addExpDot()})
                    },
                color: numpadDeleteColor,
                child: TextTemplet(".")),
            ExpandedOutlinedButton(
                onPressed: () => {
                      setState(() => {calcManager.deleteCharExpression()})
                    },
                color: numpadDeleteColor,
                child: IconTemplet(Icons.backspace)),
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
