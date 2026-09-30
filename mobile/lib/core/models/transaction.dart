import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'json.dart';
import 'property.dart';

/// A scheduled viewing window — `GET /api/visits/sessions/property/:propertyId`.
///
/// Public: no authentication, because the website shows these on the property
/// page to signed-out visitors.
@immutable
class VisitSession {
  const VisitSession({
    required this.id,
    this.propertyId = '',
    this.date,
    this.startTime = '',
    this.endTime = '',
    this.capacity = 0,
    this.bookedCount = 0,
    this.bookingDeadline,
    this.status = 'SCHEDULED',
    this.timezone = 'Africa/Bujumbura',
  });

  factory VisitSession.fromJson(Object? json) => VisitSession(
    id: idOf(json) ?? '',
    propertyId: asString(json is Map ? json['propertyId'] : null),
    date: asDate(json is Map ? json['date'] : null),
    startTime: asString(json is Map ? json['startTime'] : null),
    endTime: asString(json is Map ? json['endTime'] : null),
    capacity: asInt(json is Map ? json['capacity'] : null) ?? 0,
    bookedCount: asInt(json is Map ? json['bookedCount'] : null) ?? 0,
    bookingDeadline: asDate(json is Map ? json['bookingDeadline'] : null),
    status: asString(json is Map ? json['status'] : null, 'SCHEDULED'),
    timezone: asString(
      json is Map ? json['timezone'] : null,
      'Africa/Bujumbura',
    ),
  );

  final String id;
  final String propertyId;
  final DateTime? date;
  final String startTime;
  final String endTime;
  final int capacity;
  final int bookedCount;
  final DateTime? bookingDeadline;
  final String status;
  final String timezone;

  int get capacityRemaining => (capacity - bookedCount).clamp(0, capacity);

  bool get isFull => capacityRemaining <= 0;

  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  /// Past the booking deadline, or the session day itself has gone.
  bool isClosedAt([DateTime? now]) {
    final DateTime at = now ?? DateTime.now();
    if (isCancelled || isFull) return true;
    final DateTime? deadline = bookingDeadline;
    if (deadline != null && at.isAfter(deadline)) return true;
    final DateTime? day = date;
    if (day != null && at.isAfter(day)) return true;
    return false;
  }
}

/// A confirmed or pending visit — `GET /api/visits/bookings/my`.
@immutable
class VisitBooking {
  const VisitBooking({
    required this.id,
    this.visitSessionId,
    this.propertyId = '',
    this.property,
    this.preferredDate,
    this.startTime = '',
    this.bookingReference = '',
    this.numberOfPeople = 1,
    this.notes,
    this.status = VisitBookingStatus.pending,
    this.confirmedAt,
    this.cancelledAt,
    this.createdAt,
  });

  factory VisitBooking.fromJson(Object? json) => VisitBooking(
    id: idOf(json) ?? '',
    visitSessionId: asStringOrNull(json is Map ? json['visitSessionId'] : null),
    propertyId: asString(json is Map ? json['propertyId'] : null),
    property: asMap(child(json, 'property')) == null
        ? null
        : PropertySummary.fromJson(child(json, 'property')),
    preferredDate: asStringOrNull(json is Map ? json['preferredDate'] : null),
    startTime: asString(json is Map ? json['startTime'] : null),
    bookingReference: asString(json is Map ? json['bookingReference'] : null),
    numberOfPeople: asInt(json is Map ? json['numberOfPeople'] : null) ?? 1,
    notes: asStringOrNull(json is Map ? json['notes'] : null),
    status: VisitBookingStatus.parse(
      asStringOrNull(json is Map ? json['status'] : null),
    ),
    confirmedAt: asDate(json is Map ? json['confirmedAt'] : null),
    cancelledAt: asDate(json is Map ? json['cancelledAt'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
  );

  final String id;
  final String? visitSessionId;
  final String propertyId;
  final PropertySummary? property;
  final String? preferredDate;
  final String startTime;
  final String bookingReference;
  final int numberOfPeople;
  final String? notes;
  final VisitBookingStatus status;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;

  bool get canCancel =>
      status == VisitBookingStatus.pending || status == VisitBookingStatus.confirmed;
}

/// `POST /api/enquiries`.
@immutable
class Enquiry {
  const Enquiry({
    required this.id,
    this.propertyId = '',
    this.property,
    this.subject = '',
    this.message = '',
    this.status = EnquiryStatus.open,
    this.response,
    this.respondedAt,
    this.createdAt,
  });

  factory Enquiry.fromJson(Object? json) => Enquiry(
    id: idOf(json) ?? '',
    propertyId: asString(json is Map ? json['propertyId'] : null),
    property: asMap(child(json, 'property')) == null
        ? null
        : PropertySummary.fromJson(child(json, 'property')),
    subject: asString(json is Map ? json['subject'] : null),
    message: asString(json is Map ? json['message'] : null),
    status: EnquiryStatus.parse(asStringOrNull(json is Map ? json['status'] : null)),
    response: asStringOrNull(json is Map ? json['response'] : null),
    respondedAt: asDate(json is Map ? json['respondedAt'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
  );

  final String id;
  final String propertyId;
  final PropertySummary? property;
  final String subject;
  final String message;
  final EnquiryStatus status;
  final String? response;
  final DateTime? respondedAt;
  final DateTime? createdAt;
}

/// `POST /api/rental-applications` and `GET /api/rental-applications/my`.
@immutable
class RentalApplication {
  const RentalApplication({
    required this.id,
    this.propertyId = '',
    this.property,
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.totalOccupants = 1,
    this.numberOfChildren = 0,
    this.occupation = '',
    this.advanceAvailable = false,
    this.moveInDate,
    this.status = RentalApplicationStatus.submitted,
    this.reviewNotes,
    this.createdAt,
  });

  factory RentalApplication.fromJson(Object? json) => RentalApplication(
    id: idOf(json) ?? '',
    propertyId: asString(json is Map ? json['propertyId'] : null),
    property: asMap(child(json, 'property')) == null
        ? null
        : PropertySummary.fromJson(child(json, 'property')),
    fullName: asString(json is Map ? json['fullName'] : null),
    phone: asString(json is Map ? json['phone'] : null),
    email: asString(json is Map ? json['email'] : null),
    address: asString(json is Map ? json['address'] : null),
    totalOccupants: asInt(json is Map ? json['totalOccupants'] : null) ?? 1,
    numberOfChildren: asInt(json is Map ? json['numberOfChildren'] : null) ?? 0,
    occupation: asString(json is Map ? json['occupation'] : null),
    advanceAvailable: asBool(json is Map ? json['advanceAvailable'] : null),
    moveInDate: asDate(json is Map ? json['moveInDate'] : null),
    status: RentalApplicationStatus.parse(
      asStringOrNull(json is Map ? json['status'] : null),
    ),
    reviewNotes: asStringOrNull(json is Map ? json['reviewNotes'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
  );

  final String id;
  final String propertyId;
  final PropertySummary? property;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final int totalOccupants;
  final int numberOfChildren;
  final String occupation;
  final bool advanceAvailable;
  final DateTime? moveInDate;
  final RentalApplicationStatus status;
  final String? reviewNotes;
  final DateTime? createdAt;

  bool get canWithdraw =>
      status == RentalApplicationStatus.submitted ||
      status == RentalApplicationStatus.underReview ||
      status == RentalApplicationStatus.shortlisted;
}

/// One row of `GET /api/notifications`.
///
/// The API defines 20 notification types (`packages/shared-types/src/enums.ts`);
/// the app renders each with its own icon but the payload is intentionally kept
/// loose so a 21st type still renders as a generic notice.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    this.type = 'SYSTEM',
    this.title = '',
    this.message = '',
    this.isRead = false,
    this.propertyId,
    this.data,
    this.createdAt,
  });

  factory AppNotification.fromJson(Object? json) => AppNotification(
    id: idOf(json) ?? '',
    type: asString(json is Map ? json['type'] : null, 'SYSTEM'),
    title: asString(json is Map ? json['title'] : null),
    message: asString(json is Map ? json['message'] : null),
    isRead: asBool(json is Map ? json['isRead'] : null),
    propertyId: asStringOrNull(json is Map ? json['propertyId'] : null),
    data: asMap(json is Map ? json['data'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
  );

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? propertyId;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;
}

/// The payload of `GET /api/payment-links/r/:token` — the whole public
/// payment page, including the property thumbnail and the payee's name.
@immutable
class PaymentLink {
  const PaymentLink({
    required this.id,
    this.token = '',
    this.amount = 0,
    this.currency = 'BIF',
    this.note,
    this.status = PaymentLinkStatus.created,
    this.payeeName = '',
    this.propertyId = '',
    this.propertyTitle = '',
    this.propertyListingType,
    this.propertyImage,
    this.openedAt,
    this.paidAt,
    this.expiresAt,
  });

  factory PaymentLink.fromJson(Object? json) => PaymentLink(
    id: idOf(json) ?? '',
    token: asString(json is Map ? json['token'] : null),
    amount: asDouble(json is Map ? json['amount'] : null) ?? 0,
    currency: asString(json is Map ? json['currency'] : null, 'BIF'),
    note: asStringOrNull(json is Map ? json['note'] : null),
    status: PaymentLinkStatus.parse(asStringOrNull(json is Map ? json['status'] : null)),
    payeeName: asString(json is Map ? json['payeeName'] : null),
    propertyId: asString(json is Map ? json['propertyId'] : null),
    propertyTitle: asString(json is Map ? json['propertyTitle'] : null),
    propertyListingType: asStringOrNull(
      json is Map ? json['propertyListingType'] : null,
    ),
    propertyImage: asStringOrNull(json is Map ? json['propertyImage'] : null),
    openedAt: asDate(json is Map ? json['openedAt'] : null),
    paidAt: asDate(json is Map ? json['paidAt'] : null),
    expiresAt: asDate(json is Map ? json['expiresAt'] : null),
  );

  final String id;
  final String token;
  final double amount;
  final String currency;
  final String? note;
  final PaymentLinkStatus status;
  final String payeeName;
  final String propertyId;
  final String propertyTitle;
  final String? propertyListingType;
  final String? propertyImage;
  final DateTime? openedAt;
  final DateTime? paidAt;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!) && status.isTerminal == false;
}

/// The result of `POST /api/payment-links/r/:token/pay`.
@immutable
class PaymentResult {
  const PaymentResult({
    this.paymentReference = '',
    this.status = PaymentLinkStatus.paid,
    this.paidAt,
    this.propertyMarkedSold = false,
  });

  factory PaymentResult.fromJson(Object? json) => PaymentResult(
    paymentReference: asString(json is Map ? json['paymentReference'] : null),
    status: PaymentLinkStatus.parse(asStringOrNull(json is Map ? json['status'] : null)),
    paidAt: asDate(json is Map ? json['paidAt'] : null),
    propertyMarkedSold: asBool(json is Map ? json['propertyMarkedSold'] : null),
  );

  final String paymentReference;
  final PaymentLinkStatus status;
  final DateTime? paidAt;
  final bool propertyMarkedSold;
}
