import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastfiladmin/card/cartCard.dart';
import 'package:fastfiladmin/card/noti_card.dart';
import 'package:fastfiladmin/extensions.dart';
import 'package:fastfiladmin/modelspx/catrogory.dart';
import 'package:fastfiladmin/modelspx/notification.dart';
import 'package:fastfiladmin/responsive.dart';
import 'package:fastfiladmin/services/liveTrack.dart';
import 'package:fastfiladmin/services/routes.dart';
import 'package:fastfiladmin/style.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'card/orderCard.dart';
import 'comp2/DarkThemeProvider.dart';
import 'comp2/Styles.dart';
import 'comp2/custom_text.dart';
import 'constants.dart';
import 'databases/agentDatabase.dart';
import 'modelspx/Admin.dart';
import 'modelspx/Agents.dart';
import 'modelspx/Offcamp.dart';
import 'modelspx/Order.dart';
import 'modelspx/Product.dart';
import 'modelspx/Quantity.dart';
import 'modelspx/State.dart';
import 'modelspx/hostels.dart';
import 'modelspx/requests.dart';
import 'modelspx/student.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    // name:"Fast-fil",

    options:FirebaseOptions(
        apiKey: "AIza*********SQniFbNK-S6M",
        authDomain: "afr******app.com",
        projectId: "af***gas",
        storageBucket: "af******467",
        appId: "1:50*********9626491788e",
        measurementId: "G******DS"


    ),);
  if(kIsWeb){

  }else{

    AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true
    );


    await FlutterDownloader.initialize(
        debug: true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl: true // option: set to false to disable working with http links (default: false)
    );




  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));

  runApp( MyApp());


}



class MyApp extends StatefulWidget {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String name = 'Fastfil ADMIN';
  static const Color mainColor = Colors.deepPurple;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {

    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );



    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
  }


  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    return
      ChangeNotifierProvider(
        create: (_) {
          return themeChangeProvider;
        },
        child: Consumer<DarkThemeProvider>(
          builder: (BuildContext context, value, Widget? child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(themeChangeProvider.darkTheme, context),

              initialRoute: Routes.home,
              onGenerateRoute: (RouteSettings settings) {
                return Routes.fadeThrough(settings, (context) {
                  final settingsUri = Uri.parse(settings.name!);
                  final postID = settingsUri.queryParameters['id'];
                  print(postID); //will print "123"





                  if (settings.name ==Routes.home) {
                    return MultiProvider(
                        providers: [
                          StreamProvider<Admin?>.value(
                            value: adminData,
                            initialData: null,
                          )
                        ],

                        child: accolumn());
                  }


                  return Center(child: CircularProgressIndicator());
                });
              },
            );
          },
        ),);
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
class accolumn extends StatefulWidget {

  @override
  State<accolumn> createState() => _accolumnState();
}

class _accolumnState extends State<accolumn> {

  @override
  Widget build(BuildContext context) {

    final themeChange = Provider.of<DarkThemeProvider>(context);
    final ThemeData mode=Theme.of(context);
    final admin = Provider.of<Admin>(context);
    TextEditingController name = new TextEditingController();
    bool correctpass=false;

    return Scaffold(



      body: admin!=null? correctpass==true? home(themeChange: themeChange, mode: mode): SingleChildScrollView(
        physics: ScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.only(left: 15.0,right: 15,top: 15),
          child: Column(
            children: [



              SizedBox(height: kDefaultPadding*5),

              Text("ADMIN PASSCODE",style: TextStyle(fontSize: 39,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),

              SizedBox(height: kDefaultPadding*2),

              TextField(
                controller: name,

                decoration: InputDecoration(
                    labelText: "Type in the passcode",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: kDefaultPadding),


              InkWell(
                onTap: () async {
                  if (name.text.length > 0) {

                    if(name.text==admin.password){
                      setState(() async {
                        correctpass=true;

                        await kIsWeb ?(){}: FirebaseMessaging.instance.subscribeToTopic("ADMIN");


                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen:home(themeChange: themeChange, mode: mode),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation: PageTransitionAnimation
                              .cupertino,
                        );

                      });

                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                " Incorrect passcode "),

                          ));

                    }

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              " Please type in the passcode "),

                        ));
                  }


                },
                child: Container(
                  decoration: BoxDecoration(color: active,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CustomText(
                    text: "Continue",
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: kDefaultPadding*6),


            ],
          ),
        ),
      )  :Center(child: CircularProgressIndicator()),
    );
  }
}

class home extends StatelessWidget {
  const home({
    super.key,
    required this.themeChange,
    required this.mode,
  });

  final DarkThemeProvider themeChange;
  final ThemeData mode;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),

        child: Column(
          children: [
            SizedBox(height: kDefaultPadding/2),




            accardy(s:"Verified agents",x:"",q: Icons.done,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Verified(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),

            accardy(s:"Un-Verified agents",x:"",q: Icons.access_time,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:unVerified(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),

            accardy(s:"Pending orders",x:"",q: Icons.agriculture,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:PendOrders(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),
            accardy(s:"Completed orders",x:"",q: Icons.done_all,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:ComOrders(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),

            accardy(s:"App Data",x:"",q: Icons.dashboard_rounded,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:MultiProvider(
                    providers: [
                      StreamProvider.value(
                          value: getQuantities, initialData: null),
                      StreamProvider.value(
                          value: adminData, initialData: null)
                    ],
                    child: Writer()),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),


            accardy(s:"E-commerce",x:"",q: Icons.shopping_cart,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Categories(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),


            accardy(s:"Hostels",x:"",q: Icons.home_outlined,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Hostels(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),


            accardy(s:"Offcamp",x:"",q: Icons.location_city,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Offcamp(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),

            accardy(s:"States",x:"",q: Icons.location_city_sharp,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Statexxx(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),

            accardy(s:"Curate",x:"",q: Icons.list,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:curateprodxx(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),


            accardy(s:"Requests",x:"",q: Icons.circle,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:NewWidget(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),

            accardy(s:"Handle notifications",x:"",q: Icons.notifications_active_outlined,press: () {

              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Notifications(),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            }),
            accard(s:"Fastfil ADMIN 1.0",x:"Version",q: Icons.phone_android_sharp),


            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
              child: InkWell(
                onTap: () async {


                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text.rich(


                                  TextSpan(
                                    text: "Dark mode\n",
                                    style: TextStyle(
                                      fontSize: Responsive.isDesktop(context)?20:  16,
                                      fontWeight: FontWeight.w600,
                                    ),

                                    children: [
                                      TextSpan(
                                        text: "Theme",
                                        style: TextStyle(
                                          fontSize: Responsive.isDesktop(context)?22:  18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.redAccent,
                                        ),
                                      )

                                    ],
                                  ),
                                ),
                              ),

                              Checkbox(
                                  value: themeChange.darkTheme,
                                  onChanged: (bool? value) {
                                    themeChange.darkTheme = value!;
                                  })
                            ],
                          ),
                          SizedBox(height: kDefaultPadding / 2),
                        ],
                      ),
                    ).addNeumorphism(
                      blurRadius: mode.brightness==Brightness.dark?0: 15,
                      borderRadius: mode.brightness==Brightness.dark?9: 15,
                      offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
class accard extends StatelessWidget {
  const accard({
    Key? key, required this.s, required this.x,required this.q
  }) : super(key: key);

  final IconData q;
  final String s;
  final String x;

  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);



    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: InkWell(
        onTap: () async {


        },
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text.rich(


                          TextSpan(
                            text: s.length>1? "${x} \n":"${x}",
                            style: TextStyle(
                              fontSize: Responsive.isDesktop(context)?20:  16,
                              fontWeight: FontWeight.w600,
                            ),

                            children: [

                              TextSpan(
                                text: s,
                                style: TextStyle(
                                  fontSize: Responsive.isDesktop(context)?22:  18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Icon(q)

                    ],
                  ),
                  SizedBox(height: kDefaultPadding / 2),
                ],
              ),
            ).addNeumorphism(
              blurRadius: mode.brightness==Brightness.dark?0: 15,
              borderRadius: mode.brightness==Brightness.dark?9: 15,
              offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}


class accardy extends StatelessWidget {
  const accardy({
    Key? key, required this.s, required this.x,required this.q, required this.press
  }) : super(key: key);

  final IconData q;
  final String s;
  final String x;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);



    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: InkWell(
        onTap: ()  {

          press();

        },
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(s,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15),),
                      ),

                      Icon(q)

                    ],
                  ),
                  SizedBox(height: kDefaultPadding / 2),
                ],
              ),
            ).addNeumorphism(
              blurRadius: mode.brightness==Brightness.dark?0: 15,
              borderRadius: mode.brightness==Brightness.dark?9: 15,
              offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class NewWidget extends StatefulWidget {


  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  late Query<Requestx> usersQuery;


  FirebaseAuth firebaseAuth=FirebaseAuth.instance;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersQuery = FirebaseFirestore.instance.collection("Requests")

        .withConverter<Requestx>(
      fromFirestore: (snapshot, _) => Requestx.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );

  }


  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(
      body: FirestoreListView<Requestx>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Requestx user = snapshot.data();

          return InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:NEWPRODUCTSPECIAL(requestx: user,),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );
            },
            onLongPress: () async {
              await FirebaseFirestore.instance.collection('Requests').doc(user.id).update({'state': 2});

              sendMessageToTopic(user.student,"One of your requests has been voided",user.content);

            },

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(kDefaultPadding/1.3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Column(
                      children: [
                        Row(

                          children: [
                            SizedBox(height: kDefaultPadding / 2),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    DateFormat('yyyy-MM-dd').format(user.timestamp.toDate()),textAlign: TextAlign.left,style:GoogleFonts.nunito(
                                      fontSize: Responsive.isDesktop(context)? 19:15.8),

                                  ),



                                  Text(
                                    user.content,textAlign: TextAlign.left,style:GoogleFonts.nunito(
                                      fontSize: Responsive.isDesktop(context)? 19:15.8),

                                  ),

                                  Text(
                                    user.state==0?"This request is currently in under review": user.state==1?"This request is currently available": "This request was voided",textAlign: TextAlign.left,style:GoogleFonts.nunito(
                                      color: Colors.pink,
                                      fontSize: Responsive.isDesktop(context)? 19:15.8),

                                  ),
                                  SizedBox(height: kDefaultPadding/1.5 ),

                                ],
                              ),
                            ),


                            SizedBox(height: kDefaultPadding / 2),



                          ],
                        ),

                      ],
                    ),
                  ).addNeumorphism(
                    blurRadius: mode.brightness==Brightness.dark?0: 15,
                    borderRadius: mode.brightness==Brightness.dark?9: 15,
                    offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
                  ),

                  user.state==0? Positioned(right: 12, top: 12, child: Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.deepPurple,
                    ),
                  ),): user.state==1? Positioned(right: 12, top: 12, child: Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.blue,
                    ),
                  ),):Container(),






                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class Verified extends StatefulWidget {

  const Verified();

  @override
  State<Verified> createState() => _VerifiedState();
}

class _VerifiedState extends State<Verified> {


  final usersQuery = FirebaseFirestore.instance.collection("Agents").where("disable",isEqualTo: false)
      .withConverter<AgentData>(
    fromFirestore: (snapshot, _) => AgentData.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Verified agents",style: TextStyle(fontWeight: FontWeight.bold),),
        ), // like this!
      ),

      body:FirestoreListView<AgentData>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          AgentData user = snapshot.data();

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
            child: InkWell(
              onTap: () async {


              },
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text.rich(


                                TextSpan(
                                  text: user.name,
                                  style: TextStyle(
                                    fontSize: Responsive.isDesktop(context)?20:  16,
                                    fontWeight: FontWeight.w600,
                                  ),


                                ),
                              ),
                            ),

                            InkWell(
                              onTap: (){
                                agentDatabase(uid: user.id).updateUnvei();

                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                decoration:  BoxDecoration(
                                  border: Border.all(color: mode.brightness==Brightness.dark? Colors.white:Colors.black87),
                                ),
                                child: Center(
                                  child: Text(

                                      "Un-Vefi",
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.marcellus(
                                          textStyle: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600))

                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: kDefaultPadding / 2),
                      ],
                    ),
                  ).addNeumorphism(
                    blurRadius: mode.brightness==Brightness.dark?0: 15,
                    borderRadius: mode.brightness==Brightness.dark?9: 15,
                    offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),



    );
  }
}





class unVerified extends StatefulWidget {

  const unVerified();

  @override
  State<unVerified> createState() => _unVerifiedState();
}

class _unVerifiedState extends State<unVerified> {


  final usersQuery = FirebaseFirestore.instance.collection("Agents").where("disable",isEqualTo: true)
      .withConverter<AgentData>(
    fromFirestore: (snapshot, _) => AgentData.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Un-Verified agents",style: TextStyle(fontWeight: FontWeight.bold,),),
        ), // like this!
      ),

      body:FirestoreListView<AgentData>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          AgentData user = snapshot.data();

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
            child: InkWell(
              onTap: () async {


              },
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(kDefaultPadding),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text.rich(


                                TextSpan(
                                  text: user.name,
                                  style: TextStyle(
                                    fontSize: Responsive.isDesktop(context)?20:  16,
                                    fontWeight: FontWeight.w600,
                                  ),


                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                agentDatabase(uid: user.id).updateVei();

                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                decoration:  BoxDecoration(
                                  border: Border.all(color: mode.brightness==Brightness.dark? Colors.white:Colors.black87),
                                ),
                                child: Center(
                                  child: Text(

                                      "Ve-fi",
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.marcellus(
                                          textStyle: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600))

                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: kDefaultPadding / 2),
                      ],
                    ),
                  ).addNeumorphism(
                    blurRadius: mode.brightness==Brightness.dark?0: 15,
                    borderRadius: mode.brightness==Brightness.dark?9: 15,
                    offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),



    );
  }
}




class Hostels extends StatefulWidget {

  const Hostels();

  @override
  State<Hostels> createState() => HostelState();
}

class HostelState extends State<Hostels> {


  final usersQuery = FirebaseFirestore.instance.collection("Hostels").orderBy('orders',descending: true)
      .withConverter<Hostel>(
    fromFirestore: (snapshot, _) => Hostel.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Hostel orders",style: TextStyle(fontWeight: FontWeight.bold),),
        ), // like this!
      ),

      body:FirestoreListView<Hostel>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Hostel user = snapshot.data();

          return Stack(
            children: [

              Container(
                padding: EdgeInsets.all(kDefaultPadding/2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  //   borderRadius: BorderRadius.circular(15),

                  //  color:mode.brightness==Brightness.dark?  Color.fromARGB(250, 45, 45, 60) :Colors.white,
                ),
                child: Column(

                  children: [
                    SizedBox(height: kDefaultPadding / 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Responsive.isDesktop(context)? 60:40,
                          height: Responsive.isDesktop(context)? 60:40,

                          child: Icon(CupertinoIcons.house_alt),
                        ),
                        SizedBox(width: kDefaultPadding / 2),



                        Expanded(


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  user.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                                  fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

                              ),


                              SizedBox(height: 7),

                              Text(
                                  user.orders.toString()+" orders"
                                  ,textAlign: TextAlign.left,style:GoogleFonts.lato(
                                  fontSize: Responsive.isDesktop(context)? 19:15)


                              )

                            ],
                          ),







                        ),


                        SizedBox(width: kDefaultPadding / 2),

                      ],
                    ),
                    SizedBox(height: kDefaultPadding / 2),
                  ],
                ),
              ).addNeumorphism(
                blurRadius: mode.brightness==Brightness.dark?0: 15,
                borderRadius: mode.brightness==Brightness.dark?9: 15,
                offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
              ),
            ],
          );
        },
      ),



    );
  }
}


















class Offcamp extends StatefulWidget {

  const Offcamp();

  @override
  State<Offcamp> createState() => OffcampState();
}

class OffcampState extends State<Offcamp> {


  final usersQuery = FirebaseFirestore.instance.collection("Offcamp").orderBy('orders',descending: true)
      .withConverter<Hostel>(
    fromFirestore: (snapshot, _) => Hostel.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Offcamp orders",style: TextStyle(fontWeight: FontWeight.bold),),
        ), // like this!
      ),

      body:FirestoreListView<Hostel>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Hostel user = snapshot.data();

          return Stack(
            children: [

              Container(
                padding: EdgeInsets.all(kDefaultPadding/2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  //   borderRadius: BorderRadius.circular(15),

                  //  color:mode.brightness==Brightness.dark?  Color.fromARGB(250, 45, 45, 60) :Colors.white,
                ),
                child: Column(

                  children: [
                    SizedBox(height: kDefaultPadding / 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Responsive.isDesktop(context)? 60:40,
                          height: Responsive.isDesktop(context)? 60:40,

                          child: Icon(CupertinoIcons.location),
                        ),
                        SizedBox(width: kDefaultPadding / 2),



                        Expanded(


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  user.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                                  fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

                              ),


                              SizedBox(height: 7),

                              Text(
                                  user.orders.toString()+" orders"
                                  ,textAlign: TextAlign.left,style:GoogleFonts.lato(
                                  fontSize: Responsive.isDesktop(context)? 19:15)


                              )

                            ],
                          ),







                        ),


                        SizedBox(width: kDefaultPadding / 2),

                      ],
                    ),
                    SizedBox(height: kDefaultPadding / 2),
                  ],
                ),
              ).addNeumorphism(
                blurRadius: mode.brightness==Brightness.dark?0: 15,
                borderRadius: mode.brightness==Brightness.dark?9: 15,
                offset: mode.brightness==Brightness.dark? Offset(0, 0):Offset(2, 2),
              ),
            ],
          );
        },
      ),



    );
  }
}



class PendOrders extends StatefulWidget {

  const PendOrders();

  @override
  State<PendOrders> createState() => pendState();
}

class pendState extends State<PendOrders> {


  final usersQuery = FirebaseFirestore.instance.collection("Orders").where("state",isEqualTo: "In Progress").orderBy('timestamp',descending: true)
      .withConverter<Orderx>(
    fromFirestore: (snapshot, _) => Orderx.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Pending orders",style: TextStyle(fontWeight: FontWeight.bold),),
        ), // like this!
      ),

      body:FirestoreListView<Orderx>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Orderx user = snapshot.data();

          return orderCard( orderx: user,press:(){
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen:liveTrack(orderx: user),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation
                  .cupertino,
            );


          });
        },
      ),



    );
  }
}







class ComOrders extends StatefulWidget {

  const ComOrders();

  @override
  State<ComOrders> createState() => compState();
}

class compState extends State<ComOrders> {


  final usersQuery = FirebaseFirestore.instance.collection("Orders").where("state",isEqualTo: "Completed").orderBy('timestamp',descending: true)
      .withConverter<Orderx>(
    fromFirestore: (snapshot, _) => Orderx.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    final ThemeData mode=Theme.of(context);


    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Completed orders",style: TextStyle(fontWeight: FontWeight.bold,),),
        ), // like this!
      ),

      body:FirestoreListView<Orderx>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Orderx user = snapshot.data();

          return orderCard( orderx: user,press:(){

            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen:liveTrack(orderx: user),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation
                  .cupertino,
            );


          });
        },
      ),



    );
  }
}








class Notifications extends StatefulWidget {

  const Notifications();

  @override
  State<Notifications> createState() => notiState();
}

class notiState extends State<Notifications>  {


  final usersQuery = FirebaseFirestore.instance.collection("Notifications").orderBy('timestamp',descending: true)
      .withConverter<Notificationx>(
    fromFirestore: (snapshot, _) => Notificationx.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        centerTitle: false,
        title: Container(

          child: Text("Notifications",style: TextStyle(fontWeight: FontWeight.bold,),),
        ),
          actions: [

           Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(

                child: Text('New Post'),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:newnoti(),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation
                        .cupertino,
                  );

                  // handle the press
                },
              ),
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Notificationx>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Notificationx user = snapshot.data();

          return notiCard( email: user,press:() async {
            final CollectionReference _reference =FirebaseFirestore.instance.collection('Notifications');


            await _reference.doc(user.id).delete();




            snack("notification deleted", context);



          });
        },
      ),



    );
  }
}














class Categories extends StatefulWidget {

  const Categories();

  @override
  State<Categories> createState() => CategoriesState();
}

class CategoriesState extends State<Categories>  {


  final usersQuery = FirebaseFirestore.instance.collection("Category").orderBy('timestamp',descending: true)
      .withConverter<Categoryx>(
    fromFirestore: (snapshot, _) => Categoryx.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(

                child: Text('New category'),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:categoryor(),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation
                        .cupertino,
                  );

                  // handle the press
                },
              ),
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Categoryx>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Categoryx user = snapshot.data();

          return InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:prodxx(categoryx:user!),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );


            },

            onLongPress: (){
              FirebaseFirestore.instance.collection("Category").doc(user.id).delete();
            },


            child: Stack(
              children: [

                Container(
                  padding: EdgeInsets.all(kDefaultPadding/2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    //   borderRadius: BorderRadius.circular(15),

                    //  color:mode.brightness==Brightness.dark?  Color.fromARGB(250, 45, 45, 60) :Colors.white,
                  ),
                  child: Column(

                    children: [
                      SizedBox(height: kDefaultPadding / 2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: Responsive.isDesktop(context)? 60:40,
                            height: Responsive.isDesktop(context)? 60:40,

                            child: Icon(CupertinoIcons.tag_solid),
                          ),
                          SizedBox(width: kDefaultPadding / 2),



                          Expanded(


                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    user.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                                    fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

                                ),


                                SizedBox(height: 7),

                                Text(
                                    user.description.toString()
                                    ,textAlign: TextAlign.left,style:GoogleFonts.lato(
                                    fontSize: Responsive.isDesktop(context)? 19:15)


                                )

                              ],
                            ),







                          ),


                          SizedBox(width: kDefaultPadding / 2),

                        ],
                      ),
                      SizedBox(height: kDefaultPadding / 2),
                    ],
                  ),
                )
              ],
            ),
          );





        },
      ),



    );
  }
}



class Statexxx extends StatefulWidget {

  const Statexxx();

  @override
  State<Statexxx> createState() => StatexxxState();
}

class StatexxxState extends State<Statexxx>  {


  final usersQuery = FirebaseFirestore.instance.collection("States")
      .withConverter<Statex>(
    fromFirestore: (snapshot, _) => Statex.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("States",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(

                child: Text('New state'),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:newstate(),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation
                        .cupertino,
                  );

                  // handle the press
                },
              ),
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Statex>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Statex user = snapshot.data();

          return InkWell(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:hosoffs(categoryx:user!),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );


            },

            onLongPress: (){
              FirebaseFirestore.instance.collection("States").doc(user.name).delete();
            },


            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                  user.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                  fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

              ),
            ),
          );





        },
      ),



    );
  }
}


















class prodxx extends StatefulWidget {

  final Categoryx categoryx;
  const prodxx({required this.categoryx});

  @override
  State<prodxx> createState() => prodxxState();

}

class prodxxState extends State<prodxx>  {

  late Query<Product> usersQuery;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersQuery = FirebaseFirestore.instance.collection("Products").where("mrp",isEqualTo: widget.categoryx.id)
        .withConverter<Product>(
      fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("Products",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(

                child: Text('New product'),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:NEWPRODUCT(categoryx: widget.categoryx),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation
                        .cupertino,
                  );

                  // handle the press
                },
              ),
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Product>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Product user = snapshot.data();

          return InkWell(


            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen:Writeryyy(name: user.name, description: user.description, previousprice: user.previousprice, price: user.saleprice, id: user.id),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation
                    .cupertino,
              );

            },

            onLongPress: (){
              FirebaseFirestore.instance.collection("Products").doc(user.id).delete();
            },


            child: ProductCard(cart: user,),
          );





        },
      ),



    );
  }
}




class curateprodxx extends StatefulWidget {


  @override
  State<curateprodxx> createState() => curateprodxxState();

}

class curateprodxxState extends State<curateprodxx>  {

  late Query<Product> usersQuery;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersQuery = FirebaseFirestore.instance.collection("Products").where('curate', isEqualTo: true).orderBy('timestamp',descending: true)
        .withConverter<Product>(
      fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("Curated Products",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(

                child: Text('Pick more'),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:remcurateprodxx(),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation
                        .cupertino,
                  );

                  // handle the press
                },
              ),
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Product>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Product user = snapshot.data();

          return InkWell(

            onLongPress: () async{
              await FirebaseFirestore.instance.collection("Products").doc(user.id).update({"curate":false});

              snack("removed", context);
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
                          child: Image.network(user.image),
                        ),
                      ),

                      SizedBox(width: 12,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.description,
                            style: TextStyle( fontSize: 16),
                          ),
                          SizedBox(height: 5),


                          Text("${user.saleprice}", style: TextStyle(
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





        },
      ),



    );
  }
}


class remcurateprodxx extends StatefulWidget {


  @override
  State<remcurateprodxx> createState() => remcurateprodxxState();

}

class remcurateprodxxState extends State<remcurateprodxx>  {

  late Query<Product> usersQuery;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersQuery = FirebaseFirestore.instance.collection("Products").where('curate', isEqualTo: false).orderBy('timestamp',descending: true)
        .withConverter<Product>(
      fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("Add to curate",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),

        // like this!
      ),

      body:FirestoreListView<Product>(
        physics: BouncingScrollPhysics(),


        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Product user = snapshot.data();

          return InkWell(

            onLongPress: () async{
              await FirebaseFirestore.instance.collection("Products").doc(user.id).update({"curate":true,'timestamp':Timestamp.now()});
              snack("added", context);

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
                          child: Image.network(user.image),
                        ),
                      ),

                      SizedBox(width: 12,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.description,
                            style: TextStyle( fontSize: 16),
                          ),
                          SizedBox(height: 5),


                          Text("${user.saleprice}", style: TextStyle(
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





        },
      ),



    );
  }
}



class hosoffs extends StatefulWidget {

  final Statex categoryx;
  const hosoffs({required this.categoryx});

  @override
  State<hosoffs> createState() => hosoffsState();

}

class hosoffsState extends State<hosoffs>  {

  late Query<Hostel> usersQuery;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersQuery = FirebaseFirestore.instance.collection("Hostels").where("state",isEqualTo: widget.categoryx.name)
        .withConverter<Hostel>(
      fromFirestore: (snapshot, _) => Hostel.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("Hostel",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          actions: [

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(

                    child: Text('OFFCAMP'),
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen:offshos(categoryx: widget.categoryx),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation: PageTransitionAnimation
                            .cupertino,
                      );

                      // handle the press
                    },
                  ),
                ),

                SizedBox(width: 5,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(

                    child: Text('New POD'),
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen:newHostel(statex: widget.categoryx),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation: PageTransitionAnimation
                            .cupertino,
                      );

                      // handle the press
                    },
                  ),
                ),
              ],
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Hostel>(

        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Hostel user = snapshot.data();

          return InkWell(


            onLongPress: (){
              FirebaseFirestore.instance.collection("Hostels").doc(user.id).delete();
            },


            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                  user.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                  fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

              ),
            ),
          );





        },
      ),



    );
  }
}


class offshos extends StatefulWidget {

  final Statex categoryx;
  const offshos({required this.categoryx});

  @override
  State<offshos> createState() => offshosState();

}

class offshosState extends State<offshos>  {

  late Query<Offcampx> usersQuery;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersQuery = FirebaseFirestore.instance.collection("Offcamp").where("state",isEqualTo: widget.categoryx.name)
        .withConverter<Offcampx>(
      fromFirestore: (snapshot, _) => Offcampx.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

          centerTitle: false,
          title: Container(

            child: Text("Offcamp",style: TextStyle(fontWeight: FontWeight.bold,),),
          ),
          actions: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(

                child: Text('New POD'),
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen:newHostel(statex: widget.categoryx),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation
                        .cupertino,
                  );

                  // handle the press
                },
              ),
            )
          ]

        // like this!
      ),

      body:FirestoreListView<Offcampx>(

        query: usersQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Offcampx user = snapshot.data();

          return InkWell(


            onLongPress: (){
              FirebaseFirestore.instance.collection("Offcamp").doc(user.id).delete();
            },


            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                  user.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                  fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

              ),
            ),
          );





        },
      ),



    );
  }
}





class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here

    /*
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
            (route) => (route.settings.name != Routes.privacy) || route.isFirst,
        arguments: receivedAction);

     */
  }
}




class Writer extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<Writer> {
  TextEditingController nb = TextEditingController();



  TextEditingController fullname = TextEditingController();
  TextEditingController delivery = TextEditingController();
  TextEditingController perKG = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<Admin?>(context);
    final quantities = Provider.of<List<Quantity?>>(context);

    if(student!=null ) {
      setState(() {
        if (student!.disclaimer.length > 1) {
          fullname.text = student!.disclaimer;
        }
        if (student!.deliveryFee.length > 1) {
          delivery.text = student!.deliveryFee;
        }
        if (student!.perKG.length > 1) {
          perKG.text = student!.perKG;
        }
      });
    }


    return student!=null? Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("App Data",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: fullname,
                    decoration: const InputDecoration(
                      labelText: "Enter disclaimer text here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 4,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (fullname.text.length > 1) {
                        final CollectionReference _reference = FirebaseFirestore.instance.collection('ADMIN');


                        await _reference.doc("ihFiNg83MAyFX3danjxr").update({'disclaimer':fullname.text});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update disclaimer",
                    ),
                  ),
                  ),

                  SizedBox(height: 25.0),













                  TextFormField(
                    controller: delivery,
                    decoration: const InputDecoration(
                      labelText: "Enter Delivery fee here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (delivery.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('ADMIN');


                       await _reference.doc("ihFiNg83MAyFX3danjxr").update({'deliveryFee':delivery.text});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update delivery fee",
                    ),
                  ),
                  ),

                  SizedBox(height: 25.0),


















                  TextFormField(
                    controller: perKG,
                    decoration: const InputDecoration(
                      labelText: "Enter perKG here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (perKG.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('ADMIN');


                        await _reference.doc("ihFiNg83MAyFX3danjxr").update({'perKG':perKG.text});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update perKG",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),












                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,


                    itemCount: quantities.length,
                    // On mobile this active dosen't mean anything
                    itemBuilder: (context, index) => InkWell(
                      onTap: (){
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen:Appdata(quantity:quantities[index]!),







                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation: PageTransitionAnimation
                              .cupertino,
                        );
                      },
                      child: Stack(
                        children: [

                          Container(
                            padding: EdgeInsets.all(kDefaultPadding/2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              //   borderRadius: BorderRadius.circular(15),

                              //  color:mode.brightness==Brightness.dark?  Color.fromARGB(250, 45, 45, 60) :Colors.white,
                            ),
                            child: Column(

                              children: [
                                SizedBox(height: kDefaultPadding / 2),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: Responsive.isDesktop(context)? 60:40,
                                      height: Responsive.isDesktop(context)? 60:40,

                                      child: InkWell(

                                        onTap: () async {

                                          final CollectionReference _reference =
                                          FirebaseFirestore.instance.collection('Quantity');


                                          await _reference.doc(quantities[index]!.id).delete();
                                          snack("Updated", context);
                                        },


                                          child: Icon(CupertinoIcons.delete)),
                                    ),
                                    SizedBox(width: kDefaultPadding ),



                                    Expanded(


                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              quantities[index]!.name ,textAlign: TextAlign.left,style:GoogleFonts.lato(

                                              fontSize: Responsive.isDesktop(context)? 19:16,fontWeight: FontWeight.w600,color: Colors.pink)

                                          ),


                                          SizedBox(height: 7),

                                          Text(
                                              quantities[index]!.price.toString()
                                              ,textAlign: TextAlign.left,style:GoogleFonts.lato(
                                              fontSize: Responsive.isDesktop(context)? 19:15)


                                          )

                                        ],
                                      ),







                                    ),


                                    SizedBox(width: kDefaultPadding / 2),

                                  ],
                                ),
                                SizedBox(height: kDefaultPadding / 2),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),),



                  SizedBox(height: 25.0),


                  InkWell(
                    onTap: ()   async {

                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen:neweight(),







                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation: PageTransitionAnimation
                            .cupertino,
                      );

                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD NEW WEIGHT",
                    ),
                  ),
                  ),

                  SizedBox(height: 25.0),


                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    ):CircularProgressIndicator();
  }




}



class Writeryyy extends StatefulWidget {

  final String name;
  final String description;
  final String id;

  final int previousprice;
  final int price;

  const Writeryyy({super.key, required this.name, required this.description, required this.previousprice, required this.price, required this.id});

  @override
  _AddPostStateyyy createState() => _AddPostStateyyy();
}

class _AddPostStateyyy extends State<Writeryyy> {
  TextEditingController name = TextEditingController();



  TextEditingController description = TextEditingController();
  TextEditingController previousprice = TextEditingController();
  TextEditingController price = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {


      setState(() {
        if (widget.name.length > 1) {
          name.text = widget.name;
        }
        if (widget.description.length > 1) {
          description.text = widget.description;
        }
        if (widget.price > 0) {
          price.text = widget.price.toString();
        }

        if (widget.previousprice > 0) {
          previousprice.text = widget.previousprice.toString();
        }
      });



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text(widget.name),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: "Enter product name here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (name.text.length > 1) {
                        final CollectionReference _reference = FirebaseFirestore.instance.collection('Products');


                        await _reference.doc(widget.id).update({'name':name.text});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update name",
                    ),
                  ),
                  ),

                  SizedBox(height: 25.0),













                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(
                      labelText: "Enter Description here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 4,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (description.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Products');


                        await _reference.doc(widget.id).update({'description':description.text});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update description",
                    ),
                  ),
                  ),

                  SizedBox(height: 25.0),


















                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    controller: price,
                    decoration: const InputDecoration(
                      labelText: "Enter price here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (price.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Products');


                        await _reference.doc(widget.id).update({'saleprice':int.parse(price.text)});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update price",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    controller: previousprice,
                    decoration: const InputDecoration(
                      labelText: "Enter previous price here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (previousprice.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Products');


                        await _reference.doc(widget.id).update({'previousprice':int.parse( previousprice.text)});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update previous price",
                    ),
                  ),
                  ),



                  SizedBox(height: 25.0),


                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}






class Appdata extends StatefulWidget {
  const Appdata({super.key, required this.quantity});

  @override
  AppdataState createState() => AppdataState();

  final Quantity quantity;

}

class AppdataState extends State<Appdata> {
  TextEditingController nb = TextEditingController();



  TextEditingController kg = TextEditingController();
  TextEditingController price = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {


    if(widget.quantity!=null ) {
      setState(() {
        if (widget.quantity!.name .length > 1) {
          kg.text = widget.quantity!.name;
        }
        if (widget.quantity!.price.toString().length > 1) {
          price.text = widget.quantity.price.toString();
        }

      });
    }


    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("Update quantities",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: kg,
                    decoration: const InputDecoration(
                      labelText: "Enter kg here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (kg.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Quantity');


                        await _reference.doc(widget.quantity.id).update({'name':kg.text});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update kg",
                    ),
                  ),
                  ),

                  SizedBox(height: 25.0),













                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    controller: price,
                    decoration: const InputDecoration(
                      labelText: "Enter price here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 15.0),


                  InkWell(
                    onTap: ()   async {
                      if (price.text.length > 1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Quantity');


                        await _reference.doc(widget.quantity.id).update({'price':int.parse(price.text)});
                        snack("Updated", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "Update price",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}









class neweight extends StatefulWidget {

  @override
  neweightdataState createState() => neweightdataState();


}

class neweightdataState extends State<neweight> {



  TextEditingController kg = TextEditingController();
  TextEditingController price = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New Weight",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: kg,
                    decoration: const InputDecoration(
                      labelText: "Enter kg here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),


                  SizedBox(height: 25.0),













                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    controller: price,
                    decoration: const InputDecoration(
                      labelText: "Enter price here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 25.0),


                  InkWell(
                    onTap: ()   async {
                      if (price.text.length > 1 && kg.text.length>1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Quantity');


                        await _reference.add({'name': kg.text.toUpperCase(), 'id': "", 'price': int.parse(price.text)}).then((value) async {
                          _reference.doc(value.id).update({'id': value.id});
                        });



                        snack("New weight added", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD WEIGHT",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}








class newstate extends StatefulWidget {

  @override
  newstateState createState() => newstateState();


}

class newstateState extends State<newstate> {



  TextEditingController kg = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  bool clicked=false;

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New State",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: kg,
                    decoration: const InputDecoration(
                      labelText: "Enter name of state",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),


                  /*
                  SizedBox(height: 25.0),

                  CustomText(text: 'Select type',),
                  SizedBox(height: 10.0),

                  Text("Hostel",style: TextStyle(fontSize: 15),),
                  SizedBox(height: 10.0),
                  Text("Off-camp",style: TextStyle(fontSize: 15),),



                   */

                  SizedBox(height: 25.0),


                  InkWell(
                    onTap:clicked==false? ()   async {
                      if ( kg.text.length>1) {

                        setState(() {
                          clicked=true;

                        });

                        await FirebaseFirestore.instance.collection('States').doc(kg.text).set({'name': kg.text, 'orders': 0});


                        snack("New state added", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }:(){}, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD STATE",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}



class newHostel extends StatefulWidget {


  final Statex statex;

  const newHostel({super.key, required this.statex});

  @override
  newHostelState createState() => newHostelState();


}

class newHostelState extends State<newHostel> {



  TextEditingController kg = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  bool clicked=false;

  String xixi="";

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New POD",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: kg,
                    decoration: const InputDecoration(
                      labelText: "Enter name of state",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),



                  SizedBox(height: 25.0),

                  CustomText(text: xixi.isEmpty? 'Select type':xixi,),
                  SizedBox(height: 10.0),

                  InkWell( onTap: (){
                    setState(() {
                      xixi="Hostel";
                    });
                  },
                      child: Text("Hostel",style: TextStyle(fontSize: 15),)),
                  SizedBox(height: 10.0),




                  InkWell(
                      onTap: (){

                        setState(() {
                          xixi="Off-camp";
                        });

                      },

                      child: Text("Off-camp",style: TextStyle(fontSize: 15),)),





                  SizedBox(height: 25.0),


                  InkWell(
                    onTap:clicked==false? ()   async {
                      if ( xixi.isNotEmpty&&kg.text.length>1) {

                        setState(() {
                          clicked=true;

                        });

                        if(xixi=="Hostel") {


                          await FirebaseFirestore.instance.collection('Hostels')
                              .doc(kg.text)
                              .set({'name': kg.text, 'orders': 0,'state':widget.statex.name,'id':kg.text});

                          snack("New POD added", context);

                        }else{
                          await FirebaseFirestore.instance.collection('Offcamp')
                              .doc(kg.text)
                              .set({'name': kg.text, 'orders': 0,'state':widget.statex.name,'id':kg.text});


                            snack("New POD added", context);



                        }


                      } else {
                        snack("Invalid input", context);



                      }


                    }:(){}, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD POD",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),









                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}


















class newnoti extends StatefulWidget {

  @override
  newnotidataState createState() => newnotidataState();


}

class newnotidataState extends State<newnoti> {



  TextEditingController header = TextEditingController();
  TextEditingController content = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New notification",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: header,
                    decoration: const InputDecoration(
                      labelText: "Enter header here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),


                  SizedBox(height: 25.0),













                  TextFormField(
                    controller: content,
                    decoration: const InputDecoration(
                      labelText: "Enter context here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 4,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 25.0),


                  InkWell(
                    onTap: ()   async {
                      if (header.text.length > 1 && header.text.length>1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Notifications');


                        await _reference.add({'header': header.text, 'id': "", 'context': content.text,'timestamp':Timestamp.now(),'image':'https://firebasestorage.googleapis.com/v0/b/afri-gas.appspot.com/o/fillfast.png?alt=media&token=ade62de8-4073-4f21-906e-621f8c404356'}).then((value) async {
                          _reference.doc(value.id).update({'id': value.id});
                        });

                        sendMessageToTopic("ADMIN_USERS", "FASTFIL", content.text);



                        snack("New notification added", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD NOTIFICATION",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}








class categoryor extends StatefulWidget {

  @override
  categoryorState createState() => categoryorState();


}

class categoryorState extends State<categoryor> {



  TextEditingController header = TextEditingController();
  TextEditingController content = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New category",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),

                  TextFormField(
                    controller: header,
                    decoration: const InputDecoration(
                      labelText: "Enter category header here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 2,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),


                  SizedBox(height: 25.0),













                  TextFormField(
                    controller: content,
                    decoration: const InputDecoration(
                      labelText: "Enter category description here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 4,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 25.0),


                  InkWell(
                    onTap: ()   async {
                      if (header.text.length > 1 && header.text.length>1) {
                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Category');


                        await _reference.add({'photo': "",'name': header.text, 'id': "", 'description': content.text,'timestamp':Timestamp.now(),'items':0}).then((value) async {
                          _reference.doc(value.id).update({'id': value.id});
                        });




                        snack("New category added", context);


                      } else {
                        snack("Invalid input", context);



                      }


                    }, child: Container(

                    decoration: BoxDecoration(color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD CATEGORY",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}




class NEWPRODUCT extends StatefulWidget {


  final Categoryx categoryx;

  const NEWPRODUCT({super.key, required this.categoryx});

  @override
  NEWPRODUCTState createState() => NEWPRODUCTState();


}

class NEWPRODUCTState extends State<NEWPRODUCT> {




  TextEditingController name = TextEditingController();

  TextEditingController header = TextEditingController();
  TextEditingController content = TextEditingController();
   XFile? pickedFile;
  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  File? pickedImage;

  bool clicked=false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile!.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New Product",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),


                ElevatedButton(
                  onPressed: () async {
                    // Pick image before using it
                    _pickImage();
                  },
                  child: Text('Pick product Image'),
                ),


                  SizedBox(height: kDefaultPadding),

                  Center(
                    child: pickedImage == null
                        ? Text('No image selected.')
                        :kIsWeb? Container() :Image.file(pickedImage!),
                  ),
                  //if (pickedImage != null) ImageViewer(imageFile: pickedImage!),
                  SizedBox(height: kDefaultPadding),


                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: "Enter product name here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),
                  SizedBox(height: 15.0),


                  TextFormField(
                    controller: header,
                    decoration: const InputDecoration(
                      labelText: "Enter description here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 4,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),


                  SizedBox(height: 25.0),








                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    controller: content,
                    decoration: const InputDecoration(
                      labelText: "Enter price here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 25.0),


                  InkWell(
                    onTap:clicked==false? ()   async {

                      if (pickedFile!=null && header.text.length > 1 && name.text.length > 1 && header.text.length>1) {

                        snack("Uploading...", context);

                        setState(() {
                          clicked=true;

                        });


                        var xxx=  FirebaseStorage.instance.ref().child("Products").child(pickedFile!.path.split('/').last);

                        await xxx.putFile(File(pickedFile!.path!));

                        String imerl=await xxx.getDownloadURL();




                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('Products');


                        await _reference.add({'name':name.text, 'curate': false,  'id': "", 'description': header.text,'timestamp':Timestamp.now(),'mrp':widget.categoryx.id,'saleprice':int.parse(content.text),'previousprice':0,'image':imerl}).then((value) async {
                          _reference.doc(value.id).update({'id': value.id});
                        });


                        setState(() {
                          clicked==false;
                        });


                        snack("New product added", context);


                      } else {
                        snack("Invalid input", context);

                      }


                    }:(){



                    }  , child: Container(

                    decoration: BoxDecoration(color: clicked==false? Colors.indigo:Colors.blueGrey,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD PRODUCT",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}



class NEWPRODUCTSPECIAL extends StatefulWidget {


  final Requestx requestx;

  const NEWPRODUCTSPECIAL({super.key, required this.requestx});

  @override
  NEWPRODUCTSPECIALState createState() => NEWPRODUCTSPECIALState();


}

class NEWPRODUCTSPECIALState extends State<NEWPRODUCTSPECIAL> {




  TextEditingController name = TextEditingController();

  TextEditingController header = TextEditingController();
  TextEditingController content = TextEditingController();
  XFile? pickedFile;
  final GlobalKey<FormState> _formkey = GlobalKey();
  FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  File? pickedImage;

  bool clicked=false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile!.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {

    setState(() {

      name.text=widget.requestx.content;

    });


    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(

          child: Text("New Product",),
        ),
        // like this!
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only( left: 8.0, right: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[


                  SizedBox(height: kDefaultPadding),


                  ElevatedButton(
                    onPressed: () async {
                      // Pick image before using it
                      _pickImage();
                    },
                    child: Text('Pick product Image'),
                  ),


                  SizedBox(height: kDefaultPadding),

                  Center(
                    child: pickedImage == null
                        ? Text('No image selected.')
                        :kIsWeb? Container() :Image.file(pickedImage!),
                  ),
                  //if (pickedImage != null) ImageViewer(imageFile: pickedImage!),
                  SizedBox(height: kDefaultPadding),


                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: "Enter product name here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),
                  SizedBox(height: 15.0),


                  TextFormField(
                    controller: header,
                    decoration: const InputDecoration(
                      labelText: "Enter description here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 4,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),


                  SizedBox(height: 25.0),








                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    controller: content,
                    decoration: const InputDecoration(
                      labelText: "Enter price here",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                          right: 15, top: 15, bottom: 50, left: 15),
                    ),
                    maxLines: 1,
                    validator: (String? val) {
                      if (val!.isEmpty) {
                        return "Body field can't be empty";
                      }
                    },
                  ),

                  SizedBox(height: 25.0),


                  InkWell(
                    onTap:clicked==false? ()   async {

                      if (pickedFile!=null && header.text.length > 1 && name.text.length > 1 && header.text.length>1) {

                        snack("Uploading...", context);

                        setState(() {
                          clicked=true;

                        });


                        var xxx=  FirebaseStorage.instance.ref().child("Products").child(pickedFile!.path.split('/').last);

                        await xxx.putFile(File(pickedFile!.path!));

                        String imerl=await xxx.getDownloadURL();




                        final CollectionReference _reference =
                        FirebaseFirestore.instance.collection('SProducts');


                        await _reference.add({'name':name.text, 'curate': false,  'id': "", 'description': header.text,'timestamp':Timestamp.now(),'mrp':widget.requestx.student,'saleprice':int.parse(content.text),'previousprice':0,'image':imerl}).then((value) async {
                          _reference.doc(value.id).update({'id': value.id});
                        });



                        setState(() {
                          clicked==false;
                        });

                        await FirebaseFirestore.instance.collection('Requests').doc(widget.requestx.id).update({'state': 1});


                        sendMessageToTopic(  widget.requestx.student,"Your request is currently available!",widget.requestx.content);

                        snack("New special added", context);


                      } else {
                        snack("Invalid input", context);

                      }


                    }:(){



                    }  , child: Container(

                    decoration: BoxDecoration(color: clicked==false? Colors.indigo:Colors.blueGrey,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomText(
                      size: 16,
                      color: Colors.white,

                      text: "ADD SPECIAL",
                    ),
                  ),
                  ),

                  SizedBox(height: 15.0),


































                ],
              ),
            ),
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          _extractImage();



          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.square_grid_4x3_fill),
      ),

       */
    );
  }




}









void snack(String s, BuildContext context) {




  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),

      ));


}
void sendMessageToTopic(String topic, String title, String body) async {
  final String serverKey =
      'AAAAdI9gbIs:APA91bGyzl5yItTowitWbZoIiJMOKbUisJKreCWsCq7blS1KQ0pFM9acMtUH-lLxQJejJwWbie5qX0onPhPTMO-tSBXnEqzhah7AqV24BUpmJ0zdT3r1MaLgaLA1QXIRtRG8y9v-girh'; // Replace with your FCM server key from the Firebase Console

  final Uri fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final Map<String, dynamic> message = {
    'to': '/topics/$topic',
    'notification': {
      'title': title,
      'body': body,
      'sound': 'default',
    },
  };

  try {
    final http.Response response = await http.post(
      fcmUrl,
      headers: headers,
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully to topic: $topic');
    } else {
      print('Failed to send message. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}

class ImageViewer extends StatelessWidget {
  final File imageFile;

  ImageViewer({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Image.file(imageFile);
  }
}

Future<String?> uploadFileToFirebaseStorage(File file, String fileName) async {
  try {
    Reference storageReference = FirebaseStorage.instance.ref('Products/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() => print('File Uploaded'));

    // Get the download URL
    String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}
