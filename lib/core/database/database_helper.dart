import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  DatabaseHelper._();
  static DatabaseHelper get instance { _instance ??= DatabaseHelper._(); return _instance!; }

  Future<Database> get database async { _database ??= await _initDatabase(); return _database!; }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    debugPrint('>>> DB PATH: $path');
    final dbFile = File(path);
    if (await dbFile.exists()) { await dbFile.delete(); debugPrint('>>> OLD DB DELETED'); }
    final db = await openDatabase(path, version: AppConstants.dbVersion,
        onCreate: _onCreate, onUpgrade: _onUpgrade);
    debugPrint('>>> DB OPENED');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT, phone_number TEXT UNIQUE NOT NULL, email TEXT,
      role TEXT DEFAULT 'USER', created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');

    await db.execute('''CREATE TABLE routes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      origin_city TEXT, destination_city TEXT, base_price REAL,
      is_active INTEGER DEFAULT 1,
      is_popular INTEGER DEFAULT 0)''');   /* NEW is_popular column */

    await db.execute('''CREATE TABLE buses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bus_number TEXT, capacity INTEGER, status TEXT, condition_status TEXT)''');

    await db.execute('''CREATE TABLE trips (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      route_id INTEGER REFERENCES routes(id), bus_id INTEGER REFERENCES buses(id),
      departure_date TEXT, departure_time TEXT, available_seats INTEGER, status TEXT)''');

    await db.execute('''CREATE TABLE seats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      trip_id INTEGER REFERENCES trips(id), seat_number INTEGER,
      status TEXT DEFAULT 'AVAILABLE', occupied_by TEXT, occupied_at TEXT)''');

    await db.execute('''CREATE TABLE bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER REFERENCES users(id), trip_id INTEGER REFERENCES trips(id),
      total_passengers INTEGER, total_price REAL, status TEXT, payment_status TEXT,
      ticket_number TEXT, payment_screenshot TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');  /* NEW payment_screenshot */

    await db.execute('''CREATE TABLE passengers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_id INTEGER REFERENCES bookings(id), full_name TEXT, seat_number INTEGER)''');

    await db.execute('''CREATE TABLE luggage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_id INTEGER REFERENCES bookings(id),
      number_of_items INTEGER, total_weight REAL, extra_fee REAL)''');

    await db.execute('''CREATE TABLE payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_id INTEGER REFERENCES bookings(id),
      method TEXT, amount REAL, status TEXT, transaction_reference TEXT)''');

    await db.execute('''CREATE TABLE admin_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      action TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');

    await db.execute('''CREATE TABLE promotions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL, description TEXT, discount_percent REAL DEFAULT 0,
      valid_until TEXT, is_active INTEGER DEFAULT 1)''');

    await db.execute('''CREATE TABLE contact_info (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key_name TEXT UNIQUE NOT NULL, value TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE app_notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER, title TEXT NOT NULL, body TEXT NOT NULL,
      type TEXT NOT NULL, is_read INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP)''');

    /* NEW — admin-managed mobile money accounts */
    await db.execute('''CREATE TABLE payment_accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL, account_name TEXT, account_number TEXT NOT NULL,
      is_active INTEGER DEFAULT 1)''');

    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (final t in ['app_notifications','contact_info','promotions','admin_logs',
      'payments','luggage','passengers','bookings','seats','trips','buses','routes',
      'users','payment_accounts']) {
      await db.execute('DROP TABLE IF EXISTS $t');
    }
    await _onCreate(db, newVersion);
  }

  Future<void> _seedData(Database db) async {
    await db.insert('users', {'full_name': 'Administrateur',
      'phone_number': AppConstants.adminPhone, 'email': AppConstants.adminEmail,
      'role': AppConstants.roleAdmin, 'created_at': DateTime.now().toIso8601String()});
    await db.insert('users', {'full_name': 'Oumar Mahamat',
      'phone_number': '+23566001234', 'email': 'oumar@example.com',
      'role': AppConstants.roleUser, 'created_at': DateTime.now().toIso8601String()});

    // Routes — first 4 marked popular
    final routes = [
      ["N'Djamena", 'Moundou', 15000.0, 1],
      ["N'Djamena", 'Sarh',    18000.0, 1],
      ["N'Djamena", 'Abéché',  22000.0, 1],
      ["N'Djamena", 'Doba',    17000.0, 1],
      ['Moundou',   "N'Djamena", 15000.0, 0],
      ['Sarh',      "N'Djamena", 18000.0, 0],
      ["N'Djamena", 'Bongor',  10000.0, 0],
      ["N'Djamena", 'Mongo',   20000.0, 0],
    ];
    for (final r in routes) {
      await db.insert('routes', {'origin_city': r[0], 'destination_city': r[1],
        'base_price': r[2], 'is_active': 1, 'is_popular': r[3]});
    }

    // Buses
    for (final b in [
      ['AT-001',45,'ACTIF','EXCELLENT'],['AT-002',50,'ACTIF','BON'],
      ['AT-003',35,'ACTIF','BON'],['AT-004',45,'EN_MAINTENANCE','PASSABLE'],
      ['VIP-001',25,'ACTIF','EXCELLENT'],
    ]) {
      await db.insert('buses', {'bus_number':b[0],'capacity':b[1],'status':b[2],'condition_status':b[3]});
    }

    // Trips
    final now = DateTime.now();
    final tripData = [
      {'route_id':1,'bus_id':1,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'06:30','available_seats':32,'status':'PROGRAMME'},
      {'route_id':1,'bus_id':2,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'08:00','available_seats':42,'status':'PROGRAMME'},
      {'route_id':1,'bus_id':5,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'10:30','available_seats':18,'status':'PROGRAMME'},
      {'route_id':1,'bus_id':3,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'13:00','available_seats':28,'status':'PROGRAMME'},
      {'route_id':1,'bus_id':1,'departure_date':now.add(const Duration(days:1)).toIso8601String().split('T')[0],'departure_time':'07:00','available_seats':45,'status':'PROGRAMME'},
      {'route_id':2,'bus_id':2,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'07:30','available_seats':40,'status':'PROGRAMME'},
      {'route_id':3,'bus_id':3,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'06:00','available_seats':25,'status':'PROGRAMME'},
      {'route_id':7,'bus_id':1,'departure_date':now.toIso8601String().split('T')[0],'departure_time':'09:00','available_seats':38,'status':'PROGRAMME'},
    ];
    for (final t in tripData) {
      final tripId = await db.insert('trips', t);
      // Initialize seats for this trip
      final busCapacity = t['available_seats'] as int;
      for (int i = 1; i <= busCapacity; i++) {
        await db.insert('seats', {
          'trip_id': tripId,
          'seat_number': i,
          'status': 'AVAILABLE'
        });
      }
    }

    // Sample bookings
    await db.insert('bookings', {'user_id':2,'trip_id':1,'total_passengers':1,
      'total_price':15000.0,'status':'CONFIRME','payment_status':'PAYE',
      'ticket_number':'AS-99281','payment_screenshot': null,
      'created_at':now.subtract(const Duration(days:2)).toIso8601String()});
    await db.insert('passengers', {'booking_id':1,'full_name':'Oumar Mahamat','seat_number':14});
    await db.insert('payments', {'booking_id':1,'method':'MOOV_MONEY','amount':15000.0,'status':'PAYE','transaction_reference':'TXN-2024-001'});
    await db.insert('bookings', {'user_id':2,'trip_id':2,'total_passengers':2,
      'total_price':30000.0,'status':'EN_ATTENTE','payment_status':'EN_ATTENTE',
      'ticket_number':'AS-88120','payment_screenshot': null,
      'created_at':now.subtract(const Duration(hours:5)).toIso8601String()});

    // Contact info
    for (final e in {'phone': AppConstants.adminPhone, 'email': AppConstants.adminEmail,
      'whatsapp': AppConstants.adminWhatsApp, 'message': AppConstants.adminDefaultMessage}.entries) {
      await db.insert('contact_info', {'key_name': e.key, 'value': e.value});
    }

    // Promotion
    await db.insert('promotions', {'title':"Offre de lancement 🎉",
      'description':"10% de réduction sur tous les trajets!",
      'discount_percent':10.0,
      'valid_until':now.add(const Duration(days:60)).toIso8601String().split('T')[0],
      'is_active':1});

    // Welcome notification
    await db.insert('app_notifications', {'user_id':2,
      'title':'Bienvenue sur Assa Ticket! 🎉',
      'body':'Réservez vos billets de bus facilement partout au Tchad.',
      'type':AppConstants.notifPromotion,'is_read':0,
      'created_at':now.toIso8601String()});

    // Seed default payment accounts
    await db.insert('payment_accounts', {'type':'MOOV_MONEY',
      'account_name':'Assa Ticket SARL','account_number':'+235 66 00 00 00','is_active':1});
    await db.insert('payment_accounts', {'type':'AIRTEL_MONEY',
      'account_name':'Assa Ticket SARL','account_number':'+235 99 00 00 00','is_active':1});
  }

  // ── USERS ─────────────────────────────────────────────────────────────────
  Future<UserModel?> getUserByPhone(String phone) async {
    final db = await database;
    final r = await db.query('users', where:'phone_number=?', whereArgs:[phone], limit:1);
    return r.isEmpty ? null : UserModel.fromMap(r.first);
  }
  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final r = await db.query('users', where:'id=?', whereArgs:[id], limit:1);
    return r.isEmpty ? null : UserModel.fromMap(r.first);
  }
  Future<int> insertUser(UserModel u) async => (await database).insert('users', u.toMap());
  Future<void> updateUser(UserModel u) async =>
      (await database).update('users', u.toMap(), where:'id=?', whereArgs:[u.id]);
  Future<List<UserModel>> getAllUsers() async {
    final r = await (await database).query('users', orderBy:'created_at DESC');
    return r.map(UserModel.fromMap).toList();
  }

  // ── ROUTES ────────────────────────────────────────────────────────────────
  Future<List<RouteModel>> getAllRoutes({bool activeOnly=false}) async {
    final r = await (await database).query('routes',
        where: activeOnly ? 'is_active=1' : null, orderBy:'origin_city ASC');
    return r.map(RouteModel.fromMap).toList();
  }
  Future<List<RouteModel>> getPopularRoutes() async {
    final r = await (await database).query('routes',
        where:'is_popular=1 AND is_active=1', orderBy:'origin_city ASC');
    return r.map(RouteModel.fromMap).toList();
  }
  Future<RouteModel?> getRouteById(int id) async {
    final r = await (await database).query('routes', where:'id=?', whereArgs:[id], limit:1);
    return r.isEmpty ? null : RouteModel.fromMap(r.first);
  }
  Future<int> insertRoute(RouteModel route) async =>
      (await database).insert('routes', route.toMap());
  Future<void> updateRoute(RouteModel route) async =>
      (await database).update('routes', route.toMap(), where:'id=?', whereArgs:[route.id]);
  Future<void> deleteRoute(int id) async =>
      (await database).delete('routes', where:'id=?', whereArgs:[id]);

  // ── BUSES ─────────────────────────────────────────────────────────────────
  Future<List<BusModel>> getAllBuses() async {
    final r = await (await database).query('buses', orderBy:'bus_number ASC');
    return r.map(BusModel.fromMap).toList();
  }
  Future<BusModel?> getBusById(int id) async {
    final r = await (await database).query('buses', where:'id=?', whereArgs:[id], limit:1);
    return r.isEmpty ? null : BusModel.fromMap(r.first);
  }
  Future<int> insertBus(BusModel b) async => (await database).insert('buses', b.toMap());
  Future<void> updateBus(BusModel b) async =>
      (await database).update('buses', b.toMap(), where:'id=?', whereArgs:[b.id]);
  Future<void> deleteBus(int id) async =>
      (await database).delete('buses', where:'id=?', whereArgs:[id]);

  // ── TRIPS ─────────────────────────────────────────────────────────────────
  Future<List<TripModel>> searchTrips({required String origin,
    required String destination, required DateTime date}) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final r = await db.rawQuery('''
      SELECT t.*, r.origin_city, r.destination_city, r.base_price, r.is_popular,
             b.bus_number, b.capacity, b.status as bus_status, b.condition_status
      FROM trips t JOIN routes r ON t.route_id=r.id JOIN buses b ON t.bus_id=b.id
      WHERE r.origin_city=? AND r.destination_city=? AND t.departure_date=?
        AND t.status='PROGRAMME' AND t.available_seats>0 AND r.is_active=1
      ORDER BY t.departure_time ASC''', [origin, destination, dateStr]);
    return r.map(TripModel.fromMap).toList();
  }

  Future<List<TripModel>> getTripsByOrigin(String origin) async {
    final db = await database;
    final now = DateTime.now().toIso8601String().split('T')[0];
    final future = DateTime.now().add(const Duration(days:14))
        .toIso8601String().split('T')[0];
    final r = await db.rawQuery('''
      SELECT t.*, r.origin_city, r.destination_city, r.base_price, r.is_popular,
             b.bus_number, b.capacity, b.status as bus_status, b.condition_status
      FROM trips t JOIN routes r ON t.route_id=r.id JOIN buses b ON t.bus_id=b.id
      WHERE r.origin_city=? AND t.status='PROGRAMME' AND t.available_seats>0
        AND r.is_active=1 AND t.departure_date>=? AND t.departure_date<=?
      ORDER BY t.departure_date ASC, t.departure_time ASC
      LIMIT 10''', [origin, now, future]);
    return r.map(TripModel.fromMap).toList();
  }

  Future<List<TripModel>> getAllTrips() async {
    final r = await (await database).rawQuery('''
      SELECT t.*, r.origin_city, r.destination_city, r.base_price, r.is_popular,
             b.bus_number, b.capacity, b.status as bus_status, b.condition_status
      FROM trips t JOIN routes r ON t.route_id=r.id JOIN buses b ON t.bus_id=b.id
      ORDER BY t.departure_date DESC, t.departure_time ASC''');
    return r.map(TripModel.fromMap).toList();
  }
  Future<TripModel?> getTripById(int id) async {
    final r = await (await database).rawQuery('''
      SELECT t.*, r.origin_city, r.destination_city, r.base_price, r.is_popular,
             b.bus_number, b.capacity, b.status as bus_status, b.condition_status
      FROM trips t JOIN routes r ON t.route_id=r.id JOIN buses b ON t.bus_id=b.id
      WHERE t.id=?''', [id]);
    return r.isEmpty ? null : TripModel.fromMap(r.first);
  }
  Future<int> insertTrip(TripModel t) async =>
      (await database).insert('trips', t.toMap());
  Future<void> updateTrip(TripModel t) async =>
      (await database).update('trips', t.toMap(), where:'id=?', whereArgs:[t.id]);
  Future<void> updateTripSeats(int tripId, int seats) async =>
      (await database).update('trips', {'available_seats':seats},
          where:'id=?', whereArgs:[tripId]);

  Future<void> updateTripAvailableSeatsFromSeatsTable(int tripId) async {
    final availableCount = await getAvailableSeats(tripId);
    await updateTripSeats(tripId, availableCount.length);
  }
  Future<void> deleteTrip(int id) async =>
      (await database).delete('trips', where:'id=?', whereArgs:[id]);

  // ── BOOKINGS ──────────────────────────────────────────────────────────────
  Future<List<BookingModel>> getUserBookings(int userId) async {
    final db = await database;
    final r = await db.query('bookings', where:'user_id=?',
        whereArgs:[userId], orderBy:'created_at DESC');
    final bookings = r.map(BookingModel.fromMap).toList();
    for (final b in bookings) {
      if (b.id != null) {
        b.trip = await getTripById(b.tripId);
        b.passengers = await getPassengersByBooking(b.id!);
        b.luggage = await getLuggageByBooking(b.id!);
        b.payment = await getPaymentByBooking(b.id!);
      }
    }
    return bookings;
  }
  Future<List<BookingModel>> getAllBookings() async {
    final r = await (await database).query('bookings', orderBy:'created_at DESC');
    final bookings = r.map(BookingModel.fromMap).toList();
    for (final b in bookings) {
      if (b.id != null) {
        b.trip = await getTripById(b.tripId);
        b.passengers = await getPassengersByBooking(b.id!);
        b.payment = await getPaymentByBooking(b.id!);
      }
    }
    return bookings;
  }
  Future<BookingModel?> getBookingById(int id) async {
    final r = await (await database).query('bookings', where:'id=?', whereArgs:[id], limit:1);
    if (r.isEmpty) return null;
    final b = BookingModel.fromMap(r.first);
    b.trip = await getTripById(b.tripId);
    b.passengers = await getPassengersByBooking(id);
    b.luggage = await getLuggageByBooking(id);
    b.payment = await getPaymentByBooking(id);
    return b;
  }
  Future<int> insertBooking(BookingModel b) async =>
      (await database).insert('bookings', b.toMap());
  Future<void> updateBooking(BookingModel b) async =>
      (await database).update('bookings', b.toMap(), where:'id=?', whereArgs:[b.id]);
  Future<void> updateBookingStatus(int id, String status, String paymentStatus) async =>
      (await database).update('bookings',
          {'status':status, 'payment_status':paymentStatus},
          where:'id=?', whereArgs:[id]);
  Future<void> updateBookingScreenshot(int id, String? path) async =>
      (await database).update('bookings', {'payment_screenshot': path},
          where:'id=?', whereArgs:[id]);

  // ── PASSENGERS ────────────────────────────────────────────────────────────
  Future<int> insertPassenger(PassengerModel p) async =>
      (await database).insert('passengers', p.toMap());
  Future<List<PassengerModel>> getPassengersByBooking(int bookingId) async {
    final r = await (await database).query('passengers',
        where:'booking_id=?', whereArgs:[bookingId]);
    return r.map(PassengerModel.fromMap).toList();
  }

  // ── LUGGAGE ───────────────────────────────────────────────────────────────
  Future<int> insertLuggage(LuggageModel l) async =>
      (await database).insert('luggage', l.toMap());
  Future<LuggageModel?> getLuggageByBooking(int bookingId) async {
    final r = await (await database).query('luggage',
        where:'booking_id=?', whereArgs:[bookingId], limit:1);
    return r.isEmpty ? null : LuggageModel.fromMap(r.first);
  }

  // ── PAYMENTS ──────────────────────────────────────────────────────────────
  Future<int> insertPayment(PaymentModel p) async =>
      (await database).insert('payments', p.toMap());
  Future<PaymentModel?> getPaymentByBooking(int bookingId) async {
    final r = await (await database).query('payments',
        where:'booking_id=?', whereArgs:[bookingId], limit:1);
    return r.isEmpty ? null : PaymentModel.fromMap(r.first);
  }
  Future<void> updatePaymentStatus(int id, String status) async =>
      (await database).update('payments', {'status':status}, where:'id=?', whereArgs:[id]);
  Future<List<PaymentModel>> getAllPayments() async {
    final r = await (await database).query('payments', orderBy:'id DESC');
    return r.map(PaymentModel.fromMap).toList();
  }

  // ── ADMIN LOGS ────────────────────────────────────────────────────────────
  Future<int> insertAdminLog(String action) async =>
      (await database).insert('admin_logs',
          {'action':action, 'created_at':DateTime.now().toIso8601String()});
  Future<List<AdminLogModel>> getAdminLogs() async {
    final r = await (await database).query('admin_logs',
        orderBy:'created_at DESC', limit:100);
    return r.map(AdminLogModel.fromMap).toList();
  }

  // ── STATS ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getReportStats() async {
    final db = await database;
    int q(List<Map<String, Object?>> r) => Sqflite.firstIntValue(r) ?? 0;
    return {
      'total_bookings':      q(await db.rawQuery("SELECT COUNT(*) as count FROM bookings")),
      'total_revenue':       (await db.rawQuery("SELECT SUM(total_price) as total FROM bookings WHERE payment_status='PAYE'")).first['total'] ?? 0,
      'total_users':         q(await db.rawQuery("SELECT COUNT(*) as count FROM users WHERE role='USER'")),
      'confirmed_bookings':  q(await db.rawQuery("SELECT COUNT(*) as count FROM bookings WHERE status='CONFIRME'")),
      'pending_bookings':    q(await db.rawQuery("SELECT COUNT(*) as count FROM bookings WHERE status='EN_ATTENTE'")),
      'rejected_bookings':   q(await db.rawQuery("SELECT COUNT(*) as count FROM bookings WHERE status='REJETE'")),
      'active_trips':        q(await db.rawQuery("SELECT COUNT(*) as count FROM trips WHERE status='PROGRAMME'")),
    };
  }

  // ── SEATS ─────────────────────────────────────────────────────────────────
  Future<void> initializeSeatsForTrip(int tripId, int busCapacity) async {
    final db = await database;
    for (int i = 1; i <= busCapacity; i++) {
      await db.insert('seats', {
        'trip_id': tripId,
        'seat_number': i,
        'status': 'AVAILABLE'
      });
    }
  }

  Future<List<SeatModel>> getSeatsForTrip(int tripId) async {
    final r = await (await database).query('seats',
        where: 'trip_id=?', whereArgs: [tripId], orderBy: 'seat_number ASC');
    return r.map(SeatModel.fromMap).toList();
  }

  Future<SeatModel?> getSeat(int tripId, int seatNumber) async {
    final r = await (await database).query('seats',
        where: 'trip_id=? AND seat_number=?', whereArgs: [tripId, seatNumber], limit: 1);
    return r.isEmpty ? null : SeatModel.fromMap(r.first);
  }

  Future<void> updateSeatStatus(int tripId, int seatNumber, String status,
      {String? occupiedBy}) async {
    final updates = <String, dynamic>{'status': status, 'occupied_at': DateTime.now().toIso8601String()};
    if (occupiedBy != null) updates['occupied_by'] = occupiedBy;
    if (status == 'AVAILABLE') {
      updates['occupied_by'] = null;
      updates['occupied_at'] = null;
    }
    await (await database).update('seats', updates,
        where: 'trip_id=? AND seat_number=?', whereArgs: [tripId, seatNumber]);
  }

  Future<List<int>> getOccupiedSeats(int tripId) async {
    final r = await (await database).rawQuery('''
      SELECT seat_number FROM seats WHERE trip_id=? AND status='OCCUPIED' ''', [tripId]);
    return r.map((x) => x['seat_number'] as int).toList();
  }

  Future<List<int>> getAvailableSeats(int tripId) async {
    final r = await (await database).rawQuery('''
      SELECT seat_number FROM seats WHERE trip_id=? AND status='AVAILABLE' ''', [tripId]);
    return r.map((x) => x['seat_number'] as int).toList();
  }

  // ── PROMOTIONS ────────────────────────────────────────────────────────────
  Future<List<PromotionModel>> getActivePromotions() async {
    final r = await (await database).query('promotions',
        where:'is_active=1', orderBy:'id DESC');
    return r.map(PromotionModel.fromMap).toList();
  }
  Future<List<PromotionModel>> getAllPromotions() async {
    final r = await (await database).query('promotions', orderBy:'id DESC');
    return r.map(PromotionModel.fromMap).toList();
  }
  Future<int>  insertPromotion(PromotionModel p) async =>
      (await database).insert('promotions', p.toMap());
  Future<void> updatePromotion(PromotionModel p) async =>
      (await database).update('promotions', p.toMap(), where:'id=?', whereArgs:[p.id]);
  Future<void> deletePromotion(int id) async =>
      (await database).delete('promotions', where:'id=?', whereArgs:[id]);

  // ── CONTACT INFO ──────────────────────────────────────────────────────────
  Future<ContactInfoModel> getContactInfo() async {
    final r = await (await database).query('contact_info');
    final m = <String,String>{};
    for (final row in r) { m[row['key_name'] as String] = row['value'] as String; }
    return ContactInfoModel(
        phone:       m['phone']    ?? AppConstants.adminPhone,
        email:       m['email']    ?? AppConstants.adminEmail,
        whatsApp:    m['whatsapp'] ?? AppConstants.adminWhatsApp,
        helpMessage: m['message']  ?? AppConstants.adminDefaultMessage);
  }
  Future<void> upsertContactInfo(ContactInfoModel info) async {
    final db = await database;
    for (final e in {'phone':info.phone,'email':info.email,
      'whatsapp':info.whatsApp,'message':info.helpMessage}.entries) {
      await db.insert('contact_info', {'key_name':e.key,'value':e.value},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────────────
  Future<int> insertNotification(AppNotificationModel n) async =>
      (await database).insert('app_notifications', n.toMap());
  Future<List<AppNotificationModel>> getUserNotifications(int userId) async {
    final r = await (await database).rawQuery('''
      SELECT * FROM app_notifications WHERE user_id=? OR user_id IS NULL
      ORDER BY created_at DESC LIMIT 50''', [userId]);
    return r.map(AppNotificationModel.fromMap).toList();
  }
  Future<int> getUnreadCount(int userId) async =>
      Sqflite.firstIntValue(await (await database).rawQuery('''
      SELECT COUNT(*) as count FROM app_notifications
      WHERE (user_id=? OR user_id IS NULL) AND is_read=0''', [userId])) ?? 0;
  Future<void> markNotificationRead(int id) async =>
      (await database).update('app_notifications', {'is_read':1},
          where:'id=?', whereArgs:[id]);
  Future<void> markAllNotificationsRead(int userId) async =>
      (await database).rawUpdate('''
      UPDATE app_notifications SET is_read=1
      WHERE user_id=? OR user_id IS NULL''', [userId]);

  // ── PAYMENT ACCOUNTS (NEW) ────────────────────────────────────────────────
  Future<List<PaymentAccountModel>> getAllPaymentAccounts() async {
    final r = await (await database).query('payment_accounts', orderBy:'type ASC');
    return r.map(PaymentAccountModel.fromMap).toList();
  }
  Future<PaymentAccountModel?> getPaymentAccountByType(String type) async {
    final r = await (await database).query('payment_accounts',
        where:'type=? AND is_active=1', whereArgs:[type], limit:1);
    return r.isEmpty ? null : PaymentAccountModel.fromMap(r.first);
  }
  Future<int>  insertPaymentAccount(PaymentAccountModel a) async =>
      (await database).insert('payment_accounts', a.toMap());
  Future<void> updatePaymentAccount(PaymentAccountModel a) async =>
      (await database).update('payment_accounts', a.toMap(),
          where:'id=?', whereArgs:[a.id]);
  Future<void> deletePaymentAccount(int id) async =>
      (await database).delete('payment_accounts', where:'id=?', whereArgs:[id]);
}