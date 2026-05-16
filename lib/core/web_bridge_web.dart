import 'dart:js_interop';
import 'dart:js_interop_unsafe';

Object? evalJs(String code) => globalContext.callMethod('eval'.toJS, code.toJS);

String? evalJsString(String code) {
  final result = evalJs(code);
  return (result as JSString?)?.toDart;
}

bool evalJsBool(String code) {
  final result = evalJs(code);
  return (result as JSBoolean?)?.toDart ?? false;
}
