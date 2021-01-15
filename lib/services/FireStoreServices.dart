import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/Message.dart';
import 'package:elfchat/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreServices {
  FirebaseFirestore _firestore;
  CollectionReference _chatsRef;
  CollectionReference _usersRef;

  FireStoreServices() {
    _firestore = FirebaseFirestore.instance;
    _chatsRef = _firestore.collection('chats');
    _usersRef = _firestore.collection('users');
  }

  // Chat methods

  Stream<QuerySnapshot> getUserChatsSnippets(String userID) {
    try {
      return _usersRef.doc(userID).collection('chatsSnippets').orderBy('lastModified', descending: true).snapshots();
    } catch (e) {
      return null;
    }
  }

  Future<DocumentReference> sendMessage(String chatID, ElfUser contact, ElfMessage message) async {
    var messagesRef = _chatsRef.doc(chatID).collection('messages');

    // create message
    var msgJson = message.toJson();
    msgJson['createdAt'] = FieldValue.serverTimestamp();

    // send it
    var messageDoc = await messagesRef.add(msgJson);

    // update lastModified
    _chatsRef.doc(chatID).update({'lastModified': FieldValue.serverTimestamp()});

    updateChatSnippet(contact, message.userID, chatID, messageDoc);

    return messageDoc;
  }

  void updateChatSnippet(ElfUser contact, String userID, String chatID, DocumentReference messageDoc) {
    var msgSnippet = {
      'lastModified': FieldValue.serverTimestamp(),
      'lastMsg': messageDoc,
      'chatRefrence': _chatsRef.doc(chatID),
    };
    _usersRef.doc(contact.userID).collection('chatsSnippets').doc(chatID).set(msgSnippet
      ..addAll(
        {
          'user': userID,
        },
      ));
    _usersRef.doc(userID).collection('chatsSnippets').doc(chatID).set(msgSnippet
      ..addAll(
        {
          'user': contact.userID,
        },
      ));
  }

  Stream<QuerySnapshot> getChatMsgsStream(String chatID) {
    var chatRef = _chatsRef.doc(chatID);
    return chatRef.collection('messages').orderBy('createdAt', descending: true).snapshots();
  }

  Stream getLastMessage(String chatId) {
    var chatRef = _chatsRef.doc(chatId);
    return chatRef.collection('messages').orderBy('createdAt', descending: true).limit(1).snapshots();
  }

  Future<Map<String, dynamic>> getChatWithUser(List<Map<String, dynamic>> userChats, String contactID) async {
    for (var chat in userChats) {
      if (chat['user'] == contactID) {
        return chat;
      }
    }
    return null;
  }

  Future<DocumentReference> createChat(String userID, ElfChat chat) async {
    var newDoc = await _chatsRef.add({
      'users': [userID, chat.user.userID],
      'lastModified': FieldValue.serverTimestamp(),
    });

    await newDoc.collection('messages').get();
    return newDoc;
  }

  // User methods
  ensureUser(ElfUser user) async {
    if (!(await doesUserExistInDB(user.userID))) {
      addUser(user);
    }
  }

  Future<bool> doesUserExistInDB(userId) async {
    return (await _usersRef.doc(userId).get()).data() != null;
  }

  addUser(ElfUser user) async {
    var userJson = user.toJson();
    var userID = userJson['userID'];
    userJson.remove('userID');
    try {
      await _usersRef.doc(userID).set(userJson);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  updateUserInfo(User user) async {
    var userJson = <String, dynamic>{
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };

    try {
      await _usersRef.doc(user.uid).set(userJson);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<ElfUser> retriveUser(String userID) async {
    try {
      var user = await _usersRef.doc(userID).get();
      var userMapped = user.data();
      userMapped.addAll({'userID': userID});
      return ElfUser.fromJson(userMapped);
    } catch (e) {
      print("couldn't retrive user with uid: $userID");
      return null;
    }
  }

  Future<ElfUser> searchForUser(String email) async {
    var result = await _usersRef.where('email', isEqualTo: email).get();
    if (result.docs.isEmpty)
      return null;
    else {
      var userData = result.docs.first.data();
      userData.addAll({'userID': result.docs.first.id});
      return ElfUser.fromJson(userData);
    }
  }
}
