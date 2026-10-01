import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/transaction.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';

final FutureProvider<Paginated<AppNotification>> notificationsProvider =
    FutureProvider<Paginated<AppNotification>>(
      (Ref ref) => ref.read(apiClientProvider).notifications.list(pageSize: 50),
    );

/// Notification centre.
///
/// The API stores notifications server-side, so this list is a view of them, not
/// a local preference store. There is no per-channel opt-in endpoint, so the
/// screen does not invent notification toggles - it lists what exists and lets
/// the user mark it read.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!ref.watch(authControllerProvider).isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settingsNotifications)),
        body: AppEmptyState(
          title: l10n.notificationsRequiresSignIn,
          message: l10n.youSignedOutBody,
          icon: Icons.notifications_none_rounded,
          actionLabel: l10n.authLogin,
          onAction: () => context.push('/auth/sign-in'),
        ),
      );
    }

    final AsyncValue<Paginated<AppNotification>> value = ref.watch(
      notificationsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsNotifications),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await ref.read(apiClientProvider).notifications.markAllRead();
              ref.invalidate(notificationsProvider);
            },
            child: Text(l10n.notificationsMarkAllRead),
          ),
        ],
      ),
      body: value.when(
        loading: () => const AppSkeletonList(),
        error: (Object error, _) => AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (Paginated<AppNotification> page) {
          if (page.items.isEmpty) {
            return AppEmptyState(
              title: l10n.notificationsEmpty,
              icon: Icons.notifications_none_rounded,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              padding: AppSpacing.page,
              itemCount: page.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int i) =>
                  _NotificationTile(notification: page.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);

    return Material(
      color: notification.isRead ? Colors.transparent : p.field,
      borderRadius: AppRadii.brMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          unawaited(
            ref.read(apiClientProvider).notifications.markRead(notification.id),
          );
          ref.invalidate(notificationsProvider);
          final String? propertyId = notification.propertyId;
          if (propertyId != null && propertyId.isNotEmpty) {
            context.push('/property/$propertyId');
          }
        },
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                    if (notification.message.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        notification.message,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      f.elapsed(notification.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: p.textTertiary),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, left: AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
