import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../settings/data/preferences_controller.dart';

/// Bottom navigation shell.
///
/// An indexed stack of the four tabs, so switching tabs preserves each tab's
/// scroll position and in-flight filters — the behaviour people expect from a
/// tab bar, and the reason `StatefulShellRoute` is used rather than plain
/// top-level routes.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = AppPalette.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    final List<_Tab> tabs = <_Tab>[
      _Tab(l10n.navHome, Icons.home_outlined, Icons.home_rounded),
      _Tab(l10n.navExplore, Icons.explore_outlined, Icons.explore_rounded),
      _Tab(
        l10n.homeSaved,
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
      ),
      _Tab(
        l10n.dashboardProfile,
        Icons.person_outline_rounded,
        Icons.person_rounded,
      ),
    ];

    final int index = shell.currentIndex;

    return Scaffold(
      body: Column(
        children: <Widget>[
          const OfflineBanner(),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60 + MediaQuery.paddingOf(context).bottom,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      tab: tabs[i],
                      selected: i == index,
                      onTap: () {
                        // Re-tapping the active tab pops it back to its root,
                        // which is what Android users expect.
                        shell.goBranch(i, initialLocation: i == index);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppColors.brand
        : AppPalette.of(context).textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(selected ? tab.activeIcon : tab.icon, size: 24, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              tab.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Persistent banner shown when the device has no network path.
///
/// Deliberately not blocking: cached first pages still render, and every screen
/// carries its own retry.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool offline = ref.watch(isOfflineProvider).valueOrNull ?? false;
    if (!offline) return const SizedBox.shrink();

    final AppPalette p = AppPalette.of(context);
    return Material(
      color: p.field,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.cloud_off_rounded, size: 16, color: p.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).offlineBanner,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
