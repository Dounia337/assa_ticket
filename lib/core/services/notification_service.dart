import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import '../constants/app_constants.dart';

/// Service that wraps flutter_local_notifications and also persists
/// notifications to the local database for the in-app notification screen.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── INITIALISE ──────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
    debugPrint('>>> NotificationService initialized');
  }

  // ─── REQUEST PERMISSION (Android 13+) ───────────────────────────────────

  Future<void> requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('>>> Notification permission error: $e');
    }
  }

  // ─── SHOW A LOCAL (SYSTEM) NOTIFICATION ─────────────────────────────────

  Future<void> _showLocal({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    try {
      const androidDetails = AndroidNotificationDetails(
        'assa_ticket_channel',
        'Assa Ticket',
        channelDescription: 'Notifications de réservation et de voyage',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('>>> Local notification error: $e');
    }
  }

  // ─── PERSIST TO DB + OPTIONALLY SHOW LOCAL ───────────────────────────────

  Future<void> _send({
    required int? userId,
    required String title,
    required String body,
    required String type,
    bool showLocal = true,
  }) async {
    // Persist in DB
    try {
      await ApiService.instance.insertNotification(AppNotificationModel(
        userId: userId,
        title: title,
        body: body,
        type: type,
      ));
    } catch (e) {
      debugPrint('>>> DB notification insert error: $e');
    }

    // Fire local system notification
    if (showLocal) {
      await _showLocal(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: body,
      );
    }
  }

  // ─── TYPED TRIGGER METHODS ───────────────────────────────────────────────

  /// Called when user completes a booking
  Future<void> onBookingCreated({
    required int userId,
    required String ticketNumber,
    required String origin,
    required String destination,
    required String method,
  }) async {
    final isPaid = method != AppConstants.paymentAtGare;

    await _send(
      userId: userId,
      title: 'Réservation créée ✅',
      body: 'Billet $ticketNumber — $origin → $destination reçu avec succès.',
      type: AppConstants.notifBookingConfirmed,
    );

    if (isPaid) {
      await _send(
        userId: userId,
        title: 'Paiement confirmé 💳',
        body: 'Votre paiement pour le trajet $origin → $destination a été accepté.',
        type: AppConstants.notifPaymentConfirmed,
      );
    }
  }

  /// Called by admin when confirming a booking
  Future<void> onBookingConfirmedByAdmin({
    required int userId,
    required String ticketNumber,
  }) async {
    await _send(
      userId: userId,
      title: 'Réservation confirmée ✅',
      body: 'Votre réservation $ticketNumber a été confirmée par l\'administrateur.',
      type: AppConstants.notifBookingConfirmed,
    );
  }

  /// Called by admin when rejecting a booking
  Future<void> onBookingRejected({
    required int userId,
    required String ticketNumber,
    String reason = '',
  }) async {
    await _send(
      userId: userId,
      title: 'Réservation rejetée ❌',
      body: reason.isEmpty
          ? 'Votre réservation $ticketNumber a été rejetée. Contactez le support.'
          : 'Réservation $ticketNumber rejetée: $reason',
      type: AppConstants.notifBookingRejected,
    );
  }

  /// Simulated trip reminder
  Future<void> sendTripReminder({
    required int userId,
    required String origin,
    required String destination,
    required String departureTime,
  }) async {
    await _send(
      userId: userId,
      title: '⏰ Rappel de voyage',
      body: 'Votre bus $origin → $destination part à $departureTime. Bon voyage!',
      type: AppConstants.notifTripReminder,
    );
  }

  /// Simulated trip delay
  Future<void> sendTripDelay({
    required int userId,
    required String origin,
    required String destination,
    required int delayMinutes,
  }) async {
    await _send(
      userId: userId,
      title: '⚠️ Retard de départ',
      body: 'Le bus $origin → $destination est retardé de ${delayMinutes}min. Nous vous informerons.',
      type: AppConstants.notifTripDelay,
    );
  }

  /// Promotion broadcast (no specific userId → all users)
  Future<void> broadcastPromotion({
    required String promoTitle,
    required double discountPercent,
  }) async {
    await _send(
      userId: null, // broadcast
      title: '🎉 Nouvelle promotion!',
      body: '${discountPercent.toStringAsFixed(0)}% de réduction — $promoTitle. Réservez maintenant!',
      type: AppConstants.notifPromotion,
    );
  }
}
