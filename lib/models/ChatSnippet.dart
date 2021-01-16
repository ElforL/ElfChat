import 'package:cloud_firestore/cloud_firestore.dart';

class ElfChatSnippet {
  String chatID;
  DocumentReference chatReference;
  Map<String, dynamic> _lastMessage;
  Timestamp lastModified;

  String userID;

  get hasPhoto => _lastMessage['hasPhoto'];
  get message => _lastMessage['message'];

  ElfChatSnippet(this.chatID, this.chatReference, this._lastMessage, this.lastModified, this.userID);

  factory ElfChatSnippet.fromJson(Map<String, dynamic> json, {String chatID}) {
    return ElfChatSnippet(
      chatID ?? json['chatID'],
      json['chatRefrence'],
      json['lastMsg'],
      json['lastModified'],
      json['user'],
    );
  }

  updateFromJson(Map<String, dynamic> json, {String chatID}) {
    this.chatID = chatID ?? json['chatID'];
    this.chatReference = json['chatRefrence'];
    this._lastMessage = json['lastMsg'];
    this.lastModified = json['lastModified'];
    this.userID = json['user'];
  }

  Map<String, dynamic> toJson({bool includeChatID = true}) {
    return {
      if (includeChatID) 'chatID': chatID,
      'chatRefrence': chatReference,
      'lastMsg': _lastMessage,
      'lastModified': lastModified,
      'user': userID,
    };
  }
}
