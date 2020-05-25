
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:throwback/models/auth_model.dart';
import 'package:throwback/models/picture_message.dart';
import 'package:throwback/util/router.dart';

double width = .70;
// TODO constants file
// TODO figure out color background going past image

Widget buildMessage(BuildContext context, DocumentSnapshot document){
  PictureMessage message = PictureMessage.fromDocument(document);
  bool sentByMe = message.fromId == ScopedModel.of<ApiModel>(context).user.uid;
  return Row(
    children: <Widget>[
      Flexible(
        child: FractionallySizedBox(
          widthFactor: width,
          child: Container(
            decoration: BoxDecoration(
                color: sentByMe ? Colors.lightBlueAccent : Colors.lightBlueAccent, 
                borderRadius: BorderRadius.all(Radius.circular(6.0))
            ),
            padding: EdgeInsets.only(top: 10),
            margin: EdgeInsets.symmetric(
              vertical: 2, 
              horizontal: 10
              ),
            child: Column(
              children: <Widget>[
                Text(
                  message.title == '' ? "Title" : message.title,
                  style: TextStyle(color: Colors.white),
                ),
                _buildPicture(context, message),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ),
      ),
    ],
    mainAxisAlignment: sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
  );
}

Widget buildMessageOld(BuildContext context, DocumentSnapshot document){
  PictureMessage message = PictureMessage.fromDocument(document);
  return Row(
    children: <Widget>[
      Flexible(
        child: FractionallySizedBox(
          widthFactor: .70,
          child: Container(
            margin: EdgeInsets.fromLTRB(7, 0, 7, 7),
            child: Stack(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: new Text(
                    "Title",
                    style: TextStyle(backgroundColor: Colors.green),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: _buildPicture(context, message),

                )
                
              ],
            )
            //margin: EdgeInsets.only(bottom: 10.0), //todo maybe add padding to bottom of screen instead
          ),
        ),
      )
    ],
    mainAxisAlignment: message.fromId == ScopedModel.of<ApiModel>(context).user.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
  );
}

Widget _buildPicture(BuildContext context, PictureMessage message){
  return FlatButton(
    child: Material(
      child: Hero(child: 
        CachedNetworkImage(
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          imageUrl: message.url,
          fit: BoxFit.cover,
        ),
        tag: message.url
      ),

      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      clipBehavior: Clip.hardEdge,
    ),
    onPressed: () {
      Navigator.pushNamed(
        context, 
        Routes.picture_chat, 
        arguments: message
      );
    },
    padding: EdgeInsets.all(0),
  );
}