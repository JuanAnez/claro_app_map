// ignore: file_names
import 'package:icc_claro_app/core/types/login_error_types.dart';

class MessageResponse {
  final bool ok;
  final String message;
  final dynamic content;
  final dynamic additionalContent;
  final LoginErrorType? errorType;

  MessageResponse(
      {this.ok = false,
      this.message = "",
      this.content,
      this.additionalContent,
      this.errorType});
}