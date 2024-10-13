import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

String message = '';
int initialize = 1;

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  // change StatelessWidget to StatefulWidget
  MyApp({Key? key}) : super(key: key);
  int currentIndex = 0;
  int activeuser = -1;
  @override
  _MyAppState createState() => _MyAppState();
}

String greetingMessage = "";
/* void userTalking() {
  setState(() {
    greetingMessage = "Hello, " + myController.text;    
  });
} */

class _MyAppState extends State<MyApp> {
  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
    ].request();

    if (statuses.containsValue(PermissionStatus.denied)) {
      Fluttertoast.showToast(
          msg: "App may malfunction without granted permissions",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  Future<File> writeData(String u, String p) async {
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/data.json');
    String text = await file.readAsString();
    Map<String, dynamic> d = jsonDecode(text);
    List<dynamic> i = d['users'];
    Map<String, dynamic> e = {'username': u, 'password': p, 'messages': ''};
    i.add(e);
    d['users'] = i;
    return file.writeAsString(jsonEncode(d));
  }

  Future<Map<String, dynamic>> get jsonData async {
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/data.json');
    String text = await file.readAsString();
    final data = jsonDecode(text);
    return data;
  }

  void init() {
    jsonData.then((Map<String, dynamic> a) {
      setState(() {
        List<dynamic> b = a['users'];
        _items = b;
      });
    });
  }

  int currentIndex = 0;
  final TextEditingController textController = TextEditingController();
  final TextEditingController textController2 = TextEditingController();
  int activeuser = -1;
  List<dynamic> _items = <dynamic>[];

  @override
  Widget build(BuildContext context) {
    if (initialize == 1) {
      init();
      setState(() {
        initialize = 0;
      });
    }
    textController.text = "";
    textController2.text = "";

    List<String> messages = [];
    if (activeuser != -1) {
      String message_css = _items[activeuser]["messages"];
      messages = message_css.split("~@+}{");
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            /*appBar: AppBar(
              
            ),*/

            backgroundColor: const Color(0xffbdc4ff),
            appBar: AppBar(
                title: const Center(
                    child: Row(children: [
              Image(
                image: AssetImage("lib/mentalplus.png"),
                alignment: Alignment.centerLeft,
                height: 60,
                width: 60,), 
                Text("           Mental Plus",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 20,
                    ))],
                // Text(_items[0]),
              ),
            )),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_people_rounded),
                  label: "Profile",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
              currentIndex: currentIndex < 3 ? currentIndex : 0,
              onTap: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            body: currentIndex == 0 && activeuser == -1
                ? Center(
                    child: SingleChildScrollView(
                        child: Column(
                    children: [
                      const Image(
                          image: AssetImage("lib/mentalplus.png"),
                          height: 100,
                          width: 100),
                      Container(
                        child: const Text(
                            "Welcome to Mental Plus! Please Log In or Sign Up on the 'Profile' tab to use our app."),
                        width: 300,
                      ),
                    ],
                  )))
                : currentIndex == 0 && activeuser != -1
                    ? Container(
                        alignment: Alignment.topCenter,
                        child: Column(children: [
                          Text (
                          // ignore: prefer_interpolation_to_compose_strings
                          " Hello, " + _items[activeuser]['username']
                          ),
                          const Text(
                            "Chat",
                          ),
                          const Text("Messages"),
                          Container(
                            child: messages.length == 1
                                ? const Text("No Messages!")
                                : ListView.builder(
                                    physics:
                                        const BouncingScrollPhysics(), // Disable scrolling for ListView
                                    shrinkWrap:
                                        true, // Make the ListView occupy
                                    itemCount: messages.length - 1,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Row(children: [
                                          Text(messages[index]),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  print("Delete");
                                                },
                                                child: const Text(
                                                  "Delete",
                                                  textAlign: TextAlign.right,
                                                )),
                                          )
                                        ]),
                                      );
                                    }),
                          ),
                          TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12),
                                  hintText:
                                      'You can type your message in here...')),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () {},
                            child: const Text('Enter'),
                          )
                        ]))

                    // Adjust based on the actual structure of your JSON
                    : currentIndex == 1 && activeuser == -1
                        ? Center(
                            child: Row(
                            children: [
                              Container(
                                color: const Color(0xffffffff),
                                width: 100.0,
                                height: 80.0,
                                margin: const EdgeInsets.all(40.0),
                                child: FloatingActionButton(
                                    child: const Text("Log In"),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex = 3;
                                      });
                                    }),
                              ),
                              Container(
                                color: const Color(0xffffffff),
                                width: 100.0,
                                height: 80.0,
                                margin: const EdgeInsets.all(40.0),
                                child: FloatingActionButton(
                                    child: const Text("Sign Up"),
                                    onPressed: () {
                                      setState(() {
                                        currentIndex = 4;
                                      });
                                    }),
                              ),
                            ],
                          ))
                        : currentIndex == 3
                            ? Center(
                                child: Column(children: [
                                  TextField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                        hintText: "Username"),
                                  ),
                                  TextField(
                                    controller: textController2,
                                    decoration: const InputDecoration(
                                        hintText: "Password"),
                                    obscureText: true,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          bool foundAccount = false;
                                          init();
                                          for (int i = 0;
                                              i < _items.length;
                                              i++) {
                                            if (foundAccount ||
                                                _items[i]['username'] ==
                                                    textController.text) {
                                              if (_items[i]['password'] ==
                                                  textController2.text) {
                                                activeuser = i;
                                                currentIndex = 0;
                                                foundAccount = true;
                                              }
                                            }
                                          }
                                          if (!foundAccount) {
                                            currentIndex = 3;
                                            print(
                                                "Invalid username or password");
                                          }
                                        });
                                      },
                                      child: const Text('Log in'))
                                ]),
                              )
                            : currentIndex == 1
                                ? Center(
                                    child: Column(children: [
                                      /*
                                  Text("Change user information:"),
                                  TextField(
                                    controller: textController,
                                    decoration:
                                        InputDecoration(hintText: "Username"),
                                  ),
                                  TextField(
                                    controller: textController2,
                                    decoration:
                                        InputDecoration(hintText: "Password"),
                                  ),
                                  ElevatedButton(
                                    child: Text("Change"),
                                    onPressed: () {
                                      setState(() {
                                        _items[activeuser]["username"] =
                                            textController.text;
                                        _items[activeuser]["password"] =
                                            textController2.text;
                                        print("info changed");
                                      });
                                    },
                                  ),*/
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              activeuser = -1;
                                            });
                                          },
                                          child: const Text("Log Out"))
                                    ]),
                                  )
                                : currentIndex == 4
                                    ? Center(
                                        child: Column(children: [
                                          const Text("Sign Up:"),
                                          TextField(
                                            controller: textController,
                                            decoration: const InputDecoration(
                                                hintText: "Username"),
                                          ),
                                          TextField(
                                            controller: textController2,
                                            decoration: const InputDecoration(
                                                hintText: "Password"),
                                            obscureText: true,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  bool newAcc = true;
                                                  String t =
                                                      textController.text;
                                                  String t2 =
                                                      textController2.text;
                                                  for (int i = 0;
                                                      i < _items.length;
                                                      i++) {
                                                    if (textController.text ==
                                                        _items[i]['username']) {
                                                      newAcc = false;
                                                    }
                                                  }
                                                  if (newAcc) {
                                                    writeData(t, t2);
                                                    setState(() {
                                                      activeuser = _items.length;
                                                      currentIndex = 0;
                                                    });
                                                  } else {
                                                    print(
                                                        "Username already in use");
                                                    textController.clear();
                                                    textController2.clear();
                                                  }
                                                });
                                              },
                                              child: const Text("Submit"))
                                        ]),
                                      )
                                    : const Center(
                                        child: Text('404: Page Not Found!'),
                                      )));
  }
}
