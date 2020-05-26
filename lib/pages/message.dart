
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
  bool hasTitle = message.title != '';
  print(message.title);
  print(hasTitle);
  return Row(
    children: <Widget>[
      Flexible(
        child: FractionallySizedBox(
          widthFactor: width,
          child: Container(
            decoration: hasTitle ? BoxDecoration(
              color: sentByMe ? Colors.blue[400] : Colors.grey[300], 
              borderRadius: BorderRadius.all(Radius.circular(6.0))
            ) : null,
            //padding: EdgeInsets.only(top: 10),
            //padding: EdgeInsets.all(0),
            margin: EdgeInsets.symmetric(
              vertical: 2, 
              horizontal: 10
            ),
            child: Column(
              children: <Widget>[
                hasTitle ? Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    message.title,
                    style: TextStyle(
                      color: sentByMe ? Colors.white : Colors.black,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ) : Container(),
                _buildPicture(context, message),
              ],
              //crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ),
      ),
    ],
    mainAxisAlignment: sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
      clipBehavior: Clip.antiAlias,
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