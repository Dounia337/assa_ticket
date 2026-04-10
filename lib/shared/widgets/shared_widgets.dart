import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AssaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  const AssaAppBar({super.key, required this.title, this.actions, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ) : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  const GradientButton({super.key, required this.label, this.icon, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: disabled
              ? const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)])
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                    Text(label, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}

class CityInputField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final String hint;
  const CityInputField({super.key, required this.label, required this.value, required this.icon, required this.onTap, required this.hint});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value != null ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: value != null ? AppColors.primary : AppColors.onSurfaceVariant, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant)),
                  Text(
                    value ?? hint,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: value != null ? FontWeight.w700 : FontWeight.w400,
                      color: value != null ? AppColors.onBackground : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; String label; IconData icon;
    switch (status.toUpperCase()) {
      case 'CONFIRME': case 'CONFIRMÉ': case 'ACTIF': case 'EXCELLENT': case 'ARRIVE': case 'ARRIVÉ':
        bg = AppColors.successContainer; fg = AppColors.success;
        label = (status == 'ACTIF') ? 'Actif' : (status.toUpperCase() == 'ARRIVE' || status.toUpperCase() == 'ARRIVÉ') ? 'Arrivé' : 'Confirmé';
        icon = Icons.check_circle_rounded; break;
      case 'EN_ATTENTE': case 'PROGRAMME': case 'PROGRAMMÉ':
        bg = AppColors.warningContainer; fg = AppColors.warning;
        label = (status.toUpperCase() == 'EN_ATTENTE') ? 'En attente' : 'Programmé';
        icon = Icons.pending_rounded; break;
      case 'ANNULE': case 'ANNULÉ': case 'INACTIF': case 'MAUVAIS':
        bg = AppColors.errorContainer; fg = AppColors.error;
        label = (status.toUpperCase() == 'INACTIF') ? 'Inactif' : 'Annulé';
        icon = Icons.cancel_rounded; break;
      case 'EN_MAINTENANCE':
        bg = AppColors.tertiaryContainer; fg = AppColors.tertiary;
        label = 'Maintenance'; icon = Icons.build_rounded; break;
      case 'PARTI':
        bg = AppColors.primaryFixed; fg = AppColors.primary;
        label = 'En route'; icon = Icons.directions_bus_rounded; break;
      default:
        bg = AppColors.surfaceContainerHigh; fg = AppColors.onSurfaceVariant;
        label = status; icon = Icons.info_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String message;
  const LoadingOverlay({super.key, required this.isLoading, required this.child, this.message = 'Chargement...'});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary), strokeWidth: 3),
                    const SizedBox(height: 16),
                    Text(message, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onBackground)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onBackground)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyStateWidget({super.key, required this.icon, required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(24)),
              child: Icon(icon, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onBackground), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final Color color;
  final double height;
  const DashedDivider({super.key, this.color = AppColors.outlineVariant, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const dashWidth = 8.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(count, (_) => Container(
            width: dashWidth, height: height,
            margin: const EdgeInsets.only(right: dashSpace),
            color: color,
          )),
        );
      },
    );
  }
}

String formatPrice(double amount) {
  final f = amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  return '$f FCFA';
}

String formatDate(DateTime date) {
  const months = ['janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatDateShort(DateTime date) {
  return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
}
