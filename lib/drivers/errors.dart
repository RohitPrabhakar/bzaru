// NOTE: handler returns true if need to stop error propagation
typedef ErrorHandler = bool Function(Object error, StackTrace stacktrace);

class ErrorHandlerKey {}

class ErrorsProducer {
  // NOTE: it's important to have an ordered list,
  //   to have stack of handlers
  final _errorHandlersKeys = <ErrorHandlerKey>[];
  final _errorHandlers = <ErrorHandlerKey, ErrorHandler>{};

  void registerErrorHandler(ErrorHandlerKey key, ErrorHandler handler) {
    _errorHandlers[key] = handler;
    _errorHandlersKeys.add(key);
  }

  void unregisterErrorHandler(ErrorHandlerKey key) {
    _errorHandlers.remove(key);
    _errorHandlersKeys.remove(key);
  }

  void pushError(Object error, StackTrace stackTrace) {
    for (final handlerKey in _errorHandlersKeys.reversed) {
      final handler = _errorHandlers[handlerKey];

      if (handler(error, stackTrace)) {
        break;
      }
    }
  }
}
