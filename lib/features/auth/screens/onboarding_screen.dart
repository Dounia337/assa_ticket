import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.search_rounded,
      iconBg: AppColors.primaryFixed,
      iconColor: AppColors.primary,
      badge: 'Temps réel',
      badgeIcon: Icons.bolt,
      title: 'Recherchez votre\ntrajet facilement',
      subtitle:
          'Trouvez instantanément tous les trajets disponibles entre vos villes avec les meilleurs prix.',
      illustration: _IllustrationType.search,
    ),
    _OnboardingData(
      icon: Icons.event_seat_rounded,
      iconBg: AppColors.secondaryFixed,
      iconColor: AppColors.secondary,
      badge: 'Validation en 2s',
      badgeIcon: Icons.speed,
      title: 'Réservez en\nquelques clics',
      subtitle:
          'Sélectionnez vos sièges, ajoutez vos bagages et payez en toute sécurité en moins de 2 minutes.',
      illustration: _IllustrationType.booking,
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      iconBg: const Color(0xFFFFEDD5),
      iconColor: AppColors.warning,
      badge: 'WhatsApp intégré',
      badgeIcon: Icons.chat_bubble,
      title: 'Recevez votre\nbillet digitalement',
      subtitle:
          'Votre e-ticket est envoyé sur WhatsApp et disponible hors ligne. Voyagez sans papier!',
      illustration: _IllustrationType.whatsapp,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsOnboarded, true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.confirmation_number_outlined,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Passer',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (ctx, i) =>
                    _OnboardingPage(data: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GradientButton(
                          label: _currentPage == _pages.length - 1
                              ? 'Commencer'
                              : 'Suivant',
                          icon: _currentPage == _pages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              _finish();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
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
    );
  }
}

enum _IllustrationType { search, booking, whatsapp }

class _OnboardingData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String badge;
  final IconData badgeIcon;
  final String title;
  final String subtitle;
  final _IllustrationType illustration;

  const _OnboardingData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badge,
    required this.badgeIcon,
    required this.title,
    required this.subtitle,
    required this.illustration,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: _buildIllustration(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.badgeIcon, size: 14, color: data.iconColor),
                const SizedBox(width: 6),
                Text(
                  data.badge,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: data.iconColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    switch (data.illustration) {
      case _IllustrationType.search:
        return _SearchIllustration();
      case _IllustrationType.booking:
        return _BookingIllustration();
      case _IllustrationType.whatsapp:
        return _WhatsappIllustration();
    }
  }
}

class _SearchIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryFixed, AppColors.secondaryFixed],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40,
            left: 30,
            child: _FloatingCard(
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text("N'Djamena",
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 30,
            child: _FloatingCard(
              child: Row(
                children: [
                  const Icon(Icons.near_me, color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text('Moundou',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
          const Icon(Icons.directions_bus_rounded,
              size: 80, color: AppColors.primary),
          Positioned(
            bottom: 50,
            child: _FloatingCard(
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.warning, size: 16),
                  const SizedBox(width: 6),
                  Text('8 trajets disponibles',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.onBackground)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sélection des Sièges',
            style: GoogleFonts.manrope(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.onBackground),
          ),
          const SizedBox(height: 20),
          _buildSeatGrid(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SeatLegend(color: AppColors.surfaceContainerHigh, label: 'Libre'),
              const SizedBox(width: 12),
              _SeatLegend(color: AppColors.primary, label: 'Choisi'),
              const SizedBox(width: 12),
              _SeatLegend(color: AppColors.errorContainer, label: 'Occupé'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    final occupied = [2, 5, 8, 11];
    final chosen = [7, 12];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(16, (i) {
        final seat = i + 1;
        Color color;
        if (chosen.contains(seat)) {
          color = AppColors.primary;
        } else if (occupied.contains(seat)) {
          color = AppColors.errorContainer;
        } else {
          color = AppColors.surfaceContainerHigh;
        }
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$seat',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: chosen.contains(seat) ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _SeatLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _WhatsappIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF075E54),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF128C7E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text('Assa Ticket Official',
                      style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF8C6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Votre billet de voyage:',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.confirmation_number_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("N'Djamena → Moundou",
                                  style: GoogleFonts.manrope(
                                      fontSize: 11, fontWeight: FontWeight.w700)),
                              Text('AS-99284-NDJ',
                                  style: GoogleFonts.manrope(
                                      fontSize: 10, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _FloatingCard extends StatelessWidget {
  final Widget child;

  const _FloatingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
