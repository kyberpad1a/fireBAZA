// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebaza/mainview.dart';
import 'package:firebaza/registration.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  const MyApp({Key? key}) : super(key: key);
static const routeName = '/signin';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes:         {
      MyApp.routeName: (context) =>  const MyApp(),
        SignUp.routeName: (context) =>  const SignUp(),
        mainview.routeName: (context) => mainview(),
        }
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  @override
  void initState() {
    super.initState();
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData data) async {
      final Uri? uri = data?.link;
      if (uri != null) {
        try {
          if (FirebaseAuth.instance.isSignInWithEmailLink(uri.toString())) {
            final String email = _emailController.text;
            await FirebaseAuth.instance.signInWithEmailLink(
              email: email,
              emailLink: uri.toString(),
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("Здравствуйте, ${FirebaseAuth.instance.currentUser}"),
            ));
          }
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ошибка входа'),
          ));
        }
      }
    });
  }

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
                      Navigator.pushNamed(context, mainview.routeName);
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
                    String email = '';
                    email = _emailController.text;
                    try {
                      await FirebaseAuth.instance.sendSignInLinkToEmail(
                          email: email,
                          actionCodeSettings: ActionCodeSettings(
                            url: 'https://firebaza.page.link/kPAc',
                            androidPackageName: 'com.example.firebaza',
                            handleCodeInApp: true,
                            androidInstallApp: true,
                          ));

                      // if (FirebaseAuth.instance.isSignInWithEmailLink(
                      //     'https://firebaza.page.link/kPAc')) {
                      //   try {
                      //     await FirebaseAuth.instance.signInWithEmailLink(
                      //         email: email,
                      //         emailLink: "https://firebaza.page.link/kPAc");
                      //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //       content: Text(
                      //         "Здравствуйте, ${FirebaseAuth.instance.currentUser}",
                      //       ),
                      //     ));
                      //   } on FirebaseAuthException catch (e) {
                      //     print(e);
                      //     ScaffoldMessenger.of(context)
                      //         .showSnackBar(const SnackBar(
                      //       content: Text("Ошибка!"),
                      //     ));
                      //   }
                      // }
                    } on FirebaseAuthException catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.code),
                      ));
                    }
                  },
                  child: const Text("Auth with link")),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      signInWithGoogle().then((value) => {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Здравствуйте, ${FirebaseAuth.instance.currentUser}")))
                          });
                      UserCredential userCredential = await signInWithGoogle();
                      User user = userCredential.user!;
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.code)));
                    }
                  },
                  child: Text("Google Sign-in")),
                  ElevatedButton(onPressed: () async {
                    Navigator.pushNamed(context, SignUp.routeName);
                  }, child: Text("Регистрация"))
            ],
          ),
        ),
      ),
    );
  }
}
