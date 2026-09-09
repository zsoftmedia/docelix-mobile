
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {

  late final Dio dio;

  DioClient() {

    dio = Dio(
      BaseOptions(
        baseUrl: 'https://docelix.onrender.com/api/me',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(

        onRequest: (options, handler) {

          final session = Supabase.instance.client.auth.currentSession;

          final token = session?.accessToken;

          if (token != null && token.isNotEmpty) {

            options.headers['Authorization'] =
            'Bearer $token';
          }

          options.headers['Accept'] =
          'application/json';

          options.headers['Content-Type'] =
          'application/json';

          handler.next(options);
        },

        onError: (error, handler) {

          if (error.response?.statusCode == 401) {

            // Token is invalid/expired.
            // We can handle refresh/logout here later.
            debugPrint(
              'Unauthorized: Supabase token may be invalid/expired.',
            );
          }

          handler.next(error);
        },
      ),
    );
  }
}