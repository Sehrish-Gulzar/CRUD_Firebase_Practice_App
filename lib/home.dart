import 'dart:io';

import 'package:firebase/post.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();
  String imagePath;

  Stream postStream =
      FirebaseFirestore.instance.collection('posts').snapshots();

  @override
  Widget build(BuildContext context) {
    void pickImage() async {
      final ImagePicker _picker = ImagePicker();
      final image = await _picker.getImage(source: ImageSource.gallery);
      print(image.path);

      setState(() {
        imagePath = image.path;
      });
    }

    void submit() async {
      try {
        String title = titleController.text;
        String description = descriptionController.text;
        String imageName = path.basename(imagePath);

        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref('/$imageName');
        File file = File(imagePath);
        await ref.putFile(file);
        String downloadedURL = await ref.getDownloadURL();
        FirebaseFirestore db = FirebaseFirestore.instance;
        await db.collection("posts").add(
            {"title": title, "description": description, "url": downloadedURL});

        print("Post uploaded successfully");
        titleController.clear();
        print(downloadedURL);
      } catch (e) {
        print(e.message);
      }
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SafeArea(
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Enter your title'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration:
                    InputDecoration(labelText: 'Enter your description'),
              ),
              ElevatedButton(
                  onPressed: pickImage, child: Text("pick an image")),
              ElevatedButton(
                  onPressed: submit, child: Text("submitted a post")),
              Expanded(
                child: Container(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: postStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }

                      return ListView(
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                          Map data = document.data();
                          return Post(
                            data: data,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
