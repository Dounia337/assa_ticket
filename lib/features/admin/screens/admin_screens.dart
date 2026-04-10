import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/admin_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/models.dart';
import '../../../core/database/database_helper.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final _pages = [
    const _AdminHome(),
    const AdminRoutesScreen(),
    const AdminBusesScreen(),
    const AdminTripsScreen(),
    const AdminBookingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(Icons.dashboard_rounded, 'Accueil', 0, _selectedIndex,
                      () => setState(() => _selectedIndex = 0)),
              _NavItem(Icons.route_rounded, 'Trajets', 1, _selectedIndex,
                      () => setState(() => _selectedIndex = 1)),
              _NavItem(Icons.directions_bus_rounded, 'Bus', 2, _selectedIndex,
                      () => setState(() => _selectedIndex = 2)),
              _NavItem(Icons.departure_board_rounded, 'Voyages', 3,
                  _selectedIndex, () => setState(() => _selectedIndex = 3)),
              _NavItem(Icons.book_online_rounded, 'Réserv.', 4, _selectedIndex,
                      () => setState(() => _selectedIndex = 4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final VoidCallback onTap;

  const _NavItem(
      this.icon, this.label, this.index, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Admin Home ─────────────────────────────────────────────────────────────

class _AdminHome extends StatelessWidget {
  const _AdminHome();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final stats = admin.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.auth, (_) => false);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tableau de bord',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    auth.currentUser?.fullName ?? 'Admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              background: Container(
                  decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        title: 'Réservations',
                        value:
                        '${stats['total_bookings'] ?? 0}',
                        icon: Icons.book_online_rounded,
                        color: AppColors.primary,
                        bg: AppColors.primaryFixed,
                      ),
                      _StatCard(
                        title: 'Revenus',
                        value: formatPrice(
                            (stats['total_revenue'] ?? 0).toDouble()),
                        icon: Icons.payments_rounded,
                        color: AppColors.success,
                        bg: AppColors.successContainer,
                      ),
                      _StatCard(
                        title: 'Utilisateurs',
                        value: '${stats['total_users'] ?? 0}',
                        icon: Icons.people_rounded,
                        color: AppColors.secondary,
                        bg: AppColors.secondaryFixed,
                      ),
                      _StatCard(
                        title: 'Voyages actifs',
                        value: '${stats['active_trips'] ?? 0}',
                        icon: Icons.departure_board_rounded,
                        color: AppColors.tertiary,
                        bg: AppColors.tertiaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick actions
                  Text(
                    'Actions rapides',
                    style: GoogleFonts.manrope(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _AdminAction(
                        icon: Icons.add_road_rounded,
                        label: 'Ajouter\nTrajet',
                        color: AppColors.primary,
                        onTap: () => _showRouteForm(context),
                      ),
                      _AdminAction(
                        icon: Icons.directions_bus_rounded,
                        label: 'Ajouter\nBus',
                        color: AppColors.secondary,
                        onTap: () => _showBusForm(context),
                      ),
                      _AdminAction(
                        icon: Icons.schedule_rounded,
                        label: 'Programmer\nVoyage',
                        color: AppColors.tertiary,
                        onTap: () => _showTripForm(context),
                      ),
                      _AdminAction(
                        icon: Icons.local_offer_rounded,
                        label: 'Promotions',
                        color: AppColors.tertiary,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminPromotions),
                      ),
                      _AdminAction(
                        icon: Icons.bar_chart_rounded,
                        label: 'Rapports',
                        color: AppColors.warning,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminReportsScreen()),
                        ),
                      ),
                      _AdminAction(
                        icon: Icons.contact_phone_rounded,
                        label: 'Contact',
                        color: AppColors.success,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminContact),
                      ),
                      _AdminAction(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Comptes\nMobile',
                        color: AppColors.secondary,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminPaymentAccounts),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pending bookings
                  SectionHeader(
                    title: 'Réservations en attente',
                    action: 'Voir tout',
                    onAction: () => Navigator.pushNamed(context, AppRoutes.adminBookings),
                  ),
                  const SizedBox(height: 10),
                  ...admin.bookings
                      .where((b) => b.status == AppConstants.statusPending)
                      .take(3)
                      .map((b) => _PendingBookingTile(
                    booking: b,
                    onConfirm: () =>
                        context.read<AdminProvider>().confirmBooking(b.id!),
                  )),
                  if (admin.bookings
                      .where((b) => b.status == AppConstants.statusPending)
                      .isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Aucune réservation en attente',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRouteForm(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AdminRouteFormScreen()));
  }

  void _showBusForm(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AdminBusFormScreen()));
  }

  void _showTripForm(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AdminTripFormScreen()));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminAction(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
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

class _PendingBookingTile extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onConfirm;

  const _PendingBookingTile(
      {required this.booking, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final trip = booking.trip;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${booking.ticketNumber}',
                  style: GoogleFonts.manrope(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  trip != null
                      ? '${trip.route?.originCity} → ${trip.route?.destinationCity}'
                      : 'Trajet inconnu',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                Text(
                  formatPrice(booking.totalPrice),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text('Confirmer',
                style: GoogleFonts.manrope(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN ROUTES SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminRoutesScreen extends StatelessWidget {
  const AdminRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AdminAppBar(
        title: 'Gestion des Trajets',
        action: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminRouteFormScreen()),
          ),
        ),
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator())
          : admin.routes.isEmpty
          ? EmptyStateWidget(
        icon: Icons.route_rounded,
        title: 'Aucun trajet',
        subtitle: 'Ajoutez votre premier trajet',
        actionLabel: 'Ajouter un trajet',
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AdminRouteFormScreen()),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admin.routes.length,
        itemBuilder: (_, i) {
          final route = admin.routes[i];
          return _AdminRouteCard(
            route: route,
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AdminRouteFormScreen(existing: route)),
            ),
            onDelete: () async {
              final confirm = await _confirmDelete(context);
              if (confirm == true) {
                context
                    .read<AdminProvider>()
                    .deleteRoute(route.id!);
              }
            },
          );
        },
      ),
    );
  }
}

class _AdminRouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminRouteCard(
      {required this.route, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
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
            child: const Icon(Icons.route_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${route.originCity} → ${route.destinationCity}',
                  style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  formatPrice(route.basePrice),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: route.isActive
                  ? AppColors.successContainer
                  : AppColors.errorContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              route.isActive ? 'Actif' : 'Inactif',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: route.isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
              const PopupMenuItem(
                  value: 'delete',
                  child:
                  Text('Supprimer', style: TextStyle(color: AppColors.error))),
            ],
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN ROUTE FORM
// ═══════════════════════════════════════════════════════════════════════════

class AdminRouteFormScreen extends StatefulWidget {
  final RouteModel? existing;
  const AdminRouteFormScreen({super.key, this.existing});

  @override
  State<AdminRouteFormScreen> createState() => _AdminRouteFormScreenState();
}

class _AdminRouteFormScreenState extends State<AdminRouteFormScreen> {
  String? _origin;
  String? _destination;
  final _priceCtrl = TextEditingController();
  bool _isActive = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _origin = widget.existing!.originCity;
      _destination = widget.existing!.destinationCity;
      _priceCtrl.text = widget.existing!.basePrice.toStringAsFixed(0);
      _isActive = widget.existing!.isActive;
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_origin == null || _destination == null || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    setState(() => _loading = true);
    final route = RouteModel(
      id: widget.existing?.id,
      originCity: _origin!,
      destinationCity: _destination!,
      basePrice: double.tryParse(_priceCtrl.text) ?? 0,
      isActive: _isActive,
    );
    bool ok;
    if (widget.existing == null) {
      ok = await context.read<AdminProvider>().addRoute(route);
    } else {
      ok = await context.read<AdminProvider>().updateRoute(route);
    }
    setState(() => _loading = false);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AdminAppBar(
          title: widget.existing == null ? 'Ajouter Trajet' : 'Modifier Trajet'),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormLabel('Ville de départ'),
              _CityDropdown(
                  value: _origin,
                  hint: 'Sélectionner',
                  onChanged: (v) => setState(() => _origin = v)),
              const SizedBox(height: 14),
              _FormLabel('Destination'),
              _CityDropdown(
                  value: _destination,
                  hint: 'Sélectionner',
                  onChanged: (v) => setState(() => _destination = v)),
              const SizedBox(height: 14),
              _FormLabel('Prix de base (FCFA)'),
              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ex: 15000',
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text('Trajet actif',
                        style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                  label: widget.existing == null ? 'Ajouter' : 'Enregistrer',
                  onPressed: _save,
                  isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN BUSES SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminBusesScreen extends StatelessWidget {
  const AdminBusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AdminAppBar(
        title: 'Gestion des Bus',
        action: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminBusFormScreen()),
          ),
        ),
      ),
      body: admin.buses.isEmpty
          ? EmptyStateWidget(
        icon: Icons.directions_bus_rounded,
        title: 'Aucun bus',
        subtitle: 'Ajoutez votre premier bus',
        actionLabel: 'Ajouter un bus',
        onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminBusFormScreen())),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admin.buses.length,
        itemBuilder: (_, i) {
          final bus = admin.buses[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_bus_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.busNumber,
                        style: GoogleFonts.manrope(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${bus.capacity} places • ${bus.conditionStatus}',
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
                    StatusChip(status: bus.status),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              size: 18, color: AppColors.primary),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AdminBusFormScreen(existing: bus)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              size: 18, color: AppColors.error),
                          onPressed: () async {
                            final c = await _confirmDelete(context);
                            if (c == true) {
                              context
                                  .read<AdminProvider>()
                                  .deleteBus(bus.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN BUS FORM
// ═══════════════════════════════════════════════════════════════════════════

class AdminBusFormScreen extends StatefulWidget {
  final BusModel? existing;
  const AdminBusFormScreen({super.key, this.existing});

  @override
  State<AdminBusFormScreen> createState() => _AdminBusFormScreenState();
}

class _AdminBusFormScreenState extends State<AdminBusFormScreen> {
  final _numberCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _status = 'ACTIF';
  String _condition = 'BON';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _numberCtrl.text = widget.existing!.busNumber;
      _capacityCtrl.text = widget.existing!.capacity.toString();
      _status = widget.existing!.status;
      _condition = widget.existing!.conditionStatus;
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_numberCtrl.text.isEmpty || _capacityCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    setState(() => _loading = true);
    final bus = BusModel(
      id: widget.existing?.id,
      busNumber: _numberCtrl.text,
      capacity: int.tryParse(_capacityCtrl.text) ?? 45,
      status: _status,
      conditionStatus: _condition,
    );
    bool ok;
    if (widget.existing == null) {
      ok = await context.read<AdminProvider>().addBus(bus);
    } else {
      ok = await context.read<AdminProvider>().updateBus(bus);
    }
    setState(() => _loading = false);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AdminAppBar(
          title: widget.existing == null ? 'Ajouter Bus' : 'Modifier Bus'),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormLabel('Numéro du bus'),
              TextField(
                controller: _numberCtrl,
                decoration: const InputDecoration(
                    hintText: 'Ex: AT-001',
                    prefixIcon: Icon(Icons.confirmation_number_rounded)),
              ),
              const SizedBox(height: 14),
              _FormLabel('Capacité (sièges)'),
              TextField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Ex: 45',
                    prefixIcon: Icon(Icons.event_seat_rounded)),
              ),
              const SizedBox(height: 14),
              _FormLabel('Statut'),
              _DropdownField(
                value: _status,
                items: const ['ACTIF', 'EN_MAINTENANCE', 'INACTIF'],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 14),
              _FormLabel('État du véhicule'),
              _DropdownField(
                value: _condition,
                items: const ['EXCELLENT', 'BON', 'PASSABLE', 'MAUVAIS'],
                onChanged: (v) => setState(() => _condition = v!),
              ),
              const SizedBox(height: 24),
              GradientButton(
                  label: widget.existing == null ? 'Ajouter' : 'Enregistrer',
                  onPressed: _save,
                  isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN TRIPS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminTripsScreen extends StatelessWidget {
  const AdminTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _AdminAppBar(
        title: 'Gestion des Voyages',
        action: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminTripFormScreen()),
          ),
        ),
      ),
      body: admin.trips.isEmpty
          ? EmptyStateWidget(
        icon: Icons.departure_board_rounded,
        title: 'Aucun voyage',
        subtitle: 'Programmez votre premier voyage',
        actionLabel: 'Programmer un voyage',
        onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminTripFormScreen())),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admin.trips.length,
        itemBuilder: (_, i) {
          final trip = admin.trips[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.route != null
                            ? '${trip.route!.originCity} → ${trip.route!.destinationCity}'
                            : 'Trajet #${trip.routeId}',
                        style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${DateFormat('d MMM', 'fr_FR').format(trip.departureDate)} • ${trip.departureTime}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Bus: ${trip.bus?.busNumber ?? '#${trip.busId}'} • ${trip.availableSeats} places',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    StatusChip(status: trip.status),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              size: 18, color: AppColors.primary),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AdminTripFormScreen(existing: trip)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              size: 18, color: AppColors.error),
                          onPressed: () async {
                            final c = await _confirmDelete(context);
                            if (c == true) {
                              context
                                  .read<AdminProvider>()
                                  .deleteTrip(trip.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN TRIP FORM
// ═══════════════════════════════════════════════════════════════════════════

class AdminTripFormScreen extends StatefulWidget {
  final TripModel? existing;
  const AdminTripFormScreen({super.key, this.existing});

  @override
  State<AdminTripFormScreen> createState() => _AdminTripFormScreenState();
}

class _AdminTripFormScreenState extends State<AdminTripFormScreen> {
  int? _routeId;
  int? _busId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  final _seatsCtrl = TextEditingController();
  String _status = 'PROGRAMME';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _routeId = widget.existing!.routeId;
      _busId = widget.existing!.busId;
      _date = widget.existing!.departureDate;
      _seatsCtrl.text = widget.existing!.availableSeats.toString();
      _status = widget.existing!.status;
      try {
        final parts = widget.existing!.departureTime.split(':');
        _time = TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _seatsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    if (_routeId == null || _busId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un trajet et un bus')),
      );
      return;
    }
    setState(() => _loading = true);
    final admin = context.read<AdminProvider>();
    final bus = admin.buses.firstWhere((b) => b.id == _busId,
        orElse: () => BusModel(busNumber: '', capacity: 45));
    final seats =
        int.tryParse(_seatsCtrl.text) ?? bus.capacity;
    final trip = TripModel(
      id: widget.existing?.id,
      routeId: _routeId!,
      busId: _busId!,
      departureDate: _date,
      departureTime:
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
      availableSeats: seats,
      status: _status,
    );
    bool ok;
    if (widget.existing == null) {
      ok = await admin.addTrip(trip);
    } else {
      ok = await admin.updateTrip(trip);
    }
    setState(() => _loading = false);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: _AdminAppBar(
          title: widget.existing == null
              ? 'Programmer Voyage'
              : 'Modifier Voyage'),
      body: LoadingOverlay(
        isLoading: _loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormLabel('Trajet'),
              DropdownButtonFormField<int>(
                initialValue: _routeId,
                hint: const Text('Sélectionner un trajet'),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.route_rounded)),
                items: admin.routes
                    .map((r) => DropdownMenuItem(
                  value: r.id,
                  child: Text(r.displayName),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _routeId = v),
              ),
              const SizedBox(height: 14),
              _FormLabel('Bus'),
              DropdownButtonFormField<int>(
                initialValue: _busId,
                hint: const Text('Sélectionner un bus'),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.directions_bus_rounded)),
                items: admin.buses
                    .where((b) => b.status == 'ACTIF')
                    .map((b) => DropdownMenuItem(
                  value: b.id,
                  child: Text('${b.busNumber} (${b.capacity} places)'),
                ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _busId = v;
                    final bus = admin.buses.firstWhere((b) => b.id == v);
                    _seatsCtrl.text = bus.capacity.toString();
                  });
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Date de départ'),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(DateFormat('d MMM yyyy', 'fr_FR')
                                    .format(_date)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Heure'),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(_time.format(context)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _FormLabel('Sièges disponibles'),
              TextField(
                controller: _seatsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.event_seat_rounded)),
              ),
              const SizedBox(height: 14),
              _FormLabel('Statut'),
              _DropdownField(
                value: _status,
                items: const ['PROGRAMME', 'PARTI', 'ARRIVE', 'ANNULE'],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 24),
              GradientButton(
                  label: widget.existing == null
                      ? 'Programmer'
                      : 'Enregistrer',
                  onPressed: _save,
                  isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN BOOKINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _AdminAppBar(title: 'Gestion des Réservations'),
      body: admin.bookings.isEmpty
          ? const EmptyStateWidget(
        icon: Icons.book_online_rounded,
        title: 'Aucune réservation',
        subtitle: 'Les réservations apparaîtront ici.',
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admin.bookings.length,
        itemBuilder: (_, i) {
          final booking = admin.bookings[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border:
              Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${booking.ticketNumber}',
                        style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusChip(status: booking.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  booking.trip != null
                      ? '${booking.trip!.route?.originCity} → ${booking.trip!.route?.destinationCity}'
                      : 'Trajet #${booking.tripId}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant),
                ),
                Text(
                  '${booking.totalPassengers} passager(s) • ${formatPrice(booking.totalPrice)}',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                // Action row — always show "Voir détail"
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.adminBookingDetail,
                            arguments: booking,
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 14),
                        label: Text('Détail',
                            style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 34),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (booking.status == AppConstants.statusPending) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<AdminProvider>().confirmBooking(booking.id!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Confirmer',
                              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showRejectDialog(context, booking.id!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Rejeter',
                              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── REJECT DIALOG ────────────────────────────────────────────────────────

void _showRejectDialog(BuildContext context, int bookingId) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Rejeter la réservation',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Veuillez indiquer la raison du rejet (optionnel):',
              style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Raison du rejet...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await context.read<AdminProvider>().rejectBooking(
              bookingId,
              reason: controller.text.trim(),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Réservation rejetée.' : 'Erreur.'),
                backgroundColor: ok ? AppColors.error : AppColors.onBackground,
              ));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text('Rejeter', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN REPORTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final stats = admin.stats;

    return Scaffold(
      appBar: const _AdminAppBar(title: 'Rapports & Statistiques'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vue d\'ensemble',
                style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _ReportCard(
                    'Total Réservations',
                    '${stats['total_bookings'] ?? 0}',
                    Icons.book_online_rounded,
                    AppColors.primary),
                _ReportCard(
                    'Revenus Total',
                    formatPrice((stats['total_revenue'] ?? 0).toDouble()),
                    Icons.payments_rounded,
                    AppColors.success),
                _ReportCard(
                    'Confirmées',
                    '${stats['confirmed_bookings'] ?? 0}',
                    Icons.check_circle_rounded,
                    AppColors.success),
                _ReportCard(
                    'En attente',
                    '${stats['pending_bookings'] ?? 0}',
                    Icons.pending_rounded,
                    AppColors.warning),
                _ReportCard(
                    'Rejetées',
                    '${stats['rejected_bookings'] ?? 0}',
                    Icons.cancel_rounded,
                    AppColors.error),
                _ReportCard(
                    'Utilisateurs',
                    '${stats['total_users'] ?? 0}',
                    Icons.people_rounded,
                    AppColors.secondary),
                _ReportCard(
                    'Voyages actifs',
                    '${stats['active_trips'] ?? 0}',
                    Icons.departure_board_rounded,
                    AppColors.tertiary),
              ],
            ),
            const SizedBox(height: 24),
            Text('Réservations récentes',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...admin.bookings.take(5).map((b) => Container(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${b.ticketNumber}',
                            style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        Text(
                          b.trip != null
                              ? '${b.trip!.route?.originCity} → ${b.trip!.route?.destinationCity}'
                              : '-',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(status: b.status),
                      const SizedBox(height: 2),
                      Text(
                        formatPrice(b.totalPrice),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: color.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  ContactInfoModel _contactInfo = ContactInfoModel.defaults();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    try {
      final info = await DatabaseHelper.instance.getContactInfo();
      setState(() { _contactInfo = info; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossible d'ouvrir ce lien.")),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Aide & Support',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comment pouvons-nous vous aider?',
                          style: GoogleFonts.manrope(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                        Text(
                          _contactInfo.helpMessage.isNotEmpty
                              ? _contactInfo.helpMessage
                              : 'Notre équipe est disponible 24h/24',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Contacter le support',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _SupportOption(
              icon: Icons.phone_rounded,
              label: 'Appeler le support',
              subtitle: _contactInfo.phone,
              color: AppColors.success,
              onTap: () => _launch('tel:${_contactInfo.phone}'),
            ),
            _SupportOption(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              subtitle: _contactInfo.whatsApp,
              color: const Color(0xFF25D366),
              onTap: () {
                final number = _contactInfo.whatsApp.replaceAll('+', '').replaceAll(' ', '');
                _launch('https://wa.me/$number');
              },
            ),
            _SupportOption(
              icon: Icons.email_rounded,
              label: 'Envoyer un email',
              subtitle: _contactInfo.email,
              color: AppColors.secondary,
              onTap: () => _launch('mailto:${_contactInfo.email}'),
            ),
            const SizedBox(height: 20),
            Text('Questions fréquentes',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...[
              'Comment annuler ma réservation?',
              'Comment obtenir un remboursement?',
              'Mon code OTP n\'arrive pas',
              'Comment modifier ma réservation?',
              'Que faire si le bus est annulé?',
            ]
                .map((q) => _FaqItem(question: q))
            ,
          ],
        ),
      ),
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.manrope(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  const _FaqItem({required this.question});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Contactez notre équipe de support pour obtenir de l\'aide avec cette question. Nous sommes disponibles 24h/24, 7j/7.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.manrope(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Utilisateur',
                    style: GoogleFonts.manrope(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    user?.phoneNumber ?? '',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                  if (user?.role == AppConstants.roleAdmin)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Administrateur',
                        style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _ProfileOption(
                icon: Icons.confirmation_number_rounded,
                label: 'Mes billets',
                onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets)),
            _ProfileOption(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () {}),
            _ProfileOption(
                icon: Icons.help_rounded,
                label: 'Aide & Support',
                onTap: () => Navigator.pushNamed(context, AppRoutes.support)),
            _ProfileOption(
                icon: Icons.privacy_tip_rounded,
                label: 'Politique de confidentialité',
                onTap: () {}),
            if (user?.role == AppConstants.roleAdmin)
              _ProfileOption(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Administration',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.adminDashboard)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.auth, (_) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Se déconnecter',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label,
            style:
            GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED ADMIN WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? action;

  const _AdminAppBar({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: Navigator.canPop(context)
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: action != null ? [action!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground),
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final ValueChanged<String?> onChanged;

  const _CityDropdown(
      {required this.value, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      decoration:
      const InputDecoration(prefixIcon: Icon(Icons.location_city_rounded)),
      items: AppConstants.chadCities
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField(
      {required this.value,
        required this.items,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

Future<bool?> _confirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Confirmer la suppression',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
      content: Text('Cette action est irréversible.',
          style: GoogleFonts.plusJakartaSans()),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text('Supprimer',
              style:
              GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}


// ═══════════════════════════════════════════════════════════════════════════
// ADMIN BOOKING DETAIL SCREEN (NEW)
// ═══════════════════════════════════════════════════════════════════════════

class AdminBookingDetailScreen extends StatelessWidget {
  const AdminBookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking =
    ModalRoute.of(context)!.settings.arguments as BookingModel?;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail réservation')),
        body: const Center(child: Text('Réservation introuvable')),
      );
    }

    final trip = booking.trip;
    final route = trip?.route;
    final payment = booking.payment;
    final passengers = booking.passengers ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Réservation ${booking.ticketNumber}',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.ticketNumber,
                            style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text(
                          route != null
                              ? '${route.originCity} → ${route.destinationCity}'
                              : 'Trajet #${booking.tripId}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: booking.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Booking Status Timeline ─────────────────────────────────
            _BookingStatusTimeline(status: booking.status),
            const SizedBox(height: 16),

            // ── Info cards ─────────────────────────────────────────────
            _InfoCard(title: 'Informations du voyage', children: [
              _InfoRow('Date de départ',
                  trip != null ? formatDate(trip.departureDate) : '-'),
              _InfoRow('Heure de départ', trip?.departureTime ?? '-'),
              _InfoRow('Bus', trip?.bus?.busNumber ?? '-'),
              _InfoRow('Sièges disponibles',
                  '${trip?.availableSeats ?? '-'}'),
            ]),
            const SizedBox(height: 12),
            _InfoCard(title: 'Informations de paiement', children: [
              _InfoRow('Montant total', formatPrice(booking.totalPrice)),
              _InfoRow('Méthode',
                  _paymentLabel(payment?.method ?? '')),
              _InfoRow('Statut paiement',
                  _paymentStatusLabel(booking.paymentStatus)),
              if (payment?.transactionReference != null)
                _InfoRow('Référence', payment!.transactionReference!),
            ]),
            if (passengers.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Passagers (${passengers.length})',
                children: passengers
                    .map((p) => _InfoRow(
                    'Siège ${p.seatNumber}', p.fullName))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),

            // ── Payment screenshot ──────────────────────────────────────
            if (booking.paymentScreenshot != null) ...[
              const SizedBox(height: 12),
              _InfoCard(title: 'Reçu de paiement téléversé', children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(booking.paymentScreenshot!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          alignment: Alignment.center,
                          child: Text('Image introuvable — fichier peut avoir été déplacé.',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: AppColors.onSurfaceVariant))),
                    ),
                  ),
                ),
              ]),
            ],
            if (booking.paymentScreenshot == null &&
                (booking.payment?.method == 'MOOV_MONEY' ||
                    booking.payment?.method == 'AIRTEL_MONEY') &&
                booking.status == AppConstants.statusPending)
              Container(
                  margin: const EdgeInsets.only(bottom: 12, top: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                        "Aucun reçu téléversé. Contactez l'utilisateur pour preuve de paiement.",
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: AppColors.warning))),
                  ])),

            // ── Action Buttons ──────────────────────────────────────────
            if (booking.status == AppConstants.statusPending) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await context
                      .read<AdminProvider>()
                      .confirmBooking(booking.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Réservation confirmée ✓'
                          : 'Erreur lors de la confirmation.'),
                      backgroundColor:
                      ok ? AppColors.success : AppColors.error,
                    ));
                    if (ok) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: Text('Confirmer la réservation',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 52)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _showRejectDialog(context, booking.id!),
                icon: const Icon(Icons.cancel_rounded),
                label: Text('Rejeter la réservation',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    minimumSize: const Size(double.infinity, 52)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'MOOV_MONEY':   return 'Moov Money';
      case 'AIRTEL_MONEY': return 'Airtel Money';
      case 'A_LA_GARE':   return 'À la gare';
      default:             return method;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'PAYE':      return 'Payé ✓';
      case 'EN_ATTENTE': return 'En attente';
      case 'ECHOUE':    return 'Échoué';
      case 'REMBOURSE': return 'Remboursé';
      default:          return status;
    }
  }
}

// ─── Booking Status Timeline Widget ──────────────────────────────────────────

class _BookingStatusTimeline extends StatelessWidget {
  final String status;
  const _BookingStatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep('Créée', AppConstants.statusPending, Icons.add_circle_rounded),
      _TimelineStep('Confirmée', AppConstants.statusConfirmed, Icons.check_circle_rounded),
      _TimelineStep('Complétée', AppConstants.statusCompleted, Icons.star_rounded),
    ];

    // For rejected/cancelled, show a different last step
    final isRejected = status == AppConstants.statusRejected;
    final isCancelled = status == AppConstants.statusCancelled;
    if (isRejected || isCancelled) {
      steps[2] = _TimelineStep(
        isRejected ? 'Rejetée' : 'Annulée',
        isRejected ? AppConstants.statusRejected : AppConstants.statusCancelled,
        isRejected ? Icons.cancel_rounded : Icons.block_rounded,
      );
    }

    int currentIdx;
    switch (status) {
      case AppConstants.statusPending:   currentIdx = 0; break;
      case AppConstants.statusConfirmed: currentIdx = 1; break;
      case AppConstants.statusCompleted: currentIdx = 2; break;
      case AppConstants.statusRejected:
      case AppConstants.statusCancelled: currentIdx = 2; break;
      default:                           currentIdx = 0;
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
          Text('Statut de la réservation',
              style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Connector line
                final stepIdx = i ~/ 2;
                final filled = stepIdx < currentIdx ||
                    (stepIdx == currentIdx - 1 && !isTerminalBad);
                return Expanded(
                  child: Container(
                    height: 2,
                    color: filled
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final step = steps[stepIdx];
              final isDone = stepIdx < currentIdx;
              final isCurrent = stepIdx == currentIdx;
              Color color;
              if (isCurrent && isTerminalBad) {
                color = AppColors.error;
              } else if (isDone || isCurrent) {
                color = AppColors.primary;
              } else {
                color = AppColors.outlineVariant;
              }

              return Column(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (isDone || isCurrent)
                          ? color.withOpacity(0.12)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: isCurrent ? 2.5 : 1.5,
                      ),
                    ),
                    child: Icon(step.icon, size: 18, color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(step.label,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? color : AppColors.onSurfaceVariant,
                      )),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final String status;
  final IconData icon;
  const _TimelineStep(this.label, this.status, this.icon);
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.end,
                style: GoogleFonts.manrope(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN PROMOTIONS SCREEN (NEW)
// ═══════════════════════════════════════════════════════════════════════════

class AdminPromotionsScreen extends StatelessWidget {
  const AdminPromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Promotions',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showPromoForm(context, null),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Nouvelle promo',
            style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: admin.promotions.isEmpty
          ? const EmptyStateWidget(
        icon: Icons.local_offer_rounded,
        title: 'Aucune promotion',
        subtitle: 'Créez des promotions pour vos utilisateurs.',
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: admin.promotions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final promo = admin.promotions[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: promo.isActive
                    ? AppColors.tertiary.withOpacity(0.3)
                    : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer_rounded,
                      color: AppColors.tertiary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(promo.title,
                                style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${promo.discountPercent.toStringAsFixed(0)}%',
                              style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(promo.description,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (promo.validUntil != null) ...[
                        const SizedBox(height: 4),
                        Text('Valide jusqu\'au ${promo.validUntil}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.warning)),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: promo.isActive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) {
                        admin.updatePromotion(promo.copyWith(isActive: v));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      onPressed: () => _showPromoForm(context, promo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          size: 18, color: AppColors.error),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Supprimer la promotion',
                                style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w700)),
                            content: Text('Supprimer "${promo.title}"?',
                                style: GoogleFonts.plusJakartaSans()),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Annuler')),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          admin.deletePromotion(promo.id!);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPromoForm(BuildContext context, PromotionModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PromoFormSheet(existing: existing),
    );
  }
}

class _PromoFormSheet extends StatefulWidget {
  final PromotionModel? existing;
  const _PromoFormSheet({this.existing});

  @override
  State<_PromoFormSheet> createState() => _PromoFormSheetState();
}

class _PromoFormSheetState extends State<_PromoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _discount;
  late final TextEditingController _until;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _title    = TextEditingController(text: p?.title ?? '');
    _desc     = TextEditingController(text: p?.description ?? '');
    _discount = TextEditingController(text: p?.discountPercent.toStringAsFixed(0) ?? '10');
    _until    = TextEditingController(text: p?.validUntil ?? '');
    _active   = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _title.dispose(); _desc.dispose();
    _discount.dispose(); _until.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.existing == null ? 'Nouvelle promotion' : 'Modifier la promotion',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Titre *'),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Titre requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _discount,
                        keyboardType: TextInputType.number,
                        decoration:
                        const InputDecoration(labelText: 'Réduction (%) *'),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 0 || n > 100) {
                            return '0-100%';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _until,
                        decoration:
                        const InputDecoration(labelText: 'Valide jusqu\'au (AAAA-MM-JJ)'),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              _until.text = picked.toIso8601String().split('T')[0];
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _active,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _active = v),
                  title: Text('Promotion active',
                      style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600)),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Enregistrement...' : 'Enregistrer',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final promo = PromotionModel(
      id: widget.existing?.id,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      discountPercent: double.tryParse(_discount.text) ?? 0,
      validUntil: _until.text.isNotEmpty ? _until.text : null,
      isActive: _active,
    );

    final admin = context.read<AdminProvider>();
    final ok = widget.existing == null
        ? await admin.addPromotion(promo)
        : await admin.updatePromotion(promo);

    setState(() => _saving = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Promotion enregistrée ✓' : 'Erreur.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN CONTACT SCREEN (NEW)
// ═══════════════════════════════════════════════════════════════════════════

class AdminContactScreen extends StatefulWidget {
  const AdminContactScreen({super.key});

  @override
  State<AdminContactScreen> createState() => _AdminContactScreenState();
}

class _AdminContactScreenState extends State<AdminContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _whatsapp;
  late TextEditingController _message;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final info = context.read<AdminProvider>().contactInfo;
    _phone    = TextEditingController(text: info.phone);
    _email    = TextEditingController(text: info.email);
    _whatsapp = TextEditingController(text: info.whatsApp);
    _message  = TextEditingController(text: info.helpMessage);
  }

  @override
  void dispose() {
    _phone.dispose(); _email.dispose();
    _whatsapp.dispose(); _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Informations de contact',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ces informations apparaîtront dans l\'écran "Contactez-nous" visible par tous les utilisateurs.',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Coordonnées',
                  style: GoogleFonts.manrope(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp (avec indicatif)',
                  prefixIcon: Icon(Icons.chat_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 24),
              Text('Message d\'accueil',
                  style: GoogleFonts.manrope(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _message,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message affiché dans l\'écran support',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  _saving ? 'Enregistrement...' : 'Sauvegarder',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final info = ContactInfoModel(
      phone:       _phone.text.trim(),
      email:       _email.text.trim(),
      whatsApp:    _whatsapp.text.trim(),
      helpMessage: _message.text.trim(),
    );

    final ok = await context.read<AdminProvider>().saveContactInfo(info);
    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Informations de contact mises à jour ✓'
            : 'Erreur lors de la sauvegarde.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
      if (ok) Navigator.pop(context);
    }
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// ADMIN PAYMENT ACCOUNTS SCREEN (NEW)
// ═══════════════════════════════════════════════════════════════════════════

class AdminPaymentAccountsScreen extends StatelessWidget {
  const AdminPaymentAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Comptes Mobile Money',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAccountForm(context, null),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Ajouter un compte',
            style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                  'Ces numéros seront affichés aux utilisateurs quand ils choisissent '
                      'Moov Money ou Airtel Money. Seul le compte actif est affiché.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.primary, height: 1.4))),
            ]),
          ),

          Expanded(
            child: admin.paymentAccounts.isEmpty
                ? EmptyStateWidget(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Aucun compte configuré',
              subtitle: 'Ajoutez vos numéros Moov Money et Airtel Money.',
            )
                : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: admin.paymentAccounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final a = admin.paymentAccounts[i];
                  final color = a.type == 'MOOV_MONEY'
                      ? AppColors.secondary
                      : AppColors.error;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: a.isActive
                              ? color.withOpacity(0.3)
                              : AppColors.outlineVariant),
                    ),
                    child: Row(children: [
                      Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.phone_android_rounded,
                              color: color, size: 24)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(a.displayType,
                                  style: GoogleFonts.manrope(
                                      fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              if (a.isActive)
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: AppColors.successContainer,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text('Actif',
                                        style: GoogleFonts.manrope(
                                            fontSize: 10, fontWeight: FontWeight.w700,
                                            color: AppColors.success))),
                            ]),
                            Text(a.accountNumber,
                                style: GoogleFonts.manrope(
                                    fontSize: 16, fontWeight: FontWeight.w800,
                                    color: color, letterSpacing: 0.5)),
                            Text(a.accountName,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant)),
                          ])),
                      Column(children: [
                        Switch(
                          value: a.isActive,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) =>
                              admin.updatePaymentAccount(a.copyWith(isActive: v)),
                        ),
                        IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () => _showAccountForm(context, a)),
                        IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                size: 18, color: AppColors.error),
                            onPressed: () async {
                              final ok = await showDialog<bool>(context: context,
                                  builder: (_) => AlertDialog(
                                      title: Text('Supprimer ce compte?',
                                          style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Annuler')),
                                        ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.error),
                                            child: const Text('Supprimer')),
                                      ]));
                              if (ok == true && context.mounted) {
                                admin.deletePaymentAccount(a.id!);
                              }
                            }),
                      ]),
                    ]),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _showAccountForm(BuildContext context, PaymentAccountModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentAccountFormSheet(existing: existing),
    );
  }
}

class _PaymentAccountFormSheet extends StatefulWidget {
  final PaymentAccountModel? existing;
  const _PaymentAccountFormSheet({this.existing});

  @override
  State<_PaymentAccountFormSheet> createState() => _PaymentAccountFormSheetState();
}

class _PaymentAccountFormSheetState extends State<_PaymentAccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _name;
  late TextEditingController _number;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _type   = a?.type ?? 'MOOV_MONEY';
    _name   = TextEditingController(text: a?.accountName ?? '');
    _number = TextEditingController(text: a?.accountNumber ?? '');
    _active = a?.isActive ?? true;
  }

  @override
  void dispose() { _name.dispose(); _number.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(widget.existing == null ? 'Ajouter un compte' : 'Modifier le compte',
                style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Text('Type de compte', style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: GestureDetector(
                  onTap: () => setState(() => _type = 'MOOV_MONEY'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _type == 'MOOV_MONEY'
                            ? AppColors.secondary.withOpacity(0.1)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _type == 'MOOV_MONEY'
                                ? AppColors.secondary
                                : AppColors.outlineVariant,
                            width: _type == 'MOOV_MONEY' ? 2 : 0.5)),
                    child: Text('Moov Money', textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _type == 'MOOV_MONEY'
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant)),
                  ))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                  onTap: () => setState(() => _type = 'AIRTEL_MONEY'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _type == 'AIRTEL_MONEY'
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _type == 'AIRTEL_MONEY'
                                ? AppColors.error
                                : AppColors.outlineVariant,
                            width: _type == 'AIRTEL_MONEY' ? 2 : 0.5)),
                    child: Text('Airtel Money', textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _type == 'AIRTEL_MONEY'
                                ? AppColors.error
                                : AppColors.onSurfaceVariant)),
                  ))),
            ]),
            const SizedBox(height: 14),
            TextFormField(
                controller: _number,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Numéro de compte *',
                    prefixIcon: Icon(Icons.phone_rounded),
                    hintText: '+235 66 XX XX XX'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Numéro requis' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'Nom du compte *',
                    prefixIcon: Icon(Icons.business_rounded),
                    hintText: 'ex: Assa Ticket SARL'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Nom requis' : null),
            const SizedBox(height: 12),
            SwitchListTile(
                value: _active, activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _active = v),
                title: Text('Compte actif',
                    style: GoogleFonts.manrope(
                        fontSize: 14, fontWeight: FontWeight.w600))),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Enregistrement...' : 'Enregistrer',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700))),
          ]),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final account = PaymentAccountModel(
        id: widget.existing?.id, type: _type,
        accountName: _name.text.trim(),
        accountNumber: _number.text.trim(), isActive: _active);
    final admin = context.read<AdminProvider>();
    final ok = widget.existing == null
        ? await admin.addPaymentAccount(account)
        : await admin.updatePaymentAccount(account);
    setState(() => _saving = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Compte enregistré ✓' : 'Erreur.'),
          backgroundColor: ok ? AppColors.success : AppColors.error));
    }
  }
}