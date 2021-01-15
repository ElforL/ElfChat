import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/Message.dart';
import 'package:elfchat/screens/UserPage.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:elfchat/widgets/ChatInput.dart';
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
  final ScrollController _scrollController = ScrollController();

  ElfChat _chat;
  List<ElfMessage> _messages = [];

  void scrollToBottom() {
    if (_scrollController.hasClients)
      _scrollController.animateTo(
        0,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
  }

  void sendMessage(TextEditingController _msgController, String photoURL) async {
    var messageText = _msgController.text.trim();
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
      _msgController.text = '';
      if (photoURL != null)
        setState(() {
          photoURL = null;
        });
      scrollToBottom();
    }
  }

  @override
  void dispose() {
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Input(sendFunction: sendMessage),
          )
        ],
      ),
    );
  }
}
