import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    Key key,
    @required this.photoURL,
  }) : super(key: key);

  final String photoURL;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.photoURL,
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Icon(Icons.broken_image));
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
              value: loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes),
        );
      },
    );
  }
}
