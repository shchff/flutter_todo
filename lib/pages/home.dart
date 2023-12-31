import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String? _userTodo;
  List todoList = [];



  @override
  void initState() {
    super.initState();

    // initFirebase();

    todoList.addAll(['Buy milk', 'Wash car']);
  }

  void _menuOpen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text('Меню'),),
          body: Row(
            children: [
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }, child: Text('На главную')),
              Padding(padding: EdgeInsets.only(left: 15)),
              Text('Наше простое меню')
            ],    
          ),
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Список дел'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.menu_outlined),
            onPressed: _menuOpen,
          )
        ],
        // backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text('Нет записей');
          }
          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  // key: UniqueKey(),
                  key: Key(snapshot.data!.docs[index].id),
                  child: Card(
                    child: ListTile(
                      title: Text(snapshot.data!.docs[index].get('item')),
                      trailing: IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance.collection('items').doc(snapshot.data!.docs[index].id).delete();
                          },
                          icon: Icon(Icons.delete_sweep),
                          color: Colors.deepOrangeAccent
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    FirebaseFirestore.instance.collection('items').doc(snapshot.data!.docs[index].id).delete();
                  },
                );
              }
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Добавить элемент'),
              content: TextField(
                onChanged: (String value) {
                  _userTodo = value;
                },
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('items').add({'item': _userTodo});
                      Navigator.of(context).pop();
                    },
                    child: Text('Добавить')
                )
              ],
            );
          });
        },
        child: Icon(
          Icons.add_box,
          color: Colors.white,
        ),
      ),
    );
  }
}
