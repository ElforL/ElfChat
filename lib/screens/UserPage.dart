import 'package:elfchat/models/Chat.dart';
import 'package:elfchat/models/User.dart';
import 'package:elfchat/services/FireStoreServices.dart';
import 'package:elfchat/services/auth.dart';
import 'package:elfchat/widgets/MyButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  UserPage(this.db, this.auth);

  final FireStoreServices db;
  final AuthServices auth;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  UserDetailsForm form;
  var user;
  bool get isForLoggedIn => form == UserDetailsForm.LoggedIn;

  _signOut() {
    // sign out of firebase
    widget.auth.signOut();
    // pop until authWrapper
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _chatFunciton() async {
    var chat = await widget.db.getChatWithUser(widget.auth.user.uid, user.userID);
    Navigator.pushReplacementNamed(
      context,
      '/chat',
      arguments: ElfChat(user, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments as UserPageArguments;
    user = args.elfUser ?? args.user;
    form = args.form;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? 'User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Username
                  ListTile(
                    // The icon and the text
                    leading: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    title: Text(
                      user.displayName,
                      style: TextStyle(color: Colors.black),
                    ),
                    // Edit Button
                    trailing: isForLoggedIn
                        ? IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 18,
                            ),
                            onPressed: () {},
                          )
                        : null,
                  ),
                  // User Email
                  ListTile(
                    // The icon and the text
                    leading: Icon(
                      Icons.alternate_email,
                      color: Colors.black,
                    ),
                    title: Text(
                      user.email,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            // SignOut Btn
            if (isForLoggedIn) SignOutButton(_signOut),
            if (!isForLoggedIn)
              BottomButtons(
                form,
                chatFunction: _chatFunciton,
              ),
          ],
        ),
      ),
    );
  }
}

class BottomButtons extends StatelessWidget {
  final UserDetailsForm form;

  final Function blockFunction;
  final Function reportFunction;
  final Function chatFunction;

  const BottomButtons(this.form, {this.blockFunction, this.reportFunction, this.chatFunction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyButton(
          color: Colors.red,
          text: 'BLOCK',
          icon: Icon(Icons.block),
          onPressed: blockFunction ?? () {},
        ),
        if (form == UserDetailsForm.Chat)
          MyButton(
            color: Colors.red,
            text: 'REPORT',
            icon: Icon(Icons.report),
            onPressed: reportFunction ?? () {},
          ),
        if (form == UserDetailsForm.Search)
          MyButton(
            color: Colors.green,
            text: 'CHAT',
            icon: Icon(Icons.chat, size: 20),
            onPressed: chatFunction ?? () {},
          ),
      ],
    );
  }
}

class SignOutButton extends StatelessWidget {
  final Function signOutFunc;

  const SignOutButton(this.signOutFunc);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('SIGN OUT'),
      color: Colors.red,
      onPressed: () {
        showConfrimSignoutDialog(context);
      },
    );
  }

  showConfrimSignoutDialog(BuildContext context) {
    // create the buttons
    var cancelBtn = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    var signoutBtn = FlatButton(
      child: Text("SIGN OUT"),
      onPressed: signOutFunc,
    );
    var alert = AlertDialog(
      title: Text("Sign out"),
      content: Text("Are you sure you want to sign out?"),
      actions: [
        cancelBtn,
        signoutBtn,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class UserPageArguments {
  final ElfUser elfUser;
  final User user;
  final UserDetailsForm form;

  UserPageArguments({this.elfUser, this.user, this.form});
}

enum UserDetailsForm {
  LoggedIn,
  Chat,
  Search,
}
