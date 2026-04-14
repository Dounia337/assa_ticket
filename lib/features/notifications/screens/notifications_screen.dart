import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/models.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || user.id == null || user.id == 0) {
      setState(() => _loading = false);
      return;
    }
    try {
      final notifs = await ApiService.instance.getUserNotifications(user.id!);
      setState(() => _notifications = notifs);
    } catch (e) {
      debugPrint('>>> Notif load error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user?.id == null || user!.id == 0) return;
    await ApiService.instance.markAllNotificationsRead(user.id!);
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  Future<void> _markRead(AppNotificationModel n) async {
    if (n.isRead || n.id == null) return;
    await ApiService.instance.markNotificationRead(n.id!);
    setState(() {
      _notifications = _notifications
          .map((item) => item.id == n.id ? item.copyWith(isRead: true) : item)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Tout lire',
                  style: GoogleFonts.manrope(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) =>
                        _NotifTile(notif: _notifications[i], onTap: _markRead),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Aucune notification',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Vos notifications apparaîtront ici.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotificationModel notif;
  final Future<void> Function(AppNotificationModel) onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(notif.type);
    return GestureDetector(
      onTap: () => onTap(notif),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surfaceContainerLowest : AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppColors.outlineVariant : AppColors.primary.withOpacity(0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: cfg.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(cfg.icon, color: cfg.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(notif.title,
                        style: GoogleFonts.manrope(fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700))),
                    if (!notif.isRead)
                      Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 4),
                  Text(notif.body,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(_fmt(notif.createdAt),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NC _config(String type) {
    switch (type) {
      case AppConstants.notifBookingConfirmed: return _NC(Icons.check_circle_rounded, AppColors.success);
      case AppConstants.notifPaymentConfirmed: return _NC(Icons.payment_rounded, AppColors.secondary);
      case AppConstants.notifBookingRejected:  return _NC(Icons.cancel_rounded, AppColors.error);
      case AppConstants.notifTripReminder:     return _NC(Icons.alarm_rounded, AppColors.warning);
      case AppConstants.notifTripDelay:        return _NC(Icons.warning_amber_rounded, AppColors.warning);
      case AppConstants.notifPromotion:        return _NC(Icons.local_offer_rounded, AppColors.tertiary);
      default: return _NC(Icons.notifications_rounded, AppColors.primary);
    }
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'A l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays}j';
  }
}

class _NC {
  final IconData icon;
  final Color color;
  const _NC(this.icon, this.color);
}
