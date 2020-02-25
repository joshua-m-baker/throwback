import 'contacts.dart';

class MessageModel {
  Person to;
  Person from;
  String text; 
  DateTime timestamp;

  MessageModel(this.text, this.timestamp);

}