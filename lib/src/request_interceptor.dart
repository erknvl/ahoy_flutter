import 'package:http/http.dart';

/// The interceptor provides an opportunity for your application to perform pre-flight modifications to the Ahoy
/// requests, such as adding custom headers. NOTE: If you set the following headers they will be overwritten by Ahoy
/// prior to performing the request: `Content-Type`, `Ahoy-Visitor`, `Ahoy-Visit`.
class RequestInterceptor {
  final Function(Request) interceptRequest;

  RequestInterceptor({required this.interceptRequest});
}
