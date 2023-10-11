import 'dart:developer';
import '../library/list_stringify.dart';

enum Operator { plus, minus, mul, div }

extension OperatorToString on Operator {
  String get string {
    switch (this) {
      case Operator.plus:
        return "+";
      case Operator.minus:
        return "-";
      case Operator.div:
        return "/";
      case Operator.mul:
        return "*";
    }
  }
}

/// this class(or type) is for the primative double expression.
/// this class accept the expression like ".", "3.4.5",
/// Of course, the "3.5" and "345" forms too.
/// this class's instance string is immutable.
class NumberString {
  final String string;
  double? number;
  NumberString(this.string) {
    this.number = double.tryParse(string);
  }
}

class BracketExpressionTree {
  // Operator can be  enum that represent the +, -, *, / position.
  // number can be the type of NumberString, and the BracketExpressionTree.
  // result can be like : [1, +, 3.5, -, *, Tree(),  ...]
  //
  // (double literal must be converted from double to NumberString.)
  List<dynamic> _expComponentsList = [];
  List<dynamic> get expComponentsList {
    return _expComponentsList;
  }

  bool _isExpressionInvalid = false;

  BracketExpressionTree() {
    // this._noBracketExpression = noBracketExpression;
    // this._children = children;
  }

  /// DEPRACATED FUNCTION WARNING! this method is been depracated for now.
  /// parse expression and fill the _noBracketExpression, children property.
  /// without validation of param!
  void _parseExpressionNoValidation(String exp) {
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

  /// DEPRACATED FUNCTION WARNING! this method is been depracated for now.
  /// parse expression and fill the _noBracketExpression, children property.
  void _parseExpression(String exp) {
    // first validate the expression.
    if (validateExpression(exp) == false) {
      throw ArgumentError("invalid format expression has given.");
    }
    parseExpressionNoValidation(exp);
  }

  /// DEPRACATED FUNCTION WARNING! this method is been depracated for now.
  /// inspect the expression for if it's format is invalid.
  /// Return
  /// - false : invalid
  /// - true : valid
  static bool _validateExpression(String exp) {
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

  //region CRUD virtualize

  /// add the Operator to the current Tree's _expComponentsList.
  void _addOperator(Operator operator, int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._addOperator : index out of range");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.insert(index, operator);
    validate();
  }

  /// add the NumberString to the current Tree's _expComponentsList.
  void _addNumberString(NumberString number, int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._addNumberString : index out of range");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.insert(index, number);
    validate();
  }

  /// add the Tree to the current Tree's _expComponentsList.
  void _addTree(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._addTree : index out of range");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.insert(index, BracketExpressionTree());
    validate();
  }

  /// delete the single operator.
  void _deleteOperator(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._deleteOperator : index out of range");
    }
    // check if the target index is the Operator.
    if (!(_expComponentsList[index] is Operator)) {
      throw ArgumentError(
          "BracketExpressionTree._deleteOperator : non-operator value cannot be selected.");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.removeAt(index);
    validate();
  }

  // delete the whole one NumberString.
  void _deleteNumberString(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._deleteNumberString : index out of range");
    }
    // check if the target index is the Operator.
    if (!(_expComponentsList[index] is NumberString)) {
      throw ArgumentError(
          "BracketExpressionTree._deleteNumberString : non-NumberString value cannot be selected.");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.removeAt(index);
    validate();
  }

  // delete the whole Tree.
  void _deleteTree(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._deleteTree : index out of range");
    }
    // check if the target index is the Operator.
    if (!(_expComponentsList[index] is BracketExpressionTree)) {
      throw ArgumentError(
          "BracketExpressionTree._deleteTree : non-BracketExpressionTree value cannot be selected.");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.removeAt(index);
    validate();
  }

  // change the NumberString value to the another NumberString value.
  void _updateNumberString(int index, NumberString newNumber) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._updateNumberString : index out of range");
    }

    // check if the target is the NumberString.
    var target = _expComponentsList[index];
    if (!(target is NumberString)) {
      throw ArgumentError(
          "BracketExpressionTree._updateNumberString : non-NumberString value cannot be selected.");
    }

    // check if the new value is not the abnormal NumberString value.
    if (newNumber.number == double.nan ||
        newNumber.number == double.infinity ||
        newNumber.number == double.negativeInfinity ||
        newNumber.number == null) {
      throw ArgumentError(
          "BracketExpressionTree._updateNumberString : abnormal number value (eg. nan, inf, invalid expression) is now allowed.");
    }

    // change operator to the current compList. then validate the current Tree.
    _expComponentsList[index] = newNumber;
    validate();
  }

  // change the component (child) Tree's _expComponentsList to the another List.
  void _updateTree(int index, List newExpCompList) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList",
          "BracketExpressionTree._updateTree : index out of range");
    }

    // check if the target is the Tree.
    var target = _expComponentsList[index];
    if (!(target is BracketExpressionTree)) {
      throw ArgumentError(
          "BracketExpressionTree._updateTree : non-BracketExpressionTree value cannot be selected.");
    }

    // check if the new List only contains the NumberString, Operator, and the BracketExpressionTree.
    newExpCompList.forEach((element) {
      if (!(element is NumberString ||
          element is Operator ||
          element is BracketExpressionTree)) {
        throw ArgumentError(
            "BracketExpressionTree._updateTree : value that is not the NumberString, Operator, BracketExpressionTree, is now allowed.");
      }
    });

    // change operator to the current compList. then validate the current Tree.
    _expComponentsList[index]._expComponentsList = newExpCompList;
    validate();
  }

  //endregion

  //region override primative functuation

  static String doubleToString(double number) {
    return number.toString();
  }

  @override
  String toString() {
    String currentString = "";

    _expComponentsList.forEach((element) {
      if (element is BracketExpressionTree) {
        // if element is Tree,
        currentString += "(" + element.toString() + ")";
      } else if (element is Operator) {
        // if element is Operator,
        currentString += element.string;
      } else {
        // if element is NumberString,
        currentString += element.string;
      }
    });

    return currentString;
  }

  int get length {
    int currentLength = 0;
    _expComponentsList.forEach((element) {
      if (element is BracketExpressionTree) {
        // if element is Tree,
        currentLength += element.length + 2;
      } else if (element is Operator) {
        // if element is Operator,
        currentLength += 1;
      } else {
        // if element is NumberString,
        String elementToString = element.string;
        currentLength += elementToString.length;
      }
    });
    return currentLength;
  }

  //endregion

  //region validation and evaluation

  /// inspect the current _numberList, _operatorList.
  /// if fallacy has found, change the current _isExpressionInvalid to false.
  /// if fallacy not found, change the current _isExpressionInvalid to true.
  /// this function just can change the _isExpressionInvalid value only. can't change the other parameters.
  ///
  /// this function do the tight-validation.
  /// it will not allow the empty numberList (ex : the "()" ),
  /// not allow the missing target Operators (ex : the "3*5+"), and other diverse fallacy cases.
  void validate() {
    // check if the number(+ the BracketExpressionTree object) and the operator appears taking each other's turn.
    // if the operator is ont the index 0, or the violation of the ordering appears,
    // change _isExpressionInvalid false.
    if (_expComponentsList.length == 0 || _expComponentsList[0] is Operator) {
      _isExpressionInvalid = false;
      return;
    }
    bool isOperatorAppeared = false;
    for (int i = 0; i < _expComponentsList.length; i++) {
      var component = _expComponentsList[i];
      if (component is Operator) {
        // current target component is the operator.
        if (isOperatorAppeared == true) {
          _isExpressionInvalid = false;
          return;
        } else {
          isOperatorAppeared = true;
        }
      } else {
        // current target component is the number (or Tree).
        if (isOperatorAppeared == true) {
          isOperatorAppeared = false;
        } else {
          _isExpressionInvalid = false;
          return;
        }
      }
    }

    isOperatorAppeared = true;
    return;
  }

  /// evaluate the current tree then return the double value of expression.
  /// Return
  /// - double : worked properly
  /// - double.nan : inf, -inf, or nan returned ever once.
  ///
  /// this function do the tight-validation.
  /// it will not calculate the empty numberList (ex : the "()" ),
  /// not calculate the missing target Operators (ex : the "3*5+"), and other diverse fallacy cases.
  /// if fallacy appeared, this function just return the double.nan!
  double evaluate() {
    // if this Tree's _isExpressionInvalid is false, stop the evaluation.
    if (_isExpressionInvalid == false) {
      return double.nan;
    }

    // evaluate the some numberList elements if they are the BracketExpressionTree instance.
    // also convert the NumberString to double if possible.
    // if not, return the double.nan right away.
    var evaluatedList = [];
    for (int i = 0; i < _expComponentsList.length; i++) {
      var child = _expComponentsList[i];
      double evaluatedValue;
      if (child is BracketExpressionTree) {
        evaluatedValue = child.evaluate();
      } else if (child is NumberString) {
        if (child.number == null) {
          return double.nan;
        }
        evaluatedValue = child.number!;
      } else {
        evaluatedList.add(child);
        continue;
      }
      if (evaluatedValue == double.nan ||
          evaluatedValue == double.infinity ||
          evaluatedValue == double.negativeInfinity) {
        return double.nan;
      }
      evaluatedList.add(evaluatedValue);
    }

    // seperate the numbers and the operators.
    List<double> numberList = [];
    List<Operator> operatorList = [];
    for (int i = 0; i < evaluatedList.length; i++) {
      var target = evaluatedList[i];
      if (target is Operator) {
        operatorList.add(target);
      } else {
        numberList.add(target);
      }
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
      if (targetOperator == Operator.mul || targetOperator == Operator.div) {
        var numberBefore = numberList[i];
        var numberAfter = numberList[i + 1];
        numberList.removeAt(i + 1);
        if (targetOperator == Operator.mul) {
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
      if (targetOperator == Operator.plus) {
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

  // print the noBracketExpression and the children list.
  void debugLogSelf() {
    log("current number list : ");
    log("[");
    _expComponentsList.forEach((comp) {
      if (comp is BracketExpressionTree) {
        comp.debugLogSelf();
        log(",");
      } else if (comp is Operator) {
        log(comp.string);
      } else {
        log(doubleToString(comp));
      }
    });
    log("]");
  }
  //endregion

  /// this function finds the BracketExpressionTree to reference,
  /// index of BracketExpressionTree.expComponentsList to adjust.
  /// [targetPos] is the virtual index, assuming that original tree is stringified.
  /// return the 
  /// 
  /// ?[BracketExpressionTree targetReference, int targetIndex, int insertPos].
  ///
  /// for example, let the [tree].toString() = "12+34-(67/89)", and the [cursor] = 8,
  /// it means that the target index is "12+34-(6<here>7/89)", insert pos is 6<pos = 1>7, and the return value is :
  /// [ tree.expComponentsList[5], 0, 1]
  ///
  /// if cursor is too big, so that function can't find the insertion target, then return just null.
  static List? _inspectTargetTree(BracketExpressionTree tree, int targetPos) {
    int lengthStack =
        0; // this value will represent the temporary target index within the whole expression string.
    var treeCompList = tree.expComponentsList;

    for (int i = 0; i < treeCompList.length; i++) {
      var target = treeCompList[i];
      if (target is BracketExpressionTree) {
        // input targetPos is,  targetPos_current - lengthStack - 1
        // -1 is for the bracket.
        //
        // for example, if you want to find the cursor=7 in :
        //      ...6 char before...(<here>12+3+9)
        // your current lengthStack = 6, and cursor = 7.
        // if you direct correctly the "12", you must put the targetPos = 0. (the 7 - 6 - 1)
        var inspectResult =
            _inspectTargetTree(target, targetPos - lengthStack - 1);
        if (inspectResult != null) {
          return inspectResult;
        } else {
          lengthStack += target.length + 2; // 2 is the bracket length.
        }
      } else if (target is Operator) {
        lengthStack += 1;
      } else {
        String targetString = target.string;
        lengthStack += targetString.length;
      }

      // if targetPos is lower then or equals to the lengthStack, current routine is the answer.
      if (targetPos <= lengthStack) {
        String resultString = target.string;
        // make the inserted result
        if (target is BracketExpressionTree) {
          // in case of Tree.
          // this means that cursor is on the last bracket's after like :
          //      "...+34)<here>"
          return [tree, i, target.length - (lengthStack - targetPos)]
        } else if (target is Operator) {
          // in case of target is Operator
          // resultString = target.string;
          return [tree, i, 1 - (lengthStack - targetPos)];
        } else {
          // in case of target is NumberString
          int insertPos = resultString.length - (lengthStack - targetPos);
          // resultString = resultString.substring(0, insertPos) +
          //     resultString.substring(insertPos);
          // var createdNum = NumberString(resultString);
          return [tree, i, insertPos];
        }
      }
    }

    // no result found.
    return null;
  }
  static String InsertAllowableString = "1234567890.*/+-(";

  /// magical static function, that can insert the input char into the tree.
  /// can recept the :
  ///   "1234567890.", "*/+-", and "("
  ///
  /// [cursor] is the virtual index, assuming that original tree is stringified.
  ///
  /// for example, let the [tree].toString() = "12+34-(67/89)", and the [cursor] = 8, inputChar is "."
  /// it means that the target position is "12+34-(6<here>7/89)", and you must correct the tree like :
  /// tree.expComponentsList[5].expComponentsList[0] = 6.7
  static void magicalInsert(
      BracketExpressionTree tree, int cursor, String inputChar) {
    // validation of param.
    // inputChar must be inside of the allowable list string.
    if (!InsertAllowableString.contains(inputChar)) {
      throw ArgumentError(
          "BracketExpressionTree.magicalInsert : inputChar must be one of the \"1234567890.*/+-(\". ");
    }

    // find the target that we want to handle.
    var inspectationResult = _inspectTargetTree(tree, cursor);
    if (inspectationResult == null) {
      throw Exception("BracketExpressionTree.magicalInsert : unexpected result occoured.");
    }

    // determine which action we have to avoke, case by the target
    BracketExpressionTree targetTree = inspectationResult[0];
    int elementIndex = inspectationResult[1];
    int innerInsertPos = inspectationResult[2];
    var targetElement = targetTree._expComponentsList[elementIndex];

    Type inputCharType;
    if ("1234567890.".contains(inputChar)) {
      inputCharType = NumberString;
    } else if ("+-*/".contains(inputChar)) {
      
    }

    if (targetElement is NumberString) {
      String targetElementString = targetElement.string;
      String updatedString = targetElementString.substring(0,innerInsertPos) + inputChar + targetElementString.substring(innerInsertPos);
      targetTree._updateNumberString(elementIndex, NumberString(updatedString));
    } else if (targetElement is Operator) {

    }



    // if ("1234567890.".contains(inputChar)) {
    //   // this means we have to try to update the number.
    // }
  }
}
