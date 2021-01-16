import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/ChatSnippet.dart';
import 'package:elfchat/models/Message.dart';
import 'package:elfchat/models/User.dart';

class FireStoreServices {
  FirebaseFirestore _firestore;
  CollectionReference _chatsRef;
  CollectionReference _usersRef;

  FireStoreServices() {
    _firestore = FirebaseFirestore.instance;
    _chatsRef = _firestore.collection('chats');
    _usersRef = _firestore.collection('users');
  }

  // ////////////////////////////////////// Chat methods //////////////////////////////////////

  /// takes a userID and return the chatsnipperts of that user ordered by date.
  /// as a Stream.
  Stream<QuerySnapshot> getChatsSnippetsStream(String userID) {
    try {
      return _usersRef.doc(userID).collection('chatsSnippets').orderBy('lastModified', descending: true).snapshots();
    } catch (e) {
      return null;
    }
  }

  /// Sends a [message] in a chat with given [chatID].
  ///
  /// [reciver] is the user that is getting the message.
  Future<DocumentReference> sendMessage(String chatID, ElfUser reciver, ElfMessage message) async {
    var messagesRef = _chatsRef.doc(chatID).collection('messages');

    // create message.
    var msgJson = message.toJson();
    msgJson['createdAt'] = FieldValue.serverTimestamp();

    // send it.
    var messageDoc = await messagesRef.add(msgJson);

    // update lastModified.
    _chatsRef.doc(chatID).update({'lastModified': FieldValue.serverTimestamp()});

    // that's why we need [contact], to update thier snippet.
    updateChatSnippet(reciver.userID, message.userID, chatID, message);

    return messageDoc;
  }

  /// Updates the chat snippet of both the reciver and sender of a message.
  // reciver is idenified by [contact] and the sender by [userID].
  void updateChatSnippet(String reciverID, String senderID, String chatID, ElfMessage message) {
    // Create the snippet
    var msgSnippet = {
      'lastModified': FieldValue.serverTimestamp(),
      'lastMsg': {'message': message.message, 'hasPhoto': message.photoURL != null},
      'chatRefrence': _chatsRef.doc(chatID),
    };

    // update the reciver's
    _usersRef.doc(reciverID).collection('chatsSnippets').doc(chatID).set(msgSnippet
      ..addAll(
        {
          'user': senderID,
        },
      ));

    // update the sender's
    _usersRef.doc(senderID).collection('chatsSnippets').doc(chatID).set(msgSnippet
      ..addAll(
        {
          'user': reciverID,
        },
      ));
  }

  /// returns a Stream of messages in a chat with a given [chatID].
  Stream<QuerySnapshot> getChatMsgsStream(String chatID) {
    var chatRef = _chatsRef.doc(chatID);
    return chatRef.collection('messages').orderBy('createdAt', descending: true).snapshots();
  }

  /// returns a chat snippet with a user with a given [contactID] from the list [userChats].
  ///
  /// returns null if there's none found (no previous chats).
  Future<ElfChatSnippet> getChatWithUser(List<ElfChatSnippet> userChats, String contactID) async {
    for (var chat in userChats) {
      if (chat.userID == contactID) {
        return chat;
      }
    }
    return null;
  }

  /// Creates a new chat document and returns the refrence.
  ///
  /// [userID] is the uid of the current (signed-in) user.
  Future<DocumentReference> createChat(String userID, ElfChat chat) async {
    var newDoc = await _chatsRef.add({
      'users': [userID, chat.user.userID],
      'lastModified': FieldValue.serverTimestamp(),
    });

    return newDoc;
  }

  // ////////////////////////////////////// User methods //////////////////////////////////////

  /// ensures that [user] is in the database (i.e., adds it if it's not).
  ensureUser(ElfUser user) async {
    if (!(await doesUserExistInDB(user.userID))) {
      addUser(user);
    }
  }

  /// Returns true if the user is in the Database
  Future<bool> doesUserExistInDB(userId) async {
    return (await _usersRef.doc(userId).get()).exists;
  }

  /// Creates a Document for [user] in the Database.
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

  /// Returns `ElfUser` with given [userID] from the Database.
  ///
  /// Returns `null` if none were found, or if there was an error.
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

  /// Returns an `ElfUser` with given [email] from the database.
  ///
  /// Returns `null` if none were found.
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
