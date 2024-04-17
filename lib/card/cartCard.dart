import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../main.dart';
import '../modelspx/Product.dart';
import '../modelspx/student.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({

    required this.cart,
  });

  final Product cart;


  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth=FirebaseAuth.instance;

    return InkWell(
        onTap: (){
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen:Writeryyy(name: cart.name, description: cart.description, previousprice: cart.previousprice, price: cart.saleprice, id: cart.id),
            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation
                .cupertino,
          );

        },
      onLongPress: (){
        FirebaseFirestore.instance.collection("Products").doc(cart.id).delete();

      },

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 88,
                  child: AspectRatio(
                    aspectRatio: 0.88,
                    child: Image.network(cart.image),
                  ),
                ),

                SizedBox(width: 12,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cart.name,
                      style: TextStyle( fontSize: 16),
                    ),
                    SizedBox(height: 5),


                    Text("${cart.saleprice}", style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.deepOrange,fontSize: 16),),




                  ],
                ),
              ],
            ),
            Icon(CupertinoIcons.cart)
          ],
        ),
      ),
    );
  }
}