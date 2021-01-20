import 'dart:io';

import 'package:elfchat/screens/ImagePreviewScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  _pickImage(ImageSource source) async {
    var imagePicker = ImagePicker();
    var selected = await imagePicker.getImage(source: source);

    if (selected != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            imageFile: File(selected.path),
            sendFunction: widget.sendFunction,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Pic picker
                IconButton(
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await _pickImage(ImageSource.gallery);
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
                widget.sendFunction(_messageFieldController, null);
              });
            },
          ),
        ),
      ],
    );
  }
}
