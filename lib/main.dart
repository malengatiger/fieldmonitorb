import 'package:fieldmonitor3/ui/intro/intro_main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/bloc/fcm_bloc.dart';
import 'package:monitorlibrary/bloc/theme_bloc.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/geofence/geofencer_two.dart';


int mThemeIndex = 0;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv.dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await geofencerTwo.initialize();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  pp('🥦🥦🥦🥦🥦 Firebase core and messaging has been initialized 🥦🥦🥦🥦');
  mThemeIndex = await Prefs.getThemeIndex();
  pp('🥦🥦🥦🥦🥦 current mThemeIndex: $mThemeIndex 🥦🥦🥦🥦');
  runApp(MyApp());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: themeBloc.newThemeStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            pp('🥦🥦🥦🥦🥦  Setting theme for the app, index: 🌸 ${snapshot.data}');
            mThemeIndex = snapshot.data!;
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Field Monitor',
            theme: ThemeUtil.getTheme(themeIndex: mThemeIndex),
            home: IntroMain(),
          );
        });
  }
}
