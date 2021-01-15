import 'package:elfchat/widgets/ImagePreview.dart';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final Function sendFunction;

  const Input({
    @required this.sendFunction,
  });

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final TextEditingController _messageFieldController = TextEditingController();
  String photoURL;

  final _animationDuration = Duration(milliseconds: 200);

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
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => urlTfController.clear(),
          ),
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
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: AnimatedContainer(
                  color: Colors.white,
                  duration: _animationDuration,
                  height: photoURL != null ? 200 : 0,
                  child: photoURL != null ? ImagePreview(key: ValueKey(photoURL), photoURL: photoURL) : null,
                ),
              ),
              // The textfield
              AnimatedContainer(
                duration: photoURL == null ? _animationDuration * 3 : Duration.zero,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                    top: photoURL == null ? Radius.circular(20) : Radius.zero,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Pic picker
                        IconButton(
                          icon: Icon(
                            photoURL == null ? Icons.image_search : Icons.image_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            await showUrlDialog(context);
                            setState(() {});
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
                  ],
                ),
              ),
            ],
          ),
        ),
        // Send button
        Container(
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(360),
          ),
          child: IconButton(
              icon: Icon(Icons.send),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  widget.sendFunction(_messageFieldController, photoURL);
                  photoURL = null;
                });
              }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageFieldController.dispose();
    super.dispose();
  }
}
