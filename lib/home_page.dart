import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:testingnotifications/main.dart';

import 'local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String notificationMsg = "Waiting for notifications";

  @override
  void initState() {
    super.initState();

    //initi message
    LocalNotificationService.initialize();

    // Terminated State show message
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        setState(() {
          notificationMsg =
              "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
        });
      }
    });

    // Foreground State show message
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.showNotificationOnForeground(event);
      setState(() {
        notificationMsg =
            "${event.notification!.title} ${event.notification!.body} I am coming from foreground";
      });
    });

    // background State show message
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      setState(() {
        notificationMsg =
            "${event.notification!.title} ${event.notification!.body} I am coming from background";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Notifications"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              notificationMsg,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                localNotificationService.sendNotification().then((value) =>
                    // Fluttertoast.showToast(msg: 'Notification sent'),
                logger.i("Notification sent"),
                );
              },
              child: Text("Send"),
            ),
            TextButton(
              onPressed: () {
                localNotificationService.subscribeToTopicDevice();
              },
              child: Text("Subscribe"),
            ),
            TextButton(
              onPressed: () {
                localNotificationService.unSubscribeToTopicDevice();
              },
              child: Text("unSubscribe"),
            ),
            TextButton(
              onPressed: () {
                localNotificationService.sendNotificationToTopicALlToSee();
              },
              child: Text("send To Subscribes devices"),
            ),
          ],
        ),
      ),
    );
  }
}
