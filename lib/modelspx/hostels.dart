import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';







class Hostel{
  String id, name,state;
  int orders;


  Hostel({
    required this.name,
    required this.orders,
    required this.state,

    required this.id,


  });

  Hostel.fromJson(Map<String, Object?> json)
      : this(

    name: json['name']! as String,
    state: json['state']! as String,

    id: json['id']! as String,

    orders: json['orders']! as int,



  );

  Map<String, Object?> toJson() {
    return {

      'state': state!=null?state:"",
      'id': id!=null?id:"",
      'orders': orders!=null?orders:0,

      'name': name!=null?name:"",


    };
  }

}


List<Hostel> items(QuerySnapshot snapshot ){
  return snapshot.docs.map((doc){
    return Hostel(
      name: doc.get('name') ,
      state: doc.get('state') ,

      orders: doc.get('orders') ,

      id: doc.get('id'),

    );
  }).toList();
}




Stream<List<Hostel?>> get getHostels{

  return FirebaseFirestore.instance.collection("Hostels").snapshots().map(items);
}