import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/models.dart';

/// Remote API service — replaces DatabaseHelper for all data operations.
/// Every method signature mirrors DatabaseHelper exactly so providers need
/// only a one-line import/instance change.
class ApiService {
  static ApiService? _instance;
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }
  ApiService._();

  static const String baseUrl =
      'http://169.239.251.102:280/~deubaybe.dounia/api';

  final _client = http.Client();

  // ── HTTP helpers ───────────────────────────────────────────────────────────

  Future<dynamic> _get(String file, Map<String, String> params) async {
    try {
      final uri =
          Uri.parse('$baseUrl/$file').replace(queryParameters: params);
      final res =
          await _client.get(uri).timeout(const Duration(seconds: 20));
      final body = json.decode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) return body['data'];
      throw Exception(body['error'] ?? 'Erreur serveur');
    } on TimeoutException {
      throw Exception('Délai dépassé. Vérifiez votre connexion.');
    } catch (e) {
      debugPrint('>>> ApiService GET $file error: $e');
      rethrow;
    }
  }

  Future<dynamic> _post(String file, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl/$file');
      final res = await _client
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(data))
          .timeout(const Duration(seconds: 20));
      final body = json.decode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) return body['data'];
      throw Exception(body['error'] ?? 'Erreur serveur');
    } on TimeoutException {
      throw Exception('Délai dépassé. Vérifiez votre connexion.');
    } catch (e) {
      debugPrint('>>> ApiService POST $file error: $e');
      rethrow;
    }
  }

  // ── USERS ──────────────────────────────────────────────────────────────────

  Future<UserModel?> getUserByPhone(String phone) async {
    final data = await _get('users.php', {'action': 'getByPhone', 'phone': phone});
    return data == null ? null : UserModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<UserModel?> getUserById(int id) async {
    final data = await _get('users.php', {'action': 'getById', 'id': '$id'});
    return data == null ? null : UserModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<int> insertUser(UserModel u) async {
    final data = await _post('users.php', {'action': 'insert', ...u.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updateUser(UserModel u) async {
    await _post('users.php', {'action': 'update', ...u.toMap()});
  }

  Future<List<UserModel>> getAllUsers() async {
    final data = await _get('users.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── ROUTES ─────────────────────────────────────────────────────────────────

  Future<List<RouteModel>> getAllRoutes({bool activeOnly = false}) async {
    final data = await _get('routes.php',
        {'action': 'getAll', 'active_only': activeOnly ? '1' : '0'});
    if (data == null) return [];
    return (data as List)
        .map((e) => RouteModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<RouteModel>> getPopularRoutes() async {
    final data = await _get('routes.php', {'action': 'getPopular'});
    if (data == null) return [];
    return (data as List)
        .map((e) => RouteModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<RouteModel?> getRouteById(int id) async {
    final data = await _get('routes.php', {'action': 'getById', 'id': '$id'});
    return data == null ? null : RouteModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<int> insertRoute(RouteModel r) async {
    final data = await _post('routes.php', {'action': 'insert', ...r.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updateRoute(RouteModel r) async {
    await _post('routes.php', {'action': 'update', ...r.toMap()});
  }

  Future<void> deleteRoute(int id) async {
    await _post('routes.php', {'action': 'delete', 'id': id});
  }

  // ── BUSES ──────────────────────────────────────────────────────────────────

  Future<List<BusModel>> getAllBuses() async {
    final data = await _get('buses.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) => BusModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<BusModel?> getBusById(int id) async {
    final data = await _get('buses.php', {'action': 'getById', 'id': '$id'});
    return data == null ? null : BusModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<int> insertBus(BusModel b) async {
    final data = await _post('buses.php', {'action': 'insert', ...b.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updateBus(BusModel b) async {
    await _post('buses.php', {'action': 'update', ...b.toMap()});
  }

  Future<void> deleteBus(int id) async {
    await _post('buses.php', {'action': 'delete', 'id': id});
  }

  // ── TRIPS ──────────────────────────────────────────────────────────────────

  Future<List<TripModel>> searchTrips(
      {required String origin,
      required String destination,
      required DateTime date}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final data = await _get('trips.php', {
      'action': 'search',
      'origin': origin,
      'destination': destination,
      'date': dateStr,
    });
    if (data == null) return [];
    return (data as List)
        .map((e) => TripModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<TripModel>> getTripsByOrigin(String origin) async {
    final data =
        await _get('trips.php', {'action': 'getByOrigin', 'origin': origin});
    if (data == null) return [];
    return (data as List)
        .map((e) => TripModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<TripModel>> getAllTrips() async {
    final data = await _get('trips.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) => TripModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<TripModel?> getTripById(int id) async {
    final data = await _get('trips.php', {'action': 'getById', 'id': '$id'});
    return data == null
        ? null
        : TripModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<int> insertTrip(TripModel t) async {
    final data = await _post('trips.php', {'action': 'insert', ...t.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updateTrip(TripModel t) async {
    await _post('trips.php', {'action': 'update', ...t.toMap()});
  }

  Future<void> updateTripSeats(int tripId, int seats) async {
    await _post('trips.php',
        {'action': 'updateSeats', 'trip_id': tripId, 'seats': seats});
  }

  Future<void> updateTripAvailableSeatsFromSeatsTable(int tripId) async {
    await _post('trips.php',
        {'action': 'updateSeatsFromTable', 'trip_id': tripId});
  }

  Future<void> deleteTrip(int id) async {
    await _post('trips.php', {'action': 'delete', 'id': id});
  }

  // ── BOOKINGS ───────────────────────────────────────────────────────────────

  /// PHP returns booking rows with trip/passengers/luggage/payment already
  /// embedded — no extra round-trips needed.
  BookingModel _parseBooking(Map<String, dynamic> m) {
    final b = BookingModel.fromMap(m);
    if (m['trip'] != null) {
      b.trip = TripModel.fromMap(Map<String, dynamic>.from(m['trip'] as Map));
    }
    if (m['passengers'] != null) {
      b.passengers = (m['passengers'] as List)
          .map((p) =>
              PassengerModel.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
    }
    if (m['luggage'] != null) {
      b.luggage =
          LuggageModel.fromMap(Map<String, dynamic>.from(m['luggage'] as Map));
    }
    if (m['payment'] != null) {
      b.payment =
          PaymentModel.fromMap(Map<String, dynamic>.from(m['payment'] as Map));
    }
    return b;
  }

  Future<List<BookingModel>> getUserBookings(int userId) async {
    final data = await _get('bookings.php',
        {'action': 'getUserBookings', 'user_id': '$userId'});
    if (data == null) return [];
    return (data as List)
        .map((e) => _parseBooking(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<BookingModel>> getAllBookings() async {
    final data = await _get('bookings.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) => _parseBooking(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<BookingModel?> getBookingById(int id) async {
    final data =
        await _get('bookings.php', {'action': 'getById', 'id': '$id'});
    return data == null
        ? null
        : _parseBooking(Map<String, dynamic>.from(data as Map));
  }

  Future<int> insertBooking(BookingModel b) async {
    final data =
        await _post('bookings.php', {'action': 'insert', ...b.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updateBooking(BookingModel b) async {
    await _post('bookings.php', {'action': 'update', ...b.toMap()});
  }

  Future<void> updateBookingStatus(
      int id, String status, String paymentStatus) async {
    await _post('bookings.php', {
      'action': 'updateStatus',
      'id': id,
      'status': status,
      'payment_status': paymentStatus,
    });
  }

  Future<void> updateBookingScreenshot(int id, String? path) async {
    await _post('bookings.php', {
      'action': 'updateScreenshot',
      'id': id,
      'payment_screenshot': path,
    });
  }

  // ── PASSENGERS ─────────────────────────────────────────────────────────────

  Future<int> insertPassenger(PassengerModel p) async {
    final data =
        await _post('passengers.php', {'action': 'insert', ...p.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<List<PassengerModel>> getPassengersByBooking(int bookingId) async {
    final data = await _get('passengers.php',
        {'action': 'getByBooking', 'booking_id': '$bookingId'});
    if (data == null) return [];
    return (data as List)
        .map((e) =>
            PassengerModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── LUGGAGE ────────────────────────────────────────────────────────────────

  Future<int> insertLuggage(LuggageModel l) async {
    final data =
        await _post('luggage.php', {'action': 'insert', ...l.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<LuggageModel?> getLuggageByBooking(int bookingId) async {
    final data = await _get('luggage.php',
        {'action': 'getByBooking', 'booking_id': '$bookingId'});
    return data == null
        ? null
        : LuggageModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  // ── PAYMENTS ───────────────────────────────────────────────────────────────

  Future<int> insertPayment(PaymentModel p) async {
    final data =
        await _post('payments.php', {'action': 'insert', ...p.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<PaymentModel?> getPaymentByBooking(int bookingId) async {
    final data = await _get('payments.php',
        {'action': 'getByBooking', 'booking_id': '$bookingId'});
    return data == null
        ? null
        : PaymentModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> updatePaymentStatus(int id, String status) async {
    await _post('payments.php',
        {'action': 'updateStatus', 'id': id, 'status': status});
  }

  Future<List<PaymentModel>> getAllPayments() async {
    final data = await _get('payments.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) => PaymentModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── ADMIN LOGS ─────────────────────────────────────────────────────────────

  Future<int> insertAdminLog(String logText) async {
    final data = await _post('admin.php',
        {'action': 'insertLog', 'log_action': logText});
    return (data['id'] as num).toInt();
  }

  Future<List<AdminLogModel>> getAdminLogs() async {
    final data = await _get('admin.php', {'action': 'getLogs'});
    if (data == null) return [];
    return (data as List)
        .map((e) =>
            AdminLogModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── STATS ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReportStats() async {
    final data = await _get('admin.php', {'action': 'getStats'});
    return Map<String, dynamic>.from(data as Map);
  }

  // ── SEATS ──────────────────────────────────────────────────────────────────

  Future<void> initializeSeatsForTrip(int tripId, int busCapacity) async {
    await _post('seats.php', {
      'action': 'initialize',
      'trip_id': tripId,
      'bus_capacity': busCapacity,
    });
  }

  Future<List<SeatModel>> getSeatsForTrip(int tripId) async {
    final data =
        await _get('seats.php', {'action': 'getForTrip', 'trip_id': '$tripId'});
    if (data == null) return [];
    return (data as List)
        .map((e) => SeatModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<SeatModel?> getSeat(int tripId, int seatNumber) async {
    final data = await _get('seats.php', {
      'action': 'get',
      'trip_id': '$tripId',
      'seat_number': '$seatNumber',
    });
    return data == null
        ? null
        : SeatModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> updateSeatStatus(int tripId, int seatNumber, String status,
      {String? occupiedBy}) async {
    final body = <String, dynamic>{
      'action': 'updateStatus',
      'trip_id': tripId,
      'seat_number': seatNumber,
      'status': status,
    };
    if (occupiedBy != null) body['occupied_by'] = occupiedBy;
    await _post('seats.php', body);
  }

  Future<List<int>> getOccupiedSeats(int tripId) async {
    final data = await _get(
        'seats.php', {'action': 'getOccupied', 'trip_id': '$tripId'});
    if (data == null) return [];
    return (data as List).map((e) => (e as num).toInt()).toList();
  }

  Future<List<int>> getAvailableSeats(int tripId) async {
    final data = await _get(
        'seats.php', {'action': 'getAvailable', 'trip_id': '$tripId'});
    if (data == null) return [];
    return (data as List).map((e) => (e as num).toInt()).toList();
  }

  // ── PROMOTIONS ─────────────────────────────────────────────────────────────

  Future<List<PromotionModel>> getActivePromotions() async {
    final data = await _get('promotions.php', {'action': 'getActive'});
    if (data == null) return [];
    return (data as List)
        .map((e) =>
            PromotionModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<PromotionModel>> getAllPromotions() async {
    final data = await _get('promotions.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) =>
            PromotionModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<int> insertPromotion(PromotionModel p) async {
    final data =
        await _post('promotions.php', {'action': 'insert', ...p.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updatePromotion(PromotionModel p) async {
    await _post('promotions.php', {'action': 'update', ...p.toMap()});
  }

  Future<void> deletePromotion(int id) async {
    await _post('promotions.php', {'action': 'delete', 'id': id});
  }

  // ── CONTACT INFO ───────────────────────────────────────────────────────────

  Future<ContactInfoModel> getContactInfo() async {
    final data = await _get('contact_info.php', {'action': 'get'});
    final m = (data as Map).cast<String, dynamic>();
    return ContactInfoModel(
      phone:       m['phone']?.toString()   ?? AppConstants.adminPhone,
      email:       m['email']?.toString()   ?? AppConstants.adminEmail,
      whatsApp:    m['whatsapp']?.toString() ?? AppConstants.adminWhatsApp,
      helpMessage: m['message']?.toString() ?? AppConstants.adminDefaultMessage,
    );
  }

  Future<void> upsertContactInfo(ContactInfoModel info) async {
    await _post('contact_info.php', {
      'action':   'upsert',
      'phone':    info.phone,
      'email':    info.email,
      'whatsapp': info.whatsApp,
      'message':  info.helpMessage,
    });
  }

  // ── NOTIFICATIONS ──────────────────────────────────────────────────────────

  Future<int> insertNotification(AppNotificationModel n) async {
    final data =
        await _post('notifications.php', {'action': 'insert', ...n.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<List<AppNotificationModel>> getUserNotifications(int userId) async {
    final data = await _get('notifications.php',
        {'action': 'getForUser', 'user_id': '$userId'});
    if (data == null) return [];
    return (data as List)
        .map((e) =>
            AppNotificationModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<int> getUnreadCount(int userId) async {
    final data = await _get('notifications.php',
        {'action': 'getUnreadCount', 'user_id': '$userId'});
    return (data as num).toInt();
  }

  Future<void> markNotificationRead(int id) async {
    await _post('notifications.php', {'action': 'markRead', 'id': id});
  }

  Future<void> markAllNotificationsRead(int userId) async {
    await _post('notifications.php',
        {'action': 'markAllRead', 'user_id': userId});
  }

  // ── PAYMENT ACCOUNTS ───────────────────────────────────────────────────────

  Future<List<PaymentAccountModel>> getAllPaymentAccounts() async {
    final data = await _get('payment_accounts.php', {'action': 'getAll'});
    if (data == null) return [];
    return (data as List)
        .map((e) =>
            PaymentAccountModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<PaymentAccountModel?> getPaymentAccountByType(String type) async {
    final data = await _get(
        'payment_accounts.php', {'action': 'getByType', 'type': type});
    return data == null
        ? null
        : PaymentAccountModel.fromMap(
            Map<String, dynamic>.from(data as Map));
  }

  Future<int> insertPaymentAccount(PaymentAccountModel a) async {
    final data = await _post(
        'payment_accounts.php', {'action': 'insert', ...a.toMap()});
    return (data['id'] as num).toInt();
  }

  Future<void> updatePaymentAccount(PaymentAccountModel a) async {
    await _post('payment_accounts.php', {'action': 'update', ...a.toMap()});
  }

  Future<void> deletePaymentAccount(int id) async {
    await _post('payment_accounts.php', {'action': 'delete', 'id': id});
  }
}
