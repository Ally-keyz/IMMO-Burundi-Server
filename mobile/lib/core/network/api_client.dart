import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_provider.dart';
import 'endpoints/auth_api.dart';
import 'endpoints/directory_api.dart';
import 'endpoints/properties_api.dart';
import 'endpoints/transaction_api.dart';

/// The single place the endpoint namespaces are created.
///
/// Namespace names match `apps/web/src/lib/api.ts` exactly, so the mapping from
/// the website to the app is a name-for-name comparison rather than an
/// interpretation.
class ApiClient {
  const ApiClient({
    required this.auth,
    required this.properties,
    required this.favorites,
    required this.agents,
    required this.geo,
    required this.users,
    required this.notifications,
    required this.reports,
    required this.files,
    required this.visits,
    required this.enquiries,
    required this.rentalApplications,
    required this.paymentLinks,
  });

  final AuthApi auth;
  final PropertiesApi properties;
  final FavoritesApi favorites;
  final AgentsApi agents;
  final GeoApi geo;
  final UsersApi users;
  final NotificationsApi notifications;
  final ReportsApi reports;
  final FilesApi files;
  final VisitsApi visits;
  final EnquiriesApi enquiries;
  final RentalApplicationsApi rentalApplications;
  final PaymentLinksApi paymentLinks;
}

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return ApiClient(
    auth: AuthApi(dio),
    properties: PropertiesApi(dio),
    favorites: FavoritesApi(dio),
    agents: AgentsApi(dio),
    geo: GeoApi(dio),
    users: UsersApi(dio),
    notifications: NotificationsApi(dio),
    reports: ReportsApi(dio),
    files: FilesApi(dio),
    visits: VisitsApi(dio),
    enquiries: EnquiriesApi(dio),
    rentalApplications: RentalApplicationsApi(dio),
    paymentLinks: PaymentLinksApi(dio),
  );
});
