import "dart:developer";

/// show the inner elements of [debugParams] list.
/// can be used to inspect the simple 1D list.
///
/// however, if [debugParams] not list, just log the stringified value.
void debugConsole(dynamic debugParams) {
  String outputString = "";
  if (debugParams is List) {
    debugParams.forEach((element) {
      outputString += element.toString() + " , ";
    });
    outputString = outputString.substring(0, outputString.length - 2);
  } else {
    outputString = debugParams.toString();
  }

  // get stackTrace
  List<String> trace = StackTrace.current.toString().split("\n");
  String simpleTrace = trace[1].substring(8);

  log(simpleTrace);
  log(" =>  " + outputString);
}

void debugConsoleNoTrace(dynamic debugParams) {
  String outputString = "";
  if (debugParams is List) {
    debugParams.forEach((element) {
      outputString += element.toString() + " , ";
    });
    outputString = outputString.substring(0, outputString.length - 2);
  } else {
    outputString = debugParams.toString();
  }

  log(outputString);
}

// class DebugConsole {
// }
