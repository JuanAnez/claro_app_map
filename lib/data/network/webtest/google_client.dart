import 'dart:convert';
import 'dart:io';

class GoogleClient {
  static const _prefix = "https://webtest.prt.local/icc/api";
  static const _coverageURL = "$_prefix/getPolygonTypes";

  Future<List<Map<String, dynamic>>> fetchPolygonTypes() async {
    final url = Uri.parse(_coverageURL);
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    try {
      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw const HttpException("Failed to fetch polygon types.");
      }

      final responseData = await utf8.decodeStream(response);
      return List<Map<String, dynamic>>.from(jsonDecode(responseData));
    } catch (e) {
      throw Exception("Error fetching polygon types: $e");
    }
  }

  Future<String> fetchGeoJsonGzip(Uri url) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    try {
      final request = await client.getUrl(url);
      final response = await request.close();


      if (response.statusCode != HttpStatus.ok) {
        throw const HttpException("Failed to fetch GeoJSON.");
      }

      final gzipData = await response.fold<List<int>>(
        [],
        (buffer, chunk) => buffer..addAll(chunk),
      );

      final decodedData = GZipCodec().decode(gzipData);
      return utf8.decode(decodedData);
    } catch (e) {
      throw Exception("Error fetching GeoJSON: $e");
    }
  }
}
