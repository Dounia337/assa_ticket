import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/models.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BOOKING CONFIRMATION SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking =
        ModalRoute.of(context)?.settings.arguments as BookingModel?;

    if (booking == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Réservation introuvable',
                  style: GoogleFonts.manrope(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.home),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    }

    final trip = booking.trip;
    final isConfirmed = booking.status == AppConstants.statusConfirmed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.home, (_) => false),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.confirmation_number_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppConstants.appName,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Success icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? AppColors.successContainer
                            : AppColors.warningContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConfirmed
                            ? Icons.check_circle_rounded
                            : Icons.pending_rounded,
                        size: 44,
                        color: isConfirmed ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isConfirmed
                          ? 'Réservation réussie!'
                          : 'Réservation en attente!',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isConfirmed
                          ? 'Votre voyage est confirmé. Préparez vos bagages !'
                          : 'Votre réservation est en attente de paiement.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Ticket card
                    _TicketCard(booking: booking, trip: trip),
                    const SizedBox(height: 20),

                    // Action buttons
                    GradientButton(
                      label: 'Voir mon billet',
                      icon: Icons.confirmation_number_rounded,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.ticketDetails,
                          arguments: booking,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.home, (_) => false),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Retour à l\'accueil'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final BookingModel booking;
  final TripModel? trip;

  const _TicketCard({required this.booking, this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Numéro de Billet',
                  style: GoogleFonts.manrope(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${booking.ticketNumber}',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Journey
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Départ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            trip?.route?.originCity ?? '-',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            trip?.departureTime ?? '-',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.directions_bus_rounded,
                            color: AppColors.primary, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          '8h 30m',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Arrivée',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            trip?.route?.destinationCity ?? '-',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '04:30 PM',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const DashedDivider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _TicketInfo(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: trip != null
                          ? DateFormat('d MMM. yyyy', 'fr_FR')
                              .format(trip!.departureDate)
                          : '-',
                    ),
                    _TicketInfo(
                      icon: Icons.people_rounded,
                      label: 'Passagers',
                      value: '${booking.totalPassengers}',
                    ),
                    _TicketInfo(
                      icon: Icons.payments_rounded,
                      label: 'Total',
                      value: formatPrice(booking.totalPrice),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: booking.status == AppConstants.statusConfirmed
                  ? AppColors.successContainer
                  : AppColors.warningContainer,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                booking.status == AppConstants.statusConfirmed
                    ? '✓ Confirmé — Billet valide'
                    : '⏳ En attente de paiement',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: booking.status == AppConstants.statusConfirmed
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TicketInfo(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MY TICKETS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId = context.read<AuthProvider>().currentUser?.id ?? 0;
    context.read<BookingProvider>().loadUserBookings(userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Billets',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Gérez vos réservations et voyages à venir.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Tous'),
                Tab(text: 'Confirmés'),
                Tab(text: 'En attente'),
              ],
            ),
          ),
        ],
        body: provider.isLoadingBookings
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary)))
            : TabBarView(
                controller: _tabController,
                children: [
                  _TicketList(bookings: provider.userBookings),
                  _TicketList(
                    bookings: provider.userBookings
                        .where((b) => b.status == AppConstants.statusConfirmed)
                        .toList(),
                  ),
                  _TicketList(
                    bookings: provider.userBookings
                        .where((b) => b.status == AppConstants.statusPending)
                        .toList(),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  final List<BookingModel> bookings;

  const _TicketList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.confirmation_number_outlined,
        title: 'Aucun billet',
        subtitle: 'Vous n\'avez pas encore de billets dans cette catégorie.',
        actionLabel: 'Réserver un voyage',
        onAction: () =>
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _TicketListCard(
        booking: bookings[i],
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.ticketDetails,
          arguments: bookings[i],
        ),
      ),
    );
  }
}

class _TicketListCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _TicketListCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final trip = booking.trip;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      StatusChip(status: booking.status),
                      const Spacer(),
                      Text(
                        'ID: #${booking.ticketNumber}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Départ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              trip?.route?.originCity ?? '-',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              trip?.departureTime ?? '-',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.directions_bus_rounded,
                              color: AppColors.primary, size: 22),
                          Text(
                            '8h 30m',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Arrivée',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              trip?.route?.destinationCity ?? '-',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '04:30 PM',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Text(
                    trip != null
                        ? DateFormat('d MMMM yyyy', 'fr_FR')
                            .format(trip.departureDate)
                        : '-',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text(
                    formatPrice(booking.totalPrice),
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TICKET DETAILS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class TicketDetailsScreen extends StatelessWidget {
  const TicketDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking =
        ModalRoute.of(context)?.settings.arguments as BookingModel?;
    if (booking == null) return const SizedBox();

    final trip = booking.trip;
    final passengers = booking.passengers ?? [];
    final mainPassenger =
        passengers.isNotEmpty ? passengers.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Détails du Billet',
            style: GoogleFonts.manrope(
                fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showOptions(context, booking),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Booking Status Timeline ─────────────────────────────
            _BookingStatusTimeline(status: booking.status),
            const SizedBox(height: 16),

            // Main ticket
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.ticketGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Votre Voyage',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Billet électronique confirmé',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Départ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    trip?.route?.originCity ?? '-',
                                    style: GoogleFonts.manrope(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.directions_bus_rounded,
                                      color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Arrivée',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    trip?.route?.destinationCity ?? '-',
                                    style: GoogleFonts.manrope(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Ticket tear line
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _HalfCircle(left: true),
                        const Expanded(child: DashedDivider()),
                        _HalfCircle(left: false),
                      ],
                    ),
                  ),

                  // Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.person_rounded,
                          label: 'Passager',
                          value: mainPassenger?.fullName ?? 'N/A',
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.event_seat_rounded,
                          label: 'Siège',
                          value: mainPassenger != null
                              ? '${mainPassenger.seatNumber}A (Fenêtre)'
                              : 'N/A',
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.access_time_rounded,
                          label: 'Date & Heure',
                          value: trip != null
                              ? '${DateFormat('d MMM. yyyy', 'fr_FR').format(trip.departureDate)} • ${trip.departureTime}'
                              : 'N/A',
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.directions_bus_rounded,
                          label: 'Compagnie',
                          value: 'Assa Transport',
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.tag_rounded,
                          label: 'ID Billet',
                          value: booking.ticketNumber,
                        ),
                      ],
                    ),
                  ),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius:
                          const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: 'ASSA:${booking.ticketNumber}',
                            version: QrVersions.auto,
                            size: 120,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scannez ce code à la gare',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 12, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              'Valide 24h avant le départ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Passenger list
            if (passengers.length > 1) ...[
              SectionHeader(title: 'Tous les passagers'),
              const SizedBox(height: 10),
              ...passengers.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.outlineVariant, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              p.fullName.isNotEmpty
                                  ? p.fullName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.fullName,
                            style: GoogleFonts.manrope(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Siège ${p.seatNumber}',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Download / Share
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Télécharger'),
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Partager'),
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Télécharger PDF'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Partager via WhatsApp'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.cancel_outlined, color: AppColors.error),
              title: const Text('Annuler la réservation',
                  style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _HalfCircle extends StatelessWidget {
  final bool left;
  const _HalfCircle({required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.horizontal(
          left: left ? Radius.zero : const Radius.circular(8),
          right: left ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}

// ─── BOOKING STATUS TIMELINE (reused in TicketDetailsScreen) ──────────────

class _BookingStatusTimeline extends StatelessWidget {
  final String status;
  const _BookingStatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final isRejected = status == AppConstants.statusRejected;
    final isCancelled = status == AppConstants.statusCancelled;

    final steps = [
      _TStep('Créée',     Icons.add_circle_rounded),
      _TStep('Confirmée', Icons.check_circle_rounded),
      _TStep(isRejected ? 'Rejetée' : isCancelled ? 'Annulée' : 'Complétée',
             isRejected ? Icons.cancel_rounded : isCancelled ? Icons.block_rounded : Icons.star_rounded),
    ];

    int currentIdx;
    switch (status) {
      case AppConstants.statusPending:   currentIdx = 0; break;
      case AppConstants.statusConfirmed: currentIdx = 1; break;
      case AppConstants.statusCompleted: currentIdx = 2; break;
      case AppConstants.statusRejected:
      case AppConstants.statusCancelled: currentIdx = 2; break;
      default: currentIdx = 0;
    }

    final isTerminalBad = isRejected || isCancelled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivi de la réservation',
              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final filled = (i ~/ 2) < currentIdx && !isTerminalBad;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: filled ? AppColors.primary : AppColors.outlineVariant,
                  ),
                );
              }
              final si = i ~/ 2;
              final step = steps[si];
              final isDone = si < currentIdx;
              final isCurrent = si == currentIdx;
              Color col;
              if (isCurrent && isTerminalBad) {
                col = AppColors.error;
              } else if (isDone || isCurrent) col = AppColors.primary;
              else col = AppColors.outlineVariant;

              return Column(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: (isDone || isCurrent) ? col.withOpacity(0.12) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: col, width: isCurrent ? 2.5 : 1.5),
                    ),
                    child: Icon(step.icon, size: 16, color: col),
                  ),
                  const SizedBox(height: 5),
                  Text(step.label,
                      style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? col : AppColors.onSurfaceVariant)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TStep {
  final String label;
  final IconData icon;
  const _TStep(this.label, this.icon);
}
