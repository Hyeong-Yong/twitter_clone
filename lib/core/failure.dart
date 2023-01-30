import 'package:flutter/material.dart' show immutable;

@immutable
class Failure {
  final String message;
  final StackTrace strackTrace;

  const Failure(
    this.message,
    this.strackTrace,
  );
}
