import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/models.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final query = provider.searchQuery;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              query != null
                  ? '${query.origin} → ${query.destination}'
                  : 'Résultats',
              style: GoogleFonts.manrope(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (query != null)
              Text(
                DateFormat('d MMMM yyyy', 'fr_FR').format(query.date),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: provider.isSearching
          ? const _LoadingState()
          : provider.searchError != null
              ? EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'Aucun trajet trouvé',
                  subtitle: provider.searchError!,
                  actionLabel: 'Modifier la recherche',
                  onAction: () => Navigator.pop(context),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.account_circle_outlined,
                              size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            'Départs disponibles',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.searchResults.length} trajets',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (query != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          '${provider.searchResults.length} trajets trouvés pour votre voyage',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: provider.searchResults.length,
                        itemBuilder: (_, i) => _TripCard(
                          trip: provider.searchResults[i],
                          onTap: () {
                            context
                                .read<BookingProvider>()
                                .selectTrip(provider.searchResults[i]);
                            Navigator.pushNamed(context, AppRoutes.tripDetails);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary)),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const _TripCard({required this.trip, required this.onTap});

  String _calcArrival() {
    try {
      final parts = trip.departureTime.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dep = DateTime(2024, 1, 1, h, m);
      final arr = dep.add(const Duration(hours: 8, minutes: 30));
      return '${arr.hour.toString().padLeft(2, '0')}:${arr.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  String _busType() {
    if (trip.bus == null) return 'Standard';
    if ((trip.bus?.capacity ?? 0) <= 30) return 'Express VIP';
    if ((trip.bus?.capacity ?? 0) <= 45) return 'Premium';
    return 'Standard';
  }

  @override
  Widget build(BuildContext context) {
    final arrivalTime = _calcArrival();
    final price = trip.route?.basePrice ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.outlineVariant, width: 0.5),
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryFixed,
                    child: const Icon(Icons.directions_bus_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.bus?.busNumber ?? 'Voyages Al-Amine',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _busType(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_seat_rounded,
                              size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.availableSeats} places',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formatPrice(price),
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Par personne',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.departureTime,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        trip.route?.originCity ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '8h 30min',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(
                                    color: AppColors.outlineVariant,
                                    thickness: 1.5)),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_bus_rounded,
                                  size: 14, color: AppColors.primary),
                            ),
                            const Expanded(
                                child: Divider(
                                    color: AppColors.outlineVariant,
                                    thickness: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Direct',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        arrivalTime,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        trip.route?.destinationCity ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.ac_unit_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Climatisé',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant)),
                      const SizedBox(width: 12),
                      const Icon(Icons.wifi_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Wi-Fi',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Réserver',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: AppColors.primary),
                    ],
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
