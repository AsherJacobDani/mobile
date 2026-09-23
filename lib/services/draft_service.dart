import 'package:dio/dio.dart';

import '../models/draft.dart';
import 'storage_service.dart';

class DraftService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://instaai-production.up.railway.app",
    ),
  );

  // -----------------------------------------
  // Create Draft
  // -----------------------------------------

  Future<Draft> createDraft({
    required String username,
    required String category,
    required List<String> imagePaths,
    required String caption,
    required List<String> hashtags,
  }) async {
    final token = await StorageService.getToken();

    final response = await dio.post(
      "/draft/create",
      data: {
        "username": username,
        "category": category,
        "image_paths": imagePaths,
        "caption": caption,
        "hashtags": hashtags,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return Draft.fromJson(response.data);
  }

  // -----------------------------------------
  // Get All Drafts
  // -----------------------------------------

  Future<List<Draft>> getDrafts() async {
    final token = await StorageService.getToken();

    final response = await dio.get(
      "/draft",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return (response.data as List)
        .map((e) => Draft.fromJson(e))
        .toList();
  }

  // -----------------------------------------
  // Update Draft
  // -----------------------------------------

  Future<void> updateDraft(
    int id,
    String caption,
    List<String> hashtags,
  ) async {
    final token = await StorageService.getToken();

    await dio.post(
      "/draft/update",
      data: {
        "id": id,
        "caption": caption,
        "hashtags": hashtags,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // -----------------------------------------
  // Delete Draft
  // -----------------------------------------

  Future<void> deleteDraft(
    int id,
  ) async {
    final token = await StorageService.getToken();

    await dio.delete(
      "/draft/$id",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // -----------------------------------------
  // Schedule Draft
  // -----------------------------------------

  Future<void> scheduleDraft({
    required int draftId,
    required DateTime scheduledTime,
  }) async {
    final token = await StorageService.getToken();

    await dio.post(
      "/scheduler/schedule",
      data: {
        "draft_id": draftId,
        "scheduled_time": scheduledTime.toIso8601String(),
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
}