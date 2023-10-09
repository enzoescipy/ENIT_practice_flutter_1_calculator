import 'dart:developer';
import '../library/list_stringify.dart';

/// evaluate expression then return the result with status integer.
/// however, this function bellieves that this expression's structure is valid.
/// Return
/// [double result, int status]
/// - result = double : evaluation succeed
/// - result = double.nan : evaluation failed
/// - status = 0 : evaluation succeed
/// - status = -1 : durning evaluation, at least one part of the expression's value is inf, -inf or nan.
List evaluateExpressionWithoutValidation(String exp) {
  var expTree = BracketExpressionTree();
  expTree.parseExpressionNoValidation(exp);
  final evaluatedValue = expTree.evaluate();
  if (evaluatedValue == double.nan) {
    return [double.nan, -1];
  } else {
    return [evaluatedValue, 0];
  }
}

/// evaluate expression then return the result with status integer.
/// Return
/// [double result, int status]
/// - result = double : evaluation succeed
/// - result = double.nan : evaluation failed
/// - status = 0 : evaluation succeed
/// - status = -1 : durning evaluation, at least one part of the expression's value is inf, -inf or nan.
/// - status = 1 : given expression's format is invalid.
List evaluateExpression(String exp) {
  final isValid = BracketExpressionTree.validateExpression(exp);
  if (isValid == false) {
    return [double.nan, 1];
  }
  return evaluateExpressionWithoutValidation(exp);
}

/// same function as BracketExpressionTree.validateExpression
bool validateExpression(String exp) {
  return BracketExpressionTree.validateExpression(exp);
}

class BracketExpressionTree {
  // if expression has consecutive operators or not having the target number,
  // then place the each BracketExpressionTree.children between the two operators,
  // in order.
  //
  // Example :
  // "2+3" => 5
  // "+" => children[0] + children[1]
  // "2+*5" => 2 + children[0] * 5
  String _noBracketExpression = "";
  List<BracketExpressionTree> _children = [];

  BracketExpressionTree(
      [String noBracketExpression = "",
      List<BracketExpressionTree> children = const []]) {
    this._noBracketExpression = noBracketExpression;
    this._children = children;
  }

  /// parse expression and fill the _noBracketExpression, children property.
  /// without validation of param!
  void parseExpressionNoValidation(String exp) {
    /// get the starting index of expression, which include the starting bracket.
    /// WARNING : must give the starting index representing the expression WITH the starting bracket.
    /// ex : 3+"(3+5*(2))"+6 -> 2
    /// return the parsed BracketExpressionTree, and the ending index of parsed substring.
    /// return[0] : BracketExpressionTree
    /// return[1] : int ending_index
    /// ex : 3+"(3+5*(2))"+6 -> 10
    List recursiveDetectExpression(int start) {
      // slice then remove the first bracket
      // log(start.toString()); //debug
      String slicedExp = exp.substring(start + 1);

      // check if "(" contains
      if (!slicedExp.contains("(")) {
        int firstBracketOccours = slicedExp.indexOf(")");
        return [
          BracketExpressionTree(
              slicedExp.substring(0, firstBracketOccours), []),
          firstBracketOccours
        ];
      }

      String noBracketExpression = "";
      List<BracketExpressionTree> childrenList = [];
      for (int i = 1; i < exp.length; i++) {
        String targetChar = slicedExp[i];
        if (targetChar == "(") {
          // in case of starting bracket occours
          var parsedResult = recursiveDetectExpression(start + i);
          childrenList.add(parsedResult[0]);
          i = parsedResult[
              1]; // automatically start from after the parsed result's ending.
        } else if (targetChar == ")") {
          // in case of current depth bracket ends.
          return [
            BracketExpressionTree(noBracketExpression, childrenList),
            start + i
          ];
        } else {
          // in case of Operator like +, -, *, / occours.
          noBracketExpression += targetChar;
        }
      }

      // if no ")" found, throw err.
      throw Exception(
          "BracketExpressionTree.parseExpression : something wrong with inpecting the expression...");
    }

    // fix the expression to ensure the proper parsing.
    exp = "(" + exp + ")";

    BracketExpressionTree resultTree = recursiveDetectExpression(0)[0];

    _children = resultTree._children;
    _noBracketExpression = resultTree._noBracketExpression;
  }

  /// parse expression and fill the _noBracketExpression, children property.
  void parseExpression(String exp) {
    // first validate the expression.
    if (validateExpression(exp) == false) {
      throw ArgumentError("invalid format expression has given.");
    }
    parseExpressionNoValidation(exp);
  }

  /// inspect the expression for if it's format is invalid.
  /// Return
  /// - false : invalid
  /// - true : valid
  static bool validateExpression(String exp) {
    // put the bracket to the expression, matching with BracketExpressionTree.parseExpression
    exp = "(" + exp + ")";

    // build the whitelists
    final whiteListNumbers = "1234567890";
    final whiteListStringOperators = "-+*/";
    final whitelist = whiteListStringOperators + whiteListNumbers + "." + "()";

    // no number contains, return false.
    bool isExpHasNumber = false;
    for (int i = 0; i < whiteListNumbers.length; i++) {
      var numchar = whiteListNumbers[i];
      if (exp.contains(numchar)) {
        isExpHasNumber = true;
      }
    }
    if (isExpHasNumber == false) {
      return false;
    }
    
    // validate if expression ONLY contains the whitelist characters.
    for (int i = 0; i < exp.length; i++) {
      var targetChar = exp[i];
      if (!whitelist.contains(targetChar)) {
        return false;
      }
    }

    // validate if expression's operators have the proper target numbers.
    for (int i = 0; i < exp.length; i++) {
      var targetChar = exp[i];
      if ("*/".contains(targetChar)) {
        // for the case of *, /
        // if operator index is 0 or last, automatically this is fault.
        if (i == 0 || i == exp.length - 1) {
          return false;
        }

        // get the front & back chars.
        final front = exp[i - 1];
        final back = exp[i + 1];

        // if operator's front and back are not the number or the prper bracket, return false.
        if (((whiteListNumbers + "." + ")").contains(front) &&
                (whiteListNumbers + "." + "(").contains(back)) ==
            false) {
          return false;
        }
      } else if ("+-".contains(targetChar)) {
        // for the case of +, -
        // if operator index is 0 or last, automatically this is fault.
        if (i == 0 || i == exp.length - 1) {
          return false;
        }

        // if operator's front and back are not the number or the prper bracket, it is not the operator.
        // if sign's front are not the number or the proper bracket, it is not the sign either.
        // so, return false.
        if ((whiteListNumbers + "." + "(").contains(exp[i + 1]) == false) {
          return false;
        }
      }
    }

    // if "." do not have any number besides, return false.
    for (int i = 0; i < exp.length; i++) {
      var targetChar = exp[i];
      if (targetChar != ".") {
        continue;
      }

      if (i == 0 && !whiteListNumbers.contains(exp[i + 1])) {
        return false;
      } else if (i == exp.length - 1 &&
          !whiteListNumbers.contains(exp[i - 1])) {
        return false;
      } else if (whiteListNumbers.contains(exp[i + 1]) == false &&
          whiteListNumbers.contains(exp[i - 1]) == false) {
        return false;
      }
    }

    // validate if expression's opening & closing bracket's number is not matching to each other.
    if (")".allMatches(exp).length != "(".allMatches(exp).length) {
      return false;
    }

    // validate if brackets' arrangements are in proper state.
    // // extract only brackets.
    String bracketOnlyExp = "";
    for (int i = 0; i < exp.length; i++) {
      var targetChar = exp[i];
      if (targetChar == "(" || targetChar == ")") {
        bracketOnlyExp += targetChar;
      }
    }

    // // keep removes the pair of brackets then check if there's nothing left.
    while (bracketOnlyExp.contains("()")) {
      final indexBracket = bracketOnlyExp.indexOf("()");
      bracketOnlyExp = bracketOnlyExp.substring(0, indexBracket) +
          bracketOnlyExp.substring(indexBracket + 2);
    }
    if (bracketOnlyExp.length != 0) {
      return false;
    }

    // validation passed.
    return true;
  }

  /// evaluate the current tree then return the double value of expression.
  /// Return
  /// - double : worked properly
  /// - double.nan : inf, -inf, or nan returned ever once.
  double evaluate() {
    var evaluateChildren = [];
    // evaluate the children
    for (int i = 0; i < _children.length; i++) {
      var child = _children[i];
      var evaluated = child.evaluate();
      if (evaluated == double.nan ||
          evaluated == double.infinity ||
          evaluated == double.negativeInfinity) {
        return double.nan;
      }
      evaluateChildren.add(evaluated);
    }

    // seperate the numbers and the operators.
    List<double> numberList = [];
    String literalDouble = "";
    List<String> operatorList = [];
    final whiteListNumbers = "1234567890.";
    for (int i = 0; i < _noBracketExpression.length; i++) {
      var target = _noBracketExpression[i];
      final isSign = "+-".contains(target) &&
          (i != _noBracketExpression.length - 1 &&
              whiteListNumbers.contains(_noBracketExpression[i + 1])) &&
          (i == 0 || !whiteListNumbers.contains(_noBracketExpression[i - 1]));
      if (whiteListNumbers.contains(target) || isSign) {
        // if target is the literal number part, then append that to the literalDouble var.
        literalDouble += target;
      } else {
        // if target is operater,
        if (literalDouble.length != 0) {
          // and if literalDouble var is not empty, put it into the numberlist.
          numberList.add(double.parse(literalDouble));
          literalDouble = "";
        } else {
          // and if literalDouble var is empty, it means that we have to put the evaluate children instead of literal.
          numberList.add(evaluateChildren[0]);
          evaluateChildren.removeAt(0);
        }
        operatorList.add(target);
      }
    }

    // pick up the lefted number
    if (literalDouble.length != 0 && evaluateChildren.length != 0 ||
        evaluateChildren.length > 1) {
      throw Exception(
          "BracketExpressionTree.evaluate : something unexpected happened durning the seperation of the numbers and the operators");
    } else if (literalDouble.length != 0) {
      // and if literalDouble var is not empty, put it into the numberlist.
      numberList.add(double.parse(literalDouble));
    } else if (evaluateChildren.length != 0) {
      numberList.add(evaluateChildren[0]);
    }

    // //debug
    // log(_noBracketExpression);
    // log(ListStringify.list1DStringify(numberList));
    // log(ListStringify.list1DStringify(operatorList));
    // log(ListStringify.list1DStringify(evaluateChildren));
    // //debug

    // first calculate the *, /.
    int i = 0;
    while (i < operatorList.length) {
      var targetOperator = operatorList[i];
      if (targetOperator == "*" || targetOperator == "/") {
        var numberBefore = numberList[i];
        var numberAfter = numberList[i + 1];
        numberList.removeAt(i + 1);
        if (targetOperator == "*") {
          numberList[i] = numberBefore * numberAfter;
        } else {
          numberList[i] = numberBefore / numberAfter;
        }
        operatorList.removeAt(i);
      } else {
        i++;
      }
    }

    // then calculate the +, -
    double resultDouble = numberList[0];
    // //debug
    // log(_noBracketExpression);
    // log(ListStringify.list1DStringify(numberList));
    // log(ListStringify.list1DStringify(operatorList));
    // //debug
    for (int i = 0; i < operatorList.length; i++) {
      var targetOperator = operatorList[i];
      if (targetOperator == "+") {
        resultDouble += numberList[i + 1];
      } else {
        resultDouble -= numberList[i + 1];
      }
    }

    // return the result.
    if (resultDouble == double.nan ||
        resultDouble == double.infinity ||
        resultDouble == double.negativeInfinity) {
      return double.nan;
    }
    return resultDouble;
  }

  void parseExpression_debug(String exp) {
    parseExpression(exp);
    debugLogSelf();
  }

  // print the noBracketExpression and the children list.
  void debugLogSelf() {
    log("current noBracketExpression : ${_noBracketExpression}");
    log("current children list : ");
    log("[");
    _children.forEach((child) {
      child.debugLogSelf();
      log(",");
    });
    log("]");
  }
}
