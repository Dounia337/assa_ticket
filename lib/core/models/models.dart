// ─── USER MODEL ──────────────────────────────────────────────────────────────

class UserModel {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String role;
  final DateTime createdAt;

  UserModel({this.id, required this.fullName, required this.phoneNumber,
    this.email, this.role = 'USER', DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
      id: m['id'], fullName: m['full_name'] ?? '',
      phoneNumber: m['phone_number'] ?? '', email: m['email'],
      role: m['role'] ?? 'USER',
      createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now());

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'full_name': fullName,
    'phone_number': phoneNumber, 'email': email, 'role': role,
    'created_at': createdAt.toIso8601String()};

  UserModel copyWith({int? id, String? fullName, String? phoneNumber,
    String? email, String? role, DateTime? createdAt}) =>
      UserModel(id: id ?? this.id, fullName: fullName ?? this.fullName,
          phoneNumber: phoneNumber ?? this.phoneNumber, email: email ?? this.email,
          role: role ?? this.role, createdAt: createdAt ?? this.createdAt);
}

// ─── ROUTE MODEL ─────────────────────────────────────────────────────────────

class RouteModel {
  final int? id;
  final String originCity;
  final String destinationCity;
  final double basePrice;
  final bool isActive;
  final bool isPopular; // NEW — admin can flag as popular

  RouteModel({this.id, required this.originCity, required this.destinationCity,
    required this.basePrice, this.isActive = true, this.isPopular = false});

  factory RouteModel.fromMap(Map<String, dynamic> m) => RouteModel(
      id: m['id'], originCity: m['origin_city'] ?? '',
      destinationCity: m['destination_city'] ?? '',
      basePrice: (m['base_price'] ?? 0).toDouble(),
      isActive: (m['is_active'] ?? 1) == 1,
      isPopular: (m['is_popular'] ?? 0) == 1);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'origin_city': originCity,
    'destination_city': destinationCity, 'base_price': basePrice,
    'is_active': isActive ? 1 : 0, 'is_popular': isPopular ? 1 : 0};

  String get displayName => '$originCity → $destinationCity';

  RouteModel copyWith({int? id, String? originCity, String? destinationCity,
    double? basePrice, bool? isActive, bool? isPopular}) =>
      RouteModel(id: id ?? this.id,
          originCity: originCity ?? this.originCity,
          destinationCity: destinationCity ?? this.destinationCity,
          basePrice: basePrice ?? this.basePrice,
          isActive: isActive ?? this.isActive,
          isPopular: isPopular ?? this.isPopular);
}

// ─── BUS MODEL ───────────────────────────────────────────────────────────────

class BusModel {
  final int? id;
  final String busNumber;
  final int capacity;
  final String status;
  final String conditionStatus;

  BusModel({this.id, required this.busNumber, required this.capacity,
    this.status = 'ACTIF', this.conditionStatus = 'BON'});

  factory BusModel.fromMap(Map<String, dynamic> m) => BusModel(
      id: m['id'], busNumber: m['bus_number'] ?? '',
      capacity: m['capacity'] ?? 0, status: m['status'] ?? 'ACTIF',
      conditionStatus: m['condition_status'] ?? 'BON');

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'bus_number': busNumber,
    'capacity': capacity, 'status': status, 'condition_status': conditionStatus};

  BusModel copyWith({int? id, String? busNumber, int? capacity,
    String? status, String? conditionStatus}) =>
      BusModel(id: id ?? this.id, busNumber: busNumber ?? this.busNumber,
          capacity: capacity ?? this.capacity, status: status ?? this.status,
          conditionStatus: conditionStatus ?? this.conditionStatus);
}

// ─── TRIP MODEL ──────────────────────────────────────────────────────────────

class TripModel {
  final int? id;
  final int routeId;
  final int busId;
  final DateTime departureDate;
  final String departureTime;
  final int availableSeats;
  final String status;
  RouteModel? route;
  BusModel? bus;

  TripModel({this.id, required this.routeId, required this.busId,
    required this.departureDate, required this.departureTime,
    required this.availableSeats, this.status = 'PROGRAMME',
    this.route, this.bus});

  factory TripModel.fromMap(Map<String, dynamic> m) {
    final trip = TripModel(
        id: m['id'], routeId: m['route_id'] ?? 0, busId: m['bus_id'] ?? 0,
        departureDate: DateTime.tryParse(m['departure_date'] ?? '') ?? DateTime.now(),
        departureTime: m['departure_time'] ?? '',
        availableSeats: m['available_seats'] ?? 0,
        status: m['status'] ?? 'PROGRAMME');
    if (m['origin_city'] != null) {
      trip.route = RouteModel(id: m['route_id'],
          originCity: m['origin_city'], destinationCity: m['destination_city'],
          basePrice: (m['base_price'] ?? 0).toDouble(),
          isPopular: (m['is_popular'] ?? 0) == 1);
    }
    if (m['bus_number'] != null) {
      trip.bus = BusModel(id: m['bus_id'], busNumber: m['bus_number'],
          capacity: m['capacity'] ?? 0,
          status: m['bus_status'] ?? 'ACTIF', conditionStatus: m['condition_status'] ?? 'BON');
    }
    return trip;
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'route_id': routeId, 'bus_id': busId,
    'departure_date': departureDate.toIso8601String().split('T')[0],
    'departure_time': departureTime,
    'available_seats': availableSeats, 'status': status};

  String get formattedDepartureTime {
    try {
      final parts = departureTime.split(':');
      final h = int.parse(parts[0]);
      final m = parts.length > 1 ? parts[1] : '00';
      final p = h >= 12 ? 'PM' : 'AM';
      final dh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$dh:$m $p';
    } catch (_) { return departureTime; }
  }

  TripModel copyWith({int? id, int? routeId, int? busId,
    DateTime? departureDate, String? departureTime, int? availableSeats,
    String? status, RouteModel? route, BusModel? bus}) =>
      TripModel(id: id ?? this.id, routeId: routeId ?? this.routeId,
          busId: busId ?? this.busId,
          departureDate: departureDate ?? this.departureDate,
          departureTime: departureTime ?? this.departureTime,
          availableSeats: availableSeats ?? this.availableSeats,
          status: status ?? this.status, route: route ?? this.route,
          bus: bus ?? this.bus);
}

// ─── BOOKING MODEL ───────────────────────────────────────────────────────────

class BookingModel {
  final int? id;
  final int userId;
  final int tripId;
  final int totalPassengers;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final String ticketNumber;
  final String? paymentScreenshot; // NEW — path to uploaded receipt image

  TripModel? trip;
  List<PassengerModel>? passengers;
  LuggageModel? luggage;
  PaymentModel? payment;

  BookingModel({this.id, required this.userId, required this.tripId,
    required this.totalPassengers, required this.totalPrice,
    this.status = 'EN_ATTENTE', this.paymentStatus = 'EN_ATTENTE',
    DateTime? createdAt, String? ticketNumber,
    this.paymentScreenshot,
    this.trip, this.passengers, this.luggage, this.payment})
      : createdAt = createdAt ?? DateTime.now(),
        ticketNumber = ticketNumber ?? '';

  factory BookingModel.fromMap(Map<String, dynamic> m) => BookingModel(
      id: m['id'], userId: m['user_id'] ?? 0, tripId: m['trip_id'] ?? 0,
      totalPassengers: m['total_passengers'] ?? 1,
      totalPrice: (m['total_price'] ?? 0).toDouble(),
      status: m['status'] ?? 'EN_ATTENTE',
      paymentStatus: m['payment_status'] ?? 'EN_ATTENTE',
      createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
      ticketNumber: m['ticket_number'] ?? '',
      paymentScreenshot: m['payment_screenshot']);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'user_id': userId, 'trip_id': tripId,
    'total_passengers': totalPassengers, 'total_price': totalPrice,
    'status': status, 'payment_status': paymentStatus,
    'created_at': createdAt.toIso8601String(),
    'ticket_number': ticketNumber,
    'payment_screenshot': paymentScreenshot};

  BookingModel copyWith({int? id, int? userId, int? tripId,
    int? totalPassengers, double? totalPrice, String? status,
    String? paymentStatus, DateTime? createdAt, String? ticketNumber,
    String? paymentScreenshot,
    TripModel? trip, List<PassengerModel>? passengers,
    LuggageModel? luggage, PaymentModel? payment}) =>
      BookingModel(id: id ?? this.id, userId: userId ?? this.userId,
          tripId: tripId ?? this.tripId,
          totalPassengers: totalPassengers ?? this.totalPassengers,
          totalPrice: totalPrice ?? this.totalPrice,
          status: status ?? this.status, paymentStatus: paymentStatus ?? this.paymentStatus,
          createdAt: createdAt ?? this.createdAt,
          ticketNumber: ticketNumber ?? this.ticketNumber,
          paymentScreenshot: paymentScreenshot ?? this.paymentScreenshot,
          trip: trip ?? this.trip, passengers: passengers ?? this.passengers,
          luggage: luggage ?? this.luggage, payment: payment ?? this.payment);
}

// ─── PASSENGER MODEL ─────────────────────────────────────────────────────────

class PassengerModel {
  final int? id;
  final int bookingId;
  final String fullName;
  final int seatNumber;

  PassengerModel({this.id, required this.bookingId,
    required this.fullName, required this.seatNumber});

  factory PassengerModel.fromMap(Map<String, dynamic> m) => PassengerModel(
      id: m['id'], bookingId: m['booking_id'] ?? 0,
      fullName: m['full_name'] ?? '', seatNumber: m['seat_number'] ?? 0);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'booking_id': bookingId,
    'full_name': fullName, 'seat_number': seatNumber};
}

// ─── SEAT MODEL ──────────────────────────────────────────────────────────────

class SeatModel {
  final int? id;
  final int tripId;
  final int seatNumber;
  final String status; // 'AVAILABLE', 'OCCUPIED', 'BLOCKED'
  final String? occupiedBy; // Name of passenger or admin note
  final DateTime? occupiedAt;

  SeatModel({this.id, required this.tripId, required this.seatNumber,
    this.status = 'AVAILABLE', this.occupiedBy, this.occupiedAt});

  factory SeatModel.fromMap(Map<String, dynamic> m) => SeatModel(
      id: m['id'], tripId: m['trip_id'] ?? 0, seatNumber: m['seat_number'] ?? 0,
      status: m['status'] ?? 'AVAILABLE', occupiedBy: m['occupied_by'],
      occupiedAt: m['occupied_at'] != null ? DateTime.tryParse(m['occupied_at']) : null);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'trip_id': tripId, 'seat_number': seatNumber,
    'status': status, 'occupied_by': occupiedBy,
    'occupied_at': occupiedAt?.toIso8601String()};

  bool get isAvailable => status == 'AVAILABLE';
  bool get isOccupied => status == 'OCCUPIED';
  bool get isBlocked => status == 'BLOCKED';

  SeatModel copyWith({int? id, int? tripId, int? seatNumber, String? status,
    String? occupiedBy, DateTime? occupiedAt}) =>
      SeatModel(id: id ?? this.id, tripId: tripId ?? this.tripId,
          seatNumber: seatNumber ?? this.seatNumber, status: status ?? this.status,
          occupiedBy: occupiedBy ?? this.occupiedBy,
          occupiedAt: occupiedAt ?? this.occupiedAt);
}

// ─── LUGGAGE MODEL ───────────────────────────────────────────────────────────

class LuggageModel {
  final int? id;
  final int bookingId;
  final int numberOfItems;
  final double totalWeight;
  final double extraFee;

  LuggageModel({this.id, required this.bookingId,
    required this.numberOfItems, required this.totalWeight, this.extraFee = 0.0});

  String get weightCategory {
    if (totalWeight <= 15) return 'Léger';
    if (totalWeight <= 30) return 'Moyen';
    return 'Lourd';
  }

  factory LuggageModel.fromMap(Map<String, dynamic> m) => LuggageModel(
      id: m['id'], bookingId: m['booking_id'] ?? 0,
      numberOfItems: m['number_of_items'] ?? 0,
      totalWeight: (m['total_weight'] ?? 0).toDouble(),
      extraFee: (m['extra_fee'] ?? 0).toDouble());

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'booking_id': bookingId,
    'number_of_items': numberOfItems,
    'total_weight': totalWeight, 'extra_fee': extraFee};
}

// ─── PAYMENT MODEL ───────────────────────────────────────────────────────────

class PaymentModel {
  final int? id;
  final int bookingId;
  final String method;
  final double amount;
  final String status;
  final String? transactionReference;

  PaymentModel({this.id, required this.bookingId, required this.method,
    required this.amount, this.status = 'EN_ATTENTE', this.transactionReference});

  factory PaymentModel.fromMap(Map<String, dynamic> m) => PaymentModel(
      id: m['id'], bookingId: m['booking_id'] ?? 0,
      method: m['method'] ?? '', amount: (m['amount'] ?? 0).toDouble(),
      status: m['status'] ?? 'EN_ATTENTE',
      transactionReference: m['transaction_reference']);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'booking_id': bookingId,
    'method': method, 'amount': amount, 'status': status,
    'transaction_reference': transactionReference};
}

// ─── ADMIN LOG MODEL ─────────────────────────────────────────────────────────

class AdminLogModel {
  final int? id;
  final String action;
  final DateTime createdAt;

  AdminLogModel({this.id, required this.action, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  factory AdminLogModel.fromMap(Map<String, dynamic> m) => AdminLogModel(
      id: m['id'], action: m['action'] ?? '',
      createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now());

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'action': action,
    'created_at': createdAt.toIso8601String()};
}

// ─── SEARCH QUERY MODEL ──────────────────────────────────────────────────────

class SearchQuery {
  final String origin;
  final String destination;
  final DateTime date;
  final int passengers;

  SearchQuery({required this.origin, required this.destination,
    required this.date, this.passengers = 1});
}

// ─── PROMOTION MODEL ─────────────────────────────────────────────────────────

class PromotionModel {
  final int? id;
  final String title;
  final String description;
  final double discountPercent;
  final String? validUntil;
  final bool isActive;

  PromotionModel({this.id, required this.title, required this.description,
    required this.discountPercent, this.validUntil, this.isActive = true});

  factory PromotionModel.fromMap(Map<String, dynamic> m) => PromotionModel(
      id: m['id'], title: m['title'] ?? '', description: m['description'] ?? '',
      discountPercent: (m['discount_percent'] ?? 0).toDouble(),
      validUntil: m['valid_until'], isActive: (m['is_active'] ?? 1) == 1);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'title': title, 'description': description,
    'discount_percent': discountPercent, 'valid_until': validUntil,
    'is_active': isActive ? 1 : 0};

  PromotionModel copyWith({int? id, String? title, String? description,
    double? discountPercent, String? validUntil, bool? isActive}) =>
      PromotionModel(id: id ?? this.id, title: title ?? this.title,
          description: description ?? this.description,
          discountPercent: discountPercent ?? this.discountPercent,
          validUntil: validUntil ?? this.validUntil,
          isActive: isActive ?? this.isActive);
}

// ─── APP NOTIFICATION MODEL ──────────────────────────────────────────────────

class AppNotificationModel {
  final int? id;
  final int? userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({this.id, this.userId, required this.title,
    required this.body, required this.type, this.isRead = false, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  factory AppNotificationModel.fromMap(Map<String, dynamic> m) =>
      AppNotificationModel(id: m['id'], userId: m['user_id'],
          title: m['title'] ?? '', body: m['body'] ?? '',
          type: m['type'] ?? '', isRead: (m['is_read'] ?? 0) == 1,
          createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now());

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'user_id': userId, 'title': title,
    'body': body, 'type': type, 'is_read': isRead ? 1 : 0,
    'created_at': createdAt.toIso8601String()};

  AppNotificationModel copyWith({bool? isRead}) => AppNotificationModel(
      id: id, userId: userId, title: title, body: body, type: type,
      isRead: isRead ?? this.isRead, createdAt: createdAt);
}

// ─── CONTACT INFO MODEL ──────────────────────────────────────────────────────

class ContactInfoModel {
  final String phone;
  final String email;
  final String whatsApp;
  final String helpMessage;

  const ContactInfoModel({required this.phone, required this.email,
    required this.whatsApp, required this.helpMessage});

  factory ContactInfoModel.defaults() => const ContactInfoModel(
      phone: '+23500000000', email: 'admin@assaticket.td',
      whatsApp: '+23500000000',
      helpMessage: "Bonjour! Bienvenue sur Assa Ticket. Comment pouvons-nous vous aider?");

  ContactInfoModel copyWith({String? phone, String? email,
    String? whatsApp, String? helpMessage}) =>
      ContactInfoModel(phone: phone ?? this.phone, email: email ?? this.email,
          whatsApp: whatsApp ?? this.whatsApp,
          helpMessage: helpMessage ?? this.helpMessage);
}

// ─── PAYMENT ACCOUNT MODEL (NEW) ─────────────────────────────────────────────
// Admin-managed mobile money accounts shown to users during payment

class PaymentAccountModel {
  final int? id;
  final String type;          // MOOV_MONEY or AIRTEL_MONEY
  final String accountName;   // e.g. "Assa Ticket SARL"
  final String accountNumber; // e.g. "+235 66 00 00 00"
  final bool isActive;

  PaymentAccountModel({this.id, required this.type,
    required this.accountName, required this.accountNumber,
    this.isActive = true});

  factory PaymentAccountModel.fromMap(Map<String, dynamic> m) =>
      PaymentAccountModel(id: m['id'], type: m['type'] ?? '',
          accountName: m['account_name'] ?? '',
          accountNumber: m['account_number'] ?? '',
          isActive: (m['is_active'] ?? 1) == 1);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id, 'type': type,
    'account_name': accountName, 'account_number': accountNumber,
    'is_active': isActive ? 1 : 0};

  PaymentAccountModel copyWith({int? id, String? type, String? accountName,
    String? accountNumber, bool? isActive}) =>
      PaymentAccountModel(id: id ?? this.id, type: type ?? this.type,
          accountName: accountName ?? this.accountName,
          accountNumber: accountNumber ?? this.accountNumber,
          isActive: isActive ?? this.isActive);

  String get displayType {
    switch (type) {
      case 'MOOV_MONEY':   return 'Moov Money';
      case 'AIRTEL_MONEY': return 'Airtel Money';
      default: return type;
    }
  }
}