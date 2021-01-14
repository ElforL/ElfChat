import 'package:elfchat/models/Message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(
    this.message, {
    this.isSent = false,
    this.isFirstFromUser = true,
  });

  final ElfMessage message;

  /// true if the message is from the current user
  final bool isSent;

  /// if this message is the first from this user
  final bool isFirstFromUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 5,
        left: 5,
        bottom: 2,
        top: isFirstFromUser ? 5 : 1,
      ),
      child: Column(
        // Alignment
        crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            // set max width
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: isSent ? Colors.green[300] : Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Picture
                if (message.photoURL != null && message.photoURL.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Image.network(
                      message.photoURL,
                      errorBuilder: (context, error, stackTrace) {
                        return ImageErrorBox(isSent: isSent);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return ImageLoadingBox(isSent: isSent, loadingProgress: loadingProgress);
                      },
                    ),
                  ),
                // Message text
                if (message.message.isNotEmpty || message.photoURL == null || message.photoURL.isEmpty)
                  Text(
                    message.message,
                    maxLines: null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageErrorBox extends StatelessWidget {
  const ImageErrorBox({
    Key key,
    @required this.isSent,
  }) : super(key: key);

  final bool isSent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSent ? Colors.green[400] : Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      height: 150,
      width: 200,
      child: Center(
        child: Icon(Icons.broken_image, color: isSent ? Colors.white : Colors.grey),
      ),
    );
  }
}

class ImageLoadingBox extends StatelessWidget {
  const ImageLoadingBox({
    Key key,
    @required this.isSent,
    this.loadingProgress,
  }) : super(key: key);

  final bool isSent;
  final ImageChunkEvent loadingProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSent ? Colors.green[400] : Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      height: 150,
      width: 200,
      child: Stack(
        children: [
          Center(child: Icon(Icons.image, color: Colors.white)),
          Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
