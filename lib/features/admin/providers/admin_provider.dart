import 'package:flutter/foundation.dart';
import 'package:assa_ticket/core/database/database_helper.dart';
import 'package:assa_ticket/core/models/models.dart';
import 'package:assa_ticket/core/services/notification_service.dart';

class AdminProvider extends ChangeNotifier {
  List<RouteModel>          _routes   = [];
  List<BusModel>            _buses    = [];
  List<TripModel>           _trips    = [];
  List<BookingModel>        _bookings = [];
  List<UserModel>           _users    = [];
  List<PromotionModel>      _promotions = [];
  List<PaymentAccountModel> _paymentAccounts = [];
  ContactInfoModel _contactInfo = ContactInfoModel.defaults();
  Map<String, dynamic>      _stats    = {};
  bool   _isLoading = false;
  String? _error;

  List<RouteModel>          get routes          => _routes;
  List<BusModel>            get buses           => _buses;
  List<TripModel>           get trips           => _trips;
  List<BookingModel>        get bookings        => _bookings;
  List<UserModel>           get users           => _users;
  List<PromotionModel>      get promotions      => _promotions;
  List<PaymentAccountModel> get paymentAccounts => _paymentAccounts;
  ContactInfoModel          get contactInfo     => _contactInfo;
  Map<String, dynamic>      get stats           => _stats;
  bool                      get isLoading       => _isLoading;
  String?                   get error           => _error;

  Future<void> loadAll() async {
    _isLoading = true; notifyListeners();
    try {
      await Future.wait([loadRoutes(), loadBuses(), loadTrips(), loadBookings(),
        loadStats(), loadUsers(), loadPromotions(), loadContactInfo(),
        loadPaymentAccounts()]);
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  // ── ROUTES ────────────────────────────────────────────────────────────────
  Future<void> loadRoutes() async {
    _routes = await DatabaseHelper.instance.getAllRoutes(); notifyListeners(); }
  Future<bool> addRoute(RouteModel r) async {
    try {
      await DatabaseHelper.instance.insertRoute(r);
      await DatabaseHelper.instance.insertAdminLog(
          'Trajet ajouté: ${r.originCity} → ${r.destinationCity}');
      await loadRoutes(); return true;
    } catch (_) { return false; }
  }
  Future<bool> updateRoute(RouteModel r) async {
    try {
      await DatabaseHelper.instance.updateRoute(r);
      await DatabaseHelper.instance.insertAdminLog(
          'Trajet modifié: ${r.originCity} → ${r.destinationCity}');
      await loadRoutes(); return true;
    } catch (_) { return false; }
  }
  Future<bool> deleteRoute(int id) async {
    try {
      await DatabaseHelper.instance.deleteRoute(id);
      await DatabaseHelper.instance.insertAdminLog('Trajet supprimé (ID: $id)');
      await loadRoutes(); return true;
    } catch (_) { return false; }
  }

  // ── BUSES ─────────────────────────────────────────────────────────────────
  Future<void> loadBuses() async {
    _buses = await DatabaseHelper.instance.getAllBuses(); notifyListeners(); }
  Future<bool> addBus(BusModel b) async {
    try { await DatabaseHelper.instance.insertBus(b);
    await DatabaseHelper.instance.insertAdminLog('Bus ajouté: ${b.busNumber}');
    await loadBuses(); return true; } catch (_) { return false; }
  }
  Future<bool> updateBus(BusModel b) async {
    try { await DatabaseHelper.instance.updateBus(b);
    await DatabaseHelper.instance.insertAdminLog('Bus modifié: ${b.busNumber}');
    await loadBuses(); return true; } catch (_) { return false; }
  }
  Future<bool> deleteBus(int id) async {
    try { await DatabaseHelper.instance.deleteBus(id);
    await DatabaseHelper.instance.insertAdminLog('Bus supprimé (ID: $id)');
    await loadBuses(); return true; } catch (_) { return false; }
  }

  // ── TRIPS ─────────────────────────────────────────────────────────────────
  Future<void> loadTrips() async {
    _trips = await DatabaseHelper.instance.getAllTrips(); notifyListeners(); }
  Future<bool> addTrip(TripModel t) async {
    try { await DatabaseHelper.instance.insertTrip(t);
    await DatabaseHelper.instance.insertAdminLog('Voyage programmé');
    await loadTrips(); return true; } catch (_) { return false; }
  }
  Future<bool> updateTrip(TripModel t) async {
    try { await DatabaseHelper.instance.updateTrip(t);
    await DatabaseHelper.instance.insertAdminLog('Voyage modifié (ID: ${t.id})');
    await loadTrips(); return true; } catch (_) { return false; }
  }
  Future<bool> deleteTrip(int id) async {
    try { await DatabaseHelper.instance.deleteTrip(id);
    await DatabaseHelper.instance.insertAdminLog('Voyage supprimé (ID: $id)');
    await loadTrips(); return true; } catch (_) { return false; }
  }
  Future<bool> updateTripSeats(int tripId, int seats) async {
    try { await DatabaseHelper.instance.updateTripSeats(tripId, seats);
    await loadTrips(); return true; } catch (_) { return false; }
  }

  // ── BOOKINGS ──────────────────────────────────────────────────────────────
  Future<void> loadBookings() async {
    _bookings = await DatabaseHelper.instance.getAllBookings(); notifyListeners(); }

  Future<bool> confirmBooking(int bookingId) async {
    try {
      final b = _bookings.firstWhere((b) => b.id == bookingId);
      await DatabaseHelper.instance.updateBookingStatus(bookingId, 'CONFIRME', 'PAYE');
      await DatabaseHelper.instance.insertAdminLog('Réservation confirmée (ID: $bookingId)');
      await NotificationService.instance.onBookingConfirmedByAdmin(
          userId: b.userId, ticketNumber: b.ticketNumber);
      await loadBookings(); await loadStats(); return true;
    } catch (_) { return false; }
  }

  Future<bool> rejectBooking(int bookingId, {String reason = ''}) async {
    try {
      final b = _bookings.firstWhere((b) => b.id == bookingId);
      await DatabaseHelper.instance.updateBookingStatus(bookingId, 'REJETE', 'ECHOUE');
      await DatabaseHelper.instance.insertAdminLog(
          'Réservation rejetée (ID: $bookingId)${reason.isNotEmpty ? " — $reason" : ""}');
      await NotificationService.instance.onBookingRejected(
          userId: b.userId, ticketNumber: b.ticketNumber, reason: reason);
      await loadBookings(); await loadStats(); return true;
    } catch (_) { return false; }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      await DatabaseHelper.instance.updateBookingStatus(bookingId, 'ANNULE', 'REMBOURSE');
      await DatabaseHelper.instance.insertAdminLog('Réservation annulée (ID: $bookingId)');
      await loadBookings(); await loadStats(); return true;
    } catch (_) { return false; }
  }

  // ── USERS ─────────────────────────────────────────────────────────────────
  Future<void> loadUsers() async {
    _users = await DatabaseHelper.instance.getAllUsers(); notifyListeners(); }

  // ── STATS ─────────────────────────────────────────────────────────────────
  Future<void> loadStats() async {
    _stats = await DatabaseHelper.instance.getReportStats(); notifyListeners(); }

  // ── PROMOTIONS ────────────────────────────────────────────────────────────
  Future<void> loadPromotions() async {
    _promotions = await DatabaseHelper.instance.getAllPromotions(); notifyListeners(); }
  Future<bool> addPromotion(PromotionModel p) async {
    try {
      await DatabaseHelper.instance.insertPromotion(p);
      await DatabaseHelper.instance.insertAdminLog('Promotion créée: ${p.title}');
      await NotificationService.instance.broadcastPromotion(
          promoTitle: p.title, discountPercent: p.discountPercent);
      await loadPromotions(); return true;
    } catch (_) { return false; }
  }
  Future<bool> updatePromotion(PromotionModel p) async {
    try { await DatabaseHelper.instance.updatePromotion(p);
    await loadPromotions(); return true; } catch (_) { return false; }
  }
  Future<bool> deletePromotion(int id) async {
    try { await DatabaseHelper.instance.deletePromotion(id);
    await loadPromotions(); return true; } catch (_) { return false; }
  }

  // ── CONTACT INFO ──────────────────────────────────────────────────────────
  Future<void> loadContactInfo() async {
    _contactInfo = await DatabaseHelper.instance.getContactInfo(); notifyListeners(); }
  Future<bool> saveContactInfo(ContactInfoModel info) async {
    try {
      await DatabaseHelper.instance.upsertContactInfo(info);
      await DatabaseHelper.instance.insertAdminLog('Contact mis à jour');
      _contactInfo = info; notifyListeners(); return true;
    } catch (_) { return false; }
  }

  // ── PAYMENT ACCOUNTS (NEW) ────────────────────────────────────────────────
  Future<void> loadPaymentAccounts() async {
    _paymentAccounts = await DatabaseHelper.instance.getAllPaymentAccounts();
    notifyListeners();
  }
  Future<bool> addPaymentAccount(PaymentAccountModel a) async {
    try {
      await DatabaseHelper.instance.insertPaymentAccount(a);
      await DatabaseHelper.instance.insertAdminLog(
          'Compte paiement ajouté: ${a.displayType} — ${a.accountNumber}');
      await loadPaymentAccounts(); return true;
    } catch (_) { return false; }
  }
  Future<bool> updatePaymentAccount(PaymentAccountModel a) async {
    try {
      await DatabaseHelper.instance.updatePaymentAccount(a);
      await DatabaseHelper.instance.insertAdminLog(
          'Compte paiement modifié: ${a.displayType}');
      await loadPaymentAccounts(); return true;
    } catch (_) { return false; }
  }
  Future<bool> deletePaymentAccount(int id) async {
    try {
      await DatabaseHelper.instance.deletePaymentAccount(id);
      await loadPaymentAccounts(); return true;
    } catch (_) { return false; }
  }
}