import 'package:ahoy_flutter/ahoy_flutter.dart';
import 'package:http/http.dart';

Response validateResponse(
  Response response, {
  int acceptableCodesStart = 200,
  int acceptableCodesEnd = 399,
}) {
  if (response.statusCode >= acceptableCodesStart &&
      response.statusCode <= acceptableCodesEnd) {
    return response;
  } else {
    throw UnacceptableResponseError(
      code: response.statusCode,
      data: response.body,
    );
  }
}
