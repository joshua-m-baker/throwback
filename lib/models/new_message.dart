

import 'dart:io';

class NewMessage {
  File imageFile;
  String imageUrl;
  String toId;
  String chatId;

  String title;
  String description;

  NewMessage(this.imageFile, this.imageUrl, this.toId, this.chatId, this.title, this.description);
  
}