// ignore: file_names
class MessageResponse {
  final bool ok;
  final String message;
  final dynamic content;
  final dynamic additionalContent;

  MessageResponse(
      {this.ok = false,
      this.message = "",
      this.content,
      this.additionalContent});
}
