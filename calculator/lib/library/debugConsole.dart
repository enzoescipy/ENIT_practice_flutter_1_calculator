import "dart:developer";

bool _debugOff = true;
bool _doCount = false;
int _counter = 0;

/// show the inner elements of [debugParams] list.
/// can be used to inspect the simple 1D list.
///
/// however, if [debugParams] not list, just log the stringified value.
void debugConsole(dynamic debugParams) {
  if (_debugOff) {
    return;
  }

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
  if (_doCount) {
    _counter++;
    log("($_counter)  =>  " + outputString);
  } else {
    log("    =>  " + outputString);
  }
}

/// do the // debugConsole() without trace.
void debugConsoleNoTrace(dynamic debugParams) {
  if (_debugOff) {
    return;
  }

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

/// call this function to start print the debugging permanently
void enableDebug() {
  _debugOff = false;
}

void enableCount() {
  _doCount = true;
}

// class // debugConsole {
// }
