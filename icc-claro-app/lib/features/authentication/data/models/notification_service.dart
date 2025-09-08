import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    final String? targetDateString = notificationResponse.payload;
    if (targetDateString != null) {
      final targetDate = DateTime.parse(targetDateString);
      final int daysLeft = targetDate.difference(DateTime.now()).inDays;
      print("🗓️ Notificación recibida. Días restantes: $daysLeft");
    }
  }

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher_round');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotification,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification);

    final androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print("Permisos de notificación concedidos: $granted");
    }
  }

  static Future<void> showInstantNotifications(
      String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'icc_claro_app',
        'icc_claro_app',
        channelDescription: 'Tu canal de recordatorios',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher_round',
      ),
    );

    await notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> scheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasLoggedIn = prefs.getBool('hasLoggedIn') ?? false;

    print("🔍 Estado de sesión al programar notificaciones: $hasLoggedIn");

    if (!hasLoggedIn) {
      print(
          "🔒 Usuario no ha iniciado sesión, no se programarán notificaciones.");
      return;
    }

    final now = DateTime.now();

    final List<DateTime> notificationDates = [
      DateTime(now.year, 5, 15),
      DateTime(now.year, 6, 15),
      DateTime(now.year, 10, 15),
    ].where((date) => date.isAfter(now)).toList();

    for (final date in notificationDates) {
      final List<DateTime> scheduledDates = [
        date.subtract(Duration(days: 30)),
        date.subtract(Duration(days: 7)),
        date.subtract(Duration(days: 1)),
      ];

      for (final scheduledDate in scheduledDates) {
        if (scheduledDate.isAfter(now)) {
          _scheduleNotification(scheduledDate, date);
          print(
              "📅 Notificación programada para: ${scheduledDate.toIso8601String()} (Target: ${date.toIso8601String()})");
        }
      }
    }
  }

  static void _scheduleNotification(
      DateTime scheduledDate, DateTime targetDate) async {
    final int daysLeft = targetDate.difference(scheduledDate).inDays;
    final String payload = targetDate.toIso8601String();

    final int notificationId = scheduledDate.millisecondsSinceEpoch ~/ 1000;

    await notificationsPlugin.zonedSchedule(
      notificationId,
      'Tu recorrido aún está pendiente de finalización.',
      'Te quedan $daysLeft días para completarlo. Toque aquí para ser redirigido y finalizar su recorrido.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'icc_claro_app',
          'icc_claro_app',
          channelDescription: 'Tu canal de recordatorios',
          importance: Importance.high,
          icon: '@mipmap/ic_launcher_round',
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );

    print(
        "✅ Notificación programada para: ${scheduledDate.toIso8601String()} (Target: ${targetDate.toIso8601String()}) (ID: $notificationId)");
  }
}
