import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'contacts.dart';
import 'message_model.dart';

List<MessageModel> messages = [
  MessageModel("Hello", DateTime.now()),
  MessageModel("Hi", DateTime.now()),
  MessageModel("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", DateTime.now()),
  MessageModel("Test text", DateTime.now())
];

class ChatPage extends StatefulWidget {
  final Person person;

  ChatPage({Key key, @required this.person}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

bool newestMessageLeft(int index){ 
  return (index == messages.length-1);
}

bool newestMessageRight(int index){ 
  return (index == messages.length-1);
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = new ScrollController();
  final TextEditingController textEditingController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  void onSendMessage(String content, int type) {
    textEditingController.clear();
    messages.add(MessageModel(content, DateTime.now()));
    listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text(widget.person.name),),
      backgroundColor: Colors.white,
      body:Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessageList(),
              buildInput()
            ],
          )
        ],
      ),
    );
  }

  Widget buildMessageList(){
    return  Flexible(
      child: ListView.builder(
        itemBuilder: (context, index) => buildMessage(index, messages[index]),
        itemCount: messages.length,
        //reverse: true,
        controller: listScrollController, 
        padding: EdgeInsets.all(10.0),
      ),
    );
  }

  
  Widget buildInput(){
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
              child: Container(
                child: TextField(
                  style: TextStyle(color: Colors.red, fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),
          Material(
            child: new Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: new Icon(Icons.send),
                color: Colors.red,
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            )
          )
        ],
        ),
    );
  }

}

Widget buildMessage(index, MessageModel message){
  if (index%2 == 0){
    // right
    return Row(
      children: <Widget>[
        Container(
          child: Text(message.text, style: TextStyle(color:Colors.white)),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          width: 200.0,
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(bottom: newestMessageRight(index) ?  20.0 : 10.0, right: 10.0),
        )
      ],  
      mainAxisAlignment: MainAxisAlignment.end,
    );
  } else {
    // left
    return Row(
      children: <Widget>[
        Container(
          child: Text(message.text, style: TextStyle(color:Colors.white)),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          width: 200.0,
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(bottom: newestMessageLeft(index) ? 20.0 : 10.0, left: 10.0),
        )
      ],  
    );
  }
}