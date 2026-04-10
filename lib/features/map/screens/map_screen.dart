import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ROUTE MAP SCREEN
// How a user lands here:
//   1. Home screen → "Visualiser le trajet" banner (cities pre-filled if searched)
//   2. Trip Details screen → "Voir le trajet sur la carte" button (auto pre-filled)
//   3. Map icon in any top-bar
//
// What the user sees:
//   • All Chad cities plotted on a geographic canvas
//   • Blue pulsing dot = their GPS position (nearest city highlighted)
//   • Red marker  = departure city
//   • Purple marker = destination city
//   • Animated white route line drawn between them
//   • Distance card + estimated travel time
// ═══════════════════════════════════════════════════════════════════════════

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen>
    with TickerProviderStateMixin {

  String? _origin;
  String? _destination;
  String? _userCity;       // nearest city to GPS location
  bool _detectingGPS = false;
  bool _gpsAttempted = false;

  // Animation for the route line drawing
  late AnimationController _routeCtrl;
  late Animation<double> _routeAnim;

  // Animation for the GPS pulsing dot
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _routeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _routeAnim = CurvedAnimation(parent: _routeCtrl, curve: Curves.easeInOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Read route args passed from the calling screen, then auto-detect GPS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final o = args['origin']?.toString() ?? '';
        final d = args['destination']?.toString() ?? '';
        setState(() {
          _origin      = o.isNotEmpty ? o : null;
          _destination = d.isNotEmpty ? d : null;
        });
        if (_origin != null && _destination != null) _playRouteAnim();
      }
      // Always try GPS silently on open
      _detectGPS(silent: true);
    });
  }

  @override
  void dispose() {
    _routeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _playRouteAnim() => _routeCtrl.forward(from: 0);

  // ── GPS Detection ────────────────────────────────────────────────────────

  Future<void> _detectGPS({bool silent = false}) async {
    if (_detectingGPS) return;
    setState(() { _detectingGPS = true; });

    final city = await LocationService.instance.detectNearestCity();

    setState(() {
      _detectingGPS = false;
      _gpsAttempted = true;
      _userCity = city;
      // If no origin set yet, auto-fill with detected city
      if (city != null && _origin == null) _origin = city;
    });

    if (city == null && !silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position non disponible. Activez la localisation.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (_origin != null && _destination != null) _playRouteAnim();
  }

  // ── City Picker ──────────────────────────────────────────────────────────

  Future<void> _pickCity(bool isOrigin) async {
    final city = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        title: isOrigin ? 'Ville de départ' : 'Ville d\'arrivée',
        excludeCity: isOrigin ? _destination : _origin,
        userCity: _userCity,
      ),
    );
    if (city != null && mounted) {
      setState(() {
        if (isOrigin) {
          _origin = city;
        } else {
          _destination = city;
        }
      });
      if (_origin != null && _destination != null) _playRouteAnim();
    }
  }

  void _swapCities() {
    if (_origin == null && _destination == null) return;
    setState(() {
      final tmp = _origin;
      _origin = _destination;
      _destination = tmp;
    });
    if (_origin != null && _destination != null) _playRouteAnim();
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasRoute = _origin != null && _destination != null;
    final distKm   = hasRoute ? AppConstants.distanceBetween(_origin!, _destination!) : 0.0;
    final hours    = hasRoute ? AppConstants.estimatedHours(_origin!, _destination!) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Carte du trajet',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // GPS button — tap to re-detect location
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: 'Détecter ma position',
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => IconButton(
                  icon: _detectingGPS
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                      : Icon(
                    Icons.my_location_rounded,
                    color: _userCity != null
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                  onPressed: _detectingGPS ? null : () => _detectGPS(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [

          // ── 1. GPS status banner ──────────────────────────────────────────
          if (_userCity != null)
            Container(
              width: double.infinity,
              color: AppColors.success.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success
                            .withOpacity(_pulseAnim.value),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.4),
                            blurRadius: 6 * _pulseAnim.value,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Votre position : $_userCity',
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success),
                  ),
                ],
              ),
            ),

          // ── 2. City selector row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Origin chip
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickCity(true),
                    child: _CityChip(
                      label: _origin ?? 'Départ',
                      icon: Icons.trip_origin_rounded,
                      color: AppColors.primary,
                      filled: _origin != null,
                      isGPS: _origin != null && _origin == _userCity,
                    ),
                  ),
                ),
                // Swap button
                GestureDetector(
                  onTap: _swapCities,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: hasRoute
                          ? AppColors.primaryFixed
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 18,
                      color: hasRoute
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                // Destination chip
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickCity(false),
                    child: _CityChip(
                      label: _destination ?? 'Arrivée',
                      icon: Icons.location_on_rounded,
                      color: AppColors.secondary,
                      filled: _destination != null,
                      isGPS: false,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 3. Distance + time stats card ────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: hasRoute
                ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                      icon: Icons.straighten_rounded,
                      label: 'Distance',
                      value: '${distKm.toStringAsFixed(0)} km',
                    ),
                    Container(
                        width: 1, height: 40,
                        color: Colors.white24),
                    _StatBadge(
                      icon: Icons.access_time_rounded,
                      label: 'Temps estimé',
                      value: AppConstants.formatDuration(hours),
                      highlight: true,
                    ),
                    Container(
                        width: 1, height: 40,
                        color: Colors.white24),
                    _StatBadge(
                      icon: Icons.speed_rounded,
                      label: 'Vitesse moy.',
                      value: '${AppConstants.avgBusSpeedKmh.toStringAsFixed(0)} km/h',
                    ),
                  ],
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),

          // ── 4. Map canvas ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [

                      // Subtle grid background
                      CustomPaint(
                        painter: _GridPainter(),
                        child: Container(),
                      ),

                      // Cities + route + GPS dot
                      AnimatedBuilder(
                        animation: Listenable.merge([_routeAnim, _pulseAnim]),
                        builder: (ctx, _) => CustomPaint(
                          painter: _ChadMapPainter(
                            origin:      _origin,
                            destination: _destination,
                            userCity:    _userCity,
                            routeProgress: _routeAnim.value,
                            pulseValue:    _pulseAnim.value,
                          ),
                          child: Container(),
                        ),
                      ),

                      // Legend overlay (bottom-left)
                      Positioned(
                        left: 12, bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.93),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.outlineVariant, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LegendDot(
                                  color: AppColors.primary,
                                  label: 'Départ'),
                              const SizedBox(height: 5),
                              _LegendDot(
                                  color: AppColors.secondary,
                                  label: 'Arrivée'),
                              const SizedBox(height: 5),
                              _LegendDot(
                                  color: AppColors.success,
                                  label: 'Votre position'),
                              const SizedBox(height: 5),
                              _LegendDot(
                                  color: AppColors.onSurfaceVariant
                                      .withOpacity(0.5),
                                  label: 'Villes'),
                            ],
                          ),
                        ),
                      ),

                      // "TCHAD" badge (top-right)
                      Positioned(
                        right: 12, top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('🇹🇩 Tchad',
                              style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),

                      // Empty-state instruction (no cities selected)
                      if (!hasRoute)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.outlineVariant),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app_rounded,
                                    color: AppColors.primary, size: 32),
                                const SizedBox(height: 8),
                                Text('Sélectionnez départ et arrivée',
                                    style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Text(
                                  'Le trajet et la distance\napparaîtront ici.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 5. Footer note ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 13, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasRoute
                        ? 'Temps estimé basé sur ${AppConstants.avgBusSpeedKmh.toStringAsFixed(0)} km/h '
                        '(conditions routières du Tchad). '
                        'Appuyez sur 📍 pour détecter votre position.'
                        : 'Appuyez sur 📍 en haut à droite pour détecter votre ville automatiquement.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHAD MAP PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _ChadMapPainter extends CustomPainter {
  final String? origin;
  final String? destination;
  final String? userCity;
  final double  routeProgress;
  final double  pulseValue;

  _ChadMapPainter({
    this.origin,
    this.destination,
    this.userCity,
    required this.routeProgress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {

    // ── Draw all city dots ──────────────────────────────────────────────────
    for (final city in AppConstants.chadCities) {
      final pos       = LocationService.cityToCanvas(city, size);
      final isOrigin  = city == origin;
      final isDest    = city == destination;
      final isUser    = city == userCity;
      final isSpecial = isOrigin || isDest || isUser;

      // Glow ring for special cities
      if (isSpecial) {
        final glowColor = isOrigin
            ? AppColors.primary
            : isDest
            ? AppColors.secondary
            : AppColors.success;
        canvas.drawCircle(
          pos,
          14 * pulseValue,
          Paint()
            ..color = glowColor.withOpacity(0.15 * pulseValue)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pos,
          9,
          Paint()
            ..color = glowColor.withOpacity(0.25)
            ..style = PaintingStyle.fill,
        );
      }

      // Main city dot
      final dotColor = isOrigin
          ? AppColors.primary
          : isDest
          ? AppColors.secondary
          : isUser
          ? AppColors.success
          : AppColors.onSurfaceVariant.withOpacity(0.35);

      canvas.drawCircle(
        pos,
        isSpecial ? 6.5 : 3.5,
        Paint()..color = dotColor..style = PaintingStyle.fill,
      );

      // White border for special dots
      if (isSpecial) {
        canvas.drawCircle(
          pos,
          6.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // City label
      final isBig = isSpecial;
      final tp = TextPainter(
        text: TextSpan(
          text: city,
          style: TextStyle(
            fontSize: isBig ? 11.5 : 9,
            fontWeight: isBig ? FontWeight.w700 : FontWeight.w400,
            color: isOrigin
                ? AppColors.primary
                : isDest
                ? AppColors.secondary
                : isUser
                ? AppColors.success
                : AppColors.onSurfaceVariant.withOpacity(0.55),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);

      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy + 8),
      );
    }

    // ── Draw route line ─────────────────────────────────────────────────────
    if (origin != null && destination != null) {
      final oPos = LocationService.cityToCanvas(origin!, size);
      final dPos = LocationService.cityToCanvas(destination!, size);

      // Dashed ghost line (full distance)
      _drawDashedLine(
        canvas, oPos, dPos,
        Paint()
          ..color = AppColors.primary.withOpacity(0.18)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );

      // Solid animated line (grows from origin toward destination)
      final animEnd = Offset(
        oPos.dx + (dPos.dx - oPos.dx) * routeProgress,
        oPos.dy + (dPos.dy - oPos.dy) * routeProgress,
      );
      canvas.drawLine(
        oPos, animEnd,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2.8
          ..style  = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Moving bus dot along the route
      if (routeProgress > 0.05) {
        final t       = (routeProgress * 0.75).clamp(0.0, 1.0);
        final busPos  = Offset(
          oPos.dx + (dPos.dx - oPos.dx) * t,
          oPos.dy + (dPos.dy - oPos.dy) * t,
        );
        // Shadow
        canvas.drawCircle(busPos, 10,
            Paint()..color = Colors.black.withOpacity(0.12));
        // Background circle
        canvas.drawCircle(busPos, 9, Paint()..color = AppColors.primary);
        // Bus icon (simplified rectangle)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: busPos, width: 11, height: 7),
            const Radius.circular(2),
          ),
          Paint()..color = Colors.white,
        );
        // Wheels
        for (final dx in [-3.5, 3.5]) {
          canvas.drawCircle(
            Offset(busPos.dx + dx, busPos.dy + 3.5),
            1.5,
            Paint()..color = AppColors.primary,
          );
        }
      }

      // Destination flag marker
      if (routeProgress >= 0.99) {
        _drawFlag(canvas, dPos, AppColors.secondary);
      }
    }

    // ── User GPS location marker ─────────────────────────────────────────
    if (userCity != null) {
      final pos = LocationService.cityToCanvas(userCity!, size);
      // Outer pulse ring
      canvas.drawCircle(
        pos,
        14 * pulseValue,
        Paint()
          ..color = AppColors.success.withOpacity(0.15 * pulseValue)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawFlag(Canvas canvas, Offset pos, Color color) {
    final flagPole = Path()
      ..moveTo(pos.dx, pos.dy - 6)
      ..lineTo(pos.dx, pos.dy - 22);
    canvas.drawPath(
      flagPole,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    final flag = Path()
      ..moveTo(pos.dx, pos.dy - 22)
      ..lineTo(pos.dx + 12, pos.dy - 18)
      ..lineTo(pos.dx, pos.dy - 14)
      ..close();
    canvas.drawPath(flag, Paint()..color = color);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dash = 5.0, gap = 4.0;
    final total = (p2 - p1).distance;
    final dir   = (p2 - p1) / total;
    double walked = 0;
    bool drawing = true;
    while (walked < total) {
      final step = drawing ? dash : gap;
      final end  = (walked + step).clamp(0.0, total);
      if (drawing) {
        canvas.drawLine(p1 + dir * walked, p1 + dir * end, paint);
      }
      walked = end;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_ChadMapPainter old) =>
      old.origin        != origin        ||
          old.destination   != destination   ||
          old.userCity      != userCity      ||
          old.routeProgress != routeProgress ||
          old.pulseValue    != pulseValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// GRID PAINTER (background)
// ═══════════════════════════════════════════════════════════════════════════

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width;  x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _CityChip extends StatelessWidget {
  final String  label;
  final IconData icon;
  final Color   color;
  final bool    filled;
  final bool    isGPS;
  const _CityChip({
    required this.label, required this.icon, required this.color,
    required this.filled, required this.isGPS,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color:  filled ? color.withOpacity(0.08) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled ? color.withOpacity(0.4) : AppColors.outlineVariant,
          width: filled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGPS ? Icons.my_location_rounded : icon,
            size: 15,
            color: filled ? color : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
                color: filled ? color : AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.expand_more_rounded,
              size: 15,
              color: filled ? color : AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     highlight;
  const _StatBadge({
    required this.icon, required this.label, required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: highlight ? 16 : 13,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 9, color: Colors.white60)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color  color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 9, height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5, color: AppColors.onBackground)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CITY PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _CityPickerSheet extends StatefulWidget {
  final String  title;
  final String? excludeCity;
  final String? userCity;
  const _CityPickerSheet({
    required this.title,
    this.excludeCity,
    this.userCity,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final cities = AppConstants.chadCities
        .where((c) => c != widget.excludeCity)
        .where((c) => c.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Text(widget.title,
                    style: GoogleFonts.manrope(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher une ville...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: cities.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 56),
              itemBuilder: (ctx, i) {
                final city   = cities[i];
                final coords = AppConstants.cityCoordinates[city];
                final isUser = city == widget.userCity;

                return ListTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isUser
                          ? Icons.my_location_rounded
                          : Icons.location_city_rounded,
                      size: 18,
                      color: isUser ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(city,
                          style: GoogleFonts.manrope(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Votre position',
                            style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: coords != null
                      ? Text(
                    '${coords[0].toStringAsFixed(2)}°N  '
                        '${coords[1].toStringAsFixed(2)}°E',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant),
                  )
                      : null,
                  onTap: () => Navigator.pop(context, city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}