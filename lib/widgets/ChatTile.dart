import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatefulWidget {
  final ElfChat elfChat;
  final AuthServices _auth;
  final FireStoreServices db;

  ChatTile(this.elfChat, this._auth, this.db);

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              widget.elfChat.user.photoURL,
            ),
          ),
          title: Text(
            widget.elfChat.user.displayName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: StreamBuilder(
            stream: widget.db.getLastMessage(widget.elfChat.chatID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active && snapshot.data.docs.length > 0) {
                var msgText = (snapshot.data as QuerySnapshot).docs.first.data()['message'];
                var hasPhoto = (snapshot.data as QuerySnapshot).docs.first.data()['attachmentURL'] != null;
                return Row(
                  children: [
                    if (hasPhoto)
                      Icon(
                        Icons.image,
                        size: 17,
                        color: Colors.grey[700],
                      ),
                    Text(
                      msgText,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ],
                );
              }
              return SizedBox();
            },
          ),
          onTap: () async {
            await Navigator.pushNamed(context, '/chat', arguments: widget.elfChat);
          },
        ),
        Divider(
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
