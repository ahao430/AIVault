import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../adapters/openai_compatible.dart';

/// 画图生成结果
class ImageGenResult {
  const ImageGenResult({
    required this.success,
    this.bytes,
    this.error,
    this.httpStatus,
  });

  final bool success;
  final Uint8List? bytes;
  final String? error;
  final int? httpStatus;
}

/// OpenAI 兼容图片生成服务（Plan #26）。
/// - 无参考图：POST /v1/images/generations（JSON）
/// - 有参考图：POST /v1/images/edits（multipart）
/// 响应兼容 b64_json 与 url 两种形式。
class ImageService {
  ImageService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(minutes: 5),
            ));

  final Dio _dio;

  static String apiBase(String baseUrl) {
    final normalized = OpenAICompatibleAdapter.normalizeBaseUrl(baseUrl);
    if (normalized.toLowerCase().endsWith('/v1')) return normalized;
    return '$normalized/v1';
  }

  Future<ImageGenResult> generate({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String prompt,
    String size = '1024x1024',
    List<(String filename, Uint8List bytes)> referenceImages = const [],
  }) async {
    try {
      final Response res;
      if (referenceImages.isEmpty) {
        res = await _dio.post(
          '${apiBase(baseUrl)}/images/generations',
          options: _jsonOptions(apiKey),
          data: {
            'model': model,
            'prompt': prompt,
            'n': 1,
            'size': size,
          },
        );
      } else {
        final form = FormData();
        form.fields..add(MapEntry('model', model))..add(MapEntry('prompt', prompt))
          ..add(MapEntry('n', '1'))..add(MapEntry('size', size));
        for (final ref in referenceImages) {
          form.files.add(MapEntry(
            'image[]',
            MultipartFile.fromBytes(ref.$2, filename: ref.$1),
          ));
        }
        res = await _dio.post(
          '${apiBase(baseUrl)}/images/edits',
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
            validateStatus: (_) => true,
          ),
          data: form,
        );
      }

      final status = res.statusCode ?? 0;
      if (status != 200) {
        return ImageGenResult(
          success: false,
          httpStatus: status,
          error: 'HTTP $status：${_extractError(res.data)}',
        );
      }

      // data[0].b64_json 或 data[0].url
      final data = res.data;
      if (data is Map && data['data'] is List && (data['data'] as List).isNotEmpty) {
        final first = (data['data'] as List).first;
        if (first is Map) {
          final b64 = first['b64_json'];
          if (b64 is String && b64.isNotEmpty) {
            try {
              return ImageGenResult(
                  success: true, bytes: base64Decode(b64));
            } catch (_) {
              return const ImageGenResult(
                  success: false, error: 'b64_json 解码失败');
            }
          }
          final url = first['url'];
          if (url is String && url.isNotEmpty) {
            return await _download(url, apiKey);
          }
        }
      }
      return const ImageGenResult(success: false, error: '响应中没有图片数据');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return const ImageGenResult(success: false, error: '连接超时');
      }
      return ImageGenResult(success: false, error: e.message ?? '网络错误');
    } catch (e) {
      return ImageGenResult(success: false, error: e.toString());
    }
  }

  Future<ImageGenResult> _download(String url, String apiKey) async {
    try {
      final res = await _dio.get<List<int>>(url,
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
            responseType: ResponseType.bytes,
            validateStatus: (_) => true,
          ));
      final status = res.statusCode ?? 0;
      if (status != 200 || res.data == null) {
        return ImageGenResult(
            success: false, httpStatus: status, error: '图片下载失败 HTTP $status');
      }
      return ImageGenResult(
          success: true, bytes: Uint8List.fromList(res.data!));
    } on DioException catch (e) {
      return ImageGenResult(success: false, error: '图片下载失败：${e.message}');
    }
  }

  Options _jsonOptions(String apiKey) => Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        validateStatus: (_) => true,
      );

  static String _extractError(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      if (data['message'] is String) return data['message'] as String;
    }
    return data?.toString() ?? '';
  }
}
