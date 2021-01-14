import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/Message.dart';
import 'package:elfchat/screens/UserPage.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:elfchat/widgets/MessageBubble.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final AuthServices _auth;
  final FireStoreServices _db;

  const ChatPage(this._auth, this._db);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String photoURL;

  ElfChat _chat;
  List<ElfMessage> _messages = [];

  void scrollToBottom() {
    if (_scrollController.hasClients)
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
  }

  void sendMessage() async {
    var messageText = _messageFieldController.text.trim();
    if (messageText.isNotEmpty || photoURL != null) {
      var chatID = _chat.chatID ?? (await widget._db.createChat(widget._auth.user.uid, _chat)).id;
      // create message object
      var message = ElfMessage(
        userID: widget._auth.user.uid,
        message: messageText,
        photoURL: photoURL,
      );
      // send it
      widget._db.sendMessage(chatID, message);
      if (_chat.chatID == null) {
        setState(() {
          _chat.chatID = chatID;
        });
      }
      // clear the textfield and scroll to botttom
      _messageFieldController.text = '';
      if (photoURL != null)
        setState(() {
          photoURL = null;
        });
      scrollToBottom();
    }
  }

  photoPic(BuildContext context) {
    showUrlDialog(context);
  }

  showUrlDialog(BuildContext context) async {
    var urlTfController = TextEditingController(text: photoURL);
    // create the buttons
    var cancelBtn = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    var okBtn = FlatButton(
      child: Text("OK"),
      onPressed: () {
        var url = urlTfController.text.trim();
        photoURL = url.isEmpty ? null : url;
        Navigator.pop(context);
      },
    );
    var alert = AlertDialog(
      title: Text("Image Address"),
      content: TextField(
        controller: urlTfController,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: 'Enter image address',
        ),
      ),
      actions: [
        cancelBtn,
        okBtn,
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _messageFieldController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _chat = ModalRoute.of(context).settings.arguments as ElfChat;
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/user',
              arguments: UserPageArguments(
                elfUser: _chat.user,
                form: UserDetailsForm.Chat,
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(_chat.user.photoURL),
                radius: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(_chat.user.displayName),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder(
              stream: widget._db.getChatMsgsStream(_chat.chatID),
              builder: (context, snapshot) {
                // update messages list
                if (snapshot.connectionState == ConnectionState.active)
                  _messages = [for (var doc in snapshot.data.docs) ElfMessage.fromJson(doc.data())];

                // build it
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MessageBubble(
                      _messages[index],
                      isSent: _messages[index].userID == widget._auth.user.uid,
                      isFirstFromUser: (index + 1 < _messages.length)
                          ? _messages[index + 1].userID != _messages[index].userID
                          : true,
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      // Pic picker
                      IconButton(
                        icon: Icon(
                          photoURL == null ? Icons.image_search : Icons.image_outlined,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          photoPic(context);
                        },
                      ),
                      // Message TextField
                      Expanded(
                        child: TextField(
                          controller: _messageFieldController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type a message',
                            hintStyle: TextStyle(
                              color: Colors.grey[350],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Send button
              Container(
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(360),
                ),
                child: IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.white,
                  onPressed: () => sendMessage(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
