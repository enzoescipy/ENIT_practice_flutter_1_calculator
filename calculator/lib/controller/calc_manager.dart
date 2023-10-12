import 'dart:ffi';
import 'dart:developer';

import 'package:calculator/library/math_expression.dart';

enum ExpFault { invalid, abnormal }

class CalcManager {
  BracketExpressionTree _BETree = BracketExpressionTree();

  // this function will be called after the expression changed.
  void Function(String)? onExpressionChanged;

  int? _cursor;

  double?
      _result; // if null, this means that the result is not the normal double value.
  // invalid -> wrong expression, abnormal -> infinite or not-a-number

  ExpFault _abnormalCase = ExpFault.invalid;

  // this function will be called after some adds applied for the expression.
  void Function()? onAdd;

  // this function will be called after some deletes applied for the expression.
  void Function()? onDelete;

  CalcManager() {}

  /// debug function. delete this when production!!
  void debug() {
    // _setExpression("12+34+(5.6*7.8)/9");
    _calculate();
  }

  /// get expression from the manager.
  String getExpression() {
    var showableExp = _BETree.toString().replaceAll("/", "÷");
    return showableExp;
  }

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
    } else if (evaluateResult == double.nan) {
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
      throw ArgumentError(
          "CalcManager.moveCursor : non-fittable cursor position.");
    }
  }

  void disableCursor() {
    _cursor = null;
  }

  /// add 1 length char to the expression, then run the calculate
  /// running without validaiton of param
  void _addCharExpression(String inputChar) {
    if (_cursor == null) {
      return;
    }
    int cursor = _cursor!;
    BracketExpressionTree.magicalInsert(_BETree, cursor, inputChar);
    if (onAdd != null) {
      onAdd!();
    }
    _calculate();
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
    _addCharExpression("(");
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
  }

  /// delete the one char from the expression.
  void deleteCharExpression() {
    if (_cursor == null || _cursor! < 1) {
      return;
    }
    int cursor = _cursor!;
    BracketExpressionTree.magicalDelete(_BETree, cursor);
    if (onDelete != null) {
      onDelete!();
    }
    _calculate();
  }

  /// delete the all string from the expression,
  /// then put the current _result into the expression again.
  /// if the expresion result is not the normal case, do nothing.
  ///
  /// reguard the _calculate() is called before.
  void expressionEquals() {
    if (_result == null) {
      return;
    }
    _BETree = BracketExpressionTree.newNumericTree(_result.toString());
  }
}
