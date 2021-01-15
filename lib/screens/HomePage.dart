import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/screens/UserPage.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:elfchat/widgets/ChatTile.dart';
import 'package:elfchat/widgets/LoadingWidget.dart';
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
  List<ElfChat> chatsList = [];

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
      body: FutureBuilder(
        future: widget._db.getUserChatsList(widget._auth.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            chatsList = snapshot.data;
            return ListView.builder(
              itemCount: chatsList.length,
              itemBuilder: (BuildContext context, int index) {
                return ChatTile(chatsList[index], widget._auth, widget._db);
              },
            );
          }

          return LoadingWidget(text: 'Loading chats');
        },
      ),
    );
  }
}
