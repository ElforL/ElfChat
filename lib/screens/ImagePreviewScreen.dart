import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final Function sendFunction;

  const ImagePreviewScreen({Key key, this.sendFunction, this.imageFile}) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://elfchat-a7e0f.appspot.com');
  UploadTask _uploadTask;

  var _tfController = TextEditingController();

  bool get _isUploading => _uploadTask != null;

  _send() {
    var filePath = 'images/${DateTime.now().toString()}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.imageFile);
    });

    _uploadTask.whenComplete(() async {
      var imageURL = await _storage.ref(filePath).getDownloadURL();
      widget.sendFunction(_tfController, imageURL);
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // the scaffold is the child so the image can be in the background.
    // using Stack would cause the image to resize when the keyboard is on.
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(widget.imageFile),
          alignment: Alignment.center,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.cancel,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            // Uploading row
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUploading)
                      StreamBuilder(
                        stream: _uploadTask.snapshotEvents,
                        builder: (context, snapshot) {
                          var event = snapshot?.data;
                          double progressPercent = event != null ? event.bytesTransferred / event.totalBytes : 0;

                          return LinearProgressIndicator(value: progressPercent);
                        },
                      ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.black38,
              child: Row(
                children: [
                  // Textfield
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _tfController,
                        minLines: 1,
                        maxLines: 3,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: Colors.grey[350],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Send Btn
                  Container(
                    color: _isUploading ? Colors.grey : Colors.green,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      // disable the button when it's uploading
                      onPressed: _isUploading ? null : () => _send(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
