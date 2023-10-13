import 'dart:ffi';
import 'dart:developer';

import 'package:calculator/library/debugConsole.dart';
import 'package:calculator/library/math_expression.dart';

enum ExpFault { invalid, abnormal }

class CalcManager {
  BracketExpressionTree _BETree = BracketExpressionTree();

  /// store the right before tree's tail Operator and tail Number, for the repetable equal calculation.
  BracketExpressionTree? _historyTree;

  /// this function will be called after the expression changed.
  /// state means some special case alert.
  /// state:
  ///   -1 -> single char deleted.
  ///   0 -> single char added.
  ///   1 -> expressionEquals() fired
  ///   2 -> bracket, the "()",  added.
  void Function(String exp, int state)? onExpressionChanged;

  void Function(ExpFault faultCase)? onInvalidRequest;

  int? _cursor;

  double? _result; // if null, this means that the result is not the normal double value.
  // invalid -> wrong expression, abnormal -> infinite or not-a-number

  ExpFault _abnormalCase = ExpFault.invalid;

  CalcManager() {}

  /// debug function. delete this when production!!
  void debug() {
    // _setExpression("12+34+(5.6*7.8)/9");
    _calculate();
  }

  // /// get expression from the manager.
  // String getExpression() {
  //   var showableExp = _BETree.toString().replaceAll("/", "÷");
  //   return showableExp;
  // }

  /// get the result from the manager.
  String getResult() {
    if (_result != null) {
      return _result.toString();
    } else {
      return "";
    }
  }

  /// evaluate the current _BETree, then fill the _result.
  /// also change the _abnormalCase if needed.
  void _calculate() {
    var evaluateResult = _BETree.evaluate();
    if (evaluateResult == null) {
      _result = null;
      _abnormalCase = ExpFault.invalid;
    } else if (evaluateResult.isNaN) {
      _result = null;
      _abnormalCase = ExpFault.abnormal;
    } else {
      _result = evaluateResult;
    }
  }

  /// check if some new cursor value is fittable in the expression length.
  ///
  /// Return
  /// - false : not fittable
  /// - true : fittable
  bool _isCursorFittable(int newCursor) {
    if (newCursor < 0 || newCursor > _BETree.length) {
      return false;
    } else {
      return true;
    }
  }

  void moveCursor(int newCursor) {
    if (_isCursorFittable(newCursor)) {
      _cursor = newCursor;
    } else {
      throw ArgumentError("CalcManager.moveCursor : non-fittable cursor position.");
    }
  }

  void disableCursor() {
    _cursor = null;
  }

  /// add 1 length char to the expression, then run the calculate
  /// running without validaiton of param
  void _addCharExpression(String inputChar, {int state = 0}) {
    if (_cursor == null) {
      return;
    }
    int cursor = _cursor!;
    try {
      BracketExpressionTree.magicalInsert(_BETree, cursor, inputChar);
    } on NotAllowedValueError {
      if (onInvalidRequest != null) {
        onInvalidRequest!(ExpFault.invalid);
      }
    }
    _calculate();
    _historyTree = null;
    if (onExpressionChanged != null) {
      onExpressionChanged!(_BETree.toString(), state);
    }
  }

  /// add "1", "2" , ..., "." to exp
  void addExp1() {
    _addCharExpression("1");
  }

  void addExp2() {
    _addCharExpression("2");
  }

  void addExp3() {
    _addCharExpression("3");
  }

  void addExp4() {
    _addCharExpression("4");
  }

  void addExp5() {
    _addCharExpression("5");
  }

  void addExp6() {
    _addCharExpression("6");
  }

  void addExp7() {
    _addCharExpression("7");
  }

  void addExp8() {
    _addCharExpression("8");
  }

  void addExp9() {
    _addCharExpression("9");
  }

  void addExp0() {
    _addCharExpression("0");
  }

  void addExpDot() {
    _addCharExpression(".");
  }

  /// add bracket "(" to the expression.
  void addExpBracket() {
    _addCharExpression("(", state: 2);
  }

  void addExpMul() {
    _addCharExpression("*");
  }

  void addExpDiv() {
    _addCharExpression("/");
  }

  void addExpPlus() {
    _addCharExpression("+");
  }

  void addExpMinus() {
    _addCharExpression("-");
  }

  /// delete the all of the expression
  void initializeExpression() {
    _BETree = BracketExpressionTree();
    _result = null;
    _abnormalCase = ExpFault.invalid;
    _historyTree = null;

    if (onExpressionChanged != null) {
      onExpressionChanged!(_BETree.toString(), 1);
    }
  }

  /// delete the one char from the expression.
  void deleteCharExpression() {
    if (_cursor == null || _cursor! < 1) {
      return;
    }
    int cursor = _cursor!;

    BracketExpressionTree.magicalDelete(_BETree, cursor);

    _calculate();
    _historyTree = null;
    if (onExpressionChanged != null) {
      onExpressionChanged!(_BETree.toString(), -1);
    }
  }

  /// delete the all string from the expression,
  /// then put the current _result into the expression again.
  /// if the expresion result is not the normal case, do nothing.
  ///
  /// reguards the _calculate() is called before.
  void expressionEquals() {
    if (_result == null) {
      if (onInvalidRequest != null) {
        onInvalidRequest!(_abnormalCase);
      }
      return;
    }

    // if _historyTree is not null, it means,
    // that the expressionEquals() was once called, then the other deletion, insertion, initialization of symbol,
    // was not happened.
    if (_historyTree != null) {
      _repeatedEquals();
      return;
    }

    // save the tail operator & number to the _historyTree. (can be null)
    _historyTree = BracketExpressionTree.newHistoricalTree(_BETree);

    // initialize the BETree
    _BETree = BracketExpressionTree.newNumericTree(doubleToString(_result!));

    if (onExpressionChanged != null) {
      onExpressionChanged!(_BETree.toString(), 1);
    }
  }

  /// drag the result from the historyTree, then re-calculate the result with,
  /// repeated tail Operator & number.
  ///
  /// e.g : 1+3+(5.3) -> expressionEquals() -> 9.3 -> repeatedEquals() -> (9.3+5.3 =) 14.6
  void _repeatedEquals() {
    if (_historyTree == null) {
      return;
    }
    _historyTree!.validate();
    double? evaluateResult = _historyTree!.evaluate();
    if (evaluateResult == null) {
      if (onInvalidRequest != null) {
        onInvalidRequest!(ExpFault.invalid);
      }
      return;
    } else if (evaluateResult.isNaN) {
      if (onInvalidRequest != null) {
        onInvalidRequest!(ExpFault.abnormal);
      }
      return;
    }

    // debugConsole([evaluateResult, _historyTree]);

    _result = evaluateResult;
    _BETree = BracketExpressionTree.newNumericTree(doubleToString(evaluateResult));

    _historyTree = BracketExpressionTree.newHistoricalTree(_historyTree!);

    if (onExpressionChanged != null) {
      onExpressionChanged!(_BETree.toString(), 1);
    }
  }
}
