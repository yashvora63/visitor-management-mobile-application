// To parse this JSON data, do
//
//     final RecorderModel = RecorderModelFromJson(jsonString);

import 'dart:convert';

RecorderModel recorderModelFromJson(String str) =>
    RecorderModel.fromJson(json.decode(str));

String recorderModelToJson(RecorderModel data) => json.encode(data.toJson());

class RecorderModel {
  bool? success;
  List<Item>? items;
  num? total;

  RecorderModel({this.success, this.items, this.total});

  factory RecorderModel.fromJson(Map<String, dynamic> json) => RecorderModel(
    success: json["success"] ?? false,
    items: json["items"] == null
        ? []
        : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    total: json["total"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "total": total,
  };
}

class Item {
  num? id;
  String? name;
  String? s3Key;
  num? fileSizeBytes;
  num? duration;
  num? volume;
  String? contentType;
  DateTime? createdAt;

  Item({
    this.id,
    this.name,
    this.s3Key,
    this.fileSizeBytes,
    this.duration,
    this.volume,
    this.contentType,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    s3Key: json["s3_key"] ?? "",
    fileSizeBytes: json["file_size_bytes"] ?? 0,
    duration: json["duration"] ?? 0,
    volume: json["volume"] ?? 0,
    contentType: json["content_type"] ?? "",
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"] ?? ""),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "s3_key": s3Key,
    "file_size_bytes": fileSizeBytes,
    "duration": duration,
    "volume": volume,
    "content_type": contentType,
    "created_at": createdAt?.toIso8601String(),
  };
}

PresignedModel presignedModelFromJson(String str) =>
    PresignedModel.fromJson(json.decode(str));

String presignedModelToJson(PresignedModel data) => json.encode(data.toJson());

class PresignedModel {
  bool? success;
  String? presignedUrl;
  String? s3Key;
  num? expiresIn;

  PresignedModel({this.success, this.presignedUrl, this.s3Key, this.expiresIn});

  factory PresignedModel.fromJson(Map<String, dynamic> json) => PresignedModel(
    success: json["success"],
    presignedUrl: json["presigned_url"],
    s3Key: json["s3_key"],
    expiresIn: json["expires_in"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "presigned_url": presignedUrl,
    "s3_key": s3Key,
    "expires_in": expiresIn,
  };
}

class RecordingModel {
  final String id;
  final String filePath;
  final String name;
  final DateTime createdAt;
  final Duration duration;

  RecordingModel({
    required this.id,
    required this.filePath,
    required this.name,
    required this.createdAt,
    required this.duration,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

PreviewRecordingModel previewRecordingModelFromJson(String str) =>
    PreviewRecordingModel.fromJson(json.decode(str));

String previewRecordingModelToJson(PreviewRecordingModel data) =>
    json.encode(data.toJson());

class PreviewRecordingModel {
  num? recordingId;
  String? name;
  num? volume;
  num? duration;
  String? recordingUrl;
  num? expiresIn;

  PreviewRecordingModel({
    this.recordingId,
    this.name,
    this.volume,
    this.duration,
    this.recordingUrl,
    this.expiresIn,
  });

  factory PreviewRecordingModel.fromJson(Map<String, dynamic> json) =>
      PreviewRecordingModel(
        recordingId: json["recording_id"] ?? 0,
        name: json["name"] ?? "",
        volume: json["volume"] ?? 0,
        duration: json["duration"] ?? 0,
        recordingUrl: json["recording_url"] ?? "",
        expiresIn: json["expires_in"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "recording_id": recordingId,
    "name": name,
    "volume": volume,
    "duration": duration,
    "recording_url": recordingUrl,
    "expires_in": expiresIn,
  };
}
