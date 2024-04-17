
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Agent {
   Agent({required this.id});

   final String id;

   AgentData _userDataFromSnapshot(DocumentSnapshot? snapshot) {
      return AgentData(
         id:  snapshot!.data().toString().contains('id') ? snapshot.get('id') : '',
         image:  snapshot!.data().toString().contains('image') ? snapshot.get('image') : '',
         hostel:  snapshot.data().toString().contains('hostel') ? snapshot.get('hostel') : '',
         hostelID:  snapshot.data().toString().contains('hostelID') ? snapshot.get('hostelID') : '',
         name:  snapshot.data().toString().contains('name') ? snapshot.get('name') : '',
         number:  snapshot.data().toString().contains('number') ? snapshot.get('number') : '',
         rating: snapshot.get('rating')??0,
         deliveries: snapshot.get('deliveries')??0,
         active: snapshot.get('active')??false,
         online: snapshot.get('online')??false,
         disable: snapshot.get('disable')??false,
         disablestamp: snapshot.get('disablestamp')??Timestamp(0, 0),

      );
   }

   /// get stream

   /// get user doc stream
   Stream<AgentData?> get userData {
      final CollectionReference _reference = FirebaseFirestore.instance.collection('Agents');
      return _reference.doc(id).snapshots().map(_userDataFromSnapshot);
   }

}
class AgentData {

   final String number;
   final String name;
   final bool active;
   final String id;
   final int rating;
   final String image;
   final String hostel;
   final String hostelID;
   final bool disable;
   final Timestamp disablestamp;
   final bool online;
   final int deliveries;


   AgentData({
      required this.number,
      required this.active,
      required this.image,
      required this.hostel,
      required this.hostelID,
      required this.disable,
      required this.online,
      required this.name,
      required this.id,
      required this.disablestamp,

      required this.rating,
      required this.deliveries

   });
   AgentData.fromJson(Map<String, Object?> json)
       : this(
      number: json['number']! as String,
      image: json['image']! as String,
      hostel: json['hostel']! as String,
      hostelID: json['hostelID']! as String,
      id: json['id']! as String,
      name: json['name']! as String,

      disablestamp: json['disablestamp']! as Timestamp,
      disable: json['disable']! as bool,
      rating: json['rating']! as int,
      deliveries: json['deliveries']! as int,
      online: json['online']! as bool,

      active: json['active']! as bool,


   );

   Map<String, Object?> toJson() {
      return {
         'number': number!=null?number:"",
         'image': image!=null?image:"",
         'hostel': hostel!=null?hostel:"",
         'hostelID': hostelID!=null?hostelID:"",
         'disablestamp': disablestamp!=null?disablestamp:Timestamp(0, 0),
         'name': name!=null?name:"",
         'id': id!=null?id:"",
         'rating': rating!=null?rating:0,
         'deliveries': deliveries!=null?deliveries:0,
         'online': online!=null?online:false,
         'disable': disable!=null?disable:true,
         'active': active!=null?active:false,

      };
   }
}









List<AgentData> items(QuerySnapshot snapshot ){
   return snapshot.docs.map((doc){
      return AgentData(
         name: doc.get('name') ,
         image: doc.get('image'),
         online: doc.get('online')??false,
         hostel: doc.get('hostel'),
         hostelID: doc.get('hostelID'),
         id: doc.get('id'),
         number: doc.get("number"),
         active: doc.get('active')??false,
         disable: doc.get('disable')??false,
         deliveries: doc.get('deliveries')??0,
         rating: doc.get('rating')??0,
         disablestamp: doc.get('disablestamp')??Timestamp(0, 0),


      );
   }).toList();
}



Stream<List<AgentData>> get getableAgents{

   return FirebaseFirestore.instance.collection("Agents").where("disable",isEqualTo: false)  .snapshots().map(items);
}

Stream<List<AgentData>> get getdisAgents{

   return FirebaseFirestore.instance.collection("Agents").where("disable",isEqualTo: true)  .snapshots().map(items);
}

Stream<List<AgentData>> get getActiveAgents{

   return FirebaseFirestore.instance.collection("Agents").where("active",isEqualTo: true).where("disable",isEqualTo: false) .snapshots().map(items);
}


