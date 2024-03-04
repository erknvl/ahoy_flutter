sealed class AhoyError {}

class NoVisitError extends AhoyError {}

class MismatchingVisitError extends AhoyError {}

class UnacceptableResponseError extends AhoyError {
  UnacceptableResponseError({required this.code, required this.data});
  final int code;
  final String data;
}
