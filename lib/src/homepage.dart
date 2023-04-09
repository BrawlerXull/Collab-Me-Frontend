import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Defining an boolean to specify if the user is willing to edit the text or not
  bool f = false;
  var txt = TextEditingController();
  @override
  void initState() {
    super.initState();
    //Calling to update my text in the textformfield every 1 second
    //Only if the below conditions are satisfied
    Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) async {
        //Condition - If the user has tapped below button so that he can edit the text
        if (f) {
          var res = await http.get(
            Uri.parse("https://collab-me-backend.vercel.app/latest/1"),
          );
          var data1 = await json.decode(res.body);
          var sample = txt.text;
          if ((data1["latest msg"]["text"].length != 0) &&
              (txt.text != data1["latest msg"]["text"])) {
            setState(
              () {
                txt.text = data1["latest msg"]["text"];
              },
            );
          }
          print("Text Updated");
          print(data1["latest msg"]["text"]);
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Collab Me"),
      //   elevation: 0,
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.purple, Colors.blue],
      //       ),
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          const RiveAnimation.asset("assets/RiveAssets/shapes.riv"),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 10,
              ),
              child: SizedBox(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 20, right: 20, top: 10),
                        child: Text(
                          "Do you want to turn on collaborative mode and update your text with others",
                          style: TextStyle(color: Colors.black, fontSize: 25),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     var res = await http.get(Uri.parse(
                    //         "https://collab-me-backend.vercel.app/latest/1"));
                    //     var data = await json.decode(res.body);
                    //     print(data["latest msg"]["text"]);
                    //     setState(() {
                    //       f = !f;
                    //     });
                    //   },
                    //   child: Text(f.toString()),
                    // ),
                    Switch(
                      value: f,
                      focusColor: Colors.red,
                      onChanged: (bool value) async {
                        var res = await http.get(Uri.parse(
                            "https://collab-me-backend.vercel.app/latest/1"));
                        var data = await json.decode(res.body);
                        print(data["latest msg"]["text"]);
                        setState(() {
                          f = value;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),

                TextField(
                  controller: txt,
                  maxLines: null,
                  style: TextStyle(fontSize: 25),
                  minLines: 10,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.white70,
                      filled: true),
                  onChanged: (value) async {
                    if (txt.text.length != 0) {
                      var data = {"text": txt.text};
                      final response = await http.post(
                        Uri.parse(
                          "https://collab-me-backend.vercel.app/update",
                        ),
                        body: json.encode(data),
                        headers: {"Content-Type": "application/json"},
                      );
                      print(response.body);
                      print("data uploaded");
                    }
                    //Used to bring my editing cursor on the end of the text
                    //Used to fix an annoying bug :)
                    txt.selection =
                        TextSelection.collapsed(offset: txt.text.length);
                  },
                ),
                // Text(txt.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
