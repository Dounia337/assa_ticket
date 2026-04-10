import 'dart:math' as math;

class AppConstants {
  // App Info
  static const String appName = 'Assa Ticket';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Votre voyage à travers le Tchad commence ici.';

  // Database
  static const String dbName = 'assa_ticket.db';
  static const int dbVersion = 2;

  // SharedPreferences Keys
  static const String prefIsOnboarded = 'is_onboarded';
  static const String prefUserId = 'user_id';
  static const String prefUserPhone = 'user_phone';
  static const String prefUserName = 'user_name';
  static const String prefUserRole = 'user_role';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefAuthToken = 'auth_token';

  // Contact Info Prefs (set by admin)
  static const String prefContactPhone = 'contact_phone';
  static const String prefContactEmail = 'contact_email';
  static const String prefContactWhatsApp = 'contact_whatsapp';
  static const String prefContactMessage = 'contact_message';

  // User roles
  static const String roleUser = 'USER';
  static const String roleAdmin = 'ADMIN';

  // Booking statuses
  static const String statusConfirmed = 'CONFIRME';
  static const String statusPending = 'EN_ATTENTE';
  static const String statusCancelled = 'ANNULE';
  static const String statusCompleted = 'COMPLETE';
  static const String statusRejected = 'REJETE';

  // Payment statuses
  static const String paymentPaid = 'PAYE';
  static const String paymentPending = 'EN_ATTENTE';
  static const String paymentFailed = 'ECHOUE';
  static const String paymentRefunded = 'REMBOURSE';

  // Payment methods
  static const String paymentMoovMoney = 'MOOV_MONEY';
  static const String paymentAirtelMoney = 'AIRTEL_MONEY';
  static const String paymentAtGare = 'A_LA_GARE';

  // Trip statuses
  static const String tripScheduled = 'PROGRAMME';
  static const String tripDeparted = 'PARTI';
  static const String tripArrived = 'ARRIVE';
  static const String tripCancelled = 'ANNULE';

  // Bus statuses
  static const String busActive = 'ACTIF';
  static const String busInMaintenance = 'EN_MAINTENANCE';
  static const String busInactive = 'INACTIF';

  // Luggage
  static const double luggageLightMax = 15.0;
  static const double luggageMediumMax = 30.0;
  static const double luggageExtraFeeLight = 0.0;
  static const double luggageExtraFeeMedium = 1000.0;
  static const double luggageExtraFeeHeavy = 2500.0;
  static const int maxLuggageItems = 3;

  // Cities in Chad
  static const List<String> chadCities = [
    "N'Djamena",
    'Moundou',
    'Sarh',
    'Abéché',
    'Doba',
    'Kélo',
    'Koumra',
    'Pala',
    'Am Timan',
    'Mongo',
    'Bongor',
    'Massakory',
    'Ati',
    'Faya-Largeau',
    'Biltine',
  ];

  // City GPS coordinates [latitude, longitude]
  static const Map<String, List<double>> cityCoordinates = {
    "N'Djamena":    [12.1348, 15.0557],
    'Moundou':      [8.5667,  16.0833],
    'Sarh':         [9.1500,  18.3833],
    'Abéché':       [13.8333, 20.8333],
    'Doba':         [8.6575,  16.8513],
    'Kélo':         [9.3000,  15.8000],
    'Koumra':       [8.9000,  17.5000],
    'Pala':         [9.3667,  14.9000],
    'Am Timan':     [11.0333, 20.2833],
    'Mongo':        [12.1833, 18.6833],
    'Bongor':       [10.2833, 15.3667],
    'Massakory':    [13.0000, 15.7333],
    'Ati':          [13.2167, 18.3333],
    'Faya-Largeau': [17.9167, 19.1167],
    'Biltine':      [14.5333, 20.9167],
  };

  // Average bus speed km/h (Chad road conditions)
  static const double avgBusSpeedKmh = 65.0;

  // Dummy OTP
  static const String dummyOtp = '123456';

  // Ticket prefix
  static const String ticketPrefix = 'AS';

  // Admin contact defaults
  static const String adminPhone = '+23500000000';
  static const String adminEmail = 'admin@assaticket.td';
  static const String adminWhatsApp = '+23500000000';
  static const String adminDefaultMessage =
      'Bonjour! Bienvenue sur Assa Ticket. Comment pouvons-nous vous aider?';

  // Notification types
  static const String notifBookingConfirmed = 'BOOKING_CONFIRMED';
  static const String notifPaymentConfirmed = 'PAYMENT_CONFIRMED';
  static const String notifBookingRejected  = 'BOOKING_REJECTED';
  static const String notifTripReminder     = 'TRIP_REMINDER';
  static const String notifTripDelay        = 'TRIP_DELAY';
  static const String notifPromotion        = 'PROMOTION';

  // Haversine distance between two known cities
  static double distanceBetween(String cityA, String cityB) {
    final a = cityCoordinates[cityA];
    final b = cityCoordinates[cityB];
    if (a == null || b == null) return 0;
    return _haversine(a[0], a[1], b[0], b[1]);
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  // Estimated travel duration in hours
  static double estimatedHours(String origin, String destination) {
    final dist = distanceBetween(origin, destination);
    if (dist == 0) return 0;
    return dist / avgBusSpeedKmh;
  }

  // Format as "5h 30min"
  static String formatDuration(double hours) {
    if (hours <= 0) return 'Inconnu';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }
}
