import 'package:http/http.dart';

Future<Response> validateResponse(
  Response response, {
  int acceptableCodesStart = 200,
  int acceptableCodesEnd = 399,
}) async {
  if (response.statusCode >= acceptableCodesStart &&
      response.statusCode <= acceptableCodesEnd) {
    return response;
  } else {
    throw Exception('Unacceptable response code: ${response.statusCode}');
  }
}
