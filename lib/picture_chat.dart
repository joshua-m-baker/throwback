import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:throwback/models.dart/picture_message.dart';
import 'router.dart';

class PictureChat extends StatefulWidget {

  //final String chatId;
  final PictureMessage pictureMessage;

  //ChatPage({Key key, @required this.myId, @required this.peerId, @required this.peerName}) : super(key: key);
  PictureChat({Key key, @required this.pictureMessage }) : super(key: key);

  @override
  _PictureChatStaate createState() => _PictureChatStaate();
}

class _PictureChatStaate extends State<PictureChat>{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pictureMessage.title),),
      body: Column(
      children: <Widget>[ //change 
        Container( 
          child: Hero(
            child: buildImage(),
            tag: widget.pictureMessage.url
          ),
        ),
        Expanded(
          child: SizedBox(
            child: 
              ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => Text(index.toString()),
                itemCount: 100,
              ),
            height: 500,
          ) 
        ,)
        ]
      ,)
    ,);        
  }

  CachedNetworkImage buildImage(){
    return CachedNetworkImage(
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
        imageUrl: widget.pictureMessage.url,
        //width: 200.0,
        //height: 200.0,
        fit: BoxFit.contain,
    );
  }
}