import 'package:elfchat/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogInPage extends StatelessWidget {
  final AuthServices auth;

  const LogInPage({Key key, @required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                child: Image.asset('assets/elf.png'),
                height: 150,
              ),
            ),
            // Google button
            RaisedButton(
              child: Container(
                width: 200,
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      child: Image.asset('assets/googleLogo.png'),
                    ),
                    Expanded(
                      child: Text(
                        'Sign in with Google',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              color: Colors.white,
              onPressed: () async {
                try {
                  await auth.signInWithGoogle();
                } on PlatformException catch (e) {
                  if (e.code == 'network_error') {
                    showNetworkErrorDialog(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  showNetworkErrorDialog(BuildContext context) {
    // create the buttons
    var okBtn = FlatButton(
      child: Text(
        "OK",
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    var alert = AlertDialog(
      title: Text("Network Error"),
      content: Text("There was a problem connecting to the servers.\nPlease try again later."),
      actions: [
        okBtn,
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
