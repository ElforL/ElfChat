import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/ChatSnippet.dart';
import 'package:elfchat/models/User.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatefulWidget {
  final AuthServices _auth;
  final FireStoreServices _db;

  ElfChatSnippet snippet;
  ElfUser user;
  ElfChat chat;

  ChatTile(this.snippet, this._auth, this._db, {this.user});

  update(ElfChatSnippet snippet) {
    this.snippet = snippet;
  }

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: widget.user == null
                ? widget._db.retriveUser(widget.snippet.userID)
                : Future<ElfUser>.value(widget.user),
            builder: (context, AsyncSnapshot<ElfUser> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && widget.user == null) {
                widget.user = snapshot.data;
              }
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: widget.user != null
                      ? NetworkImage(
                          widget.user.photoURL,
                        )
                      : null,
                  child: widget.user != null ? null : CircularProgressIndicator(),
                ),
                title: widget.user != null
                    ? Text(
                        widget.user.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : LinearProgressIndicator(),
                subtitle: Row(
                  children: [
                    if (widget.snippet.hasPhoto)
                      Icon(
                        Icons.image,
                        size: 17,
                        color: Colors.grey[700],
                      ),
                    Text(
                      widget.snippet.message,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ],
                ),
                onTap: () async {
                  if (widget.user != null) {
                    widget.chat = ElfChat(snapshot.data, widget.snippet.chatID);
                    await Navigator.pushNamed(context, '/chat', arguments: widget.chat);
                  }
                },
              );
            }),
        Divider(
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
