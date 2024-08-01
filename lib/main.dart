import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:awesome_notify/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  if (taskId == "0") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Simple Notification',
        body: 'Simple body',
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        fullScreenIntent: true,
      ),
    );
    // IsolateNameServer.lookupPortByName("myUniquePortName")?.send("start");

    print("[BackgroundFetch] Event received");
  } else {
    FlutterRingtonePlayer.stop();
  }
}

void awesomeNotificationInitialize() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        criticalAlerts: true,
        playSound: false,
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        locked: true,
        defaultPrivacy: NotificationPrivacy.Public,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
          channelGroupkey: 'basic_channel_group',
          channelGroupName: 'Basic group')
    ],
    debug: true,
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}

void _onBackgroundFetch(String taskId) async {
  if (taskId == "0") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Simple Notification',
        body: 'Simple body',
        category: NotificationCategory.Alarm,
        criticalAlert: true,
        fullScreenIntent: true,
      ),
    );
    FlutterRingtonePlayer.playAlarm();
    // IsolateNameServer.lookupPortByName("myUniquePortName")?.send("start");
    print("[BackgroundFetch] Event received");
//TODO: perform your task like : call the API’s, call the DB and local notification.
  } else {
    FlutterRingtonePlayer.stop();
  }
}

void _onBackgroundFetchTimeout(String taskId) {
  print("[BackgroundFetch] TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}

Future<void> initPlatformState() async {
// Configure BackgroundFetch.
  var status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        forceAlarmManager: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout);
  print("[BackgroundFetch] configure success: $status");
}

fcmBackgroundHandler() async {
  const String portName = 'myUniquePortName';
  ReceivePort receiver = ReceivePort();
  IsolateNameServer.registerPortWithName(receiver.sendPort, portName);

  receiver.listen((message) async {
    if (message == "stop") {
      await FlutterRingtonePlayer.stop();
    }
    if (message == "start") {
      await FlutterRingtonePlayer.playAlarm();
    }
  });
}

Future<void> main() async {
  awesomeNotificationInitialize();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        NotificationPage.routeName: (context) => const NotificationPage(),
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer? audioPlayer;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    initPlatformState();
    fcmBackgroundHandler();
    AwesomeNotifications()
        .actionStream
        .listen((ReceivedNotification receivedNotification) {
      Navigator.of(context).pushNamed(
        NotificationPage.routeName,
        arguments: receivedNotification,
        // your page params. I recommend you to pass the
        // entire *receivedNotification* object
      );
    });
    super.initState();
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
            ElevatedButton(
              onPressed: () async {
                await audioPlayer!.setAsset("assets/alarm.mp3");
                audioPlayer!.play();
              },
              child: const Text(
                'Play',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                audioPlayer!.stop();
              },
              child: const Text(
                'Pause',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BackgroundFetch.scheduleTask(
            TaskConfig(
              taskId: "0",
              delay: 1000 * 10,
              periodic: false,
              stopOnTerminate: false,
              enableHeadless: true,
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
