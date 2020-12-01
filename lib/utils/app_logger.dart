import 'package:meta/meta.dart';
import 'dart:developer' as developer;

class AppLogger {
  static AppLogger log;

  /// Logging levels
  static const OFF = 2000;
  static const FINEST = 300;
  static const FINER = 400;
  static const FINE = 500;
  static const CONFIG = 700;
  static const INFO = 800;
  static const WARNING = 900;
  static const SEVERE = 1000;
  static const SHOUT = 1200;

  AppLogger({
    @required String logIdentifier,
  }) {
    if (AppLogger.log != null) {
      throw Exception("AppLogger.log must be a singleton!");
    }

    AppLogger.log = this;
  }
}

extension CustomLoggerExtension on AppLogger {
  void finest(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.FINEST,
    );
  }

  void finer(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.FINER,
    );
  }

  void fine(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.FINE,
    );
  }

  void config(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.CONFIG,
    );
  }

  void info(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      message,
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.INFO,
      name: methodName != null ? "SEV:$methodName" : "SEV",
    );
  }

  void warning(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.WARNING,
    );
  }

  void severe(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.SEVERE,
    );
  }

  void shout(
    message, {
    Object error,
    StackTrace stackTrace,
    String methodName,
  }) {
    developer.log(
      "$methodName :: $message",
      error: error,
      stackTrace: stackTrace,
      level: AppLogger.SHOUT,
    );
  }
}
