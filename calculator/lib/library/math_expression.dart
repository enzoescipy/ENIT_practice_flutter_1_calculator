import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:calculator/library/debugConsole.dart';
import '../library/list_stringify.dart';

class NotAllowedValueError implements Exception {
  final String? msg;

  const NotAllowedValueError([this.msg]);

  @override
  String toString() => msg ?? 'NotAllowedValue';
}

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

/// operator setter.
Operator _getOperator(String inputChar) {
  switch (inputChar) {
    case "+":
      return Operator.plus;
    case "-":
      return Operator.minus;
    case "/":
      return Operator.div;
    case "*":
      return Operator.mul;
  }
  throw ArgumentError("getOperator : unexpected input given.");
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

  /// boolean for verifying if tree is not having mathmetical fallacies.
  /// false -> no fallacy
  bool _isExpressionInvalid = true;

  /// reference of mother, used when the collapse() of self needed.
  BracketExpressionTree? _mother;
  BracketExpressionTree get mother {
    if (_mother != null) {
      return _mother!;
    } else {
      throw Exception("BracketExpressionTree.mother : top node of tree cannot get its mother.");
    }
  }

  /// new the Tree and place it inside the this._expComponentsList at [index].
  void _newTree(int index) {
    if (!(0 <= index || index <= _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree.magicalInsert : out of range cursor.");
    }
    var newTreeInstance = BracketExpressionTree();
    newTreeInstance._mother = this;
    _expComponentsList.insert(index, newTreeInstance);
  }

  /// remove the tree from its mother and spread the inner elements.
  void collapse() {
    if (mother == null) {
      throw Exception("BracketExpressionTree.collapse : top node of tree cannot be collapse.");
    }

    List motherList = mother.expComponentsList;
    int myIndex = motherList.indexOf(this);
    motherList.removeAt(myIndex);
    motherList.insertAll(myIndex, expComponentsList);

    mother.validate();
  }

  BracketExpressionTree() {
    // this._noBracketExpression = noBracketExpression;
    // this._children = children;
  }

  // #region CRUD virtualize

  /// add the Operator to the current Tree's _expComponentsList.
  void _addOperator(Operator operator, int index) {
    // validation of param
    if (!(0 <= index && index <= _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._addOperator : index out of range");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.insert(index, operator);
    validate();
  }

  /// add the NumberString to the current Tree's _expComponentsList.
  void _addNumberString(NumberString number, int index) {
    // if empty number has given, skip the procedure.
    if (number.string.isEmpty) {
      return;
    }
    // validation of param
    if (!(0 <= index && index <= _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._addNumberString : index out of range");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.insert(index, number);
    validate();
  }

  /// add the Tree to the current Tree's _expComponentsList.
  void _addTree(int index) {
    // validation of param
    if (!(0 <= index && index <= _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._addTree : index out of range");
    }

    // put operator to the current compList. then validate the current Tree.
    _newTree(index);
    validate();
  }

  /// delete the single operator.
  void _deleteOperator(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._deleteOperator : index out of range");
    }
    // check if the target index is the Operator.
    if (!(_expComponentsList[index] is Operator)) {
      throw ArgumentError("BracketExpressionTree._deleteOperator : non-operator value cannot be selected.");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.removeAt(index);
    validate();
  }

  // delete the whole one NumberString.
  void _deleteNumberString(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._deleteNumberString : index out of range");
    }
    // check if the target index is the Operator.
    if (!(_expComponentsList[index] is NumberString)) {
      throw ArgumentError("BracketExpressionTree._deleteNumberString : non-NumberString value cannot be selected.");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.removeAt(index);
    validate();
  }

  // delete the whole Tree.
  void _deleteTree(int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._deleteTree : index out of range");
    }
    // check if the target index is the Operator.
    if (!(_expComponentsList[index] is BracketExpressionTree)) {
      throw ArgumentError("BracketExpressionTree._deleteTree : non-BracketExpressionTree value cannot be selected.");
    }

    // put operator to the current compList. then validate the current Tree.
    _expComponentsList.removeAt(index);
    validate();
  }

  // change the NumberString value to the another NumberString value.
  void _updateNumberString(NumberString newNumber, int index) {
    // if empty number has given, change the procedure to the deletetion..
    if (newNumber.string.isEmpty) {
      _deleteNumberString(index);
      return;
    }
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._updateNumberString : index out of range");
    }

    // check if the target is the NumberString.
    var target = _expComponentsList[index];
    if (!(target is NumberString)) {
      throw ArgumentError("BracketExpressionTree._updateNumberString : non-NumberString value cannot be selected.");
    }

    // check if the new value is not the abnormal NumberString value.
    if (newNumber.number == null || newNumber.number!.isNaN || newNumber.number!.isInfinite) {
      throw NotAllowedValueError("BracketExpressionTree._updateNumberString : abnormal number value (eg. nan, inf, invalid expression) is now allowed.");
    }

    // change operator to the current compList. then validate the current Tree.
    _expComponentsList[index] = newNumber;
    validate();
  }

  // change the component (child) Tree's _expComponentsList to the another List.
  void _updateTree(List newExpCompList, int index) {
    // validation of param
    if (!(0 <= index && index < _expComponentsList.length)) {
      throw RangeError.index(index, _expComponentsList, "_expComponentsList", "BracketExpressionTree._updateTree : index out of range");
    }

    // check if the target is the Tree.
    var target = _expComponentsList[index];
    if (!(target is BracketExpressionTree)) {
      throw ArgumentError("BracketExpressionTree._updateTree : non-BracketExpressionTree value cannot be selected.");
    }

    // check if the new List only contains the NumberString, Operator, and the BracketExpressionTree.
    newExpCompList.forEach((element) {
      if (!(element is NumberString || element is Operator || element is BracketExpressionTree)) {
        throw ArgumentError("BracketExpressionTree._updateTree : value that is not the NumberString, Operator, BracketExpressionTree, is now allowed.");
      }
    });

    // change operator to the current compList. then validate the current Tree.
    _expComponentsList[index]._expComponentsList = newExpCompList;
    validate();
  }

  // #endregion

  // #region override primative functuation

  static String doubleToString(double number) {
    return number.toString();
  }

  @override
  String toString() {
    String currentString = "";

    _expComponentsList.forEach((element) {
      if (element is BracketExpressionTree) {
        // if element is Tree,
        currentString += element.toString();
      } else if (element is Operator) {
        // if element is Operator,
        currentString += element.string;
      } else {
        // if element is NumberString,
        currentString += element.string;
      }
    });

    if (_mother == null) {
      return currentString;
    } else {
      return "($currentString)";
    }
  }

  int get length {
    int currentLength = 0;
    _expComponentsList.forEach((element) {
      if (element is BracketExpressionTree) {
        // if element is Tree,
        currentLength += element.length;
      } else if (element is Operator) {
        // if element is Operator,
        currentLength += 1;
      } else {
        // if element is NumberString,
        String elementToString = element.string;
        currentLength += elementToString.length;
      }
    });
    if (_mother == null) {
      return currentLength;
    } else {
      return currentLength + 2;
    }
  }

  // #endregion

  // #region validation and evaluation

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
    // change _isExpressionInvalid true.
    if (_expComponentsList.length == 0 || _expComponentsList[0] is Operator || _expComponentsList[_expComponentsList.length - 1] is Operator) {
      _isExpressionInvalid = true;
      // debugConsole("fallacy 0");
      return;
    }
    bool isOperatorAppeared = true;
    for (int i = 0; i < _expComponentsList.length; i++) {
      var component = _expComponentsList[i];
      if (component is Operator) {
        // current target component is the operator.
        if (isOperatorAppeared == true) {
          _isExpressionInvalid = true;
          // debugConsole("fallacy 1");
          return;
        } else {
          isOperatorAppeared = true;
        }
      } else {
        // current target component is the number (or Tree).
        if (isOperatorAppeared == true) {
          isOperatorAppeared = false;
        } else {
          _isExpressionInvalid = true;
          // debugConsole("fallacy 2");
          return;
        }
      }
    }

    // debugConsole("good 0");
    _isExpressionInvalid = false;
    return;
  }

  /// evaluate the current tree then return the double value of expression.
  /// Return
  /// - double : worked properly
  /// - double.nan : inf, -inf, or nan returned ever once.
  /// - null : invalid input
  ///
  /// this function do the tight-validation.
  /// it will not calculate the empty numberList (ex : the "()" ),
  /// not calculate the missing target Operators (ex : the "3*5+"), and other diverse fallacy cases.
  /// if fallacy appeared, this function  return null.
  double? evaluate() {
    // if this Tree's _isExpressionInvalid is false, stop the evaluation.
    if (_isExpressionInvalid == true) {
      return null;
    }

    // evaluate the some numberList elements if they are the BracketExpressionTree instance.
    // also convert the NumberString to double if possible.
    // if not, return the double.nan right away.
    var evaluatedList = [];
    for (int i = 0; i < _expComponentsList.length; i++) {
      var child = _expComponentsList[i];
      double evaluatedValue;
      if (child is BracketExpressionTree) {
        var evaluateResult = child.evaluate();
        if (evaluateResult == null) {
          return null;
        }
        evaluatedValue = evaluateResult;
      } else if (child is NumberString) {
        if (child.number == null) {
          return null;
        }
        evaluatedValue = child.number!;
      } else {
        evaluatedList.add(child);
        continue;
      }
      if (evaluatedValue.isNaN || evaluatedValue.isInfinite) {
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
    // // debugConsole(_noBracketExpression);
    // // debugConsole(ListStringify.list1DStringify(numberList));
    // // debugConsole(ListStringify.list1DStringify(operatorList));
    // // debugConsole(ListStringify.list1DStringify(evaluateChildren));
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
    // // debugConsole(_noBracketExpression);
    // // debugConsole(ListStringify.list1DStringify(numberList));
    // // debugConsole(ListStringify.list1DStringify(operatorList));
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
    if (resultDouble.isNaN || resultDouble.isInfinite) {
      return double.nan;
    }
    return resultDouble;
  }

  // #endregion

  // #region magical & non-magical static method

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
  /// for the same reason, if tree is empty, then return null too.
  static List? _inspectTargetTree(BracketExpressionTree tree, int targetPos) {
    // debugConsoleNoTrace(["get is", tree.debugString(), targetPos]);
    // if tree is empty, return the null.
    if (tree.expComponentsList.length == 0) {
      return null;
    }
    // this value will represent the temporary target index within the whole expression string.
    int lengthStack = 0;
    var treeCompList = tree.expComponentsList;

    for (int i = 0; i < treeCompList.length; i++) {
      var target = treeCompList[i];
      if (target is BracketExpressionTree) {
        // input targetPos is,  targetPos_current - lengthStack - 1
        // -1 is for the bracket.
        //
        // for example, if you want to find the cursor=14 in :
        //      ...6 char before...(12+3+9)<here>
        // your current lengthStack = 6, and cursor = 14.
        // if you want the correct target, you must put the targetPos = 7. (the 14 - 6 - 1)
        // debugConsole(["put the", targetPos - lengthStack - 1, "by", targetPos, lengthStack]);
        var inspectResult = _inspectTargetTree(target, targetPos - lengthStack - 1);
        if (inspectResult != null) {
          return inspectResult;
        } else {
          // if tree is empty or the cursor is too big to find its place inside the given tree, null will be returned.
          lengthStack += target.length; // 2 is the bracket length.
        }
      } else if (target is Operator) {
        lengthStack += 1;
      } else {
        String targetString = target.string;
        lengthStack += targetString.length;
      }

      // if targetPos is lower then or equals to the lengthStack, current routine is the answer.
      if (targetPos <= lengthStack) {
        // make the inserted result
        if (target is BracketExpressionTree) {
          // in case of Tree.
          // this means that cursor is on the last bracket's after like :
          //      "...+34)<here>"  -> insertPos=target.length
          // or the first bracket's before like :
          //      "<here>(34+..."  -> insertPos=0
          // debugConsole(["(case : 0) result is", tree.debugString(), i, target.length - (lengthStack - targetPos)]);
          // debugConsoleNoTrace(["target.length", target.length, "lengthStack", lengthStack, "targetPos", targetPos]);
          // debugConsoleNoTrace([target.debugString(), target.length, target.toString()]);
          return [tree, i, target.length - (lengthStack - targetPos)];
        } else if (target is Operator) {
          // in case of target is Operator
          // resultString = target.string;
          // debugConsole(["(case : 1) result is", tree.debugString(), i, 1 - (lengthStack - targetPos)]);
          return [tree, i, 1 - (lengthStack - targetPos)];
        } else {
          // in case of target is NumberString
          int insertPos = target.string.length - (lengthStack - targetPos);
          // resultString = resultString.substring(0, insertPos) +
          //     resultString.substring(insertPos);
          // var createdNum = NumberString(resultString);
          // debugConsole(["(case : 2) result is", tree.debugString(), i, insertPos]);
          return [tree, i, insertPos];
        }
      }
    }

    // no result found. this means that cursor is too big to find the proper place.
    return null;
  }

  static String InsertAllowableString = "1234567890.*/+-(";

  /// magical static function, that can insert the input char into the tree.
  /// can recept the :
  ///   "1234567890.", "*/+-", and "("
  ///
  /// [cursor] can be the tree.string length.
  /// [cursor] is the virtual index, assuming that original tree is stringified.
  ///
  /// for example, let the [tree].toString() = "12+34-(67/89)", and the [cursor] = 8, inputChar is "."
  /// it means that the target position is "12+34-(6<here>7/89)", and you must correct the tree like :
  /// tree.expComponentsList[5].expComponentsList[0] = 6.7
  static void magicalInsert(BracketExpressionTree tree, int cursor, String inputChar) {
    // debugConsole(["cursor", cursor, "inputChar", inputChar]);
    // validation of param.
    // inputChar must be inside of the allowable list string.
    if (!InsertAllowableString.contains(inputChar)) {
      throw ArgumentError("BracketExpressionTree.magicalInsert : inputChar must be one of the \"1234567890.*/+-(\". ");
    }
    // cursor must below the length of tree.
    if (!(0 <= cursor || cursor <= tree.length)) {
      throw RangeError.index(cursor, tree._expComponentsList, "_expComponentsList", "BracketExpressionTree.magicalInsert : out of range cursor.");
    }

    // inputChar must be just one letter.
    if (inputChar.length != 1) {
      throw ArgumentError("BracketExpressionTree.magicalInsert : inputChar must be the length of 1.");
    }

    // if tree has no elements and cursor is just 0, create new directly.
    if (tree.expComponentsList.isEmpty) {
      if ("1234567890.".contains(inputChar)) {
        tree._addNumberString(NumberString(inputChar), 0);
      } else if ("+-*/".contains(inputChar)) {
        tree._addOperator(_getOperator(inputChar), 0);
      } else {
        tree._addTree(0);
      }
      return;
    }

    // find the target that we want to handle.
    var inspectationResult = _inspectTargetTree(tree, cursor);

    if (inspectationResult == null) {
      // this means that tree is empty or cursor is over the tree legnth. but this case is already checked. so,
      throw Exception("BracketExpressionTree.magicalInsert : unexpected result occoured.");
    }

    // determine which action we have to avoke, case by the target
    // // prepare the variables.
    BracketExpressionTree targetTree = inspectationResult[0];
    int elementIndex = inspectationResult[1];
    int innerInsertPos = inspectationResult[2];
    var targetElement = targetTree.expComponentsList[elementIndex];
    // debugConsole(["inspectationResult result is", targetTree.debugString(), elementIndex, innerInsertPos]);

    // // main case verifing.
    if ("1234567890.".contains(inputChar)) {
      if (targetElement is NumberString) {
        // debugConsole("magicalInput00");
        // insert numberstring on the numberstring means merge.
        final targetElementString = targetElement.string;
        final updatedString = targetElementString.substring(0, innerInsertPos) + inputChar + targetElementString.substring(innerInsertPos);
        targetTree._updateNumberString(NumberString(updatedString), elementIndex);
      } else if (targetElement is Operator) {
        // debugConsole("magicalInput01");
        // insert numberstring on the operator means the new numberstring adds.
        // position is just 0:front, 1:back only.
        targetTree._addNumberString(NumberString(inputChar), elementIndex + innerInsertPos);
      } else {
        // debugConsole("magicalInput02");
        // insert numberstring on the Tree means have three special cases.
        // [<here>(...)] , [(...)<here>], [(<here>)]
        // each are, "adding obj on the head", "adding obj on the tail", "adding obj inside of the empty tree"
        if (innerInsertPos == 0) {
          targetTree._addNumberString(NumberString(inputChar), elementIndex);
        } else if (innerInsertPos == targetElement.length) {
          targetTree._addNumberString(NumberString(inputChar), elementIndex + 1);
        } else {
          targetElement._addNumberString(NumberString(inputChar), 0);
        }
      }
    } else if ("+-*/".contains(inputChar)) {
      if (targetElement is NumberString) {
        // debugConsole("magicalInput10");
        // insert Operator on the numberstring means split.
        final targetElementString = targetElement.string;
        final aheadNumberString = NumberString(targetElementString.substring(0, innerInsertPos));
        final newOperator = _getOperator(inputChar);
        final followNumberString = NumberString(targetElementString.substring(innerInsertPos));
        targetTree._updateNumberString(aheadNumberString, elementIndex);
        targetTree._addNumberString(followNumberString, elementIndex + 1);
        targetTree._addOperator(newOperator, elementIndex + 1);
      } else if (targetElement is Operator) {
        // debugConsole("magicalInput11");
        // insert numberstring on the operator means the new numberstring adds.
        // position is just 0:front, 1:back only.
        targetTree._addOperator(_getOperator(inputChar), elementIndex + innerInsertPos);
      } else {
        // debugConsole("magicalInput12");
        // insert Operator on the Tree means just two special cases.
        // both of the cases means the adds of Operator.
        if (innerInsertPos == 0) {
          targetTree._addOperator(_getOperator(inputChar), elementIndex);
        } else if (innerInsertPos == targetElement.length) {
          targetTree._addOperator(_getOperator(inputChar), elementIndex + 1);
        } else {
          targetElement._addOperator(_getOperator(inputChar), 0);
        }
      }
    } else {
      // this is the most creaziest part...
      if (targetElement is NumberString) {
        // debugConsole("magicalInput20");
        // insert Tree on the number means split of number and create of tree.
        final targetElementString = targetElement.string;
        final aheadNumberString = NumberString(targetElementString.substring(0, innerInsertPos));
        final followNumberString = NumberString(targetElementString.substring(innerInsertPos));
        targetTree._updateNumberString(aheadNumberString, elementIndex);
        targetTree._addNumberString(followNumberString, elementIndex + 1);
        targetTree._addTree(elementIndex + 1);
      } else if (targetElement is Operator) {
        // debugConsole("magicalInput21");
        // insert Tree on the operator means the new numberstring adds.
        // position is just 0:front, 1:back only.
        targetTree._addTree(elementIndex + innerInsertPos);
      } else {
        // debugConsole("magicalInput22");
        // also the insertion of tree on the tree is just adding another tree inside tree.
        if (innerInsertPos == 0) {
          targetTree._addTree(elementIndex);
        } else if (innerInsertPos == targetElement.length) {
          targetTree._addTree(elementIndex + 1);
        } else {
          targetElement._addTree(0);
        }
      }
    }
  }

  /// magical static function, that can insert the input char into the tree.
  ///
  /// [cursor] range can be the length of tree.string
  ///
  /// deletion of char is occours the front of the cursor.
  /// eg : "12+34+5<delete here>6" -> "12+34+6"
  static void magicalDelete(BracketExpressionTree tree, int cursor) {
    // validation of param.
    // cursor must below the length of tree.
    if (!(0 <= cursor || cursor <= tree.length)) {
      throw RangeError.index(cursor, tree._expComponentsList, "_expComponentsList", "BracketExpressionTree.magicalInsert : out of range cursor.");
    }

    // find the target that we want to handle.
    var inspectationResult = _inspectTargetTree(tree, cursor);
    if (inspectationResult == null) {
      throw Exception("BracketExpressionTree.magicalInsert : unexpected result occoured.");
    }

    // determine which action we have to avoke, case by the target
    // // prepare the variables.
    BracketExpressionTree targetTree = inspectationResult[0];
    int elementIndex = inspectationResult[1];
    int innerDeletionPos = inspectationResult[2];
    var targetElement = targetTree.expComponentsList[elementIndex];

    // if innerDeletionPos is 0, conversion of indices or the deletion of tree is needed.
    if (innerDeletionPos == 0) {
      if (elementIndex == 0) {
        // both innerDeletionPos and elementIndex are 0 then the tree must be collapsed.
        tree.collapse();
        return;
      }
      // only innerDeletionPos is 0, just moves to the front element.
      elementIndex -= 1;
      targetElement = targetTree.expComponentsList[elementIndex];
      if (targetElement is NumberString || targetElement is Operator) {
        innerDeletionPos = targetElement.string.length;
      } else {
        // if deletion target is tree, must be collapsed.
        tree.collapse();
        return;
      }
    }

    // // main case verifing.
    if (targetElement is NumberString) {
      // delete char of the numberstring means delete one digit.
      final targetElementString = targetElement.string;
      final updatedString = targetElementString.substring(0, targetElementString.length - 1);
      if (updatedString.isNotEmpty) {
        targetTree._updateNumberString(NumberString(updatedString), elementIndex);
      } else {
        // if no digit left, delete that.
        targetTree._deleteNumberString(elementIndex);
      }
    } else if (targetElement is Operator) {
      // delete one char on the operator means just delete.
      targetTree._deleteOperator(elementIndex);
    } else {
      // delete tree means collapse.
      targetElement.collapse();
    }
  }

  static BracketExpressionTree newNumericTree(String numberString) {
    var newTree = BracketExpressionTree();
    newTree.expComponentsList.add(NumberString(numberString));
    return newTree;
  }

  // #endregion

  /// print the noBracketExpression and the children list.
  void debugLogSelf() {
    // debugConsole("current number list : ");
    // debugConsole("[");
    _expComponentsList.forEach((comp) {
      if (comp is BracketExpressionTree) {
        comp.debugLogSelf();
        // debugConsole(",");
      } else if (comp is Operator) {
        // debugConsole(comp.string);
      } else {
        // debugConsole(doubleToString(comp));
      }
    });
    // debugConsole("]");
  }

  String debugString() {
    String mystring = "[";
    _expComponentsList.forEach((element) {
      if (element is BracketExpressionTree) {
        mystring += element.debugString();
        mystring += ",";
      } else if (element is Operator) {
        mystring += element.string + ",";
      } else {
        mystring += element.string + ",";
      }
    });

    if (mystring.length != 1) {
      mystring = mystring.substring(0, mystring.length - 1);
    }

    return mystring + "]";
  }
}
