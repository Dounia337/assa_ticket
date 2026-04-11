import 'package:flutter/foundation.dart';
import 'package:assa_ticket/core/api/api_service.dart';
import 'package:assa_ticket/core/models/models.dart';
import 'package:assa_ticket/core/constants/app_constants.dart';
import 'package:assa_ticket/core/services/notification_service.dart';

class BookingProvider extends ChangeNotifier {
  SearchQuery? _searchQuery;
  List<TripModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  TripModel? _selectedTrip;
  List<int> _selectedSeats = [];
  List<Map<String, String>> _passengerDetails = [];
  LuggageModel? _luggageDetails;
  String? _selectedPaymentMethod;
  String? _paymentScreenshot; // NEW

  List<BookingModel> _userBookings = [];
  bool _isLoadingBookings = false;

  SearchQuery?          get searchQuery          => _searchQuery;
  List<TripModel>       get searchResults        => _searchResults;
  bool                  get isSearching          => _isSearching;
  String?               get searchError          => _searchError;
  TripModel?            get selectedTrip         => _selectedTrip;
  List<int>             get selectedSeats        => _selectedSeats;
  List<Map<String,String>> get passengerDetails  => _passengerDetails;
  LuggageModel?         get luggageDetails       => _luggageDetails;
  String?               get selectedPaymentMethod=> _selectedPaymentMethod;
  String?               get paymentScreenshot    => _paymentScreenshot;
  List<BookingModel>    get userBookings         => _userBookings;
  bool                  get isLoadingBookings    => _isLoadingBookings;

  double get totalPrice {
    if (_selectedTrip?.route == null) return 0;
    return _selectedTrip!.route!.basePrice * _selectedSeats.length
        + (_luggageDetails?.extraFee ?? 0);
  }

  Future<void> searchTrips(SearchQuery query) async {
    _searchQuery = query; _isSearching = true;
    _searchError = null; _searchResults = []; notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _searchResults = await ApiService.instance.searchTrips(
          origin: query.origin, destination: query.destination, date: query.date);
      if (_searchResults.isEmpty) {
        _searchError = 'Aucun trajet trouvé pour cette recherche.';
      }
    } catch (_) { _searchError = 'Erreur lors de la recherche. Réessayez.'; }
    finally { _isSearching = false; notifyListeners(); }
  }

  void selectTrip(TripModel trip) {
    _selectedTrip = trip; _selectedSeats = []; _passengerDetails = [];
    _luggageDetails = null; _selectedPaymentMethod = null;
    _paymentScreenshot = null; notifyListeners();
  }

  void toggleSeat(int seat) {
    _selectedSeats.contains(seat)
        ? _selectedSeats.remove(seat)
        : _selectedSeats.add(seat);
    notifyListeners();
  }

  void clearSeats() { _selectedSeats = []; notifyListeners(); }

  void setPassengerDetails(List<Map<String, String>> details) {
    _passengerDetails = details; notifyListeners(); }

  void setLuggage(LuggageModel luggage) { _luggageDetails = luggage; notifyListeners(); }

  void selectPaymentMethod(String method) { _selectedPaymentMethod = method; notifyListeners(); }

  void setPaymentScreenshot(String? path) { _paymentScreenshot = path; notifyListeners(); }

  Future<BookingModel?> completeBooking(int userId) async {
    if (_selectedTrip == null || _selectedSeats.isEmpty) return null;
    try {
      final ticketNumber = _generateTicketNumber();
      final isMobile = _selectedPaymentMethod == AppConstants.paymentMoovMoney ||
          _selectedPaymentMethod == AppConstants.paymentAirtelMoney;
      final hasScreenshot = _paymentScreenshot != null;

      final booking = BookingModel(
        userId: userId, tripId: _selectedTrip!.id!,
        totalPassengers: _selectedSeats.length, totalPrice: totalPrice,
        // If mobile money with screenshot → pending admin confirmation
        // If à la gare → pending
        // Otherwise → confirmed
        status: _selectedPaymentMethod == AppConstants.paymentAtGare || (isMobile && !hasScreenshot)
            ? AppConstants.statusPending
            : isMobile && hasScreenshot
            ? AppConstants.statusPending  // admin must confirm after seeing screenshot
            : AppConstants.statusConfirmed,
        paymentStatus: _selectedPaymentMethod == AppConstants.paymentAtGare
            ? AppConstants.paymentPending
            : isMobile
            ? AppConstants.paymentPending  // pending until admin confirms
            : AppConstants.paymentPaid,
        ticketNumber: ticketNumber,
        paymentScreenshot: _paymentScreenshot,
      );

      final bookingId = await ApiService.instance.insertBooking(booking);

      for (int i = 0; i < _passengerDetails.length; i++) {
        final seat = i < _selectedSeats.length ? _selectedSeats[i] : 0;
        await ApiService.instance.insertPassenger(PassengerModel(
            bookingId: bookingId,
            fullName: _passengerDetails[i]['name'] ?? 'Passager ${i + 1}',
            seatNumber: seat));

        // Mark seat as occupied
        if (seat > 0) {
          await ApiService.instance.updateSeatStatus(
            _selectedTrip!.id!, seat, 'OCCUPIED',
            occupiedBy: _passengerDetails[i]['name'] ?? 'Passager ${i + 1}');
        }
      }

      if (_luggageDetails != null) {
        await ApiService.instance.insertLuggage(LuggageModel(
            bookingId: bookingId,
            numberOfItems: _luggageDetails!.numberOfItems,
            totalWeight: _luggageDetails!.totalWeight,
            extraFee: _luggageDetails!.extraFee));
      }

      final txRef = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
      await ApiService.instance.insertPayment(PaymentModel(
          bookingId: bookingId,
          method: _selectedPaymentMethod ?? AppConstants.paymentAtGare,
          amount: totalPrice,
          status: (isMobile) ? AppConstants.paymentPending : AppConstants.paymentPaid,
          transactionReference: txRef));

      final newSeats =
      (_selectedTrip!.availableSeats - _selectedSeats.length).clamp(0, 999);
      await ApiService.instance.updateTripSeats(_selectedTrip!.id!, newSeats);

      // Update available seats count from seats table
      await ApiService.instance.updateTripAvailableSeatsFromSeatsTable(_selectedTrip!.id!);

      // Send notification
      try {
        await NotificationService.instance.onBookingCreated(
            userId: userId, ticketNumber: ticketNumber,
            origin: _selectedTrip!.route?.originCity ?? '',
            destination: _selectedTrip!.route?.destinationCity ?? '',
            method: _selectedPaymentMethod ?? AppConstants.paymentAtGare);
      } catch (e) { debugPrint('>>> Notification error (non-fatal): $e'); }

      final fullBooking = await ApiService.instance.getBookingById(bookingId);
      return fullBooking?.copyWith(ticketNumber: ticketNumber);
    } catch (e) {
      debugPrint('>>> completeBooking error: $e');
      return null;
    }
  }

  String _generateTicketNumber() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    return '${AppConstants.ticketPrefix}-${ts.substring(ts.length - 5)}';
  }

  Future<void> loadUserBookings(int userId) async {
    _isLoadingBookings = true; notifyListeners();
    try { _userBookings = await ApiService.instance.getUserBookings(userId); }
    catch (_) { _userBookings = []; }
    finally { _isLoadingBookings = false; notifyListeners(); }
  }

  void resetBookingFlow() {
    _selectedTrip = null; _selectedSeats = []; _passengerDetails = [];
    _luggageDetails = null; _selectedPaymentMethod = null;
    _paymentScreenshot = null; notifyListeners();
  }
}