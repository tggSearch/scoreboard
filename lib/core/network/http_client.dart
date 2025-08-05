import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class HttpClient {
  static HttpClient? _instance;
  late dio.Dio _dio;

  HttpClient._() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: 'https://api.scoreboardpro.com/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(dio.LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('DIO LOG: $obj'),
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  static HttpClient get instance {
    _instance ??= HttpClient._();
    return _instance!;
  }

  /// GET request
  Future<Map<String, dynamic>> getRequest(
    String url, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: params,
        options: headers != null ? dio.Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> postRequest(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: params,
        options: headers != null ? dio.Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> putRequest(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: params,
        options: headers != null ? dio.Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> deleteRequest(
    String url, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        queryParameters: params,
        options: headers != null ? dio.Options(headers: headers) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Handle successful response
  Map<String, dynamic> _handleResponse(dio.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        try {
          return jsonDecode(response.data);
        } catch (e) {
          return {'data': response.data};
        }
      } else {
        return {'data': response.data};
      }
    } else {
      throw dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: dio.DioExceptionType.badResponse,
      );
    }
  }

  /// Handle error
  Map<String, dynamic> _handleError(dynamic error) {
    String message = '网络请求失败';
    int code = -1;

    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          message = '请求超时，请检查网络连接';
          code = -2;
          break;
        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 400:
              message = '请求参数错误';
              code = 400;
              break;
            case 401:
              message = '未授权，请重新登录';
              code = 401;
              break;
            case 403:
              message = '禁止访问';
              code = 403;
              break;
            case 404:
              message = '请求的资源不存在';
              code = 404;
              break;
            case 500:
              message = '服务器内部错误';
              code = 500;
              break;
            default:
              message = '服务器错误 (${statusCode ?? 'unknown'})';
              code = statusCode ?? -1;
          }
          break;
        case dio.DioExceptionType.cancel:
          message = '请求已取消';
          code = -3;
          break;
        case dio.DioExceptionType.connectionError:
          message = '网络连接失败';
          code = -4;
          break;
        default:
          message = '网络请求失败';
          code = -1;
      }
    }

    // Show error message
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    return {
      'success': false,
      'code': code,
      'message': message,
      'data': null,
    };
  }
} 