import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/models.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _origin;
  String? _destination;
  DateTime _date = DateTime.now();
  int _passengers = 1;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('fr', 'FR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _pickCity(bool isOrigin) async {
    final city = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        title: isOrigin ? 'Ville de départ' : 'Destination',
        excludeCity: isOrigin ? _destination : _origin,
      ),
    );
    if (city != null) {
      setState(() {
        if (isOrigin) {
          _origin = city;
        } else {
          _destination = city;
        }
      });
    }
  }

  void _swapCities() {
    setState(() {
      final tmp = _origin;
      _origin = _destination;
      _destination = tmp;
    });
  }

  void _search() {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner les villes de départ et d\'arrivée')),
      );
      return;
    }
    final query = SearchQuery(
      origin: _origin!,
      destination: _destination!,
      date: _date,
      passengers: _passengers,
    );
    context.read<BookingProvider>().searchTrips(query);
    Navigator.pushNamed(context, AppRoutes.searchResults);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final firstName = (user?.fullName ?? 'Voyageur').split(' ').first;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Text(
                AppConstants.appName,
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('Mes Billets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.myTickets);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.support);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            child: const Icon(Icons.menu_rounded,
                                color: Colors.white, size: 26),
                          ),
                          Text(
                            AppConstants.appName,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              // Notifications bell
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.notifications),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.notifications_rounded,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Profile avatar
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.profile),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: Text(
                                    firstName.isNotEmpty
                                        ? firstName[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bonjour,',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        firstName,
                        style: GoogleFonts.manrope(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Où voyageons-nous aujourd\'hui ?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Search card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Origin & Destination
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    CityInputField(
                                      label: 'Ville de départ',
                                      value: _origin,
                                      icon: Icons.location_on_rounded,
                                      onTap: () => _pickCity(true),
                                      hint: 'Choisir',
                                    ),
                                    const SizedBox(height: 10),
                                    CityInputField(
                                      label: 'Destination',
                                      value: _destination,
                                      icon: Icons.near_me_rounded,
                                      onTap: () => _pickCity(false),
                                      hint: 'Choisir',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Swap button
                              GestureDetector(
                                onTap: _swapCities,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.swap_vert_rounded,
                                      color: Colors.white,
                                      size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Date & Passengers
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.outlineVariant),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.calendar_today_rounded,
                                            color: AppColors.primary,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('d MMM yyyy', 'fr_FR')
                                                  .format(_date),
                                              style: GoogleFonts.manrope(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.outlineVariant),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (_passengers > 1) {
                                            setState(() => _passengers--);
                                          }
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.outlineVariant,
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.remove,
                                              size: 14),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '$_passengers',
                                            style: GoogleFonts.manrope(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            'Pass.',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (_passengers < 9) {
                                            setState(() => _passengers++);
                                          }
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.add,
                                              size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            label: 'Rechercher',
                            icon: Icons.search_rounded,
                            onPressed: _search,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick actions
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Mes Billets',
                          color: AppColors.primaryFixed,
                          iconColor: AppColors.primary,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.myTickets),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.history_rounded,
                          label: 'Historique',
                          color: AppColors.secondaryFixed,
                          iconColor: AppColors.secondary,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.myTickets),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.local_offer_rounded,
                          label: 'Promotions',
                          color: AppColors.tertiaryContainer,
                          iconColor: AppColors.tertiary,
                          onTap: () => _showPromotions(context),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.support_agent_rounded,
                          label: 'Support',
                          color: AppColors.successContainer,
                          iconColor: AppColors.success,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.support),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Route Map Button ─────────────────────────────
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.routeMap,
                          arguments: {
                            'origin': _origin ?? '',
                            'destination': _destination ?? '',
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                                  Text('Visualiser le trajet',
                                      style: GoogleFonts.manrope(
                                          fontSize: 13, fontWeight: FontWeight.w700)),
                                  Text(
                                    (_origin != null && _destination != null)
                                        ? 'Distance: ${AppConstants.distanceBetween(_origin!, _destination!).toStringAsFixed(0)} km • ${AppConstants.formatDuration(AppConstants.estimatedHours(_origin!, _destination!))}'
                                        : 'Carte des trajets du Tchad',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11, color: AppColors.onSurfaceVariant),
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
                    const SizedBox(height: 24),

                    // ── Active Promotions Banner ──────────────────────
                    _PromotionsBanner(),
                    const SizedBox(height: 24),

                    // ── GPS-based nearby trips ────────────────────────
                    _NearbyTripsSection(
                      onCityDetected: (city) {
                        if (mounted) setState(() => _origin = city);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Popular routes from admin ─────────────────────
                    _PopularRoutesSection(
                      onRouteSelected: (origin, destination) {
                        setState(() {
                          _origin      = origin;
                          _destination = destination;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Admin shortcut for admin users
                    if (auth.isAdmin)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.adminDashboard),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.admin_panel_settings_rounded,
                                  color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Accéder au panneau d\'administration',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularRouteCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String price;
  final String duration;
  final VoidCallback onTap;

  const _PopularRouteCard({
    required this.origin,
    required this.destination,
    required this.price,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_bus_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$origin → $destination',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  Text(
                    duration,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Par pers.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  final String title;
  final String? excludeCity;

  const _CityPickerSheet({required this.title, this.excludeCity});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cities = AppConstants.chadCities
        .where((c) =>
    c != widget.excludeCity &&
        c.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: GoogleFonts.manrope(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une ville...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.location_city_rounded,
                    color: AppColors.primary, size: 20),
                title: Text(cities[i],
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, cities[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── PROMOTIONS BANNER (shown inline in HomeScreen) ────────────────────────

class _PromotionsBanner extends StatefulWidget {
  const _PromotionsBanner();

  @override
  State<_PromotionsBanner> createState() => _PromotionsBannerState();
}

class _PromotionsBannerState extends State<_PromotionsBanner> {
  List<PromotionModel> _promos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final promos = await DatabaseHelper.instance.getActivePromotions();
      if (mounted) setState(() => _promos = promos);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_promos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '🎉 Promotions en cours',
          action: 'Tout voir',
          onAction: () => _showPromotions(context),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _promos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final p = _promos[i];
              return Container(
                width: 240,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A0CA3), Color(0xFF7B5EAB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '-${p.discountPercent.toStringAsFixed(0)}%',
                          style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.title,
                              style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(p.description,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Top-level helper to show promotions modal
void _showPromotions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PromosSheet(),
  );
}

class _PromosSheet extends StatefulWidget {
  const _PromosSheet();

  @override
  State<_PromosSheet> createState() => _PromosSheetState();
}

class _PromosSheetState extends State<_PromosSheet> {
  List<PromotionModel> _promos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await DatabaseHelper.instance.getActivePromotions();
      if (mounted) setState(() { _promos = p; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text('Promotions actives 🎉',
                    style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _promos.isEmpty
                ? Center(
                child: Text('Aucune promotion active.',
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.onSurfaceVariant)))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _promos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final p = _promos[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A0CA3), Color(0xFF7B5EAB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '-${p.discountPercent.toStringAsFixed(0)}%',
                            style: GoogleFonts.manrope(
                                fontSize: 16, fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: GoogleFonts.manrope(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(p.description,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8))),
                            if (p.validUntil != null) ...[
                              const SizedBox(height: 6),
                              Text('Valide jusqu\'au ${p.validUntil}',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.6))),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GPS-BASED NEARBY TRIPS SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _NearbyTripsSection extends StatefulWidget {
  final ValueChanged<String> onCityDetected;
  const _NearbyTripsSection({required this.onCityDetected});

  @override
  State<_NearbyTripsSection> createState() => _NearbyTripsSectionState();
}

class _NearbyTripsSectionState extends State<_NearbyTripsSection> {
  String?          _city;
  List<TripModel>  _trips     = [];
  bool             _detecting = false;
  bool             _asked     = false;
  String?          _error;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final alreadyAsked = _prefs.getBool('location_permission_asked') ?? false;
    
    if (!alreadyAsked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askAndDetect());
    } else {
      // User has been asked before, check their preference and detect if allowed
      final locationAllowed = _prefs.getBool('location_permission_allowed') ?? false;
      if (locationAllowed && mounted) {
        setState(() => _asked = true);
        await _detectAndLoad();
      }
    }
  }

  Future<void> _askAndDetect() async {
    if (_asked) return;
    setState(() { _asked = true; _detecting = true; });

    // Polite dialog asking for permission
    if (mounted) {
      final allow = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Utiliser ma position',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary, size: 34)),
            const SizedBox(height: 16),
            Text(
                'Assa Ticket souhaite utiliser votre position pour vous '
                    'suggérer les voyages disponibles depuis votre ville.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5)),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Non merci',
                    style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant))),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Autoriser',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700))),
          ],
        ),
      );
      
      // Save user's choice to SharedPreferences
      await _prefs.setBool('location_permission_asked', true);
      await _prefs.setBool('location_permission_allowed', allow ?? false);
      
      if (allow != true) { setState(() => _detecting = false); return; }
    }

    await _detectAndLoad();
  }

  Future<void> _detectAndLoad() async {
    setState(() { _detecting = true; _error = null; });
    try {
      final city = await LocationService.instance.detectNearestCity();
      if (city != null) {
        final trips = await DatabaseHelper.instance.getTripsByOrigin(city);
        setState(() { _city = city; _trips = trips; });
        widget.onCityDetected(city);
      } else {
        setState(() => _error = 'Position non disponible.');
      }
    } catch (e) {
      setState(() => _error = 'Erreur de localisation.');
    } finally {
      setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_asked) return const SizedBox.shrink();

    if (_detecting) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant)),
        child: const Center(child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Détection de votre position...'),
          ],
        )),
      );
    }

    if (_error != null || _city == null) {
      return const SizedBox.shrink();
    }

    if (_trips.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Voyages depuis $_city 📍',
          action: 'Actualiser',
          onAction: _detectAndLoad,
        ),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant)),
            child: Text(
                'Aucun voyage disponible depuis $_city pour les 14 prochains jours.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center)),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Voyages depuis $_city 📍',
        action: 'Actualiser',
        onAction: _detectAndLoad,
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _trips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (ctx, i) {
            final trip = _trips[i];
            return _NearbyTripCard(
              trip: trip,
              onTap: () {
                context.read<BookingProvider>().selectTrip(trip);
                Navigator.pushNamed(context, AppRoutes.tripDetails);
              },
            );
          },
        ),
      ),
    ]);
  }
}

class _NearbyTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _NearbyTripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final route = trip.route;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.directions_bus_rounded,
                  color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text(trip.bus?.busNumber ?? 'Bus',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: Colors.white60)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('${trip.availableSeats} places',
                    style: GoogleFonts.manrope(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(route?.destinationCity ?? 'Destination',
                style: GoogleFonts.manrope(
                    fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(
                '${DateFormat('d MMM', 'fr_FR').format(trip.departureDate)} • ${trip.departureTime}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
            const Spacer(),
            Row(children: [
              Text(
                  formatPrice(route?.basePrice ?? 0),
                  style: GoogleFonts.manrope(
                      fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Réserver',
                    style: GoogleFonts.manrope(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// POPULAR ROUTES SECTION (from admin DB)
// ═══════════════════════════════════════════════════════════════════════════

class _PopularRoutesSection extends StatefulWidget {
  final void Function(String origin, String destination) onRouteSelected;
  const _PopularRoutesSection({required this.onRouteSelected});

  @override
  State<_PopularRoutesSection> createState() => _PopularRoutesSectionState();
}

class _PopularRoutesSectionState extends State<_PopularRoutesSection> {
  List<RouteModel> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await DatabaseHelper.instance.getPopularRoutes();
      if (mounted) setState(() { _routes = r; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Trajets populaires', action: 'Voir tout', onAction: () {}),
        const SizedBox(height: 10),
        const SizedBox(height: 80,
            child: Center(child: CircularProgressIndicator())),
      ]);
    }
    if (_routes.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Trajets populaires',
        action: 'Voir tout',
        onAction: () {},
      ),
      const SizedBox(height: 12),
      ..._routes.map((r) => _PopularRouteCard(
        origin: r.originCity,
        destination: r.destinationCity,
        price: formatPrice(r.basePrice),
        duration: AppConstants.formatDuration(
            AppConstants.estimatedHours(r.originCity, r.destinationCity)),
        onTap: () => widget.onRouteSelected(r.originCity, r.destinationCity),
      )),
    ]);
  }
}