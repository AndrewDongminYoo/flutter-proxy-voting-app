// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:uuid/uuid.dart';

// FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

// final Uuid uuid = Uuid();

// Collection refs
CollectionReference liveRef = firestore.collection('live');
