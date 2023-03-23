
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class mainview extends StatefulWidget {
  const mainview({super.key});
  static const routeName = "/mainview";

  @override
  State<mainview> createState() => _mainviewState();
}

class _mainviewState extends State<mainview> {
    TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('user').snapshots();
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              setState(() {
                showAddScreen();
              });
            },
            child: const Text("Добавить")),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          return
              ListView(
                padding: const EdgeInsets.all(8),
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () async {
                                      deleteUser(document.id);
                                  },
                                  child: Text("Удалить"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showUpdateScreen(data['email'], document.id );
                                    });
                                  },
                                  child: Text("Обновить"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      Text(data['email'])
                                ),
                              ]

                      );
                      
                    })
                    .toList()
                    .cast(),
              );
        },
      ),
    );
  }

  void showUpdateScreen(String email, String uid) async {
    _emailController.text = email;
    showDialog(
      context: context,
      builder: (context) => gradeDialog(1, uid),
    );
  }
  
  void showAddScreen() async {
    _emailController.text ='';
                showDialog(
      context: context,
      builder: (context) => gradeDialog(-1, ''),
    );
  }

  StatefulBuilder gradeDialog(int index, String uid) {
    return StatefulBuilder(
      builder: (context, _setter) {
        return SimpleDialog(
          children: [
            const Spacer(),
            const Text(
              'Управление',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26),
            ),
            const Spacer(),
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Поле email пустое';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                child: Text("Сохранить"),
                onPressed: () {
                  if(index!=-1)
                  {
                    updUser(uid);
                  }
                  else{
                    addUser();
                  }
                }),
          ],
        );
      },
    );
  }
    void addUser() async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
      await fireStore
          .collection('user')
          .add(
            {'email': _emailController.text},
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User Added"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to add user: $error"))));
      Navigator.pop(context);
  }

  void updUser(String uid) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
      await fireStore
          .collection('user').doc(uid)
          .set(
            {'email': _emailController.text},
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User Update"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update user: $error"))));
      Navigator.pop(context);
  }

  void deleteUser(String uid) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection('user').doc(uid)
          .delete(
          )
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("User Delete"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to delete user: $error"))));
  }
}