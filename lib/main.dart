// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //createNewUser();
  runApp(const MyApp());
}

Future<void> createNewUser() async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "email@mail.ru",
      password: "NEREALNOJOSKIYPASSWORD1488",
    );
    print("User created successfully: ${userCredential.user!.email}");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorization'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Здравствуйте, ${FirebaseAuth.instance.currentUser}")));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found' ||
                          e.code == 'wrong-password') {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Неверное имя пользователя или пароль!")));
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: const Text('Authorize'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    FirebaseAuth.instance.signInAnonymously().then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Здравствуйте, ${FirebaseAuth.instance.currentUser}")));
                    });
                  },
                  child: const Text('Authorize anonimously')),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.sendSignInLinkToEmail(
                          email: _emailController.text,
                          actionCodeSettings: ActionCodeSettings(
                            url: 'https://firebaza.page.link/kPAc',
                            androidPackageName: 'com.example.firebaza',
                            handleCodeInApp: true,
                            androidInstallApp: true,
                          ));
                      if (FirebaseAuth.instance.isSignInWithEmailLink(
                          'https://firebaza.page.link/kPAc')) {
                        try {
                          await FirebaseAuth.instance.signInWithEmailLink(
                              email: _emailController.text,
                              emailLink: "https://firebaza.page.link/kPAc");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              "Здравствуйте, ${FirebaseAuth.instance.currentUser}",
                            ),
                          ));
                        } on FirebaseAuthException catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Ошибка!"),
                          ));
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.code),
                      ));
                    } 
                  },
                  child: const Text("Auth with link"))
            ],
          ),
        ),
      ),
    );
  }
}
