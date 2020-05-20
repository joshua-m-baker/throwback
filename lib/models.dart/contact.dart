
import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String uid;
  String email;
  String name;
  String chatId;

  Contact(String myId, String uid, String email, String name){
    this.uid = uid;
    this.email = email;
    this.name = name;
    this.chatId = _genChatId(myId, this.uid);
  }

  Contact.fromDocument(String myId, DocumentSnapshot snapshot){
    this.uid = snapshot.documentID;
    this.email = snapshot.data['email'];
    this.name = snapshot.data['name'];
    this.chatId = _genChatId(myId, this.uid);
  }

  String _genChatId(String myId, String peerId){
    if (myId.hashCode <= peerId.hashCode) {
      return myId + peerId;
    } else {
      return peerId + myId;
    }
  }
}