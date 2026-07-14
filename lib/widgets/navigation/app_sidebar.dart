import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../common/confirmation_dialog.dart';
import 'app_logo.dart';
import 'nav_item_tile.dart';

class _NavEntry {
  const _NavEntry({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;
}

const List<_NavEntry> _navItems = <_NavEntry>[
  _NavEntry(icon: Icons.dashboard_outlined, label: AppStrings.navDashboard, route: AppRoutes.dashboard),
  _NavEntry(icon: Icons.people_outline, label: AppStrings.navEmployees, route: AppRoutes.employees),
  _NavEntry(icon: Icons.business_outlined, label: AppStrings.navClients, route: AppRoutes.clients),
  _NavEntry(icon: Icons.settings_outlined, label: AppStrings.navSettings, route: AppRoutes.settings),
  _NavEntry(icon: Icons.info_outline, label: AppStrings.navAbout, route: AppRoutes.about),
];

/// The primary navigation surface (Section 6 of the UI/UX spec).
///
/// Rendered as a permanent panel on desktop/tablet ([AppShell]) and as
/// the content of a [Drawer] on mobile. [expanded] controls whether
/// labels are shown next to icons (used for the collapsible tablet
/// rail). [onToggleCollapse], when provided, shows a collapse/expand
/// affordance at the bottom of the sidebar.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    this.expanded = true,
    this.onToggleCollapse,
  });

  final String currentRoute;
  final bool expanded;
  final VoidCallback? onToggleCollapse;

  bool _isSelected(String itemRoute) {
    if (itemRoute == AppRoutes.employees) {
      return currentRoute == AppRoutes.employees || currentRoute == AppRoutes.employeeDetails;
    }
    if (itemRoute == AppRoutes.clients) {
      return currentRoute == AppRoutes.clients || currentRoute == AppRoutes.clientDetails;
    }
    return currentRoute == itemRoute;
  }

  void _navigate(BuildContext context, String route) {
    if (_isSelected(route)) {
      // Already on this section - close the drawer on mobile, do nothing otherwise.
      if (Scaffold.of(context).isDrawerOpen) Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _logout(BuildContext context) async {
    final bool confirmed = await ConfirmationDialog.show(
      context,
      title: AppStrings.logoutConfirmTitle,
      message: AppStrings.logoutConfirmMessage,
      confirmLabel: AppStrings.logoutConfirmButton,
      isDanger: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final double width = expanded ? AppSpacing.sidebarWidthExpanded : AppSpacing.sidebarWidthCollapsed;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
              child: expanded ? const AppLogo() : const Center(child: AppLogo(showLabel: false)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
                children: [
                  for (final entry in _navItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: NavItemTile(
                        icon: entry.icon,
                        label: entry.label,
                        showLabel: expanded,
                        selected: _isSelected(entry.route),
                        onTap: () => _navigate(context, entry.route),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: NavItemTile(
                icon: Icons.logout,
                label: AppStrings.navLogout,
                showLabel: expanded,
                selected: false,
                isDanger: true,
                onTap: () => _logout(context),
              ),
            ),
            if (onToggleCollapse != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: IconButton(
                  onPressed: onToggleCollapse,
                  tooltip: expanded ? 'Collapse sidebar' : 'Expand sidebar',
                  icon: Icon(expanded ? Icons.chevron_left : Icons.chevron_right),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
