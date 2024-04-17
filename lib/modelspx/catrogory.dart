
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class Categoryx {
   String description;
   String name;
   int items;
   String id;
   Timestamp timestamp;

   Categoryx({
      required this.description,
      required this.name,
      required this.items,
      required this.id,
      required this.timestamp
   });
   Categoryx.fromJson(Map<String, Object?> json)
       : this(
      name: json['name']! as String,
      items: json['items']! as int,
      id: json['id']! as String,
      description: json['description']! as String,

      timestamp: json['timestamp']! as Timestamp,


   );

   Map<String, Object?> toJson() {
      return {
         'id': id!=null?id:"",
         'description': description!=null?description:"",
         'items': items!=null?items:0,
         'name': name!=null?name:"",

         'timestamp': timestamp!=null?timestamp:Timestamp(0, 0),

      };
   }


}
List<Categoryx> items(QuerySnapshot snapshot ){
   return snapshot.docs.map((doc){
      return Categoryx(
         description: doc.get('description') ,
         name: doc.get('name'),
         items: doc.get('items'),
         id: doc.get('id'),
         timestamp: doc.get('timestamp')??Timestamp(0, 0),


      );
   }).toList();
}




Stream<List<Categoryx>> get getProducts{

   return FirebaseFirestore.instance.collection("Category").snapshots().map(items);
}





