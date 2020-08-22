import 'package:Flutter_CRUD/Model/User.dart';
import 'package:Flutter_CRUD/Services/UserService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Stateful Widget Class
class HomeView extends StatefulWidget {
  HomeView() : super();
  final String title = 'Flutter Firebase CRUD';

  @override
  _FirebaseFireStoreDemoState createState() => _FirebaseFireStoreDemoState();
}

class _FirebaseFireStoreDemoState extends State<HomeView> {
  bool _showTextField = false;
  bool isEditing = false;
  TextEditingController controller = new TextEditingController();
  UserService userService;
  User user, curUser;

  @override
  void initState() {
    super.initState();
    user = new User();
    userService = new UserService();
  }

  //Widget for List
  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => buildListItem(context, data)).toList(),
    );
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: userService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error} ');
        }
        if (snapshot.hasData) {
          print("Documents ${snapshot.data.docs.length}");
          return buildList(context, snapshot.data.docs);
        }
        return CircularProgressIndicator();
      },
    );
  }

  //Widget for ListItem
  Widget buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);
    return Padding(
      key: ValueKey(user.name),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(user.name),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              userService.delete(user);
            },
          ),
          onTap: () {
            setUpdateUI(user);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _showTextField = !_showTextField;
                });
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //If ShowTextField Set
              _showTextField
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: "Name",
                            hintText: "Enter Name",
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //Calls Button Method
                        button()
                      ],
                    )
                  //Else Empty Container
                  : Container(),
              SizedBox(
                height: 20,
              ),
              Text(
                "USERS",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 20,
              ),
              Flexible(
                child: buildBody(context),
              )
            ],
          ),
        ));
  }

  //Functions
  add() {
    if (isEditing) {
      userService.update(curUser, controller.text);
    } else {
      userService.addUser(controller.text);
    }
    controller.text = '';
  }

  button() {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        child: Text(isEditing ? "UPDATE" : "ADD"),
        onPressed: () {
          add();
          setState(() {
            _showTextField = false;
          });
        },
      ),
    );
  }

  setUpdateUI(User user) {
    controller.text = user.name;
    setState(() {
      _showTextField = true;
      isEditing = true;
      curUser = user;
    });
  }
}
