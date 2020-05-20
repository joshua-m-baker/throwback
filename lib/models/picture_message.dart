
import 'package:cloud_firestore/cloud_firestore.dart';

class PictureMessage {
  String messageId;
  String fromId;
  String toId;
  String chatId;
  int timestamp;
  String url;
  String title;
  String description;

  PictureMessage(this.messageId, this.fromId, this.toId, this.chatId, this.timestamp, this.url, this.title, this.description);

  PictureMessage.fromDocument(DocumentSnapshot document){
    this.messageId =  document['messageId'];
    this.fromId = document['fromId'];
    this.toId = document['toId'];
    this.chatId = document['chatId'];
    this.timestamp = document['timestamp'];
    this.url = document['url'];
    this.title = document['title'];
    this.description = document['description'];
  }
}
