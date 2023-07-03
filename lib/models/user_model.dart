import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserModel {
  String userId;
  String fullName;
  String email;
  String phone;
  String username;
  String? profilePic;
  String? sign;
  String? status;
  List<String> friends;
  List<PhotoModel> photos;
  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.username,
    this.profilePic,
    this.sign,
    this.status,
    required this.friends,
    required this.photos,
  });

  UserModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? username,
    String? profilePic,
    String? sign,
    String? status,
    List<String>? friends,
    List<PhotoModel>? photos,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      sign: sign ?? this.sign,
      status: status ?? this.status,
      friends: friends ?? this.friends,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'username': username,
      'profilePic': profilePic,
      'sign': sign,
      'status': status,
      'friends': friends,
      'photos': photos.map((x) => x.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'],
      sign: map['sign'] ?? '',
      status: map['status'] ?? '',
      friends: List<String>.from(map['friends']),
      photos: List<PhotoModel>.from(map['photos']?.map((x) => PhotoModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(userId: $userId, fullName: $fullName, email: $email, phone: $phone, username: $username, profilePic: $profilePic, sign: $sign, status: $status, friends: $friends, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.email == email &&
        other.phone == phone &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.sign == sign &&
        other.status == status &&
        listEquals(other.friends, friends) &&
        listEquals(other.photos, photos);
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        fullName.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        username.hashCode ^
        profilePic.hashCode ^
        sign.hashCode ^
        status.hashCode ^
        friends.hashCode ^
        photos.hashCode;
  }
}

class PhotoModel {
  List<String> photoUrls;
  List<String> userTags;
  List<String> starTags;
  DateTime createdAt;
  PhotoModel({
    required this.photoUrls,
    required this.userTags,
    required this.starTags,
    required this.createdAt,
  });

  PhotoModel copyWith({
    List<String>? photoUrls,
    List<String>? userTags,
    List<String>? starTags,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      photoUrls: photoUrls ?? this.photoUrls,
      userTags: userTags ?? this.userTags,
      starTags: starTags ?? this.starTags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoUrls': photoUrls,
      'userTags': userTags,
      'starTags': starTags,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      photoUrls: List<String>.from(map['photoUrls']),
      userTags: List<String>.from(map['userTags']),
      starTags: List<String>.from(map['starTags']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PhotoModel.fromJson(String source) => PhotoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PhotoModel(photoUrls: $photoUrls, userTags: $userTags, starTags: $starTags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PhotoModel &&
      listEquals(other.photoUrls, photoUrls) &&
      listEquals(other.userTags, userTags) &&
      listEquals(other.starTags, starTags) &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return photoUrls.hashCode ^
      userTags.hashCode ^
      starTags.hashCode ^
      createdAt.hashCode;
  }
}
