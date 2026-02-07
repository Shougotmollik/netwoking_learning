import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:networking_learning/constant/api_constant.dart';
import 'package:networking_learning/constant/app_constant.dart';
import 'package:networking_learning/service/prefs_helper.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static late Dio _dio;
  static String _bearerToken = "";

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Initialize Dio with base configuration
  static Future<void> initialize() async {
    _bearerToken = await PrefsHelper.getString(AppConstant.bearerToken);

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());

    // Add pretty logger only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  /// Update bearer token (call after login/logout)
  static Future<void> updateToken() async {
    _bearerToken = await PrefsHelper.getString(AppConstant.bearerToken);
  }

  /// Clear token (logout)
  static void clearToken() {
    _bearerToken = "";
  }

  // ========== GET REQUEST ==========
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== POST REQUEST ==========
  static Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== POST MULTIPART REQUEST ==========
  static Future<Response> postMultipart(
    String endpoint, {
    required Map<String, dynamic> fields,
    Map<String, MultipartFile>? files,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap(fields);

      // Add files if provided
      if (files != null && files.isNotEmpty) {
        files.forEach((key, file) {
          formData.files.add(MapEntry(key, file));
        });
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PUT REQUEST ==========
  static Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PUT MULTIPART REQUEST ==========
  static Future<Response> putMultipart(
    String endpoint, {
    required Map<String, dynamic> fields,
    Map<String, MultipartFile>? files,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap(fields);

      if (files != null && files.isNotEmpty) {
        files.forEach((key, file) {
          formData.files.add(MapEntry(key, file));
        });
      }

      final response = await _dio.put(
        endpoint,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PATCH REQUEST ==========
  static Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PATCH MULTIPART REQUEST ==========
  static Future<Response> patchMultipart(
    String endpoint, {
    required Map<String, dynamic> fields,
    Map<String, MultipartFile>? files,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap(fields);

      if (files != null && files.isNotEmpty) {
        files.forEach((key, file) {
          formData.files.add(MapEntry(key, file));
        });
      }

      final response = await _dio.patch(
        endpoint,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== DELETE REQUEST ==========
  static Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== DOWNLOAD FILE ==========
  static Future<Response> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== ERROR HANDLER ==========
  static ApiException _handleError(DioException error) {
    String message = "Something went wrong, please try again";
    int statusCode = 0;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Connection timeout. Please check your internet connection.";
        statusCode = -1;
        break;

      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode ?? 0;
        message =
            _parseErrorMessage(error.response?.data) ??
            error.response?.statusMessage ??
            "Server error occurred";
        break;

      case DioExceptionType.cancel:
        message = "Request cancelled";
        statusCode = -2;
        break;

      case DioExceptionType.connectionError:
        message = "No internet connection. Please check your network.";
        statusCode = -3;
        break;

      case DioExceptionType.badCertificate:
        message = "Security certificate error";
        statusCode = -4;
        break;

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          message = "No internet connection";
          statusCode = -3;
        } else {
          message = error.message ?? "Unknown error occurred";
        }
        break;
    }

    debugPrint("❌ API Error [$statusCode]: $message");
    return ApiException(message: message, statusCode: statusCode);
  }

  /// Parse error message from response
  static String? _parseErrorMessage(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map) {
        // Common API error patterns
        if (data.containsKey('message')) return data['message'];
        if (data.containsKey('error')) {
          final error = data['error'];
          if (error is String) return error;
          if (error is Map && error.containsKey('message')) {
            return error['message'];
          }
        }
        if (data.containsKey('msg')) return data['msg'];
        if (data.containsKey('detail')) return data['detail'];
      }
    } catch (e) {
      debugPrint("Error parsing error message: $e");
    }
    return null;
  }

  /// Helper method to create MultipartFile from File path
  static Future<MultipartFile> fileFromPath(
    String filePath, {
    String? filename,
  }) async {
    return await MultipartFile.fromFile(
      filePath,
      filename: filename ?? filePath.split('/').last,
    );
  }

  /// Helper method to create MultipartFile from bytes
  static MultipartFile fileFromBytes(
    List<int> bytes, {
    required String filename,
  }) {
    return MultipartFile.fromBytes(bytes, filename: filename);
  }
}

// ========== AUTH INTERCEPTOR ==========
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add bearer token if available
    if (ApiClient._bearerToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${ApiClient._bearerToken}';
    }
    super.onRequest(options, handler);
  }
}

// ========== ERROR INTERCEPTOR ==========
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      debugPrint("🔒 Unauthorized - Token may be expired");
      // You can add logout logic here or refresh token
      // Get.offAllNamed('/login'); // Example
    }

    // Handle 403 Forbidden
    if (err.response?.statusCode == 403) {
      debugPrint("🚫 Forbidden - Access denied");
    }

    // Handle 404 Not Found
    if (err.response?.statusCode == 404) {
      debugPrint("🔍 Not Found - Endpoint doesn't exist");
    }

    super.onError(err, handler);
  }
}

// ========== CUSTOM EXCEPTION CLASS ==========
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
