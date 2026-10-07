class AvatarModel {
  final String? url;
  final int? expiresIn;
  final String? mimeType;
  final int? sizeBytes;
  final String? updatedAt;

  AvatarModel({
    this.url,
    this.expiresIn,
    this.mimeType,
    this.sizeBytes,
    this.updatedAt,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      url: json['url']?.toString(),
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse(
        json['expires_in']?.toString() ?? '',
      ),
      mimeType: json['mime_type']?.toString(),
      sizeBytes: json['size_bytes'] is int
          ? json['size_bytes']
          : int.tryParse(
        json['size_bytes']?.toString() ?? '',
      ),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'expires_in': expiresIn,
      'mime_type': mimeType,
      'size_bytes': sizeBytes,
      'updated_at': updatedAt,
    };
  }
}
