import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:testingnotifications/home_page.dart';
import 'package:testingnotifications/local_notifications.dart';
import 'package:testingnotifications/notification_service.dart';

import 'firebase_options.dart';

Logger logger = Logger(printer: PrettyPrinter(colors: true));

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  logger.e(
      "Handling a background message: ${message.messageId} ${message.notification?.title} ${message.notification?.body}");
}

LocalNotificationService localNotificationService = LocalNotificationService();
FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void unSubscribeToTopicSwitch() async {
    logger.i("unSubscribe");
    await FirebaseMessaging.instance.unsubscribeFromTopic("topic").whenComplete(
          () => logger.i("Unsubscribed"),
        );
  }

  void subscribeToTopicSwitch() async {
    logger.i("subscribe");
    await FirebaseMessaging.instance.subscribeToTopic("topic").whenComplete(
          () => logger.i("Subscribed"),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                subscribeToTopicSwitch();
                NotificationServices notificationService =
                    NotificationServices();
                notificationService.getDeviceToken().then((value) async {
                  var data = {
                    //current device
                    'to': value.toString(),
                    'priority': 'high',
                    'notification': {
                      'title': "title",
                      'body': "Subscribe to my channel",
                    },
                    //route
                    'data': {
                      'type': 'msj',
                      'id': 'asif12345',
                    }
                  };

                  await http.post(
                      Uri.parse('https://fcm.googleapis.com/fcm/send'),
                      body: jsonEncode(data),
                      headers: {
                        'priority': "high",
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization':
                            'AAAANcqEdDA:APA91bGdr_w0xw6MemCCrXGjcX8CPrUuHYieAvjOZiUNumG9LD2NDdo6SGI_UyN_pq5rQgSMGgaIfjqQzA6Z8XAfJ-Qls1a1PjM7qskltEOxEH3ObU1Wb0B3PlezTDMJJPnMS4DTrPZL',
                      });
                });
              },
              child: const Text("Subscribe"),
            ),
            TextButton(
              onPressed: () {
                unSubscribeToTopicSwitch();
              },
              child: const Text("unsubscribe"),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
