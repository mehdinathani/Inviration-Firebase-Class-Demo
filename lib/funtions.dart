import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

loginWithEmail(String email, String password) async {
  final auth = FirebaseAuth.instance;
  try {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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

signOut() async {
  await FirebaseAuth.instance.signOut();
}

registerUser(name, email, password, rollnumber, context) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
        .then(updteUserData(
            FirebaseAuth.instance.currentUser!.uid, name, email, rollnumber))
        .then(navigateToHome(context));
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

updteUserData(uid, name, email, rollNumber) async {
  try {
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'time': FieldValue.serverTimestamp(),
    });
  } on FirebaseException catch (e) {
    log(e.message.toString());
  }
}

navigateToHome(BuildContext context) {
  Navigator.pushNamed(context, '/home');
}

Future<void> uploadTask(title, content, filePath, taskTile) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    //upload imagefirst
    final imageURL = await uploadImage(filePath, taskTile);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(title)
        .set({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'creater': uid,
      'imageURL': imageURL,
    });
  } on FirebaseException catch (e) {
    log('Error on upload${e.message}');
  }
}

Future uploadImage(File filePath, taskTile) async {
  final file = File(filePath.path);
  final metadata = SettableMetadata(contentType: "image/jpeg");

  final storageRef = FirebaseStorage.instance.ref();

  final uploadTask = storageRef.child('images').child(taskTile).putFile(file);
  final taskSnaphot = await uploadTask;
  // Listen for state changes, errors, and completion of the upload.
  uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
    switch (taskSnapshot.state) {
      case TaskState.running:
        final progress =
            100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        print("Upload is $progress% complete.");
        break;
      case TaskState.paused:
        print("Upload is paused.");
        break;
      case TaskState.canceled:
        print("Upload was canceled");
        break;
      case TaskState.error:
        // Handle unsuccessful uploads
        break;
      case TaskState.success:
        // Handle successful uploads on complete
        // ...
        break;
    }
  });

  final imageURL = await taskSnaphot.ref.getDownloadURL();
  log("Image UR: $imageURL");
  return imageURL;
}
