import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class PictureChat extends StatefulWidget {

  // final String myId;
  // final String peerId;
  // final String peerName;

  final String chatId;
  final String imageLink;

  //ChatPage({Key key, @required this.myId, @required this.peerId, @required this.peerName}) : super(key: key);
  PictureChat({Key key, @required this.chatId, @required this.imageLink }) : super(key: key);

  @override
  _PictureChatStaate createState() => _PictureChatStaate();
}

class _PictureChatStaate extends State<PictureChat>{
  
  @override
  Widget build(BuildContext context) {
    return 
        
  }

  CachedNetworkImage buildImage(){
    CachedNetworkImage(
        placeholder: (context, url) => Container(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          padding: EdgeInsets.all(70.0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Material(
          child: Text("Error getting image"),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          clipBehavior: Clip.hardEdge,
        ),
        imageUrl: widget.imageLink,
        //width: 200.0,
        //height: 200.0,
        fit: BoxFit.contain,
    );
  }
}