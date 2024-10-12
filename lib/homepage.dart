import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasedemo/custom_textfield.dart';
import 'package:firebasedemo/funtions.dart';
import 'package:firebasedemo/utils.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskContent = TextEditingController();
  File? filePath;
  @override
  void initState() {
    taskTitle = TextEditingController();
    taskContent = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    taskTitle.dispose();
    taskContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
              onPressed: () {
                filePath = null;

                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text("Add Tasks"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextfield(
                                hintText: "Title",
                                controller: taskTitle,
                              ),
                              CustomTextfield(
                                hintText: "Content",
                                controller: taskContent,
                              ),
                              IconButton(
                                  onPressed: () async {
                                    filePath = await selectImage();
                                    print(
                                        "Image selected: ${filePath!.path}"); // Debug: check if file path is valid

                                    setState(() {});
                                  },
                                  icon: Icon(Icons.camera)),
                              filePath != null
                                  ? Image.file(filePath!)
                                  : const Text("No Image Selected"),
                              ElevatedButton(
                                  onPressed: () async {
                                    await uploadTask(
                                      taskTitle.text,
                                      taskContent.text,
                                      filePath,
                                      taskTitle.text,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Add"))
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('tasks')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      "No Task Yet",
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                  ),
                );
              }
              final data = snapshot.data!.docs.where((doc) {
                return doc['title'].toString().toLowerCase().contains('new');
              }).toList();
              return Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final indexData = data[index];
                    return Dismissible(
                      onUpdate: (details) {
                        log(details.direction.name);
                      },
                      onDismissed: (direction) async {
                        final desertRef = FirebaseStorage.instance
                            .ref()
                            .child('images')
                            .child(taskTitle.text);
                        await desertRef.delete();
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('tasks')
                            .doc(indexData.id)
                            .delete();
                        setState(() {});
                      },
                      background: Container(
                        color: Colors.yellow,
                      ),
                      key: ValueKey(index),
                      child: ListTile(
                        onTap: () {
                          taskTitle.text = indexData['title'];
                          taskContent.text = indexData['content'];
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Add Tasks"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextfield(
                                      hintText: "Title",
                                      controller: taskTitle,
                                    ),
                                    CustomTextfield(
                                      hintText: "Content",
                                      controller: taskContent,
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .collection('tasks')
                                              .doc(indexData.id)
                                              .update({
                                            'title': taskTitle.text,
                                            'content': taskContent.text,
                                            'updatedon':
                                                FieldValue.serverTimestamp(),
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Add"))
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        title: Text(indexData['title']),
                        trailing: Text(indexData['content']),
                        leading: CircleAvatar(
                          backgroundImage: indexData.data()['imageURL'] != null
                              ? NetworkImage(indexData['imageURL'])
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: const Text("SignOut"))
        ],
      ),
    );
  }
}
