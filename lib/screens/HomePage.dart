import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/ChatSnippet.dart';
import 'package:elfchat/screens/SearchPage.dart';
import 'package:elfchat/screens/UserPage.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:elfchat/widgets/ChatTile.dart';
import 'package:flutter/material.dart';

/// the chats list page
class HomePage extends StatefulWidget {
  final AuthServices _auth;
  final FireStoreServices _db;

  const HomePage(this._auth, this._db);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ElfChatSnippet> chatsList = [];
  List<ChatTile> tiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/user',
                arguments: UserPageArguments(
                  chatList: chatsList,
                  user: widget._auth.user,
                  form: UserDetailsForm.LoggedIn,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          Navigator.pushNamed(context, '/search', arguments: chatsList);
        },
      ),
      body: StreamBuilder(
        stream: widget._db.getChatsSnippetsStream(widget._auth.user.uid),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            for (var docChange in snapshot.data.docChanges) {
              // ADD.
              if (docChange.type == DocumentChangeType.added) {
                // if a doc is added, delete any previous copies of it.
                chatsList.removeWhere((element) => element.chatID == docChange.doc.id);
                tiles.removeWhere((element) => element.snippet.chatID == docChange.doc.id);
                // then add it to the list/
                var newSnippet = ElfChatSnippet.fromJson(docChange.doc.data(), chatID: docChange.doc.id);
                chatsList.add(newSnippet);
                tiles.add(ChatTile(newSnippet, widget._auth, widget._db));

                // MODIFY.
              } else if (docChange.type == DocumentChangeType.modified) {
                // fetch
                var snippet = chatsList.where((element) => element.chatID == docChange.doc.id).first;
                // update
                snippet.updateFromJson(docChange.doc.data(), chatID: docChange.doc.id);

                var tile = tiles.where((element) => element.snippet.chatID == docChange.doc.id).first;
                var tileUser = tile.user;

                tiles.remove(tile);
                tiles.add(ChatTile(snippet, widget._auth, widget._db, user: tileUser));

                // REMOVE.
              } else if (docChange.type == DocumentChangeType.removed) {
                chatsList.removeWhere((element) => element.chatID == docChange.doc.id);
                tiles.removeWhere((element) => element.snippet.chatID == docChange.doc.id);
              }

              tiles.sort((a, b) {
                try {
                  return b.snippet.lastModified.compareTo(a.snippet.lastModified);
                } catch (e) {
                  // this is to prevent 'seconds was called on a null'.
                  // smh.
                }
              });
            }
          }
          return ListView.builder(
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              return tiles[index];
            },
          );
        },
      ),
    );
  }
}
