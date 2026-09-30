import 'package:dio/dio.dart';

import '../../models/enums.dart';
import '../../models/paginated.dart';
import '../../models/transaction.dart';
import '../interceptors/envelope_interceptor.dart';

List<Map<String, dynamic>> _objects(Object? data) =>
    (data as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

/// `GET|POST /api/visits*`.
///
/// `GET /sessions/property/:id` is public — the website shows availability to
/// signed-out visitors. Everything else requires a session.
class VisitsApi {
  const VisitsApi(this._dio);

  final Dio _dio;

  /// Public on purpose: an unsigned visitor can see when viewings are possible.
  Future<List<VisitSession>> sessionsForProperty(String propertyId) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/visits/sessions/property/$propertyId',
    );
    return _objects(res.data).map(VisitSession.fromJson).toList(growable: false);
  }

  /// Books a scheduled session.
  Future<VisitBooking> bookSession({
    required String visitSessionId,
    required int numberOfPeople,
    String? notes,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/visits/book',
      data: <String, dynamic>{
        'visitSessionId': visitSessionId,
        'numberOfPeople': numberOfPeople,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return VisitBooking.fromJson(res.data);
  }

  /// Books an any-time request. `preferredDate` and `startTime` are the only
  /// required fields on this path.
  Future<VisitBooking> bookAnyTime({
    required String propertyId,
    required DateTime preferredDate,
    required String startTime,
    required int numberOfPeople,
    String? notes,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/visits/book',
      data: <String, dynamic>{
        'propertyId': propertyId,
        'preferredDate': preferredDate.toIso8601String(),
        'startTime': startTime,
        'numberOfPeople': numberOfPeople,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return VisitBooking.fromJson(res.data);
  }

  Future<Paginated<VisitBooking>> myBookings({
    int page = 1,
    int pageSize = 20,
  }) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/visits/bookings/my',
      queryParameters: <String, dynamic>{'page': page, 'pageSize': pageSize},
    );
    return Paginated<VisitBooking>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      VisitBooking.fromJson,
    );
  }

  /// Idempotent server-side, so a double tap is safe.
  Future<VisitBooking> cancel(String bookingId) async {
    final Response<dynamic> res = await _dio.patch<Map<String, dynamic>>(
      '/visits/bookings/$bookingId/cancel',
    );
    return VisitBooking.fromJson(res.data);
  }
}

/// `GET|POST /api/enquiries*` — the user's own enquiries only.
///
/// `/inbox`, `/property/:id` and `/:id/status` are agent-side and deliberately
/// absent; `messagesApi` is likewise omitted pending decision Q2.
class EnquiriesApi {
  const EnquiriesApi(this._dio);

  final Dio _dio;

  Future<Paginated<Enquiry>> mine({int page = 1, int pageSize = 20}) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/enquiries',
      queryParameters: <String, dynamic>{'page': page, 'pageSize': pageSize},
    );
    return Paginated<Enquiry>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      Enquiry.fromJson,
    );
  }

  Future<Enquiry> create({
    required String propertyId,
    required String subject,
    required String message,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/enquiries',
      data: <String, dynamic>{
        'propertyId': propertyId,
        'subject': subject,
        'message': message,
      },
    );
    return Enquiry.fromJson(res.data);
  }
}

/// `GET|POST|PATCH /api/rental-applications*`.
class RentalApplicationsApi {
  const RentalApplicationsApi(this._dio);

  final Dio _dio;

  Future<Paginated<RentalApplication>> mine({
    int page = 1,
    int pageSize = 20,
  }) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/rental-applications/my',
      queryParameters: <String, dynamic>{'page': page, 'pageSize': pageSize},
    );
    return Paginated<RentalApplication>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      RentalApplication.fromJson,
    );
  }

  Future<RentalApplication> create({
    required String propertyId,
    required String fullName,
    required String phone,
    required String email,
    required String address,
    required int totalOccupants,
    required int numberOfChildren,
    required String occupation,
    required bool advanceAvailable,
    required DateTime moveInDate,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/rental-applications',
      data: <String, dynamic>{
        'propertyId': propertyId,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'address': address,
        'totalOccupants': totalOccupants,
        'numberOfChildren': numberOfChildren,
        'occupation': occupation,
        'advanceAvailable': advanceAvailable,
        'moveInDate': moveInDate.toIso8601String(),
      },
    );
    return RentalApplication.fromJson(res.data);
  }

  Future<RentalApplication> withdraw(String id) async {
    final Response<dynamic> res = await _dio.patch<Map<String, dynamic>>(
      '/rental-applications/$id',
      data: <String, dynamic>{'status': RentalApplicationStatus.withdrawn.apiValue},
    );
    return RentalApplication.fromJson(res.data);
  }
}

/// `GET|POST /api/payment-links/r/:token*`.
///
/// Both routes are `optionalAuth` and the website puts no guard on `/pay/:token`,
/// so the app does not either: a buyer can settle a link they were sent without
/// creating an account first.
class PaymentLinksApi {
  const PaymentLinksApi(this._dio);

  final Dio _dio;

  Future<PaymentLink> resolve(String token) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/payment-links/r/$token',
    );
    return PaymentLink.fromJson(res.data);
  }

  /// `provider` is one of `LUMICASH`, `ECOCASH`, `IHELA`; `payerPhone` is the
  /// bare 8-digit Burundi number.
  ///
  /// The API records a COMPLETED payment and marks the property SOLD
  /// (`apps/api/src/modules/paymentLinks/paymentLinks.service.ts`). No gateway is
  /// wired server-side, so the app presents this as "payment recorded", never
  /// as a bank confirmation.
  Future<PaymentResult> pay({
    required String token,
    required MobileMoneyProvider provider,
    required String payerPhone,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/payment-links/r/$token/pay',
      data: <String, dynamic>{
        'provider': provider.apiValue,
        'payerPhone': payerPhone,
      },
    );
    return PaymentResult.fromJson(res.data);
  }
}
