import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User data model
///
/// Represents a user entity with JSON serialization support.
/// This model is used throughout the app for user data.
@JsonSerializable()
class User extends Equatable {
  /// Unique user identifier
  final String id;

  /// User's email address
  final String email;

  /// User's full name
  final String name;

  /// Optional profile image URL
  final String? profileImage;

  /// Optional bio/description
  final String? bio;

  /// Optional phone number
  final String? phone;

  /// Account creation timestamp
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Last update timestamp
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    this.bio,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Convert User to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    String? bio,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user initials from name
  String get initials {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Check if user has profile image
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        profileImage,
        bio,
        phone,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}
