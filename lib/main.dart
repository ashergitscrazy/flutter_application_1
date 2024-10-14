import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

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
    Map<String, dynamic> e = {
      'username': u,
      'password': p,
      'messages': '',
      'pfp':
          'https://media.istockphoto.com/id/1337144146/vector/default-avatar-profile-icon-vector.jpg?s=612x612&w=0&k=20&c=BIbFwuv7FxTWvh5S3vB6bkT0Qv8Vn8N5Ffseq84ClGI='
    };
    i.add(e);
    d['users'] = i;
    setState(() {
      _items.add(e);
    });
    return file.writeAsString(jsonEncode(d));
  }

  Future<File> writeReply(String username, String message, int n) async {
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/forum.json');
    String text = await file.readAsString();
    Map<String, dynamic> d = jsonDecode(text);
    Map<String, dynamic> i = d['posts'][n];
    String replies = i['replies'];
    replies += "#@#" + username + "@@" + ": " + message;
    i['replies'] = replies;
    d['posts'][n] = i;
    setState(() {
      _posts[n]['replies'] = replies;
    });
    return file.writeAsString(jsonEncode(d));
  }

  Future<File> writePost(String title, String body) async {
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/forum.json');
    String text = await file.readAsString();
    Map<String, dynamic> d = jsonDecode(text);
    List<dynamic> i = d['posts'];
    Map<String, dynamic> e = {
      'author': _items[activeuser]['username'],
      'title': title,
      'description': body,
      'replies': ''
    };
    i.add(e);
    d['posts'] = i;
    setState(() {
      _posts.add(e);
    });
    return file.writeAsString(jsonEncode(d));
  }

  Future<File> setPFP(String url) async {
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/data.json');
    String text = await file.readAsString();
    Map<String, dynamic> d = jsonDecode(text);
    d['users'][activeuser]['pfp'] = url;
    setState(() {
      _items[activeuser]['pfp'] = url;
    });

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

  Future<Map<String, dynamic>> get forumData async {
    final Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/forum.json');
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
    forumData.then((Map<String, dynamic> c) {
      setState(() {
        List<dynamic> d = c['posts'];
        _posts = d;
      });
    });
  }

  List toList(String str) {
    return str.split("#@#");
  }

  String getUsername(String str, bool a) {
    List ls = str.split("@@");
    if (a) {
      return ls[0];
    }
    return ls[1];
  }

  String usernametoPFP(String username) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i]['username'] == username) {
        return _items[i]['pfp'];
      }
    }
    return "";
  }

  int currentIndex = 0;
  final TextEditingController textController = TextEditingController();
  final TextEditingController textController2 = TextEditingController();
  final TextEditingController textController3 = TextEditingController();
  final TextEditingController textController4 = TextEditingController();
  int activeuser = -1;
  int postIndex = -1;
  List<dynamic> _items = <dynamic>[];
  List<dynamic> _posts = <dynamic>[];

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
    textController3.text = "";
    textController4.text = "";

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            /*appBar: AppBar(
              
            ),*/

            backgroundColor: const Color(0xffbdc4ff),
            appBar: AppBar(
                title: const Center(
              child: Row(
                children: [
                  Image(
                    image: AssetImage("lib/mentalplus.png"),
                    alignment: Alignment.centerLeft,
                    height: 60,
                    width: 60,
                  ),
                  Text("           Mental Plus",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff000000),
                        fontSize: 20,
                      ))
                ],
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
              ],
              currentIndex: currentIndex < 2 ? currentIndex : 0,
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
                          // ignore: prefer_interpolation_to_compose_strings
                          Text(" Hi, " + _items[activeuser]['username'] + "!",
                              style: GoogleFonts.oleoScript(
                                  color: const Color.fromARGB(255, 12, 61, 102),
                                  fontSize: 64)),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("Forum",
                                  style: GoogleFonts.roboto(
                                      color: const Color.fromARGB(
                                          255, 12, 61, 102),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold))),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: _posts.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            currentIndex = 10;
                                            postIndex = index;
                                          });
                                        },
                                        // ignore: prefer_interpolation_to_compose_strings
                                        child: Text("• " +
                                            _posts[index]['title'] +
                                                " (" +
                                                _posts[index]['author'] + ")",
                                            style: GoogleFonts.roboto(
                                                color: const Color.fromARGB(255, 8, 79, 185),
                                                fontSize: 24, fontWeight: FontWeight.bold))));
                              }),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  textController.text = "";
                                  textController2.text = "";
                                  currentIndex = 13;
                                });
                              },
                              child: const Text("Create post"))
                        ]))
                    : currentIndex == 13
                        ? Column(children: [
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: TextField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                        hintText: " Title"))),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: TextField(
                                  maxLines: null,
                                    controller: textController2,
                                    decoration: const InputDecoration(
                                        hintText: " Body"))),
                            Padding(
                                padding: EdgeInsets.all(20),
                                child: ElevatedButton(
                                    onPressed: () {
                                      writePost(textController.text,
                                          textController2.text);
                                      setState(() {
                                        currentIndex = 0;
                                      });
                                    },
                                    child: const Text("Post"))),
                          ])
                        : currentIndex == 10
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(_posts[postIndex]['title'],
                                          style: GoogleFonts.roboto(
                                              color: const Color.fromARGB(
                                                  255, 12, 61, 102),
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold))),
                                  Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                          _posts[postIndex]['description'],
                                          style: GoogleFonts.roboto(
                                              color: const Color.fromARGB(
                                                  255, 12, 61, 102),
                                              fontSize: 16))),
                                  Padding(
                                      padding: const EdgeInsets.all(4),
                                      // ignore: prefer_interpolation_to_compose_strings
                                      child: Text(
                                          "-- " + _posts[postIndex]['author'],
                                          style: GoogleFonts.roboto(
                                              color: const Color.fromARGB(255, 8, 79, 185),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold))),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: (toList(_posts[postIndex]
                                                    ['replies']))
                                                .length -
                                            1,
                                        itemBuilder: (context, index) {
                                          return Row(children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  usernametoPFP(getUsername(
                                                      toList(_posts[postIndex]
                                                              ['replies'])[
                                                          index + 1],
                                                      true))),
                                              radius: 15,
                                            ),
                                            Flexible(
                                                fit: FlexFit.loose,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: RichText(
                                                        text: TextSpan(
                                                            text: getUsername(
                                                                toList(_posts[postIndex]
                                                                        ['replies'])[
                                                                    index + 1],
                                                                true),
                                                            style: GoogleFonts.roboto(
                                                                color:
                                                                    const Color.fromARGB(255, 8, 79, 185),
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            children: <TextSpan>[
                                                          TextSpan(
                                                              text: getUsername(
                                                                  toList(_posts[
                                                                              postIndex]
                                                                          [
                                                                          'replies'])[
                                                                      index +
                                                                          1],
                                                                  false),
                                                              style: GoogleFonts.roboto(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0),
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal))
                                                        ]))))
                                          ]);
                                        }),
                                  ),
                                  TextField(
                                      controller: textController3,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                          hintText:
                                              " Leave a reply (make sure to be respectful)...")),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (textController3.text != "") {
                                              writeReply(
                                                  _items[activeuser]
                                                      ['username'],
                                                  textController3.text,
                                                  postIndex);
                                            }
                                            ;
                                            setState(() {
                                              currentIndex = 11;
                                            });
                                          },
                                          child: const Text("Post reply"))),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          currentIndex = 0;
                                        });
                                      },
                                      child: const Text("Exit"))
                                ],
                              )
                            : currentIndex == 11
                                ? Column(children: [
                                    Text("Thanks for your reply!",
                                        style: GoogleFonts.oleoScript(
                                            color: const Color.fromARGB(
                                                255, 12, 61, 102),
                                            fontSize: 64)),
                                    ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            currentIndex = 10;
                                          });
                                        },
                                        child: const Text("Back to post"))
                                  ])
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
                                                decoration:
                                                    const InputDecoration(
                                                        hintText: "Username"),
                                              ),
                                              TextField(
                                                controller: textController2,
                                                decoration:
                                                    const InputDecoration(
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
                                                            _items[i][
                                                                    'username'] ==
                                                                textController
                                                                    .text) {
                                                          if (_items[i][
                                                                  'password'] ==
                                                              textController2
                                                                  .text) {
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
                                        : currentIndex == 1 && activeuser != -1
                                            ? Center(
                                                child: Column(children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text("Profile",
                                                        style: GoogleFonts
                                                            .oleoScript(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    12,
                                                                    61,
                                                                    102),
                                                                fontSize: 64)),
                                                  ),
                                                  CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            _items[activeuser]
                                                                ['pfp']),
                                                    radius: 50,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                        'Username: ${_items[activeuser]['username']}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    12,
                                                                    61,
                                                                    102),
                                                                fontSize: 16)),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              currentIndex = 12;
                                                            });
                                                          },
                                                          child: const Text(
                                                              "Set Profile Picture"))),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          activeuser = -1;
                                                        });
                                                      },
                                                      child:
                                                          const Text("Log Out"))
                                                ]),
                                              )
                                            : currentIndex == 12
                                                ? Center(
                                                    child: Column(children: [
                                                    Text(
                                                        'Enter new image address',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    12,
                                                                    61,
                                                                    102),
                                                                fontSize: 32)),
                                                    TextField(
                                                        controller:
                                                            textController4,
                                                        decoration:
                                                            const InputDecoration(
                                                                hintText:
                                                                    "Image address...")),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          setPFP(textController4
                                                              .text);
                                                          setState(() {
                                                            currentIndex = 1;
                                                          });
                                                        },
                                                        child:
                                                            const Text("Apply"))
                                                  ]))
                                                : currentIndex == 4
                                                    ? Center(
                                                        child: Column(
                                                            children: [
                                                              const Text(
                                                                  "Sign Up:"),
                                                              TextField(
                                                                controller:
                                                                    textController,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        hintText:
                                                                            "Username"),
                                                              ),
                                                              TextField(
                                                                controller:
                                                                    textController2,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        hintText:
                                                                            "Password"),
                                                                obscureText:
                                                                    true,
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      bool
                                                                          newAcc =
                                                                          true;
                                                                      String t =
                                                                          textController
                                                                              .text;
                                                                      String
                                                                          t2 =
                                                                          textController2
                                                                              .text;
                                                                      for (int i =
                                                                              0;
                                                                          i < _items.length;
                                                                          i++) {
                                                                        if (textController.text ==
                                                                            _items[i]['username']) {
                                                                          newAcc =
                                                                              false;
                                                                        }
                                                                      }
                                                                      if (newAcc) {
                                                                        writeData(
                                                                            t,
                                                                            t2);
                                                                        setState(
                                                                            () {
                                                                          activeuser =
                                                                              _items.length;
                                                                          currentIndex =
                                                                              0;
                                                                        });
                                                                      } else {
                                                                        print(
                                                                            "Username already in use");
                                                                        textController
                                                                            .clear();
                                                                        textController2
                                                                            .clear();
                                                                      }
                                                                    });
                                                                  },
                                                                  child: const Text(
                                                                      "Submit"))
                                                            ]),
                                                      )
                                                    : const Center(
                                                        child: Text(
                                                            '404: Page Not Found'),
                                                      )));
  }
}
