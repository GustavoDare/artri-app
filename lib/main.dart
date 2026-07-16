import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'package:artriapp/views/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(App());
}
