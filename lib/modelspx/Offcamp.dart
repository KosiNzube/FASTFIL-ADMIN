import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class Offcampx{
  String id, name,state;


  Offcampx({
    required this.name,
    required this.state,

    required this.id,
    });
  Offcampx.fromJson(Map<String, Object?> json)
      : this(

    name: json['name']! as String,
    state: json['state']! as String,

    id: json['id']! as String,




  );

  Map<String, Object?> toJson() {
    return {

      'state': state!=null?state:"",
      'id': id!=null?id:"",

      'name': name!=null?name:"",


    };
  }
}


List<Offcampx> items(QuerySnapshot snapshot ){
  return snapshot.docs.map((doc){
    return Offcampx(
      name: doc.get('name') ,
      state: doc.get('state') ,

      id: doc.get('id'),

    );
  }).toList();
}




Stream<List<Offcampx?>> get getOffcamps{

  return FirebaseFirestore.instance.collection("Offcamp").snapshots().map(items);
}
