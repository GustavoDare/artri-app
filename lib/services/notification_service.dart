import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

// Esta função precisa ser de nível superior (fora da classe) para rodar com o app fechado
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (notificationResponse.actionId == 'consume_action' && notificationResponse.payload != null) {
    final id = notificationResponse.payload!;
    final prefs = await SharedPreferences.getInstance();

    // Lendo a memória do usuário 1 (se tiver mais usuários, essa lógica precisará ser dinâmica)
    final String? checklistJson = prefs.getString('checklist_user_1');
    Map<String, dynamic> consumedDates = {};
    if (checklistJson != null) {
      consumedDates = jsonDecode(checklistJson);
    }

    final now = DateTime.now();
    final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Salva o medicamento como consumido no dia de hoje
    consumedDates[id] = todayString;
    await prefs.setString('checklist_user_1', jsonEncode(consumedDates));
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  Function(String?)? onForegroundAction;

  Future<void> init({Function(String?)? onAction}) async {
    this.onForegroundAction = onAction;
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Se o usuário clicar com o app aberto/em segundo plano
        if (response.actionId == 'consume_action' && onForegroundAction != null) {
          onForegroundAction!(response.payload);
        }
      },
      // Se o usuário clicar com o app totalmente fechado
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Solicitar as permissões para o usuário (Android 13+ e Alarmes Exatos)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> scheduleRemedyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> daysOfWeek,
    required int reminderMinutes,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'remedy_channel',
      'Lembretes de Medicamentos',
      channelDescription: 'Notificações para tomar seus medicamentos',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'consume_action', // ID da ação
          'Marcar como Consumido', // Texto do botão
          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    final now = tz.TZDateTime.now(tz.local);

    for (int day in daysOfWeek) {
      // Cria a data no horário marcado, subtraindo os minutos do lembrete
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute)
          .subtract(Duration(minutes: reminderMinutes));

      // Ajusta para o próximo dia da semana correspondente (no Dart, Segunda = 1, nossa lista Segunda = 0. Então day + 1)
      while (scheduledDate.weekday != (day + 1) || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      int uniqueId = int.parse('${id}${day}'); // ID único combinando remédio + dia

      await _notificationsPlugin.zonedSchedule(
        uniqueId,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Permite tocar em modo ocioso
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Repete toda semana
        payload: id.toString(), // Envia o ID do remédio no payload
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    for (int i = 0; i < 7; i++) {
      await _notificationsPlugin.cancel(int.parse('${id}${i}'));
    }
  }
}