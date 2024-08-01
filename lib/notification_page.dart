import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  static const routeName = '/notificationpage';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    FlutterRingtonePlayer.playRingtone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ReceivedNotification args =
        ModalRoute.of(context)!.settings.arguments as ReceivedNotification;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Page"),
      ),
      body: Center(
        child: Text("Notification: ${args.id.toString()}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // BackgroundFetch.scheduleTask(
          //   TaskConfig(
          //     taskId: "1000",
          //     delay: 1000,
          //     periodic: false,
          //     stopOnTerminate: false,
          //     enableHeadless: true,
          //   ),
          // );
          IsolateNameServer.lookupPortByName("myUniquePortName")?.send("stop");
          FlutterRingtonePlayer.stop();
        },
      ),
    );
  }
}
