import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/models.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRIP DETAILS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<BookingProvider>().selectedTrip;
    if (trip == null) return const SizedBox();
    final price = trip.route?.basePrice ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AssaAppBar(title: AppConstants.appName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded,
                                size: 14, color: AppColors.onTertiaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              trip.bus != null &&
                                  (trip.bus!.capacity) <= 30
                                  ? 'Premium Express'
                                  : 'Express Standard',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${trip.route?.originCity ?? ''} → ${trip.route?.destinationCity ?? ''}',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
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
                              trip.departureTime,
                              style: GoogleFonts.manrope(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${trip.route?.originCity ?? ''}, Gare Nord',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DÉPART',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: AppColors.secondaryContainer,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.directions_bus_rounded,
                              color: Colors.white, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            '9h 15min',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '16:45',
                              style: GoogleFonts.manrope(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${trip.route?.destinationCity ?? ''}, Gare Centrale',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ARRIVÉE',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: AppColors.secondaryContainer,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
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
            const SizedBox(height: 20),

            // Info row
            Row(
              children: [
                _InfoChip(
                    icon: Icons.schedule_rounded,
                    label: 'Durée totale',
                    value: '9h 15min'),
                const SizedBox(width: 10),
                _InfoChip(
                    icon: Icons.event_seat_rounded,
                    label: 'Places libres',
                    value: '${trip.availableSeats}'),
                const SizedBox(width: 10),
                _InfoChip(
                    icon: Icons.directions_bus_rounded,
                    label: 'Bus',
                    value: trip.bus?.busNumber ?? '-'),
              ],
            ),
            const SizedBox(height: 20),

            // Services
            Text(
              'Services à bord',
              style: GoogleFonts.manrope(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _ServiceBadge(icon: Icons.wifi_rounded, label: 'Wi-Fi'),
                SizedBox(width: 10),
                _ServiceBadge(icon: Icons.ac_unit_rounded, label: 'Clim.'),
                SizedBox(width: 10),
                _ServiceBadge(icon: Icons.usb_rounded, label: 'Chargeur'),
                SizedBox(width: 10),
                _ServiceBadge(
                    icon: Icons.tv_rounded, label: 'Divertissement'),
              ],
            ),
            const SizedBox(height: 20),

            // Price
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prix par personne',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          formatPrice(price),
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✓ Disponible',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Map route preview button ─────────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.routeMap,
                  arguments: {
                    'origin':      trip.route?.originCity      ?? '',
                    'destination': trip.route?.destinationCity ?? '',
                  },
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.map_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voir le trajet sur la carte',
                            style: GoogleFonts.manrope(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                          Text(
                            trip.route != null
                                ? 'Distance: ${AppConstants.distanceBetween(trip.route!.originCity, trip.route!.destinationCity).toStringAsFixed(0)} km '
                                '• ${AppConstants.formatDuration(AppConstants.estimatedHours(trip.route!.originCity, trip.route!.destinationCity))}'
                                : 'Carte du trajet',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.primary.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            GradientButton(
              label: 'Sélectionner les sièges',
              icon: Icons.event_seat_rounded,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.seatSelection),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 9, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEAT SELECTION SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Set<int> _occupied = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOccupied();
  }

  Future<void> _loadOccupied() async {
    final trip = context.read<BookingProvider>().selectedTrip;
    if (trip?.id != null) {
      try {
        final occupiedSeats = await ApiService.instance.getOccupiedSeats(trip!.id!);
        setState(() {
          _occupied = occupiedSeats.toSet();
          _loading = false;
        });
      } catch (e) {
        debugPrint('Error loading seats: $e');
        setState(() => _loading = false);
      }
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final trip = provider.selectedTrip;
    final capacity = trip?.bus?.capacity ?? 45;
    final selected = provider.selectedSeats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AssaAppBar(title: AppConstants.appName),
      body: Column(
        children: [
          // Progress
          _BookingProgress(step: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sélectionnez vos sièges',
                    style: GoogleFonts.manrope(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  _TripSummaryBanner(trip: trip),
                  const SizedBox(height: 16),

                  // Legend
                  Row(
                    children: [
                      _SeatLegendItem(
                          color: AppColors.surfaceContainerHigh,
                          label: 'Libre'),
                      const SizedBox(width: 16),
                      _SeatLegendItem(
                          color: AppColors.primary, label: 'Choisi'),
                      const SizedBox(width: 16),
                      _SeatLegendItem(
                          color: AppColors.errorContainer,
                          label: 'Occupé'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Driver
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.outlineVariant),
                        ),
                        child: const Icon(Icons.drive_eta_rounded,
                            color: AppColors.onSurfaceVariant, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Text('Chauffeur',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Seat grid
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _SeatGrid(
                    capacity: capacity,
                    occupied: _occupied,
                    selected: selected.toSet(),
                    onSeatTap: (s) {
                      if (!_occupied.contains(s)) {
                        context.read<BookingProvider>().toggleSeat(s);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Selected summary
                  if (selected.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_seat_rounded,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sièges choisis: ${selected.join(', ')}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Prix total: ${formatPrice((trip?.route?.basePrice ?? 0) * selected.length)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.onPrimaryFixedVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              label: selected.isEmpty
                  ? 'Sélectionnez un siège'
                  : 'Continuer (${selected.length} siège${selected.length > 1 ? 's' : ''})',
              icon: Icons.arrow_forward_rounded,
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pushNamed(
                  context, AppRoutes.passengerDetails),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatGrid extends StatelessWidget {
  final int capacity;
  final Set<int> occupied;
  final Set<int> selected;
  final Function(int) onSeatTap;

  const _SeatGrid({
    required this.capacity,
    required this.occupied,
    required this.selected,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: capacity,
      itemBuilder: (_, i) {
        final seat = i + 1;
        final isOccupied = occupied.contains(seat);
        final isSelected = selected.contains(seat);

        Color bg;
        Color textColor;
        if (isSelected) {
          bg = AppColors.primary;
          textColor = Colors.white;
        } else if (isOccupied) {
          bg = AppColors.errorContainer;
          textColor = AppColors.error;
        } else {
          bg = AppColors.surfaceContainerHigh;
          textColor = AppColors.onBackground;
        }

        // Aisle gap every 2 seats
        final col = i % 4;
        final extraRight = col == 1 ? 8.0 : 0.0;

        return GestureDetector(
          onTap: () => onSeatTap(seat),
          child: Padding(
            padding: EdgeInsets.only(right: extraRight),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOccupied
                        ? Icons.person_rounded
                        : Icons.event_seat_rounded,
                    color: textColor,
                    size: 18,
                  ),
                  Text(
                    '$seat',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SeatLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _SeatLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PASSENGER DETAILS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class PassengerDetailsScreen extends StatefulWidget {
  const PassengerDetailsScreen({super.key});

  @override
  State<PassengerDetailsScreen> createState() =>
      _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  late List<Map<String, TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    final seats = context.read<BookingProvider>().selectedSeats;
    _controllers = List.generate(
      seats.length,
          (_) => {
        'name': TextEditingController(),
        'phone': TextEditingController(),
      },
    );

    // Pre-fill first passenger from logged in user
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && _controllers.isNotEmpty) {
      _controllers[0]['name']?.text = user.fullName;
      _controllers[0]['phone']?.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    for (final m in _controllers) {
      m['name']?.dispose();
      m['phone']?.dispose();
    }
    super.dispose();
  }

  void _continue() {
    final isGuest = context.read<AuthProvider>().isGuest;
    final details = _controllers.map((m) => {
      'name': m['name']?.text ?? '',
      'phone': m['phone']?.text ?? '',
    }).toList();

    if (details.any((d) => (d['name'] ?? '').isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir le nom de tous les passagers')),
      );
      return;
    }

    // For guest users, phone number is required
    if (isGuest && details.any((d) => (d['phone'] ?? '').isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Le numéro de téléphone est requis pour les invités')),
      );
      return;
    }

    context.read<BookingProvider>().setPassengerDetails(details);
    Navigator.pushNamed(context, AppRoutes.luggageManagement);
  }

  @override
  Widget build(BuildContext context) {
    final seats = context.watch<BookingProvider>().selectedSeats;
    final trip = context.watch<BookingProvider>().selectedTrip;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AssaAppBar(title: AppConstants.appName),
      body: Column(
        children: [
          _BookingProgress(step: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Détails des Passagers',
                        style: GoogleFonts.manrope(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        'Étape 3 sur 4',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _TripSummaryBanner(trip: trip),
                  const SizedBox(height: 20),
                  ...List.generate(seats.length, (i) {
                    final isFirst = i == 0;
                    return _PassengerCard(
                      index: i,
                      seat: seats[i],
                      isMain: isFirst,
                      nameController: _controllers[i]['name']!,
                      phoneController: _controllers[i]['phone']!,
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              label: 'Continuer',
              icon: Icons.arrow_forward_rounded,
              onPressed: _continue,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerCard extends StatelessWidget {
  final int index;
  final int seat;
  final bool isMain;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const _PassengerCard({
    required this.index,
    required this.seat,
    required this.isMain,
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMain
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isMain ? AppColors.primaryFixed : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: isMain
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isMain ? 'Passager Principal' : 'Passager ${index + 1}',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Siège $seat',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nom Complet',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LUGGAGE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class LuggageScreen extends StatefulWidget {
  const LuggageScreen({super.key});

  @override
  State<LuggageScreen> createState() => _LuggageScreenState();
}

class _LuggageScreenState extends State<LuggageScreen> {
  int _items = 1;
  int _weightCategory = 0; // 0=léger, 1=moyen, 2=lourd

  double get _extraFee {
    switch (_weightCategory) {
      case 1:
        return AppConstants.luggageExtraFeeMedium * _items;
      case 2:
        return AppConstants.luggageExtraFeeHeavy * _items;
      default:
        return 0;
    }
  }

  double get _avgWeight {
    switch (_weightCategory) {
      case 1:
        return 22.0;
      case 2:
        return 35.0;
      default:
        return 10.0;
    }
  }

  void _continue() {
    final luggage = LuggageModel(
      bookingId: 0,
      numberOfItems: _items,
      totalWeight: _avgWeight * _items,
      extraFee: _extraFee,
    );
    context.read<BookingProvider>().setLuggage(luggage);
    Navigator.pushNamed(context, AppRoutes.payment);
  }

  @override
  Widget build(BuildContext context) {
    final weightLabels = ['Léger\n0-15kg', 'Moyen\n15-30kg', 'Lourd\n30kg+'];
    final weightIcons = [
      Icons.luggage_outlined,
      Icons.luggage_rounded,
      Icons.cases_rounded
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Détails des bagages',
            style: GoogleFonts.manrope(
                fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.luggage_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Voyagez en toute sérénité',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Items
                  Text('Nombre de bagages',
                      style: GoogleFonts.manrope(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Bagages en soute — Maximum ${AppConstants.maxLuggageItems} sacs par voyageur',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CounterBtn(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (_items > 0) setState(() => _items--);
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              '$_items',
                              style: GoogleFonts.manrope(
                                  fontSize: 32, fontWeight: FontWeight.w800),
                            ),
                            Text('sac(s)',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                        _CounterBtn(
                          icon: Icons.add_rounded,
                          onTap: () {
                            if (_items < AppConstants.maxLuggageItems) {
                              setState(() => _items++);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weight category
                  Row(
                    children: [
                      const Icon(Icons.scale_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Poids estimé',
                          style: GoogleFonts.manrope(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(3, (i) {
                      final selected = _weightCategory == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _weightCategory = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  weightIcons[i],
                                  color: selected
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weightLabels[i],
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Fee info
                  if (_extraFee > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.warning, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Frais supplémentaires',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                                Text(
                                  '${formatPrice(_extraFee)} pour $_items sac(s) ${weightLabels[_weightCategory].split('\n')[0].toLowerCase()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              label: 'Continuer vers le paiement',
              icon: Icons.arrow_forward_rounded,
              onPressed: _continue,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  bool _isLoading = false;
  PaymentAccountModel? _account; // fetched from DB when mobile method selected
  String? _screenshotPath;       // path to uploaded payment receipt

  final _methods = [
    {'id': AppConstants.paymentMoovMoney,  'label': 'Moov Money',
      'subtitle': 'Paiement mobile instantané', 'icon': Icons.phone_android_rounded,
      'color': AppColors.secondary},
    {'id': AppConstants.paymentAirtelMoney,'label': 'Airtel Money',
      'subtitle': 'Rapide et sécurisé',        'icon': Icons.mobile_friendly_rounded,
      'color': AppColors.error},
    {'id': AppConstants.paymentAtGare,     'label': 'Payer à la gare',
      'subtitle': 'Réservez maintenant, payez à la gare',
      'icon': Icons.payments_rounded,          'color': AppColors.tertiary},
  ];

  Future<void> _onMethodSelected(String methodId) async {
    setState(() { _selectedMethod = methodId; _account = null; _screenshotPath = null; });
    if (methodId == AppConstants.paymentMoovMoney ||
        methodId == AppConstants.paymentAirtelMoney) {
      final acct = await ApiService.instance.getPaymentAccountByType(methodId);
      setState(() => _account = acct);
    }
  }

  Future<void> _pickScreenshot() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) setState(() => _screenshotPath = picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Impossible d'ouvrir la galerie: $e"),
            backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _pay() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un mode de paiement')));
      return;
    }
    // For mobile money, screenshot is strongly recommended (not blocking)
    setState(() => _isLoading = true);
    context.read<BookingProvider>().selectPaymentMethod(_selectedMethod!);
    context.read<BookingProvider>().setPaymentScreenshot(_screenshotPath);

    final auth    = context.read<AuthProvider>();
    final userId  = auth.currentUser?.id ?? 0;
    final booking = await context.read<BookingProvider>().completeBooking(userId);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (booking != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.bookingConfirmation,
              (r) => r.settings.name == AppRoutes.home,
          arguments: booking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de la réservation. Réessayez.'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<BookingProvider>();
    final trip      = provider.selectedTrip;
    final isMobile  = _selectedMethod == AppConstants.paymentMoovMoney ||
        _selectedMethod == AppConstants.paymentAirtelMoney;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AssaAppBar(title: AppConstants.appName),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Traitement de la réservation...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Finalisez votre voyage',
                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // ── Trip summary card ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trajet', style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.onSurfaceVariant)),
                    Text(
                        "${trip?.route?.originCity ?? ''} → ${trip?.route?.destinationCity ?? ''}",
                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        "Départ: ${trip != null ? DateFormat('d MMMM, HH:mm', 'fr_FR').format(trip.departureDate) : ''}",
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _PriceLine(
                        label: 'Billet (${provider.selectedSeats.length} '
                            'personne${provider.selectedSeats.length > 1 ? 's' : ''})',
                        value: formatPrice(
                            (trip?.route?.basePrice ?? 0) * provider.selectedSeats.length)),
                    if ((provider.luggageDetails?.extraFee ?? 0) > 0)
                      _PriceLine(label: 'Bagages',
                          value: formatPrice(provider.luggageDetails!.extraFee)),
                    const Divider(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Prix total', style: GoogleFonts.manrope(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(formatPrice(provider.totalPrice),
                          style: GoogleFonts.manrope(fontSize: 20,
                              fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Payment method selector ───────────────────────────────────
              Text('Mode de paiement',
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._methods.map((m) {
                final isSelected = _selectedMethod == m['id'];
                return GestureDetector(
                  onTap: () => _onMethodSelected(m['id'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: isSelected
                            ? (m['color'] as Color).withOpacity(0.08)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isSelected
                                ? (m['color'] as Color)
                                : AppColors.outlineVariant,
                            width: isSelected ? 2 : 0.5)),
                    child: Row(children: [
                      Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                              color: (m['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(m['icon'] as IconData,
                              color: m['color'] as Color, size: 22)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['label'] as String, style: GoogleFonts.manrope(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(m['subtitle'] as String, style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ])),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: m['color'] as Color, size: 22),
                    ]),
                  ),
                );
              }),

              // ── Mobile money payment details ──────────────────────────────
              if (isMobile) ...[
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.success.withOpacity(0.4))),
                  child: _account == null
                      ? Row(children: [
                    const SizedBox(width: 12,height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('Chargement du numéro de paiement...',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ])
                      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.account_balance_wallet_rounded,
                              color: AppColors.success, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_account!.displayType,
                                style: GoogleFonts.manrope(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(_account!.accountName,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ])),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withOpacity(0.3))),
                      child: Column(children: [
                        Text('Numéro à créditer',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(_account!.accountNumber,
                            style: GoogleFonts.manrope(
                                fontSize: 22, fontWeight: FontWeight.w900,
                                color: AppColors.success,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                              'Montant: ${formatPrice(provider.totalPrice)}',
                              style: GoogleFonts.manrope(
                                  fontSize: 16, fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        '1. Envoyez ${formatPrice(provider.totalPrice)} au numéro ci-dessus\n'
                            '2. Prenez une capture d\'écran du reçu\n'
                            '3. Téléversez-la ci-dessous pour confirmer',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.7)),
                  ]),
                ),
                const SizedBox(height: 12),

                // ── Screenshot upload section ─────────────────────────────
                GestureDetector(
                  onTap: _pickScreenshot,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _screenshotPath != null
                          ? AppColors.successContainer
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _screenshotPath != null
                              ? AppColors.success
                              : AppColors.outlineVariant,
                          width: _screenshotPath != null ? 2 : 0.5),
                    ),
                    child: _screenshotPath != null
                        ? Row(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                              File(_screenshotPath!),
                              width: 56, height: 56, fit: BoxFit.cover)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reçu téléversé ✓',
                                style: GoogleFonts.manrope(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: AppColors.success)),
                            Text('Appuyez pour changer l\'image',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant)),
                          ])),
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success),
                    ])
                        : Row(children: [
                      Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.upload_rounded,
                              color: AppColors.primary, size: 22)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Téléverser le reçu de paiement',
                                style: GoogleFonts.manrope(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                            Text('Capture d\'écran du transfert mobile',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant)),
                          ])),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.onSurfaceVariant),
                    ]),
                  ),
                ),

                // Warning if no screenshot yet for mobile payment
                if (_screenshotPath == null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                          'Le téléversement du reçu est fortement recommandé. '
                              'Sans reçu, l\'admin pourra demander une preuve avant de confirmer.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.warning))),
                    ]),
                  ),
                ],
                const SizedBox(height: 8),
              ],

              // ── À la gare info ────────────────────────────────────────────
              if (_selectedMethod == AppConstants.paymentAtGare) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.onTertiaryContainer, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                        'Votre billet sera réservé. Vous devrez payer '
                            'à la gare avant la date de départ pour confirmer votre place. '
                            'Sans paiement, la réservation peut être annulée.',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.onTertiaryContainer, height: 1.5))),
                  ]),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 24),
              GradientButton(
                label: 'Confirmer ma réservation',
                icon: Icons.lock_rounded,
                onPressed: _pay,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}


class _PriceLine extends StatelessWidget {
  final String label;
  final String value;

  const _PriceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.onSurfaceVariant)),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED BOOKING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _BookingProgress extends StatelessWidget {
  final int step; // 1=seats, 2=passengers, 3=luggage, 4=payment

  const _BookingProgress({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i < step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TripSummaryBanner extends StatelessWidget {
  final TripModel? trip;

  const _TripSummaryBanner({this.trip});

  @override
  Widget build(BuildContext context) {
    if (trip == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${trip!.route?.originCity ?? ''} → ${trip!.route?.destinationCity ?? ''}',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Départ prévu • ${trip!.departureTime}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.onPrimaryFixedVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}