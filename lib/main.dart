import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'contacts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Helvetica',
      ),
      
      home: ContactsPage(),
    );
  }
}

class ContactsPage extends StatefulWidget {
  ContactsPage({Key key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Throwback"),),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index){
          return ListTile(
            title: Text(contacts[index].name),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ChatPage(person: contacts[index]),
                ),
              );
            },
          );
          // return Container(
          //   height: 50,
          //   color: Colors.blue[50],
          //   // padding: EdgeInsets.only(left: 8),
          //   child: Text(contacts[index].name, style: Theme.of(context).textTheme.title), 
          // );
        },
        
      ),
    );
  }
}

