import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('sw'),
  ];

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceDesc;

  /// No description provided for @sortViews.
  ///
  /// In en, this message translates to:
  /// **'Most viewed'**
  String get sortViews;

  /// No description provided for @sortFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured first'**
  String get sortFeatured;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterTitle;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filterApply;

  /// No description provided for @filterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filterClearAll;

  /// No description provided for @filterListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get filterListingType;

  /// No description provided for @filterPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get filterPropertyType;

  /// No description provided for @filterVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get filterVerification;

  /// No description provided for @filterProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get filterProvince;

  /// No description provided for @filterCommune.
  ///
  /// In en, this message translates to:
  /// **'Commune'**
  String get filterCommune;

  /// No description provided for @filterMinBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get filterMinBedrooms;

  /// No description provided for @filterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get filterPriceRange;

  /// No description provided for @filterMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get filterMinPrice;

  /// No description provided for @filterMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get filterMaxPrice;

  /// No description provided for @filterActiveCount.
  ///
  /// In en, this message translates to:
  /// **'\'{\'count, plural, =0\'{\'No filters\'}\' =1\'{\'1 filter\'}\' other\'{\'{count} filters\'}\'\'}\''**
  String filterActiveCount(num count);

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by city, neighborhood or property ID…'**
  String get searchPlaceholder;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No properties match your search'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try removing a filter or searching for a different commune.'**
  String get searchNoResultsHint;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// No description provided for @searchClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearHistory;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'\'{\'count, plural, =0\'{\'No results\'}\' =1\'{\'1 result\'}\' other\'{\'{count} results\'}\'\'}\''**
  String searchResultsCount(num count);

  /// No description provided for @listingForSale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get listingForSale;

  /// No description provided for @listingForRent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get listingForRent;

  /// No description provided for @listingForLease.
  ///
  /// In en, this message translates to:
  /// **'For lease'**
  String get listingForLease;

  /// No description provided for @listingAuction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get listingAuction;

  /// No description provided for @listingInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get listingInvestment;

  /// No description provided for @typeHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get typeHouse;

  /// No description provided for @typeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get typeApartment;

  /// No description provided for @typeVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get typeVilla;

  /// No description provided for @typeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get typeLand;

  /// No description provided for @typeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get typeShop;

  /// No description provided for @typeOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get typeOffice;

  /// No description provided for @typeWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get typeWarehouse;

  /// No description provided for @typeCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get typeCommercial;

  /// No description provided for @typeIndustrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get typeIndustrial;

  /// No description provided for @typeFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get typeFarm;

  /// No description provided for @typeHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get typeHotel;

  /// No description provided for @typeGuestHouse.
  ///
  /// In en, this message translates to:
  /// **'Guest house'**
  String get typeGuestHouse;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @verificationNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get verificationNotVerified;

  /// No description provided for @verificationPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get verificationPartial;

  /// No description provided for @verificationVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verificationVerified;

  /// No description provided for @verificationFullyVerified.
  ///
  /// In en, this message translates to:
  /// **'Fully verified'**
  String get verificationFullyVerified;

  /// No description provided for @badgeFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get badgeFeatured;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @badgePromoted.
  ///
  /// In en, this message translates to:
  /// **'Promoted'**
  String get badgePromoted;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any property to keep it here.'**
  String get savedEmptyBody;

  /// No description provided for @savedRequiresSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save properties'**
  String get savedRequiresSignIn;

  /// No description provided for @savedUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your saved properties'**
  String get savedUpdateFailed;

  /// No description provided for @propertyOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get propertyOverview;

  /// No description provided for @propertyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get propertyFeatures;

  /// No description provided for @propertyLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get propertyLocation;

  /// No description provided for @propertyAgent.
  ///
  /// In en, this message translates to:
  /// **'Listed by'**
  String get propertyAgent;

  /// No description provided for @propertySimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get propertySimilar;

  /// No description provided for @propertyEnquire.
  ///
  /// In en, this message translates to:
  /// **'Send enquiry'**
  String get propertyEnquire;

  /// No description provided for @propertyBookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a visit'**
  String get propertyBookVisit;

  /// No description provided for @propertyApplyRental.
  ///
  /// In en, this message translates to:
  /// **'Apply to rent'**
  String get propertyApplyRental;

  /// No description provided for @propertyShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share this property'**
  String get propertyShareTitle;

  /// No description provided for @propertyDescriptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'The agent has not added a description.'**
  String get propertyDescriptionEmpty;

  /// No description provided for @propertyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get propertyNotFound;

  /// No description provided for @propertyShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get propertyShare;

  /// No description provided for @propertySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get propertySave;

  /// No description provided for @propertySold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get propertySold;

  /// No description provided for @propertyCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get propertyCall;

  /// No description provided for @propertyNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get propertyNegotiable;

  /// No description provided for @propertyVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'Our team has checked the documents for this property.'**
  String get propertyVerificationNote;

  /// No description provided for @propertyCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {coordinates}'**
  String propertyCoordinates(String coordinates);

  /// No description provided for @propertyCoordinatesHidden.
  ///
  /// In en, this message translates to:
  /// **'Exact location hidden'**
  String get propertyCoordinatesHidden;

  /// No description provided for @enquiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Send an enquiry'**
  String get enquiryTitle;

  /// No description provided for @enquirySubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get enquirySubject;

  /// No description provided for @enquiryMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get enquiryMessage;

  /// No description provided for @enquirySend.
  ///
  /// In en, this message translates to:
  /// **'Send enquiry'**
  String get enquirySend;

  /// No description provided for @enquirySent.
  ///
  /// In en, this message translates to:
  /// **'Your enquiry was sent to the agent'**
  String get enquirySent;

  /// No description provided for @enquirySignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send an enquiry'**
  String get enquirySignInRequired;

  /// No description provided for @enquiryLabelOpen.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get enquiryLabelOpen;

  /// No description provided for @enquiryLabelInProgress.
  ///
  /// In en, this message translates to:
  /// **'Agent is looking'**
  String get enquiryLabelInProgress;

  /// No description provided for @enquiryLabelResponded.
  ///
  /// In en, this message translates to:
  /// **'Agent replied'**
  String get enquiryLabelResponded;

  /// No description provided for @enquiryLabelDealAgreed.
  ///
  /// In en, this message translates to:
  /// **'Deal agreed'**
  String get enquiryLabelDealAgreed;

  /// No description provided for @enquiryLabelClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get enquiryLabelClosed;

  /// No description provided for @enquiryAgentReply.
  ///
  /// In en, this message translates to:
  /// **'Agent\'\'s reply'**
  String get enquiryAgentReply;

  /// No description provided for @bookingNumberOfPeople.
  ///
  /// In en, this message translates to:
  /// **'How many people?'**
  String get bookingNumberOfPeople;

  /// No description provided for @bookingNotes.
  ///
  /// In en, this message translates to:
  /// **'Anything the agent should know?'**
  String get bookingNotes;

  /// No description provided for @bookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get bookingConfirm;

  /// No description provided for @bookingNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No visit times are available for this property.'**
  String get bookingNoSessions;

  /// No description provided for @bookingSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book a visit'**
  String get bookingSignInRequired;

  /// No description provided for @agentProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get agentProperties;

  /// No description provided for @agentSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get agentSold;

  /// No description provided for @agentContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get agentContact;

  /// No description provided for @agentCall.
  ///
  /// In en, this message translates to:
  /// **'Call agent'**
  String get agentCall;

  /// No description provided for @agentWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp agent'**
  String get agentWhatsapp;

  /// No description provided for @agentAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get agentAbout;

  /// No description provided for @agentLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get agentLicense;

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a visit'**
  String get bookingTitle;

  /// No description provided for @bookingAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any available date'**
  String get bookingAnyTime;

  /// No description provided for @bookingPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get bookingPickDate;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your visit is booked'**
  String get bookingSuccess;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get bookingReference;

  /// No description provided for @bookingMyVisits.
  ///
  /// In en, this message translates to:
  /// **'My visits'**
  String get bookingMyVisits;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get paymentMethod;

  /// No description provided for @paymentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm and pay'**
  String get paymentConfirm;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentSuccess;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment is being processed'**
  String get paymentPending;

  /// No description provided for @paymentAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get paymentAmountDue;

  /// No description provided for @paymentPayee.
  ///
  /// In en, this message translates to:
  /// **'Payee'**
  String get paymentPayee;

  /// No description provided for @paymentExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get paymentExpires;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'This payment link was cancelled'**
  String get paymentCancelled;

  /// No description provided for @paymentPayerPhone.
  ///
  /// In en, this message translates to:
  /// **'Your mobile money number'**
  String get paymentPayerPhone;

  /// No description provided for @paymentPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Burundi mobile money number'**
  String get paymentPhoneInvalid;

  /// No description provided for @paymentReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get paymentReference;

  /// No description provided for @paymentRecordedNote.
  ///
  /// In en, this message translates to:
  /// **'No payment gateway is connected yet, so this records your payment and marks the property as sold. It is not a bank confirmation.'**
  String get paymentRecordedNote;

  /// No description provided for @youTitle.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youTitle;

  /// No description provided for @youSignedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'You are browsing as a guest'**
  String get youSignedOutTitle;

  /// No description provided for @youSignedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save properties, contact agents and book visits.'**
  String get youSignedOutBody;

  /// No description provided for @youMyPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get youMyPayments;

  /// No description provided for @youMyVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get youMyVisits;

  /// No description provided for @youEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get youEditProfile;

  /// No description provided for @youAccountActivity.
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get youAccountActivity;

  /// No description provided for @accountViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get accountViews;

  /// No description provided for @accountEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get accountEnquiries;

  /// No description provided for @accountSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get accountSaved;

  /// No description provided for @authSetupRemaining.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your account'**
  String get authSetupRemaining;

  /// No description provided for @profilePhotoSection.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoSection;

  /// No description provided for @profilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Shown next to your name across the platform. JPEG, PNG, WEBP or GIF, up to 5 MB.'**
  String get profilePhotoHint;

  /// No description provided for @profilePhotoChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get profilePhotoChoose;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profilePhotoRemove;

  /// No description provided for @profilePhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get profilePhotoUploading;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed.'**
  String get profilePhotoRemoved;

  /// No description provided for @profilePhotoInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPEG, PNG, WEBP or GIF image.'**
  String get profilePhotoInvalid;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image must be 5 MB or smaller.'**
  String get profilePhotoTooLarge;

  /// No description provided for @profilePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read this image.'**
  String get profilePhotoFailed;

  /// No description provided for @profilePersonalSection.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalSection;

  /// No description provided for @profilePersonalHint.
  ///
  /// In en, this message translates to:
  /// **'Update your name, phone number and email address.'**
  String get profilePersonalHint;

  /// No description provided for @profilePersonalSaved.
  ///
  /// In en, this message translates to:
  /// **'Your personal information was saved.'**
  String get profilePersonalSaved;

  /// No description provided for @profileSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecuritySection;

  /// No description provided for @profileSecurityHint.
  ///
  /// In en, this message translates to:
  /// **'Change the password you use to sign in.'**
  String get profileSecurityHint;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPassword;

  /// No description provided for @profilePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get profilePasswordHint;

  /// No description provided for @profilePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get profilePasswordTooShort;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get profileEmailInvalid;

  /// No description provided for @profileWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That current password is not correct.'**
  String get profileWrongPassword;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate IMMO BURUNDI'**
  String get settingsRateApp;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of IMMO BURUNDI?'**
  String get settingsSignOutConfirm;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @currencyChanged.
  ///
  /// In en, this message translates to:
  /// **'Currency changed'**
  String get currencyChanged;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsRequiresSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your notifications'**
  String get notificationsRequiresSignIn;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This document is not available offline.'**
  String get legalUnavailable;

  /// No description provided for @legalReadOnSite.
  ///
  /// In en, this message translates to:
  /// **'Read the full document on the website'**
  String get legalReadOnSite;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline - some things may not update'**
  String get offlineBanner;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error — check your connection.'**
  String get errorNetwork;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tabSaved;

  /// No description provided for @tabYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tabYou;

  /// No description provided for @commonCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get commonCurrency;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @commonYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commonYou;

  /// No description provided for @commonNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get commonNow;

  /// No description provided for @commonNotify.
  ///
  /// In en, this message translates to:
  /// **'Notify notifications'**
  String get commonNotify;

  /// No description provided for @commonEstimate.
  ///
  /// In en, this message translates to:
  /// **'estimate'**
  String get commonEstimate;

  /// No description provided for @commonEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get commonEstimated;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// No description provided for @commonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonPrevious;

  /// No description provided for @navigationClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get navigationClose;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @mediaViewPhotos.
  ///
  /// In en, this message translates to:
  /// **'View photos'**
  String get mediaViewPhotos;

  /// No description provided for @mediaOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get mediaOf;

  /// No description provided for @mediaPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get mediaPhoto;

  /// No description provided for @mediaPreviousPhoto.
  ///
  /// In en, this message translates to:
  /// **'Previous photo'**
  String get mediaPreviousPhoto;

  /// No description provided for @mediaNextPhoto.
  ///
  /// In en, this message translates to:
  /// **'Next photo'**
  String get mediaNextPhoto;

  /// No description provided for @mediaImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get mediaImageUnavailable;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonPagination.
  ///
  /// In en, this message translates to:
  /// **'Pagination'**
  String get commonPagination;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @errorBoundaryBody.
  ///
  /// In en, this message translates to:
  /// **'The app hit an unexpected error. Your data is safe - try again, or reload the page.'**
  String get errorBoundaryBody;

  /// No description provided for @errorReload.
  ///
  /// In en, this message translates to:
  /// **'Reload page'**
  String get errorReload;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @themeLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get themeLightMode;

  /// No description provided for @themeDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get themeDarkMode;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get commonFrom;

  /// No description provided for @commonTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get commonTo;

  /// No description provided for @commonAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get commonAnd;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get commonMin;

  /// No description provided for @commonMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get commonMax;

  /// No description provided for @commonAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get commonAny;

  /// No description provided for @commonFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get commonFilters;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get commonPage;

  /// No description provided for @commonOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get commonOf;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get commonOptional;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get commonRequired;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNa.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNa;

  /// No description provided for @commonResults.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get commonResults;

  /// No description provided for @commonProperty.
  ///
  /// In en, this message translates to:
  /// **'property'**
  String get commonProperty;

  /// No description provided for @commonProperties.
  ///
  /// In en, this message translates to:
  /// **'properties'**
  String get commonProperties;

  /// No description provided for @commonViews.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get commonViews;

  /// No description provided for @commonShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get commonShowMore;

  /// No description provided for @commonShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get commonShowLess;

  /// No description provided for @commonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopy;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get navBuy;

  /// No description provided for @navRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get navRent;

  /// No description provided for @navLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get navLand;

  /// No description provided for @navCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get navCommercial;

  /// No description provided for @navFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get navFeatured;

  /// No description provided for @navVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get navVerified;

  /// No description provided for @navAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get navAgents;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @navLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get navLogin;

  /// No description provided for @navRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get navRegister;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get navLogout;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowse;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navListProperty.
  ///
  /// In en, this message translates to:
  /// **'List property'**
  String get navListProperty;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search properties'**
  String get searchTitle;

  /// No description provided for @searchPlaceholderShort.
  ///
  /// In en, this message translates to:
  /// **'Search properties…'**
  String get searchPlaceholderShort;

  /// No description provided for @searchQuickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick links'**
  String get searchQuickLinks;

  /// No description provided for @searchSegmentProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get searchSegmentProperties;

  /// No description provided for @searchSegmentAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get searchSegmentAgents;

  /// No description provided for @searchSegmentMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get searchSegmentMore;

  /// No description provided for @searchSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get searchSortBy;

  /// No description provided for @searchAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get searchAdvancedTitle;

  /// No description provided for @searchAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Refine your search below — set a location, budget and bedrooms.'**
  String get searchAdvancedDesc;

  /// No description provided for @searchPropertyAgent.
  ///
  /// In en, this message translates to:
  /// **'Search agents'**
  String get searchPropertyAgent;

  /// No description provided for @searchPerson.
  ///
  /// In en, this message translates to:
  /// **'Search people or properties'**
  String get searchPerson;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get searchLocation;

  /// No description provided for @searchPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get searchPropertyType;

  /// No description provided for @searchMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get searchMinPrice;

  /// No description provided for @searchMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get searchMaxPrice;

  /// No description provided for @searchBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get searchBedrooms;

  /// No description provided for @searchPropertyId.
  ///
  /// In en, this message translates to:
  /// **'Property ID'**
  String get searchPropertyId;

  /// No description provided for @searchTabBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get searchTabBuy;

  /// No description provided for @searchTabRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get searchTabRent;

  /// No description provided for @searchTabLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get searchTabLand;

  /// No description provided for @searchTabCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get searchTabCommercial;

  /// No description provided for @searchTabInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get searchTabInvestment;

  /// No description provided for @searchSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get searchSort;

  /// No description provided for @searchSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get searchSortNewest;

  /// No description provided for @searchSortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get searchSortPriceAsc;

  /// No description provided for @searchSortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get searchSortPriceDesc;

  /// No description provided for @searchSortViews.
  ///
  /// In en, this message translates to:
  /// **'Most viewed'**
  String get searchSortViews;

  /// No description provided for @searchSortFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured first'**
  String get searchSortFeatured;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get searchResults;

  /// No description provided for @searchResultsPlural.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get searchResultsPlural;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filter results'**
  String get searchFilters;

  /// No description provided for @searchPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Personalize results'**
  String get searchPersonalize;

  /// No description provided for @searchResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get searchResetFilters;

  /// No description provided for @searchProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get searchProvince;

  /// No description provided for @searchCommune.
  ///
  /// In en, this message translates to:
  /// **'Commune'**
  String get searchCommune;

  /// No description provided for @searchVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get searchVerificationStatus;

  /// No description provided for @searchFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured only'**
  String get searchFeatured;

  /// No description provided for @searchSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface area (m²)'**
  String get searchSurface;

  /// No description provided for @searchMinSurface.
  ///
  /// In en, this message translates to:
  /// **'Min surface'**
  String get searchMinSurface;

  /// No description provided for @searchMaxSurface.
  ///
  /// In en, this message translates to:
  /// **'Max surface'**
  String get searchMaxSurface;

  /// No description provided for @searchListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get searchListingType;

  /// No description provided for @searchPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get searchPriceRange;

  /// No description provided for @searchCleared.
  ///
  /// In en, this message translates to:
  /// **'Filters cleared'**
  String get searchCleared;

  /// No description provided for @propertyBuyHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the agent about your interest in buying this property'**
  String get propertyBuyHint;

  /// No description provided for @propertyBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get propertyBuy;

  /// No description provided for @propertyForSale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get propertyForSale;

  /// No description provided for @propertyForRent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get propertyForRent;

  /// No description provided for @propertyForLease.
  ///
  /// In en, this message translates to:
  /// **'For lease'**
  String get propertyForLease;

  /// No description provided for @propertyForAuction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get propertyForAuction;

  /// No description provided for @propertyForInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get propertyForInvestment;

  /// No description provided for @propertyIsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get propertyIsNew;

  /// No description provided for @propertyIsPromoted.
  ///
  /// In en, this message translates to:
  /// **'Promoted'**
  String get propertyIsPromoted;

  /// No description provided for @propertyViews.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get propertyViews;

  /// No description provided for @propertyFavorites.
  ///
  /// In en, this message translates to:
  /// **'favorites'**
  String get propertyFavorites;

  /// No description provided for @propertyBedrooms.
  ///
  /// In en, this message translates to:
  /// **'bed'**
  String get propertyBedrooms;

  /// No description provided for @propertyBathrooms.
  ///
  /// In en, this message translates to:
  /// **'bath'**
  String get propertyBathrooms;

  /// No description provided for @propertySurface.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get propertySurface;

  /// No description provided for @propertyFloors.
  ///
  /// In en, this message translates to:
  /// **'floors'**
  String get propertyFloors;

  /// No description provided for @propertyParking.
  ///
  /// In en, this message translates to:
  /// **'parking'**
  String get propertyParking;

  /// No description provided for @propertyYearBuilt.
  ///
  /// In en, this message translates to:
  /// **'Built'**
  String get propertyYearBuilt;

  /// No description provided for @propertyRooms.
  ///
  /// In en, this message translates to:
  /// **'rooms'**
  String get propertyRooms;

  /// No description provided for @propertyNotNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Not negotiable'**
  String get propertyNotNegotiable;

  /// No description provided for @propertyVerifyStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification status'**
  String get propertyVerifyStatus;

  /// No description provided for @propertyVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get propertyVerified;

  /// No description provided for @propertyPartial.
  ///
  /// In en, this message translates to:
  /// **'Partially verified'**
  String get propertyPartial;

  /// No description provided for @propertyNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get propertyNotVerified;

  /// No description provided for @propertyFullyVerified.
  ///
  /// In en, this message translates to:
  /// **'Fully verified'**
  String get propertyFullyVerified;

  /// No description provided for @propertyVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get propertyVerificationStatus;

  /// No description provided for @propertyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Verification is based on documents provided and does not guarantee ownership.'**
  String get propertyDisclaimer;

  /// No description provided for @propertyContactAgent.
  ///
  /// In en, this message translates to:
  /// **'Contact agent'**
  String get propertyContactAgent;

  /// No description provided for @propertyWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get propertyWhatsapp;

  /// No description provided for @propertyMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get propertyMessage;

  /// No description provided for @propertyRequestVisit.
  ///
  /// In en, this message translates to:
  /// **'Request visit'**
  String get propertyRequestVisit;

  /// No description provided for @propertyApplyRent.
  ///
  /// In en, this message translates to:
  /// **'Apply to rent'**
  String get propertyApplyRent;

  /// No description provided for @propertyReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get propertyReport;

  /// No description provided for @propertyRelatedProperties.
  ///
  /// In en, this message translates to:
  /// **'Related properties'**
  String get propertyRelatedProperties;

  /// No description provided for @propertyAboutThis.
  ///
  /// In en, this message translates to:
  /// **'About this property'**
  String get propertyAboutThis;

  /// No description provided for @propertyMap.
  ///
  /// In en, this message translates to:
  /// **'Location map'**
  String get propertyMap;

  /// No description provided for @propertyMapApproxNote.
  ///
  /// In en, this message translates to:
  /// **'Approximate location'**
  String get propertyMapApproxNote;

  /// No description provided for @propertyMapHidden.
  ///
  /// In en, this message translates to:
  /// **'The exact location of this property is hidden.'**
  String get propertyMapHidden;

  /// No description provided for @propertyPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get propertyPrice;

  /// No description provided for @propertySpecs.
  ///
  /// In en, this message translates to:
  /// **'Quick specs'**
  String get propertySpecs;

  /// No description provided for @propertySpecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Description & specs'**
  String get propertySpecsTitle;

  /// No description provided for @propertySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to favorites'**
  String get propertySaved;

  /// No description provided for @propertyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get propertyRemoved;

  /// No description provided for @propertyLoginToFavorite.
  ///
  /// In en, this message translates to:
  /// **'Log in to save this property'**
  String get propertyLoginToFavorite;

  /// No description provided for @propertyLoginToContact.
  ///
  /// In en, this message translates to:
  /// **'Log in to contact the agent'**
  String get propertyLoginToContact;

  /// No description provided for @propertySaves.
  ///
  /// In en, this message translates to:
  /// **'saves'**
  String get propertySaves;

  /// No description provided for @propertyLikes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get propertyLikes;

  /// No description provided for @propertyMultipleAgents.
  ///
  /// In en, this message translates to:
  /// **'Multiple agents'**
  String get propertyMultipleAgents;

  /// No description provided for @propertyViewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get propertyViewMore;

  /// No description provided for @propertySameAgent.
  ///
  /// In en, this message translates to:
  /// **'Same agent'**
  String get propertySameAgent;

  /// No description provided for @propertySameNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Same neighborhood'**
  String get propertySameNeighborhood;

  /// No description provided for @propertyNoRelated.
  ///
  /// In en, this message translates to:
  /// **'No related properties found'**
  String get propertyNoRelated;

  /// No description provided for @propertyAgentCard.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get propertyAgentCard;

  /// No description provided for @propertyTopAgent.
  ///
  /// In en, this message translates to:
  /// **'Top agent'**
  String get propertyTopAgent;

  /// No description provided for @propertyViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get propertyViewProfile;

  /// No description provided for @propertyAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get propertyAsk;

  /// No description provided for @propertyAskPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask the agent a question…'**
  String get propertyAskPlaceholder;

  /// No description provided for @propertyPhotos.
  ///
  /// In en, this message translates to:
  /// **'photos'**
  String get propertyPhotos;

  /// No description provided for @propertyQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get propertyQuestions;

  /// No description provided for @propertyNoQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions yet — be the first to ask.'**
  String get propertyNoQuestionsYet;

  /// No description provided for @relToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get relToday;

  /// No description provided for @relDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String relDaysAgo(String days);

  /// No description provided for @relWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks}w ago'**
  String relWeeksAgo(String weeks);

  /// No description provided for @relMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months}mo ago'**
  String relMonthsAgo(String months);

  /// No description provided for @relYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{years}y ago'**
  String relYearsAgo(String years);

  /// No description provided for @propertyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this property'**
  String get propertyReportTitle;

  /// No description provided for @propertyReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your report has been submitted.'**
  String get propertyReportSuccess;

  /// No description provided for @propertyGalleryFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Toggle fullscreen'**
  String get propertyGalleryFullscreen;

  /// No description provided for @propertyGalleryZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom image'**
  String get propertyGalleryZoom;

  /// No description provided for @propertyGalleryThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Thumbnails'**
  String get propertyGalleryThumbnails;

  /// No description provided for @propertyPrimary.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get propertyPrimary;

  /// No description provided for @propertyHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get propertyHome;

  /// No description provided for @propertyPropertyId.
  ///
  /// In en, this message translates to:
  /// **'Property ID'**
  String get propertyPropertyId;

  /// No description provided for @propertytypeHOUSE.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get propertytypeHOUSE;

  /// No description provided for @propertytypeOFFICE.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get propertytypeOFFICE;

  /// No description provided for @propertytypeFARM.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get propertytypeFARM;

  /// No description provided for @propertytypeAPARTMENT.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get propertytypeAPARTMENT;

  /// No description provided for @propertytypeSHOP.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get propertytypeSHOP;

  /// No description provided for @propertytypeINDUSTRIAL.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get propertytypeINDUSTRIAL;

  /// No description provided for @propertytypeVILLA.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get propertytypeVILLA;

  /// No description provided for @propertytypeWAREHOUSE.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get propertytypeWAREHOUSE;

  /// No description provided for @propertytypeOTHER.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get propertytypeOTHER;

  /// No description provided for @propertytypeLAND.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get propertytypeLAND;

  /// No description provided for @propertytypeHOTEL.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get propertytypeHOTEL;

  /// No description provided for @propertytypeCOMMERCIAL.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get propertytypeCOMMERCIAL;

  /// No description provided for @propertytypeGUESTHOUSE.
  ///
  /// In en, this message translates to:
  /// **'Guest house'**
  String get propertytypeGUESTHOUSE;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Document verification'**
  String get verificationTitle;

  /// No description provided for @verificationLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get verificationLearnMore;

  /// No description provided for @verificationLandTitle.
  ///
  /// In en, this message translates to:
  /// **'Land title'**
  String get verificationLandTitle;

  /// No description provided for @verificationSaleAgreement.
  ///
  /// In en, this message translates to:
  /// **'Sale agreement'**
  String get verificationSaleAgreement;

  /// No description provided for @verificationTop.
  ///
  /// In en, this message translates to:
  /// **'Proof of payment (TOP)'**
  String get verificationTop;

  /// No description provided for @verificationPropertyTax.
  ///
  /// In en, this message translates to:
  /// **'Property tax'**
  String get verificationPropertyTax;

  /// No description provided for @verificationOwnerId.
  ///
  /// In en, this message translates to:
  /// **'Owner ID'**
  String get verificationOwnerId;

  /// No description provided for @verificationOther.
  ///
  /// In en, this message translates to:
  /// **'Other document'**
  String get verificationOther;

  /// No description provided for @verificationPassed.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verificationPassed;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get verificationFailed;

  /// No description provided for @verificationNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get verificationNotApplicable;

  /// No description provided for @verificationVerifiedAt.
  ///
  /// In en, this message translates to:
  /// **'Verified on'**
  String get verificationVerifiedAt;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmail;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhone;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHasAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authLoginTabPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authLoginTabPhone;

  /// No description provided for @authLoginTabEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLoginTabEmail;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authRegisterWelcome.
  ///
  /// In en, this message translates to:
  /// **'Join IMMO BURUNDI'**
  String get authRegisterWelcome;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get authLoginSuccess;

  /// No description provided for @authRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get authRegisterSuccess;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordMismatch;

  /// No description provided for @authTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept our'**
  String get authTermsPrefix;

  /// No description provided for @authTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get authTermsLink;

  /// No description provided for @authPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get authPhoneRequired;

  /// No description provided for @authNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get authNameRequired;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @authTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get authTerms;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogout;

  /// No description provided for @authSignUpEyebrow.
  ///
  /// In en, this message translates to:
  /// **'JOIN IMMO BURUNDI'**
  String get authSignUpEyebrow;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignUpTitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite properties, message agents and get notified about new listings.'**
  String get authSignUpSubtitle;

  /// No description provided for @authLogInEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get authLogInEyebrow;

  /// No description provided for @authLogInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log back in to manage your favorites, messages and visits.'**
  String get authLogInSubtitle;

  /// No description provided for @authPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordPlaceholder;

  /// No description provided for @authNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Jean Ndayishimiye'**
  String get authNamePlaceholder;

  /// No description provided for @authEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailPlaceholder;

  /// No description provided for @authPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+257 79 000 000'**
  String get authPhonePlaceholder;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'My dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent dashboard'**
  String get dashboardAgentTitle;

  /// No description provided for @dashboardFavorites.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get dashboardFavorites;

  /// No description provided for @dashboardRecentViews.
  ///
  /// In en, this message translates to:
  /// **'Recent watched'**
  String get dashboardRecentViews;

  /// No description provided for @dashboardApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get dashboardApplications;

  /// No description provided for @dashboardVisits.
  ///
  /// In en, this message translates to:
  /// **'My visits'**
  String get dashboardVisits;

  /// No description provided for @dashboardMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get dashboardMessages;

  /// No description provided for @dashboardNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get dashboardNotifications;

  /// No description provided for @dashboardProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboardProfile;

  /// No description provided for @dashboardEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get dashboardEditProfile;

  /// No description provided for @dashboardSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get dashboardSaveChanges;

  /// No description provided for @dashboardLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get dashboardLanguage;

  /// No description provided for @dashboardCurrency.
  ///
  /// In en, this message translates to:
  /// **'Preferred currency'**
  String get dashboardCurrency;

  /// No description provided for @dashboardSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get dashboardSignedInAs;

  /// No description provided for @dashboardProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get dashboardProfileUpdated;

  /// No description provided for @dashboardPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get dashboardPasswordChanged;

  /// No description provided for @dashboardSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboardSettings;

  /// No description provided for @dashboardMyProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get dashboardMyProperties;

  /// No description provided for @dashboardPropFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dashboardPropFilterAll;

  /// No description provided for @dashboardPropFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get dashboardPropFilterActive;

  /// No description provided for @dashboardPropFilterReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get dashboardPropFilterReview;

  /// No description provided for @dashboardPropFilterChanges.
  ///
  /// In en, this message translates to:
  /// **'Needs changes'**
  String get dashboardPropFilterChanges;

  /// No description provided for @dashboardPropFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get dashboardPropFilterRejected;

  /// No description provided for @dashboardPropFilterDraft.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get dashboardPropFilterDraft;

  /// No description provided for @dashboardPropFilterArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get dashboardPropFilterArchive;

  /// No description provided for @dashboardPropFilterSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get dashboardPropFilterSold;

  /// No description provided for @dashboardPropFilterRented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get dashboardPropFilterRented;

  /// No description provided for @dashboardRelistProperty.
  ///
  /// In en, this message translates to:
  /// **'Publish again'**
  String get dashboardRelistProperty;

  /// No description provided for @dashboardRelistPropertyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Publish {title} again? An admin must approve it before it goes back live.'**
  String dashboardRelistPropertyConfirm(String title);

  /// No description provided for @dashboardBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get dashboardBookings;

  /// No description provided for @dashboardAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get dashboardAnalytics;

  /// No description provided for @dashboardVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get dashboardVerification;

  /// No description provided for @dashboardListProperty.
  ///
  /// In en, this message translates to:
  /// **'List property'**
  String get dashboardListProperty;

  /// No description provided for @dashboardProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get dashboardProperties;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardOverview;

  /// No description provided for @dashboardAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get dashboardAgents;

  /// No description provided for @dashboardRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get dashboardRequests;

  /// No description provided for @dashboardNoPropertiesDesc.
  ///
  /// In en, this message translates to:
  /// **'List a property to start managing it here.'**
  String get dashboardNoPropertiesDesc;

  /// No description provided for @dashboardNoBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get dashboardNoBookings;

  /// No description provided for @dashboardNoBookingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit requests for your properties will appear here.'**
  String get dashboardNoBookingsDesc;

  /// No description provided for @dashboardNoVerification.
  ///
  /// In en, this message translates to:
  /// **'No verification requests'**
  String get dashboardNoVerification;

  /// No description provided for @dashboardNoVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Request verification for a property to have it reviewed.'**
  String get dashboardNoVerificationDesc;

  /// No description provided for @dashboardProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get dashboardProperty;

  /// No description provided for @dashboardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dashboardConfirm;

  /// No description provided for @dashboardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dashboardCancel;

  /// No description provided for @dashboardStatViews.
  ///
  /// In en, this message translates to:
  /// **'Total views'**
  String get dashboardStatViews;

  /// No description provided for @dashboardStatLikes.
  ///
  /// In en, this message translates to:
  /// **'Total likes'**
  String get dashboardStatLikes;

  /// No description provided for @dashboardStatShares.
  ///
  /// In en, this message translates to:
  /// **'Total shares'**
  String get dashboardStatShares;

  /// No description provided for @dashboardStatBookings.
  ///
  /// In en, this message translates to:
  /// **'Visit bookings'**
  String get dashboardStatBookings;

  /// No description provided for @dashboardStatEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get dashboardStatEnquiries;

  /// No description provided for @dashboardPerProperty.
  ///
  /// In en, this message translates to:
  /// **'Per property'**
  String get dashboardPerProperty;

  /// No description provided for @navMyProperties.
  ///
  /// In en, this message translates to:
  /// **'My properties'**
  String get navMyProperties;

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @navFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get navFeedback;

  /// No description provided for @dashboardHome.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardHome;

  /// No description provided for @dashboardInbox.
  ///
  /// In en, this message translates to:
  /// **'Bookings & Inquiries'**
  String get dashboardInbox;

  /// No description provided for @dashboardSidebarAgency.
  ///
  /// In en, this message translates to:
  /// **'Your agency'**
  String get dashboardSidebarAgency;

  /// No description provided for @dashboardSidebarProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboardSidebarProfile;

  /// No description provided for @dashboardAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add property'**
  String get dashboardAddNew;

  /// No description provided for @dashboardClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get dashboardClearFilters;

  /// No description provided for @dashboardSearchProperties.
  ///
  /// In en, this message translates to:
  /// **'Search by title, reference or description'**
  String get dashboardSearchProperties;

  /// No description provided for @dashboardResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {from}-{to} of {total}'**
  String dashboardResultsCount(String from, String to, num total);

  /// No description provided for @dashboardNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No properties match your search. Try a different term or clear the search.'**
  String get dashboardNoSearchResults;

  /// No description provided for @dashboardRequester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get dashboardRequester;

  /// No description provided for @dashboardAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses ▾'**
  String get dashboardAllStatuses;

  /// No description provided for @dashboardCardsListTitle.
  ///
  /// In en, this message translates to:
  /// **'List your first property'**
  String get dashboardCardsListTitle;

  /// No description provided for @dashboardCardsListDesc.
  ///
  /// In en, this message translates to:
  /// **'Publish a listing to start receiving views and inquiries.'**
  String get dashboardCardsListDesc;

  /// No description provided for @dashboardCardsListCta.
  ///
  /// In en, this message translates to:
  /// **'Add property'**
  String get dashboardCardsListCta;

  /// No description provided for @dashboardCardsAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get dashboardCardsAnalyticsTitle;

  /// No description provided for @dashboardCardsAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track views, favorites and lead enquiries for each property.'**
  String get dashboardCardsAnalyticsDesc;

  /// No description provided for @dashboardCardsAnalyticsCta.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get dashboardCardsAnalyticsCta;

  /// No description provided for @dashboardCardsTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent tips'**
  String get dashboardCardsTipsTitle;

  /// No description provided for @dashboardCardsTip1.
  ///
  /// In en, this message translates to:
  /// **'High-quality photos can increase visits by up to 70%.'**
  String get dashboardCardsTip1;

  /// No description provided for @dashboardCardsTip2.
  ///
  /// In en, this message translates to:
  /// **'Reply to inquiries within the first hour.'**
  String get dashboardCardsTip2;

  /// No description provided for @dashboardCardsTip3.
  ///
  /// In en, this message translates to:
  /// **'Mark the deal as agreed before sending a payment link.'**
  String get dashboardCardsTip3;

  /// No description provided for @dashboardColProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get dashboardColProperty;

  /// No description provided for @dashboardColFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get dashboardColFlags;

  /// No description provided for @dashboardColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dashboardColStatus;

  /// No description provided for @dashboardColListed.
  ///
  /// In en, this message translates to:
  /// **'Date listed'**
  String get dashboardColListed;

  /// No description provided for @dashboardColViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get dashboardColViews;

  /// No description provided for @dashboardColInquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get dashboardColInquiries;

  /// No description provided for @dashboardEmptyProps.
  ///
  /// In en, this message translates to:
  /// **'No properties yet'**
  String get dashboardEmptyProps;

  /// No description provided for @dashboardEmptyPropsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your first listing to start building your portfolio.'**
  String get dashboardEmptyPropsDesc;

  /// No description provided for @dashboardColActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get dashboardColActions;

  /// No description provided for @dashboardEditProperty.
  ///
  /// In en, this message translates to:
  /// **'Edit property'**
  String get dashboardEditProperty;

  /// No description provided for @dashboardDeleteProperty.
  ///
  /// In en, this message translates to:
  /// **'Delete property'**
  String get dashboardDeleteProperty;

  /// No description provided for @dashboardRequestVerification.
  ///
  /// In en, this message translates to:
  /// **'Request verification'**
  String get dashboardRequestVerification;

  /// No description provided for @dashboardRequestVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Send this property to the IMMO BURUNDI team for verification. An officer will review the documents and contact you if anything is missing.'**
  String get dashboardRequestVerificationDesc;

  /// No description provided for @dashboardVerificationRequested.
  ///
  /// In en, this message translates to:
  /// **'Verification requested'**
  String get dashboardVerificationRequested;

  /// No description provided for @dashboardVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get dashboardVerificationCode;

  /// No description provided for @dashboardVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the verification team'**
  String get dashboardVerificationNote;

  /// No description provided for @dashboardVerificationNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Anything the officer should know (optional)'**
  String get dashboardVerificationNotePlaceholder;

  /// No description provided for @dashboardVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification already in progress'**
  String get dashboardVerificationPending;

  /// No description provided for @dashboardVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get dashboardVerified;

  /// No description provided for @dashboardVerificationIntro.
  ///
  /// In en, this message translates to:
  /// **'Track every property you manage: what is still waiting on a decision, what is already verified, and exactly what to fix before the administration accepts a listing.'**
  String get dashboardVerificationIntro;

  /// No description provided for @dashboardVerificationPendingSection.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get dashboardVerificationPendingSection;

  /// No description provided for @dashboardVerificationVerifiedSection.
  ///
  /// In en, this message translates to:
  /// **'Verified properties'**
  String get dashboardVerificationVerifiedSection;

  /// No description provided for @dashboardVerificationActionSection.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get dashboardVerificationActionSection;

  /// No description provided for @dashboardVerificationNoPending.
  ///
  /// In en, this message translates to:
  /// **'No property is waiting on a verification decision.'**
  String get dashboardVerificationNoPending;

  /// No description provided for @dashboardVerificationNoVerified.
  ///
  /// In en, this message translates to:
  /// **'None of your properties are verified yet.'**
  String get dashboardVerificationNoVerified;

  /// No description provided for @dashboardVerificationNoAction.
  ///
  /// In en, this message translates to:
  /// **'Nothing to fix — every property you manage is complete.'**
  String get dashboardVerificationNoAction;

  /// No description provided for @dashboardVerificationEmpty.
  ///
  /// In en, this message translates to:
  /// **'You do not manage any property yet. Add a property to start tracking its verification.'**
  String get dashboardVerificationEmpty;

  /// No description provided for @dashboardVerificationEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Go to my properties'**
  String get dashboardVerificationEmptyCta;

  /// No description provided for @dashboardVerificationWhatToUpdate.
  ///
  /// In en, this message translates to:
  /// **'What to update for acceptance'**
  String get dashboardVerificationWhatToUpdate;

  /// No description provided for @dashboardVerificationAllMet.
  ///
  /// In en, this message translates to:
  /// **'Every requirement is met. This property is ready for a verification decision.'**
  String get dashboardVerificationAllMet;

  /// No description provided for @dashboardVerificationAdminNote.
  ///
  /// In en, this message translates to:
  /// **'Note from the administration'**
  String get dashboardVerificationAdminNote;

  /// No description provided for @dashboardVerificationReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Note from the review team'**
  String get dashboardVerificationReviewNote;

  /// No description provided for @dashboardVerificationRequestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get dashboardVerificationRequestedOn;

  /// No description provided for @dashboardVerificationReviewedBy.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by'**
  String get dashboardVerificationReviewedBy;

  /// No description provided for @dashboardVerificationDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attached documents'**
  String get dashboardVerificationDocuments;

  /// No description provided for @dashboardVerificationNoDocuments.
  ///
  /// In en, this message translates to:
  /// **'No document attached yet.'**
  String get dashboardVerificationNoDocuments;

  /// No description provided for @dashboardVerificationMissing.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get dashboardVerificationMissing;

  /// No description provided for @dashboardVerificationProvided.
  ///
  /// In en, this message translates to:
  /// **'provided'**
  String get dashboardVerificationProvided;

  /// No description provided for @dashboardVerificationCount.
  ///
  /// In en, this message translates to:
  /// **'items to fix'**
  String get dashboardVerificationCount;

  /// No description provided for @dashboardVerificationAdminDecides.
  ///
  /// In en, this message translates to:
  /// **'A system administrator reviews and decides the final verification. You cannot mark a property as verified yourself.'**
  String get dashboardVerificationAdminDecides;

  /// No description provided for @dashboardVerificationView.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get dashboardVerificationView;

  /// No description provided for @verifyreqDocumentLANDTITLE.
  ///
  /// In en, this message translates to:
  /// **'Land title (titre foncier)'**
  String get verifyreqDocumentLANDTITLE;

  /// No description provided for @verifyreqDocumentOWNERID.
  ///
  /// In en, this message translates to:
  /// **'Owner identification'**
  String get verifyreqDocumentOWNERID;

  /// No description provided for @verifyreqDocumentSALEAGREEMENT.
  ///
  /// In en, this message translates to:
  /// **'Signed sale agreement'**
  String get verifyreqDocumentSALEAGREEMENT;

  /// No description provided for @verifyreqDocumentTOP.
  ///
  /// In en, this message translates to:
  /// **'Town planning certificate (TOP)'**
  String get verifyreqDocumentTOP;

  /// No description provided for @verifyreqDocumentPROPERTYTAX.
  ///
  /// In en, this message translates to:
  /// **'Property tax receipt'**
  String get verifyreqDocumentPROPERTYTAX;

  /// No description provided for @verifyreqDocumentOTHER.
  ///
  /// In en, this message translates to:
  /// **'Other supporting document'**
  String get verifyreqDocumentOTHER;

  /// No description provided for @verifyreqFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing title'**
  String get verifyreqFieldTitle;

  /// No description provided for @verifyreqFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get verifyreqFieldDescription;

  /// No description provided for @verifyreqFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get verifyreqFieldPrice;

  /// No description provided for @verifyreqFieldSurfaceArea.
  ///
  /// In en, this message translates to:
  /// **'Surface area'**
  String get verifyreqFieldSurfaceArea;

  /// No description provided for @verifyreqFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Province and commune'**
  String get verifyreqFieldLocation;

  /// No description provided for @verifyreqFieldMedia.
  ///
  /// In en, this message translates to:
  /// **'At least one photo'**
  String get verifyreqFieldMedia;

  /// No description provided for @verificationPropertiesTab.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get verificationPropertiesTab;

  /// No description provided for @verificationAgentsTab.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get verificationAgentsTab;

  /// No description provided for @verificationShowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed'**
  String get verificationShowCompleted;

  /// No description provided for @verificationNoPendingProperties.
  ///
  /// In en, this message translates to:
  /// **'No property awaiting verification'**
  String get verificationNoPendingProperties;

  /// No description provided for @verificationNoPendingPropertiesDesc.
  ///
  /// In en, this message translates to:
  /// **'New requests from agents will appear here for review.'**
  String get verificationNoPendingPropertiesDesc;

  /// No description provided for @verificationNoPendingAgents.
  ///
  /// In en, this message translates to:
  /// **'No agent awaiting verification'**
  String get verificationNoPendingAgents;

  /// No description provided for @verificationNoPendingAgentsDesc.
  ///
  /// In en, this message translates to:
  /// **'New agents appear here until you verify them.'**
  String get verificationNoPendingAgentsDesc;

  /// No description provided for @verificationRequestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String verificationRequestedOn(String date);

  /// No description provided for @verificationRegisteredOn.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String verificationRegisteredOn(String date);

  /// No description provided for @verificationAgent.
  ///
  /// In en, this message translates to:
  /// **'Listed agent'**
  String get verificationAgent;

  /// No description provided for @verificationNoAgent.
  ///
  /// In en, this message translates to:
  /// **'No agent assigned to this property.'**
  String get verificationNoAgent;

  /// No description provided for @verificationVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verificationVerify;

  /// No description provided for @verificationReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get verificationReject;

  /// No description provided for @verificationRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject verification'**
  String get verificationRejectTitle;

  /// No description provided for @verificationRejectDesc.
  ///
  /// In en, this message translates to:
  /// **'The requester is notified with your reason, so make it clear and actionable.'**
  String get verificationRejectDesc;

  /// No description provided for @verificationReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get verificationReason;

  /// No description provided for @verificationReasonPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What is missing or wrong?'**
  String get verificationReasonPlaceholder;

  /// No description provided for @verificationReasonHint.
  ///
  /// In en, this message translates to:
  /// **'This reason is sent to the agent and shown on the request.'**
  String get verificationReasonHint;

  /// No description provided for @verificationReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason is required to reject a verification.'**
  String get verificationReasonRequired;

  /// No description provided for @verificationConfirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm rejection'**
  String get verificationConfirmReject;

  /// No description provided for @verificationRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get verificationRejectionReason;

  /// No description provided for @verificationLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get verificationLicenseNumber;

  /// No description provided for @verificationProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get verificationProvince;

  /// No description provided for @verificationAgentStatus.
  ///
  /// In en, this message translates to:
  /// **'Agent: {status}'**
  String verificationAgentStatus(String status);

  /// No description provided for @verificationAgentWhatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is the IMMO BURUNDI verification team about \"{title}\".'**
  String verificationAgentWhatsappMessage(String title);

  /// No description provided for @dashboardDeletePropertyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This listing will be removed for good.'**
  String dashboardDeletePropertyConfirm(String title);

  /// No description provided for @dashboardBlockedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Blocked by the administration'**
  String get dashboardBlockedByAdmin;

  /// No description provided for @dashboardTabBookings.
  ///
  /// In en, this message translates to:
  /// **'Viewing requests'**
  String get dashboardTabBookings;

  /// No description provided for @dashboardTabEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Buying requests'**
  String get dashboardTabEnquiries;

  /// No description provided for @dashboardTabMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get dashboardTabMessages;

  /// No description provided for @dashboardContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get dashboardContact;

  /// No description provided for @dashboardWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get dashboardWhatsApp;

  /// No description provided for @dashboardSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send payment link'**
  String get dashboardSendLink;

  /// No description provided for @dashboardCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get dashboardCopyLink;

  /// No description provided for @dashboardMarkDeal.
  ///
  /// In en, this message translates to:
  /// **'Mark deal agreed'**
  String get dashboardMarkDeal;

  /// No description provided for @dashboardLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get dashboardLinkCopied;

  /// No description provided for @dashboardNoInbox.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get dashboardNoInbox;

  /// No description provided for @dashboardNoInboxDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit requests and buying inquiries for your properties will appear here.'**
  String get dashboardNoInboxDesc;

  /// No description provided for @bookingStatusPENDING.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingStatusPENDING;

  /// No description provided for @bookingStatusCONFIRMED.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get bookingStatusCONFIRMED;

  /// No description provided for @bookingStatusCOMPLETED.
  ///
  /// In en, this message translates to:
  /// **'Deal agreed'**
  String get bookingStatusCOMPLETED;

  /// No description provided for @bookingStatusCANCELLED.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get bookingStatusCANCELLED;

  /// No description provided for @bookingStatusNOSHOW.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get bookingStatusNOSHOW;

  /// No description provided for @bookingStatusDEALAGREED.
  ///
  /// In en, this message translates to:
  /// **'Deal agreed'**
  String get bookingStatusDEALAGREED;

  /// No description provided for @enquiryStatusNEW.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get enquiryStatusNEW;

  /// No description provided for @enquiryStatusOPEN.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get enquiryStatusOPEN;

  /// No description provided for @enquiryStatusINPROGRESS.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get enquiryStatusINPROGRESS;

  /// No description provided for @enquiryStatusRESPONDED.
  ///
  /// In en, this message translates to:
  /// **'Responded'**
  String get enquiryStatusRESPONDED;

  /// No description provided for @enquiryStatusDEALAGREED.
  ///
  /// In en, this message translates to:
  /// **'Deal agreed'**
  String get enquiryStatusDEALAGREED;

  /// No description provided for @enquiryStatusCLOSED.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get enquiryStatusCLOSED;

  /// No description provided for @dealAgreed.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get dealAgreed;

  /// No description provided for @dealTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark deal as agreed?'**
  String get dealTitle;

  /// No description provided for @dealDesc.
  ///
  /// In en, this message translates to:
  /// **'This unlocks sending a payment link to the requester.'**
  String get dealDesc;

  /// No description provided for @dealConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, mark agreed'**
  String get dealConfirm;

  /// No description provided for @plinkStatusCREATED.
  ///
  /// In en, this message translates to:
  /// **'Link sent'**
  String get plinkStatusCREATED;

  /// No description provided for @plinkStatusSENT.
  ///
  /// In en, this message translates to:
  /// **'Link sent'**
  String get plinkStatusSENT;

  /// No description provided for @plinkStatusOPENED.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get plinkStatusOPENED;

  /// No description provided for @plinkStatusPAID.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get plinkStatusPAID;

  /// No description provided for @plinkStatusCANCELLED.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get plinkStatusCANCELLED;

  /// No description provided for @plinkStatusEXPIRED.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get plinkStatusEXPIRED;

  /// No description provided for @analyticsTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get analyticsTabOverview;

  /// No description provided for @analyticsTabProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get analyticsTabProperties;

  /// No description provided for @analyticsTabClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get analyticsTabClients;

  /// No description provided for @analyticsTabTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get analyticsTabTrends;

  /// No description provided for @analyticsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Last 28 days'**
  String get analyticsPeriod;

  /// No description provided for @analyticsAvgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. time on listing'**
  String get analyticsAvgTime;

  /// No description provided for @analyticsStatLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get analyticsStatLeads;

  /// No description provided for @analyticsStatRealtime.
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get analyticsStatRealtime;

  /// No description provided for @analyticsRealtimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Live activity on your published properties.'**
  String get analyticsRealtimeDesc;

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No activity yet in this period'**
  String get analyticsNoData;

  /// No description provided for @analyticsViewsShort.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get analyticsViewsShort;

  /// No description provided for @analyticsFavoritesShort.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get analyticsFavoritesShort;

  /// No description provided for @analyticsInquiriesShort.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get analyticsInquiriesShort;

  /// No description provided for @listDropTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload property photos'**
  String get listDropTitle;

  /// No description provided for @listDropHint.
  ///
  /// In en, this message translates to:
  /// **'Add one photo URL per line — the first image becomes the cover.'**
  String get listDropHint;

  /// No description provided for @listSelectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select files'**
  String get listSelectFiles;

  /// No description provided for @listNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? We\'\'re here to assist.'**
  String get listNeedHelp;

  /// No description provided for @listUploadNotice.
  ///
  /// In en, this message translates to:
  /// **'Photos are public. Do not include personal documents.'**
  String get listUploadNotice;

  /// No description provided for @listPhotoCountOk.
  ///
  /// In en, this message translates to:
  /// **'Enough photos ({count} added).'**
  String listPhotoCountOk(num count);

  /// No description provided for @listPhotoCountMissing.
  ///
  /// In en, this message translates to:
  /// **'Add {count} more photo(s) — at least 4 are required.'**
  String listPhotoCountMissing(num count);

  /// No description provided for @listPhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos…'**
  String get listPhotoUploading;

  /// No description provided for @listPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get listPhotoFailed;

  /// No description provided for @listRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get listRemovePhoto;

  /// No description provided for @listPropertyAdded.
  ///
  /// In en, this message translates to:
  /// **'Property added'**
  String get listPropertyAdded;

  /// No description provided for @listPropertyAddedBody.
  ///
  /// In en, this message translates to:
  /// **'It is now in your property list.'**
  String get listPropertyAddedBody;

  /// No description provided for @listPropertyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Property updated'**
  String get listPropertyUpdated;

  /// No description provided for @listPropertyUpdatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes have been saved.'**
  String get listPropertyUpdatedBody;

  /// No description provided for @listPropertyPhotosSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) saved'**
  String listPropertyPhotosSaved(num count);

  /// No description provided for @listSavedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Saved as a draft. Submit it for review when you are ready.'**
  String get listSavedAsDraft;

  /// No description provided for @listSubmittedForReview.
  ///
  /// In en, this message translates to:
  /// **'Submitted for review. An admin will check it before it goes live.'**
  String get listSubmittedForReview;

  /// No description provided for @listDropzoneHint.
  ///
  /// In en, this message translates to:
  /// **'Drag photos here, or choose files. You can drop several at once.'**
  String get listDropzoneHint;

  /// No description provided for @listDropActive.
  ///
  /// In en, this message translates to:
  /// **'Drop your photos to upload them'**
  String get listDropActive;

  /// No description provided for @listPhotoLimit.
  ///
  /// In en, this message translates to:
  /// **'A listing can hold at most {count} photos.'**
  String listPhotoLimit(num count);

  /// No description provided for @payTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payTitle;

  /// No description provided for @paySecure.
  ///
  /// In en, this message translates to:
  /// **'Secure payment link'**
  String get paySecure;

  /// No description provided for @payAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get payAmountLabel;

  /// No description provided for @payPropertyLabel.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get payPropertyLabel;

  /// No description provided for @payTo.
  ///
  /// In en, this message translates to:
  /// **'For:'**
  String get payTo;

  /// No description provided for @payConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get payConfirm;

  /// No description provided for @payProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get payProcessing;

  /// No description provided for @paySuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paySuccess;

  /// No description provided for @paySuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your payment reference is {reference}.'**
  String paySuccessDesc(String reference);

  /// No description provided for @payBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get payBackToHome;

  /// No description provided for @payLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get payLoginPrompt;

  /// No description provided for @payLoginPromptDesc.
  ///
  /// In en, this message translates to:
  /// **'This is a secure payment link. Sign in to the account it was sent to.'**
  String get payLoginPromptDesc;

  /// No description provided for @payNotForYou.
  ///
  /// In en, this message translates to:
  /// **'This link is for a different account'**
  String get payNotForYou;

  /// No description provided for @payNotForYouDesc.
  ///
  /// In en, this message translates to:
  /// **'Please sign in with the account that received this payment link.'**
  String get payNotForYouDesc;

  /// No description provided for @payLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid payment link'**
  String get payLinkInvalid;

  /// No description provided for @payLinkInvalidDesc.
  ///
  /// In en, this message translates to:
  /// **'The link is missing, was removed, or has expired.'**
  String get payLinkInvalidDesc;

  /// No description provided for @payAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Already paid'**
  String get payAlreadyPaid;

  /// No description provided for @payAlreadyPaidDesc.
  ///
  /// In en, this message translates to:
  /// **'This payment link was already completed.'**
  String get payAlreadyPaidDesc;

  /// No description provided for @payGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get payGoToLogin;

  /// No description provided for @payGoSignup.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get payGoSignup;

  /// No description provided for @payChangeAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get payChangeAccount;

  /// No description provided for @payPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on {date}'**
  String payPaidOn(String date);

  /// No description provided for @payPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with your mobile money'**
  String get payPanelTitle;

  /// No description provided for @payPanelDesc.
  ///
  /// In en, this message translates to:
  /// **'All mobile money services available in Burundi. Pick your wallet, then enter the number you want to charge on the left.'**
  String get payPanelDesc;

  /// No description provided for @payPanelFootnote.
  ///
  /// In en, this message translates to:
  /// **'You will get a prompt on your phone to confirm the payment with your PIN.'**
  String get payPanelFootnote;

  /// No description provided for @payProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile money service'**
  String get payProviderLabel;

  /// No description provided for @payPickProvider.
  ///
  /// In en, this message translates to:
  /// **'Choose a mobile money service'**
  String get payPickProvider;

  /// No description provided for @payPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number'**
  String get payPhoneLabel;

  /// No description provided for @payPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'The number registered with your mobile money operator.'**
  String get payPhoneHint;

  /// No description provided for @payInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Burundian mobile money number, for example 79 11 10 01.'**
  String get payInvalidNumber;

  /// No description provided for @payConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'Confirm on'**
  String get payConfirmPrompt;

  /// No description provided for @payProviderLUMICASH.
  ///
  /// In en, this message translates to:
  /// **'Lumicash'**
  String get payProviderLUMICASH;

  /// No description provided for @payProviderECOCASH.
  ///
  /// In en, this message translates to:
  /// **'EcoCash'**
  String get payProviderECOCASH;

  /// No description provided for @payProviderIHELA.
  ///
  /// In en, this message translates to:
  /// **'iHela'**
  String get payProviderIHELA;

  /// No description provided for @listTitle.
  ///
  /// In en, this message translates to:
  /// **'List your property'**
  String get listTitle;

  /// No description provided for @listSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your property details — it will be submitted for review by an admin.'**
  String get listSubtitle;

  /// No description provided for @listDetails.
  ///
  /// In en, this message translates to:
  /// **'Property details'**
  String get listDetails;

  /// No description provided for @listTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get listTitleLabel;

  /// No description provided for @listPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get listPropertyType;

  /// No description provided for @listListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get listListingType;

  /// No description provided for @listPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get listPrice;

  /// No description provided for @listCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get listCurrency;

  /// No description provided for @listSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface area (m²)'**
  String get listSurface;

  /// No description provided for @listBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get listBedrooms;

  /// No description provided for @listBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get listBathrooms;

  /// No description provided for @listLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get listLocation;

  /// No description provided for @listProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get listProvince;

  /// No description provided for @listCommune.
  ///
  /// In en, this message translates to:
  /// **'Commune'**
  String get listCommune;

  /// No description provided for @listAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get listAddress;

  /// No description provided for @listNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Price is negotiable'**
  String get listNegotiable;

  /// No description provided for @listPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get listPhotos;

  /// No description provided for @listPhotosPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://…/photo1.jpg\nhttps://…/photo2.jpg'**
  String get listPhotosPlaceholder;

  /// No description provided for @listSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit property'**
  String get listSubmit;

  /// No description provided for @listCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get listCancel;

  /// No description provided for @footerDescription.
  ///
  /// In en, this message translates to:
  /// **'IMMO BURUNDI connects owners, buyers, tenants, investors and trusted agents across Burundi.'**
  String get footerDescription;

  /// No description provided for @footerCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get footerCompany;

  /// No description provided for @footerServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get footerServices;

  /// No description provided for @footerLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get footerLegal;

  /// No description provided for @footerSocial.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get footerSocial;

  /// No description provided for @footerLinksAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get footerLinksAboutUs;

  /// No description provided for @footerLinksContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get footerLinksContact;

  /// No description provided for @footerLinksCareers.
  ///
  /// In en, this message translates to:
  /// **'Careers'**
  String get footerLinksCareers;

  /// No description provided for @footerLinksPartners.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get footerLinksPartners;

  /// No description provided for @footerLinksBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get footerLinksBuy;

  /// No description provided for @footerLinksRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get footerLinksRent;

  /// No description provided for @footerLinksSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get footerLinksSell;

  /// No description provided for @footerLinksVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get footerLinksVerification;

  /// No description provided for @footerLinksPromotion.
  ///
  /// In en, this message translates to:
  /// **'Promotion'**
  String get footerLinksPromotion;

  /// No description provided for @footerLinksPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get footerLinksPrivacy;

  /// No description provided for @footerLinksTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get footerLinksTerms;

  /// No description provided for @footerLinksVerificationDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Verification disclaimer'**
  String get footerLinksVerificationDisclaimer;

  /// No description provided for @footerLinksCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookie policy'**
  String get footerLinksCookies;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Marketplace'**
  String get footerTagline;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get errorNotFound;

  /// No description provided for @errorNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist or has been moved.'**
  String get errorNotFoundDesc;

  /// No description provided for @errorNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this section.'**
  String get errorNoPermission;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get errorTryAgain;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @errorBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get errorBackHome;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get errorForbidden;

  /// No description provided for @errorInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Please check the information you entered.'**
  String get errorInvalidData;

  /// No description provided for @errorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get errorLoadFailed;

  /// No description provided for @errorPropertyLoadFail.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this property.'**
  String get errorPropertyLoadFail;

  /// No description provided for @emptyNoProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties found'**
  String get emptyNoProperties;

  /// No description provided for @emptyNoPropertiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search for something else.'**
  String get emptyNoPropertiesDesc;

  /// No description provided for @emptyNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get emptyNoFavorites;

  /// No description provided for @emptyNoFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any property to save it here.'**
  String get emptyNoFavoritesDesc;

  /// No description provided for @emptyNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get emptyNoResults;

  /// No description provided for @emptyNoResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'We could not find anything matching your search.'**
  String get emptyNoResultsDesc;

  /// No description provided for @emptyNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get emptyNoMessages;

  /// No description provided for @emptyNoMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Message an agent about a property you like.'**
  String get emptyNoMessagesDesc;

  /// No description provided for @emptyNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get emptyNoNotifications;

  /// No description provided for @emptyNoNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications will appear here.'**
  String get emptyNoNotificationsDesc;

  /// No description provided for @emptyNoVisits.
  ///
  /// In en, this message translates to:
  /// **'No upcoming visits'**
  String get emptyNoVisits;

  /// No description provided for @emptyNoVisitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Book a visit from any property page.'**
  String get emptyNoVisitsDesc;

  /// No description provided for @emptyNoApplications.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get emptyNoApplications;

  /// No description provided for @emptyNoApplicationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Buy requests and rental applications you send will appear here.'**
  String get emptyNoApplicationsDesc;

  /// No description provided for @applicationsBuyRequest.
  ///
  /// In en, this message translates to:
  /// **'Buy request'**
  String get applicationsBuyRequest;

  /// No description provided for @applicationsRentApplication.
  ///
  /// In en, this message translates to:
  /// **'Rent application'**
  String get applicationsRentApplication;

  /// No description provided for @applicationsViewProperty.
  ///
  /// In en, this message translates to:
  /// **'View property'**
  String get applicationsViewProperty;

  /// No description provided for @emptyNoRecentViews.
  ///
  /// In en, this message translates to:
  /// **'No recent views'**
  String get emptyNoRecentViews;

  /// No description provided for @emptyNoRecentViewsDesc.
  ///
  /// In en, this message translates to:
  /// **'Properties you view will appear here.'**
  String get emptyNoRecentViewsDesc;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Find your next home in Burundi'**
  String get homeTagline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified properties, trusted agents, and transparent pricing from Bujumbura to Muyinga.'**
  String get homeSubtitle;

  /// No description provided for @homeForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get homeForYou;

  /// No description provided for @homeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeSaved;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get feedTitle;

  /// No description provided for @feedDesc.
  ///
  /// In en, this message translates to:
  /// **'Hand-picked listings based on what people like you are searching.'**
  String get feedDesc;

  /// No description provided for @feedPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Personalize your feed'**
  String get feedPersonalize;

  /// No description provided for @feedPersonalizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you are looking for and we will tailor your feed.'**
  String get feedPersonalizeDesc;

  /// No description provided for @tilesApartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get tilesApartments;

  /// No description provided for @tilesHouses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get tilesHouses;

  /// No description provided for @tilesLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get tilesLand;

  /// No description provided for @tilesCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get tilesCommercial;

  /// No description provided for @tilesRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get tilesRentals;

  /// No description provided for @tilesForSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get tilesForSale;

  /// No description provided for @tilesVillas.
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get tilesVillas;

  /// No description provided for @tilesExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore more'**
  String get tilesExplore;

  /// No description provided for @homeFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured properties'**
  String get homeFeatured;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeRecent;

  /// No description provided for @homeRecentDesc.
  ///
  /// In en, this message translates to:
  /// **'Fresh listings published in the last 30 days.'**
  String get homeRecentDesc;

  /// No description provided for @homeVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified properties'**
  String get homeVerified;

  /// No description provided for @homeVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Documents checked by our verification team.'**
  String get homeVerifiedDesc;

  /// No description provided for @homePopularLocations.
  ///
  /// In en, this message translates to:
  /// **'Popular locations'**
  String get homePopularLocations;

  /// No description provided for @homePopularLocationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Where property seekers look the most.'**
  String get homePopularLocationsDesc;

  /// No description provided for @homeHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How IMMO BURUNDI works'**
  String get homeHowItWorks;

  /// No description provided for @homeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeStep1Title;

  /// No description provided for @homeStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Browse thousands of listings across every province of Burundi.'**
  String get homeStep1Desc;

  /// No description provided for @homeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get homeStep2Title;

  /// No description provided for @homeStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Documents are checked by our verification team.'**
  String get homeStep2Desc;

  /// No description provided for @homeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get homeStep3Title;

  /// No description provided for @homeStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Book a visit directly from the listing.'**
  String get homeStep3Desc;

  /// No description provided for @homeStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Buy or rent'**
  String get homeStep4Title;

  /// No description provided for @homeStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Close securely with a trusted agent.'**
  String get homeStep4Desc;

  /// No description provided for @heroLine1.
  ///
  /// In en, this message translates to:
  /// **'FIND YOUR'**
  String get heroLine1;

  /// No description provided for @heroLine2.
  ///
  /// In en, this message translates to:
  /// **'PERFECT HOME'**
  String get heroLine2;

  /// No description provided for @heroLine3.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get heroLine3;

  /// No description provided for @heroWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to IMMO BURUNDI — start your search below.'**
  String get heroWelcome;

  /// No description provided for @heroDesc.
  ///
  /// In en, this message translates to:
  /// **'We provide tailored real estate solutions, guiding you through every step with personalized experiences that meet your unique needs and aspirations.'**
  String get heroDesc;

  /// No description provided for @heroStatsListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get heroStatsListings;

  /// No description provided for @heroStatsProvinces.
  ///
  /// In en, this message translates to:
  /// **'Provinces'**
  String get heroStatsProvinces;

  /// No description provided for @heroStatsVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get heroStatsVerified;

  /// No description provided for @heroAgentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Expert agents'**
  String get heroAgentsLabel;

  /// No description provided for @aboutHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'About IMMO BURUNDI'**
  String get aboutHeroTitle;

  /// No description provided for @aboutHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A modern, trustworthy real estate marketplace for Burundi.'**
  String get aboutHeroSubtitle;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'IMMO BURUNDI connects property owners, buyers, tenants, investors and professional agents on a single transparent platform. We make finding, verifying and transacting on property in Burundi simple and secure.'**
  String get aboutMissionBody;

  /// No description provided for @aboutValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our values'**
  String get aboutValuesTitle;

  /// No description provided for @aboutValuesTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get aboutValuesTrust;

  /// No description provided for @aboutValuesTrustDesc.
  ///
  /// In en, this message translates to:
  /// **'Every listing is verified by a dedicated team before it is promoted.'**
  String get aboutValuesTrustDesc;

  /// No description provided for @aboutValuesTransparency.
  ///
  /// In en, this message translates to:
  /// **'Transparency'**
  String get aboutValuesTransparency;

  /// No description provided for @aboutValuesTransparencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Original prices, verification status and document checks are always shown.'**
  String get aboutValuesTransparencyDesc;

  /// No description provided for @aboutValuesQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get aboutValuesQuality;

  /// No description provided for @aboutValuesQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'We work with verified agents and complete, accurate property descriptions.'**
  String get aboutValuesQualityDesc;

  /// No description provided for @aboutValuesAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get aboutValuesAccessibility;

  /// No description provided for @aboutValuesAccessibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Available in French, English and Swahili, built for every device.'**
  String get aboutValuesAccessibilityDesc;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions, feedback or partnership ideas — we would love to hear from you.'**
  String get contactSubtitle;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get contactPhone;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get contactEmail;

  /// No description provided for @contactSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactSubject;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// No description provided for @contactSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get contactSubmit;

  /// No description provided for @contactSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent. We will reply shortly.'**
  String get contactSendSuccess;

  /// No description provided for @contactSendError.
  ///
  /// In en, this message translates to:
  /// **'We could not send your message. Please try again.'**
  String get contactSendError;

  /// No description provided for @contactOffice.
  ///
  /// In en, this message translates to:
  /// **'Head office'**
  String get contactOffice;

  /// No description provided for @contactHours.
  ///
  /// In en, this message translates to:
  /// **'Business hours'**
  String get contactHours;

  /// No description provided for @contactHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Monday – Saturday, 8:00 – 18:00'**
  String get contactHoursValue;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhoneLabel;

  /// No description provided for @contactWhatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsappLabel;

  /// No description provided for @contactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmailLabel;

  /// No description provided for @contactAddressValue.
  ///
  /// In en, this message translates to:
  /// **'Chaussée Prince Louis Rwagasore, Bujumbura, Burundi'**
  String get contactAddressValue;

  /// No description provided for @contactWhatsappCta.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get contactWhatsappCta;

  /// No description provided for @contactChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact the agent'**
  String get contactChatTitle;

  /// No description provided for @contactAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get contactAgent;

  /// No description provided for @contactCallCta.
  ///
  /// In en, this message translates to:
  /// **'Call the agent'**
  String get contactCallCta;

  /// No description provided for @contactNoPhone.
  ///
  /// In en, this message translates to:
  /// **'This agent has not published a phone number yet.'**
  String get contactNoPhone;

  /// No description provided for @contactWhatsappProperty.
  ///
  /// In en, this message translates to:
  /// **'Hello, I am interested in \"{title}\". Is it still available?'**
  String contactWhatsappProperty(String title);

  /// No description provided for @contactWhatsappGeneric.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like to know more about this property.'**
  String get contactWhatsappGeneric;

  /// No description provided for @contactVisitBooked.
  ///
  /// In en, this message translates to:
  /// **'Your visit is booked. Contact the agent if anything changes.'**
  String get contactVisitBooked;

  /// No description provided for @contactBuyRequested.
  ///
  /// In en, this message translates to:
  /// **'Request sent. Contact the agent to go further.'**
  String get contactBuyRequested;

  /// No description provided for @contactListTitle.
  ///
  /// In en, this message translates to:
  /// **'List your property'**
  String get contactListTitle;

  /// No description provided for @contactListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Selling or renting? Publish on IMMO BURUNDI in minutes and reach thousands of buyers and tenants.'**
  String get contactListSubtitle;

  /// No description provided for @contactListButton.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get contactListButton;

  /// No description provided for @contactListEmail.
  ///
  /// In en, this message translates to:
  /// **'hello@immoburundi.bi'**
  String get contactListEmail;

  /// No description provided for @catEyebrow.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get catEyebrow;

  /// No description provided for @catBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties for sale'**
  String get catBuyTitle;

  /// No description provided for @catBuySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Houses, apartments, villas and more across every province of Burundi.'**
  String get catBuySubtitle;

  /// No description provided for @catRentTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties for rent'**
  String get catRentTitle;

  /// No description provided for @catRentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apartments, houses and villas available for rent.'**
  String get catRentSubtitle;

  /// No description provided for @catLandTitle.
  ///
  /// In en, this message translates to:
  /// **'Land for sale'**
  String get catLandTitle;

  /// No description provided for @catLandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Land plots across all provinces of Burundi.'**
  String get catLandSubtitle;

  /// No description provided for @catCommercialTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial properties'**
  String get catCommercialTitle;

  /// No description provided for @catCommercialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shops, offices, warehouses and industrial spaces.'**
  String get catCommercialSubtitle;

  /// No description provided for @catFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured properties'**
  String get catFeaturedTitle;

  /// No description provided for @catFeaturedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hand-picked listings promoted by our team.'**
  String get catFeaturedSubtitle;

  /// No description provided for @catVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified properties'**
  String get catVerifiedTitle;

  /// No description provided for @catVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Documents checked by our verification team.'**
  String get catVerifiedSubtitle;

  /// No description provided for @catOpenSearch.
  ///
  /// In en, this message translates to:
  /// **'View all in search'**
  String get catOpenSearch;

  /// No description provided for @agentsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'NETWORK'**
  String get agentsEyebrow;

  /// No description provided for @agentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Our trusted agents'**
  String get agentsTitle;

  /// No description provided for @agentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified professionals helping you buy, sell and rent with confidence.'**
  String get agentsSubtitle;

  /// No description provided for @agentsTop.
  ///
  /// In en, this message translates to:
  /// **'Top agent'**
  String get agentsTop;

  /// No description provided for @agentsListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get agentsListings;

  /// No description provided for @agentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No agents found'**
  String get agentsEmpty;

  /// No description provided for @agentsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'We could not find any agents matching your search.'**
  String get agentsEmptyDesc;

  /// No description provided for @agentLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get agentLatest;

  /// No description provided for @agentPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get agentPopular;

  /// No description provided for @agentPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get agentPriceAsc;

  /// No description provided for @agentPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get agentPriceDesc;

  /// No description provided for @agentSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get agentSubscribe;

  /// No description provided for @agentSubscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get agentSubscribed;

  /// No description provided for @agentPublished.
  ///
  /// In en, this message translates to:
  /// **'published assets'**
  String get agentPublished;

  /// No description provided for @agentAgentCode.
  ///
  /// In en, this message translates to:
  /// **'Agent code'**
  String get agentAgentCode;

  /// No description provided for @agentRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get agentRating;

  /// No description provided for @agentMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get agentMemberSince;

  /// No description provided for @agentNoBio.
  ///
  /// In en, this message translates to:
  /// **'This agent has not added a biography yet.'**
  String get agentNoBio;

  /// No description provided for @agentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No published assets yet'**
  String get agentEmpty;

  /// No description provided for @agentEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'This agent has not published any property yet.'**
  String get agentEmptyDesc;

  /// No description provided for @agentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Agent not found'**
  String get agentNotFound;

  /// No description provided for @agentNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'This agent may be inactive or the link may be wrong.'**
  String get agentNotFoundDesc;

  /// No description provided for @agentAgency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agentAgency;

  /// No description provided for @agentHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get agentHome;

  /// No description provided for @agentListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get agentListings;

  /// No description provided for @agentReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get agentReviews;

  /// No description provided for @agentRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent listings'**
  String get agentRecent;

  /// No description provided for @agentActiveListings.
  ///
  /// In en, this message translates to:
  /// **'active listings'**
  String get agentActiveListings;

  /// No description provided for @agentReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String agentReviewsCount(num count);

  /// No description provided for @agentSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search this agent\'\'s listings'**
  String get agentSearchPlaceholder;

  /// No description provided for @agentMoreLinks.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String agentMoreLinks(num count);

  /// No description provided for @agentReviewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No written reviews yet'**
  String get agentReviewsEmpty;

  /// No description provided for @agentReviewsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Ratings and transaction history are shown below; written reviews are coming soon.'**
  String get agentReviewsEmptyDesc;

  /// No description provided for @agentSoldHidden.
  ///
  /// In en, this message translates to:
  /// **'Sold listings are only shown to signed-in users.'**
  String get agentSoldHidden;

  /// No description provided for @agentSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get agentSales;

  /// No description provided for @agentDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals closed'**
  String get agentDeals;

  /// No description provided for @agentMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get agentMore;

  /// No description provided for @visitBookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book visit'**
  String get visitBookVisit;

  /// No description provided for @visitPlacesRemaining.
  ///
  /// In en, this message translates to:
  /// **'places remaining'**
  String get visitPlacesRemaining;

  /// No description provided for @visitBookingClosesIn.
  ///
  /// In en, this message translates to:
  /// **'Booking closes in'**
  String get visitBookingClosesIn;

  /// No description provided for @visitDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get visitDate;

  /// No description provided for @visitTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get visitTime;

  /// No description provided for @visitSessionFull.
  ///
  /// In en, this message translates to:
  /// **'Session full'**
  String get visitSessionFull;

  /// No description provided for @visitNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No visit sessions available right now.'**
  String get visitNoSessions;

  /// No description provided for @visitBooked.
  ///
  /// In en, this message translates to:
  /// **'Visit booked'**
  String get visitBooked;

  /// No description provided for @visitBookedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your visit has been booked. Check the dashboard for details.'**
  String get visitBookedSuccess;

  /// No description provided for @visitBookError.
  ///
  /// In en, this message translates to:
  /// **'Could not book this visit.'**
  String get visitBookError;

  /// No description provided for @visitPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of people'**
  String get visitPeople;

  /// No description provided for @visitLoginToBook.
  ///
  /// In en, this message translates to:
  /// **'Log in to book a visit'**
  String get visitLoginToBook;

  /// No description provided for @visitScheduleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Availability updated live.'**
  String get visitScheduleUpdated;

  /// No description provided for @visitStepWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get visitStepWhen;

  /// No description provided for @visitStepWho.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get visitStepWho;

  /// No description provided for @visitStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get visitStepConfirm;

  /// No description provided for @visitPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Please pick a date and time for your visit.'**
  String get visitPickDateTime;

  /// No description provided for @visitGuestInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your details to continue.'**
  String get visitGuestInfoRequired;

  /// No description provided for @visitUseScheduled.
  ///
  /// In en, this message translates to:
  /// **'Browse scheduled sessions'**
  String get visitUseScheduled;

  /// No description provided for @visitAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Request any time'**
  String get visitAnyTime;

  /// No description provided for @visitFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get visitFirstName;

  /// No description provided for @visitLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get visitLastName;

  /// No description provided for @visitPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get visitPhone;

  /// No description provided for @visitEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get visitEmail;

  /// No description provided for @visitPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get visitPassword;

  /// No description provided for @visitGuestNote.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest — we will create an account and log you in automatically so your visit is saved.'**
  String get visitGuestNote;

  /// No description provided for @visitVisitor.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get visitVisitor;

  /// No description provided for @visitNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes for the agent'**
  String get visitNotes;

  /// No description provided for @visitBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get visitBack;

  /// No description provided for @visitContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get visitContinue;

  /// No description provided for @visitCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get visitCreateAccount;

  /// No description provided for @visitConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get visitConfirmBooking;

  /// No description provided for @visitStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get visitStepPassword;

  /// No description provided for @visitFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get visitFullName;

  /// No description provided for @visitEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get visitEmailOrPhone;

  /// No description provided for @visitConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get visitConfirmPassword;

  /// No description provided for @visitPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get visitPasswordMismatch;

  /// No description provided for @visitPasswordHintStrong.
  ///
  /// In en, this message translates to:
  /// **'Use a strong password — at least 8 characters.'**
  String get visitPasswordHintStrong;

  /// No description provided for @visitFullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get visitFullNamePlaceholder;

  /// No description provided for @visitContactPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+257 … or you@mail.com'**
  String get visitContactPlaceholder;

  /// No description provided for @visitPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit placed!'**
  String get visitPlacedTitle;

  /// No description provided for @visitPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your visit request has been received. The agent will contact you to confirm.'**
  String get visitPlacedSuccess;

  /// No description provided for @visitDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get visitDone;

  /// No description provided for @visitManageInDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manage or cancel it from your dashboard.'**
  String get visitManageInDashboard;

  /// No description provided for @visitDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit details'**
  String get visitDetailsTitle;

  /// No description provided for @visitStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get visitStatusPending;

  /// No description provided for @visitStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get visitStatusConfirmed;

  /// No description provided for @visitStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get visitStatusCancelled;

  /// No description provided for @visitStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get visitStatusNoShow;

  /// No description provided for @visitReference.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get visitReference;

  /// No description provided for @visitPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get visitPeopleCount;

  /// No description provided for @visitBookedOn.
  ///
  /// In en, this message translates to:
  /// **'Booked on'**
  String get visitBookedOn;

  /// No description provided for @visitViewProperty.
  ///
  /// In en, this message translates to:
  /// **'View property'**
  String get visitViewProperty;

  /// No description provided for @visitCancelVisit.
  ///
  /// In en, this message translates to:
  /// **'Cancel visit'**
  String get visitCancelVisit;

  /// No description provided for @pickerSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get pickerSelectDate;

  /// No description provided for @pickerSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get pickerSelectTime;

  /// No description provided for @pickerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get pickerToday;

  /// No description provided for @pickerTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get pickerTomorrow;

  /// No description provided for @pickerMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get pickerMorning;

  /// No description provided for @pickerAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get pickerAfternoon;

  /// No description provided for @pickerEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get pickerEvening;

  /// No description provided for @visitSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date.'**
  String get visitSelectDate;

  /// No description provided for @visitSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select a time.'**
  String get visitSelectTime;

  /// No description provided for @visitSelectSession.
  ///
  /// In en, this message translates to:
  /// **'Choose a visit session.'**
  String get visitSelectSession;

  /// No description provided for @visitMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Required: {fields}.'**
  String visitMissingFields(String fields);

  /// No description provided for @visitPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters.'**
  String get visitPasswordHint;

  /// No description provided for @mapApproximateLocation.
  ///
  /// In en, this message translates to:
  /// **'Approximate location'**
  String get mapApproximateLocation;

  /// No description provided for @mapLocationHidden.
  ///
  /// In en, this message translates to:
  /// **'Exact location hidden for owner privacy.'**
  String get mapLocationHidden;

  /// No description provided for @mapShowOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get mapShowOnMap;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationTitle;

  /// No description provided for @notificationUnread.
  ///
  /// In en, this message translates to:
  /// **'unread'**
  String get notificationUnread;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationMarkAllRead;

  /// No description provided for @modalBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Express interest in buying'**
  String get modalBuyTitle;

  /// No description provided for @modalContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact the agent'**
  String get modalContactTitle;

  /// No description provided for @modalContactName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get modalContactName;

  /// No description provided for @modalContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Your phone'**
  String get modalContactPhone;

  /// No description provided for @modalContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get modalContactMessage;

  /// No description provided for @modalMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get modalMessageTitle;

  /// No description provided for @modalApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply to rent this property'**
  String get modalApplyTitle;

  /// No description provided for @modalApplyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly income (BIF)'**
  String get modalApplyIncome;

  /// No description provided for @modalApplyEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment status'**
  String get modalApplyEmployment;

  /// No description provided for @modalApplyReferences.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get modalApplyReferences;

  /// No description provided for @modalContactSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your message was sent to the agent.'**
  String get modalContactSendSuccess;

  /// No description provided for @modalRequireLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get modalRequireLogin;

  /// No description provided for @modalBuySuccess.
  ///
  /// In en, this message translates to:
  /// **'Your request to buy was sent to the agent.'**
  String get modalBuySuccess;

  /// No description provided for @modalBuyOptionalMessage.
  ///
  /// In en, this message translates to:
  /// **'Optional — tell the agent what you would like to know.'**
  String get modalBuyOptionalMessage;

  /// No description provided for @applySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your rental application has been submitted to the agent.'**
  String get applySubmitted;

  /// No description provided for @legalVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Disclaimer'**
  String get legalVerificationTitle;

  /// No description provided for @legalCookiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cookie Policy'**
  String get legalCookiesTitle;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get legalUpdated;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
