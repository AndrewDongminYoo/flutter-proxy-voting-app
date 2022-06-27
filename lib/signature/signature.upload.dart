import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show GetxController;

class CustomSignatureController extends GetxController {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadSignature(
      String company, String filename, Uint8List data, String category) async {
    Reference agendaStorage = storage.ref().child(category).child(company);
    Reference storageReference = agendaStorage.child(filename);
    await storageReference.putData(
        data, SettableMetadata(contentType: 'image/jpg'));
    return await storageReference.getDownloadURL();
  }

  Future<Image> downloadSignature(
      String company, String filename, String category) async {
    Reference gsRef = storage.refFromURL('gs://bside-kr.appspot.com/');
    Reference tgRef = gsRef.child(category).child(company).child(filename);
    String imageUrl = await tgRef.getDownloadURL();
    return Image.network(imageUrl);
  }
}
