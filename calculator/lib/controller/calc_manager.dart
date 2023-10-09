import 'dart:ffi';

import 'package:calculator/library/math_expression.dart';

enum ExpFault { invalid, abnormal }

class CalcManager {
  String _expression = "";
  int _cursor = 0;

  double? _result =
      null; // if null, this means that the result is not the normal double value.
  // invalid -> wrong expression, abnormal -> infinite or not-a-number

  ExpFault _abnormalCase = ExpFault.invalid;

  CalcManager() {}

  /// evaluate the current _expression, then fill the _result.
  /// also change the _abnormalCase if needed.
  void _calculate() {
    var evaluateResult = evaluateExpression(_expression);
    if (evaluateResult[1] == 0) {
      _result = evaluateResult[0];
    } else if (evaluateResult[1] == 1) {
      _result = null;
      _abnormalCase = ExpFault.invalid;
    } else {
      _result = null;
      _abnormalCase = ExpFault.abnormal;
    }
  }

  /// validate if the current _expression is valid format.
  bool _validate(String exp) {
    return validateExpression(exp);
  }

  /// check if some new cursor value is fittable in the expression length.
  ///
  /// Return
  /// - false : not fittable
  /// - true : fittable
  bool _isCursorFittable(int newCursor) {
    if (newCursor < 0 || newCursor > _expression.length) {
      return false;
    } else {
      return true;
    }
  }

  // /// check if current cursor value is fittable in the expression length
  // void _validateCursor() {
  //   if (!_isCursorFittable(_cursor)) {
  //     throw ArgumentError(
  //         "CalcManager._validateCursor : non-fittable cursor position.");
  //   }
  // }

  void moveCursor(int newCursor) {
    if (_isCursorFittable(newCursor)) {
      _cursor = newCursor;
    } else {
      throw ArgumentError(
          "CalcManager.moveCursor : non-fittable cursor position.");
    }
  }

  /// add 1 length char to the expression, then run the calculate
  /// running without validaiton of param
  void _addCharExpression(String numberChar) {
    _expression = _expression.substring(0, _cursor) +
        numberChar +
        _expression.substring(_cursor);
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

  void addExpDot() {
    _addCharExpression(".");
  }

  /// add bracket "(" to the expression.
  void addExpLeftBracket() {
    _addCharExpression("(");
  }

  /// add bracket ")" to the expression.
  void addExpRightBracket() {
    _addCharExpression(")");
  }

  /// delete the all of the expression
  void initializeExpression() {
    _expression = "";
    _result = null;
    _abnormalCase = ExpFault.invalid;
  }

  /// delete the one char from the expression.
  void deleteCharExpression() {
    _expression =
        _expression.substring(0, _cursor - 1) + _expression.substring(_cursor);
    _calculate();
  }

  /// delete the all string from the expression,
  /// then put the current _result into the expression again.
  /// if the expresion result is not the normal case, do nothing.
  ///
  /// reguard the _calculate() is called before.
  void getResult() {
    if (_result == null) {
      return;
    }

    _expression = _result.toString();
  }
}
