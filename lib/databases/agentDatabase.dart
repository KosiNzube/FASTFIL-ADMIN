import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../modelspx/Order.dart';



class agentDatabase {
  final String? uid;

  agentDatabase({ this.uid});

  /// collection reference 'test'.
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('Agents');

  FirebaseAuth firebaseAuth=FirebaseAuth.instance;


  Future updateUnvei() async {
    return await _reference.doc(uid).update({'disable':true}).then((value) => print("unvei update"))
        .catchError((error) => print("Failed to update unvei: $error"));

  }



  Future updateVei() async {
    return await _reference.doc(uid).update({'disable':false}).then((value) => print("vei update"))
        .catchError((error) => print("Failed to update vei: $error"));

  }

}
