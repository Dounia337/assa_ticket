import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/search/screens/search_results_screen.dart';
import 'features/booking/screens/booking_screens.dart';
import 'features/tickets/screens/ticket_screens.dart';
import 'features/admin/screens/admin_screens.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'core/constants/app_routes.dart';
import 'core/services/notification_service.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialise local notification service
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  runApp(const AssaTicketApp());
}

class AssaTicketApp extends StatelessWidget {
  const AssaTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Assa Ticket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash:               (_) => const SplashScreen(),
          AppRoutes.onboarding:           (_) => const OnboardingScreen(),
          AppRoutes.auth:                 (_) => const AuthScreen(),
          AppRoutes.otp:                  (_) => const OtpScreen(),
          AppRoutes.register:             (_) => const RegisterScreen(),
          AppRoutes.home:                 (_) => const HomeScreen(),
          AppRoutes.searchResults:        (_) => const SearchResultsScreen(),
          AppRoutes.tripDetails:          (_) => const TripDetailsScreen(),
          AppRoutes.seatSelection:        (_) => const SeatSelectionScreen(),
          AppRoutes.passengerDetails:     (_) => const PassengerDetailsScreen(),
          AppRoutes.luggageManagement:    (_) => const LuggageScreen(),
          AppRoutes.payment:              (_) => const PaymentScreen(),
          AppRoutes.bookingConfirmation:  (_) => const BookingConfirmationScreen(),
          AppRoutes.myTickets:            (_) => const MyTicketsScreen(),
          AppRoutes.ticketDetails:        (_) => const TicketDetailsScreen(),
          AppRoutes.support:              (_) => const SupportScreen(),
          AppRoutes.profile:              (_) => const ProfileScreen(),
          // NEW routes
          AppRoutes.notifications:        (_) => const NotificationsScreen(),
          AppRoutes.routeMap:             (_) => const RouteMapScreen(),
          // Admin
          AppRoutes.adminDashboard:       (_) => const AdminDashboardScreen(),
          AppRoutes.adminRoutes:          (_) => const AdminRoutesScreen(),
          AppRoutes.adminRouteForm:       (_) => const AdminRouteFormScreen(),
          AppRoutes.adminBuses:           (_) => const AdminBusesScreen(),
          AppRoutes.adminBusForm:         (_) => const AdminBusFormScreen(),
          AppRoutes.adminTrips:           (_) => const AdminTripsScreen(),
          AppRoutes.adminTripForm:        (_) => const AdminTripFormScreen(),
          AppRoutes.adminBookings:        (_) => const AdminBookingsScreen(),
          AppRoutes.adminBookingDetail:   (_) => const AdminBookingDetailScreen(),
          AppRoutes.adminReports:         (_) => const AdminReportsScreen(),
          AppRoutes.adminPromotions:      (_) => const AdminPromotionsScreen(),
          AppRoutes.adminContact:         (_) => const AdminContactScreen(),
          AppRoutes.adminPaymentAccounts: (_) => const AdminPaymentAccountsScreen(),
        },
      ),
    );
  }
}