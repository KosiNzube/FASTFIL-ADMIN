
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class Admin {
   String perKG;
   String disclaimer;
   String deliveryFee;

   String password;
   String id;


   Admin({
      required this.perKG,
      required this.password,
      required this.disclaimer,
      required this.id,
      required this.deliveryFee,

   });




   /// get stream

   /// get user doc stream


}
Admin _userDataFromSnapshot(DocumentSnapshot? snapshot) {
   return Admin(
      id:  snapshot!.data().toString().contains('id') ? snapshot.get('id') : '',
      password:  snapshot.data().toString().contains('password') ? snapshot.get('password') : '',
      perKG:  snapshot.data().toString().contains('perKG') ? snapshot.get('perKG') : '',
      disclaimer:  snapshot.data().toString().contains('disclaimer') ? snapshot.get('disclaimer') : '',
      deliveryFee:  snapshot.data().toString().contains('deliveryFee') ? snapshot.get('deliveryFee') : '',
   );
}
Stream<Admin> get adminData {
   final CollectionReference _reference =
   FirebaseFirestore.instance.collection('ADMIN');
   return _reference.doc("ihFiNg83MAyFX3danjxr").snapshots().map(_userDataFromSnapshot);
}





