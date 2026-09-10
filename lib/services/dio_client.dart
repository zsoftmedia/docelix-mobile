
import 'package:dio/dio.dart';

class DioClient {

  final Dio _dio = Dio();

  Future<Response> getMe(String url, String accessToken) async {
    return await _dio.get(
      'https://docelix.onrender.com/api$url',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}