import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ElfMessage {
  final String userID;
  final String message;
  final String photoURL;
  Timestamp createdAt;

  ElfMessage({
    @required this.userID,
    @required this.message,
    @required this.photoURL,
    this.createdAt,
  });

  factory ElfMessage.fromJson(Map<String, dynamic> json) {
    return ElfMessage(
      userID: json['user'],
      message: json['message'],
      photoURL: json['attachmentURL'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userID,
      'message': message,
      'attachmentURL': photoURL,
      'createdAt': createdAt,
    };
  }
}
