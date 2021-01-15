import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/User.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatefulWidget {
  final Map<String, dynamic> snippet;
  final AuthServices _auth;
  final FireStoreServices db;

  ElfChat _chat;

  ChatTile(this.snippet, this._auth, this.db);

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: widget.db.retriveUser(widget.snippet['user']),
            builder: (context, AsyncSnapshot<ElfUser> snapshot) {
              var isUserDone = snapshot.connectionState == ConnectionState.done;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: isUserDone
                      ? NetworkImage(
                          snapshot.data.photoURL,
                        )
                      : null,
                  child: isUserDone ? null : CircularProgressIndicator(),
                ),
                title: isUserDone
                    ? Text(
                        snapshot.data.displayName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : LinearProgressIndicator(),
                subtitle: FutureBuilder(
                  future: (widget.snippet['lastMsg'] as DocumentReference).get(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    var isMsgDone = snapshot.connectionState == ConnectionState.done;
                    var hasPhoto = isMsgDone ? snapshot.data.data()['attachmentURL'] != null : false;
                    var msgText = isMsgDone ? snapshot.data.data()['message'] : '';

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
                  },
                ),
                onTap: () async {
                  if (isUserDone) {
                    print('chatID = ${widget.snippet}');
                    widget._chat = ElfChat(snapshot.data, widget.snippet['chatID']);
                    await Navigator.pushNamed(context, '/chat', arguments: widget._chat);
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
