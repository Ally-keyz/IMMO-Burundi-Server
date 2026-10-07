// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get sortViews => 'Most viewed';

  @override
  String get sortFeatured => 'Featured first';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterApply => 'Apply filters';

  @override
  String get filterClearAll => 'Clear all';

  @override
  String get filterListingType => 'Listing type';

  @override
  String get filterPropertyType => 'Property type';

  @override
  String get filterVerification => 'Verification';

  @override
  String get filterProvince => 'Province';

  @override
  String get filterCommune => 'Commune';

  @override
  String get filterMinBedrooms => 'Bedrooms';

  @override
  String get filterPriceRange => 'Price range';

  @override
  String get filterMinPrice => 'Min price';

  @override
  String get filterMaxPrice => 'Max price';

  @override
  String filterActiveCount(num count) {
    return '{count, plural, =0{No filters} =1{1 filter} other{$count filters}\'}';
  }

  @override
  String get searchPlaceholder =>
      'Search by city, neighborhood or property ID…';

  @override
  String get searchNoResults => 'No properties match your search';

  @override
  String get searchNoResultsHint =>
      'Try removing a filter or searching for a different commune.';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClearHistory => 'Clear';

  @override
  String searchResultsCount(num count) {
    return '{count, plural, =0{No results} =1{1 result} other{$count results}\'}';
  }

  @override
  String get listingForSale => 'For sale';

  @override
  String get listingForRent => 'For rent';

  @override
  String get listingForLease => 'For lease';

  @override
  String get listingAuction => 'Auction';

  @override
  String get listingInvestment => 'Investment';

  @override
  String get typeHouse => 'House';

  @override
  String get typeApartment => 'Apartment';

  @override
  String get typeVilla => 'Villa';

  @override
  String get typeLand => 'Land';

  @override
  String get typeShop => 'Shop';

  @override
  String get typeOffice => 'Office';

  @override
  String get typeWarehouse => 'Warehouse';

  @override
  String get typeCommercial => 'Commercial';

  @override
  String get typeIndustrial => 'Industrial';

  @override
  String get typeFarm => 'Farm';

  @override
  String get typeHotel => 'Hotel';

  @override
  String get typeGuestHouse => 'Guest house';

  @override
  String get typeOther => 'Other';

  @override
  String get verificationNotVerified => 'Not verified';

  @override
  String get verificationPartial => 'Partial';

  @override
  String get verificationVerified => 'Verified';

  @override
  String get verificationFullyVerified => 'Fully verified';

  @override
  String get badgeFeatured => 'Featured';

  @override
  String get badgeNew => 'New';

  @override
  String get badgePromoted => 'Promoted';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyBody => 'Tap the heart on any property to keep it here.';

  @override
  String get savedRequiresSignIn => 'Sign in to save properties';

  @override
  String get savedUpdateFailed => 'Could not update your saved properties';

  @override
  String get savedAdd => 'Save this property';

  @override
  String get savedRemove => 'Remove from saved';

  @override
  String get propertyOverview => 'Overview';

  @override
  String get propertyFeatures => 'Features';

  @override
  String get propertyLocation => 'Location';

  @override
  String get propertyAgent => 'Listed by';

  @override
  String get propertySimilar => 'Similar';

  @override
  String get propertyEnquire => 'Send enquiry';

  @override
  String get propertyBookVisit => 'Book a visit';

  @override
  String get propertyApplyRental => 'Apply to rent';

  @override
  String get propertyShareTitle => 'Share this property';

  @override
  String get propertyDescriptionEmpty =>
      'The agent has not added a description.';

  @override
  String get propertyNotFound => 'Property not found';

  @override
  String get propertyShare => 'Share';

  @override
  String get propertySave => 'Save';

  @override
  String get propertySold => 'Sold';

  @override
  String get propertyCall => 'Call';

  @override
  String get propertyNegotiable => 'Negotiable';

  @override
  String get propertyVerificationNote =>
      'Our team has checked the documents for this property.';

  @override
  String propertyCoordinates(String coordinates) {
    return 'Coordinates: $coordinates';
  }

  @override
  String get propertyCoordinatesHidden => 'Exact location hidden';

  @override
  String get enquiryTitle => 'Send an enquiry';

  @override
  String get enquirySubject => 'Subject';

  @override
  String get enquiryMessage => 'Message';

  @override
  String get enquirySend => 'Send enquiry';

  @override
  String get enquirySent => 'Your enquiry was sent to the agent';

  @override
  String get enquirySignInRequired => 'Sign in to send an enquiry';

  @override
  String get enquiryLabelOpen => 'Sent';

  @override
  String get enquiryLabelInProgress => 'Agent is looking';

  @override
  String get enquiryLabelResponded => 'Agent replied';

  @override
  String get enquiryLabelDealAgreed => 'Deal agreed';

  @override
  String get enquiryLabelClosed => 'Closed';

  @override
  String get enquiryAgentReply => 'Agent\'s reply';

  @override
  String get bookingNumberOfPeople => 'How many people?';

  @override
  String get bookingNotes => 'Anything the agent should know?';

  @override
  String get bookingConfirm => 'Confirm booking';

  @override
  String get bookingNoSessions =>
      'No visit times are available for this property.';

  @override
  String get bookingSignInRequired => 'Sign in to book a visit';

  @override
  String get agentProperties => 'Properties';

  @override
  String get agentSold => 'Sold';

  @override
  String get agentContact => 'Contact';

  @override
  String get agentCall => 'Call agent';

  @override
  String get agentWhatsapp => 'WhatsApp agent';

  @override
  String get agentAbout => 'About';

  @override
  String get agentLicense => 'License';

  @override
  String get bookingTitle => 'Book a visit';

  @override
  String get bookingAnyTime => 'Any available date';

  @override
  String get bookingPickDate => 'Pick a date';

  @override
  String get bookingSuccess => 'Your visit is booked';

  @override
  String get bookingReference => 'Reference';

  @override
  String get bookingMyVisits => 'My visits';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentMethod => 'Pay with';

  @override
  String get paymentConfirm => 'Confirm and pay';

  @override
  String get paymentSuccess => 'Payment received';

  @override
  String get paymentPending => 'Payment is being processed';

  @override
  String get paymentAmountDue => 'Amount due';

  @override
  String get paymentPayee => 'Payee';

  @override
  String get paymentExpires => 'Expires';

  @override
  String get paymentCancelled => 'This payment link was cancelled';

  @override
  String get paymentPayerPhone => 'Your mobile money number';

  @override
  String get paymentPhoneInvalid => 'Enter a valid Burundi mobile money number';

  @override
  String get paymentReference => 'Reference';

  @override
  String get paymentRecordedNote =>
      'No payment gateway is connected yet, so this records your payment and marks the property as sold. It is not a bank confirmation.';

  @override
  String get youTitle => 'You';

  @override
  String get youSignedOutTitle => 'You are browsing as a guest';

  @override
  String get youSignedOutBody =>
      'Sign in to save properties, contact agents and book visits.';

  @override
  String get youMyPayments => 'Payments';

  @override
  String get youMyVisits => 'Visits';

  @override
  String get youEditProfile => 'Edit profile';

  @override
  String get youAccountActivity => 'Your activity';

  @override
  String get accountViews => 'Views';

  @override
  String get accountEnquiries => 'Enquiries';

  @override
  String get accountSaved => 'Saved';

  @override
  String get authSetupRemaining => 'Finish setting up your account';

  @override
  String get profilePhotoSection => 'Profile photo';

  @override
  String get profilePhotoHint =>
      'Shown next to your name across the platform. JPEG, PNG, WEBP or GIF, up to 5 MB.';

  @override
  String get profilePhotoChoose => 'Choose photo';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get profilePhotoUploading => 'Uploading photo...';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profilePhotoRemoved => 'Profile photo removed.';

  @override
  String get profilePhotoInvalid => 'Choose a JPEG, PNG, WEBP or GIF image.';

  @override
  String get profilePhotoTooLarge => 'The image must be 5 MB or smaller.';

  @override
  String get profilePhotoFailed => 'Could not read this image.';

  @override
  String get profilePersonalSection => 'Personal information';

  @override
  String get profilePersonalHint =>
      'Update your name, phone number and email address.';

  @override
  String get profilePersonalSaved => 'Your personal information was saved.';

  @override
  String get profileSecuritySection => 'Security';

  @override
  String get profileSecurityHint => 'Change the password you use to sign in.';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profilePasswordHint => 'At least 8 characters';

  @override
  String get profilePasswordTooShort => 'Use at least 8 characters.';

  @override
  String get profileEmailInvalid => 'Enter a valid email address.';

  @override
  String get profileWrongPassword => 'That current password is not correct.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsTerms => 'Terms & Conditions';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsRateApp => 'Rate IMMO BURUNDI';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirm => 'Sign out of IMMO BURUNDI?';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get currencyChanged => 'Currency changed';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsRequiresSignIn => 'Sign in to see your notifications';

  @override
  String get legalTermsTitle => 'Terms & Conditions';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalUnavailable => 'This document is not available offline.';

  @override
  String get legalReadOnSite => 'Read the full document on the website';

  @override
  String get offlineBanner => 'Offline - some things may not update';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'Network error — check your connection.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabSaved => 'Saved';

  @override
  String get tabYou => 'You';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutMissionBodyLong =>
      'From Bujumbura to Muyinga, we help buyers, tenants and investors discover verified properties while giving owners and professional agents the tools to reach the right audience. Every listing carries a transparent verification status and an original price, and our team works to keep the marketplace free of fraud.';

  @override
  String get aboutContactTitle => 'Contact us';

  @override
  String get aboutEmailSubject => 'Hello IMMO BURUNDI';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutCopy => 'Copy';

  @override
  String get aboutCopied => 'Copied to clipboard';

  @override
  String get contactAddressLabel => 'Head office';

  @override
  String get errorNoAppForLink => 'No app on this device can open that link.';

  @override
  String get errorSomethingWrongTitle => 'Something went wrong';

  @override
  String get errorRetry => 'Retry';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsClearCache => 'Clear cached images';

  @override
  String get settingsCacheCleared => 'Cache cleared';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsCookiePolicy => 'Cookie Policy';

  @override
  String get commonCurrency => 'Currency';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonYou => 'You';

  @override
  String get commonNow => 'now';

  @override
  String get commonNotify => 'Notify notifications';

  @override
  String get commonEstimate => 'estimate';

  @override
  String get commonEstimated => 'Estimated';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonPrevious => 'Back';

  @override
  String get navigationClose => 'Close';

  @override
  String get commonViewAll => 'View all';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get mediaViewPhotos => 'View photos';

  @override
  String get mediaOf => 'of';

  @override
  String get mediaPhoto => 'Photo';

  @override
  String get mediaPreviousPhoto => 'Previous photo';

  @override
  String get mediaNextPhoto => 'Next photo';

  @override
  String get mediaImageUnavailable => 'Image unavailable';

  @override
  String get commonDone => 'Done';

  @override
  String get commonPagination => 'Pagination';

  @override
  String get commonNext => 'Next';

  @override
  String get errorBoundaryBody =>
      'The app hit an unexpected error. Your data is safe - try again, or reload the page.';

  @override
  String get errorReload => 'Reload page';

  @override
  String get commonSend => 'Send';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSearch => 'Search';

  @override
  String get themeLightMode => 'Switch to light mode';

  @override
  String get themeDarkMode => 'Switch to dark mode';

  @override
  String get commonAll => 'All';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonFrom => 'from';

  @override
  String get commonTo => 'to';

  @override
  String get commonAnd => 'and';

  @override
  String get commonOr => 'or';

  @override
  String get commonMin => 'Min';

  @override
  String get commonMax => 'Max';

  @override
  String get commonAny => 'Any';

  @override
  String get commonFilters => 'Filters';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonPage => 'Page';

  @override
  String get commonOf => 'of';

  @override
  String get commonOptional => 'optional';

  @override
  String get commonRequired => 'required';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNa => 'N/A';

  @override
  String get commonResults => 'results';

  @override
  String get commonProperty => 'property';

  @override
  String get commonProperties => 'properties';

  @override
  String get commonViews => 'views';

  @override
  String get commonShowMore => 'Show more';

  @override
  String get commonShowLess => 'Show less';

  @override
  String get commonMore => 'More';

  @override
  String get commonCopy => 'Copied to clipboard';

  @override
  String get navHome => 'Home';

  @override
  String get navBuy => 'Buy';

  @override
  String get navRent => 'Rent';

  @override
  String get navLand => 'Land';

  @override
  String get navCommercial => 'Commercial';

  @override
  String get navFeatured => 'Featured';

  @override
  String get navVerified => 'Verified';

  @override
  String get navAgents => 'Agents';

  @override
  String get navAbout => 'About';

  @override
  String get navContact => 'Contact';

  @override
  String get navLogin => 'Log in';

  @override
  String get navRegister => 'Register';

  @override
  String get navLogout => 'Log out';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMessages => 'Messages';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSearch => 'Search';

  @override
  String get navMenu => 'Menu';

  @override
  String get navExplore => 'Explore';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navMore => 'More';

  @override
  String get navListProperty => 'List property';

  @override
  String get searchTitle => 'Search properties';

  @override
  String get searchPlaceholderShort => 'Search properties…';

  @override
  String get searchQuickLinks => 'Quick links';

  @override
  String get searchSegmentProperties => 'Properties';

  @override
  String get searchSegmentAgents => 'Agents';

  @override
  String get searchSegmentMore => 'More';

  @override
  String get searchSortBy => 'Sort by';

  @override
  String get searchAdvancedTitle => 'Advanced search';

  @override
  String get searchAdvancedDesc =>
      'Refine your search below — set a location, budget and bedrooms.';

  @override
  String get searchPropertyAgent => 'Search agents';

  @override
  String get searchPerson => 'Search people or properties';

  @override
  String get searchButton => 'Search';

  @override
  String get searchLocation => 'Location';

  @override
  String get searchPropertyType => 'Property type';

  @override
  String get searchMinPrice => 'Min price';

  @override
  String get searchMaxPrice => 'Max price';

  @override
  String get searchBedrooms => 'Bedrooms';

  @override
  String get searchPropertyId => 'Property ID';

  @override
  String get searchTabBuy => 'Buy';

  @override
  String get searchTabRent => 'Rent';

  @override
  String get searchTabLand => 'Land';

  @override
  String get searchTabCommercial => 'Commercial';

  @override
  String get searchTabInvestment => 'Investment';

  @override
  String get searchSort => 'Sort';

  @override
  String get searchSortNewest => 'Newest first';

  @override
  String get searchSortPriceAsc => 'Lowest price';

  @override
  String get searchSortPriceDesc => 'Highest price';

  @override
  String get searchSortViews => 'Most viewed';

  @override
  String get searchSortFeatured => 'Featured first';

  @override
  String get searchResults => 'Result';

  @override
  String get searchResultsPlural => 'Results';

  @override
  String get searchFilters => 'Filter results';

  @override
  String get searchPersonalize => 'Personalize results';

  @override
  String get searchResetFilters => 'Reset filters';

  @override
  String get searchProvince => 'Province';

  @override
  String get searchCommune => 'Commune';

  @override
  String get searchVerificationStatus => 'Verification';

  @override
  String get searchFeatured => 'Featured only';

  @override
  String get searchSurface => 'Surface area (m²)';

  @override
  String get searchMinSurface => 'Min surface';

  @override
  String get searchMaxSurface => 'Max surface';

  @override
  String get searchListingType => 'Listing type';

  @override
  String get searchPriceRange => 'Price range';

  @override
  String get searchCleared => 'Filters cleared';

  @override
  String get propertyBuyHint =>
      'Tell the agent about your interest in buying this property';

  @override
  String get propertyBuy => 'Buy';

  @override
  String get propertyForSale => 'For sale';

  @override
  String get propertyForRent => 'For rent';

  @override
  String get propertyForLease => 'For lease';

  @override
  String get propertyForAuction => 'Auction';

  @override
  String get propertyForInvestment => 'Investment';

  @override
  String get propertyIsNew => 'New';

  @override
  String get propertyIsPromoted => 'Promoted';

  @override
  String get propertyViews => 'views';

  @override
  String get propertyFavorites => 'favorites';

  @override
  String get propertyBedrooms => 'bed';

  @override
  String get propertyBathrooms => 'bath';

  @override
  String get propertySurface => 'm²';

  @override
  String propertyBedroomsShort(String count) {
    return '$count bedroom';
  }

  @override
  String propertyBedroomsShortPlural(String count) {
    return '$count bedrooms';
  }

  @override
  String propertyBathroomsShort(String count) {
    return '$count bathroom';
  }

  @override
  String propertyBathroomsShortPlural(String count) {
    return '$count bathrooms';
  }

  @override
  String get propertyFloors => 'floors';

  @override
  String get propertyParking => 'parking';

  @override
  String get propertyYearBuilt => 'Built';

  @override
  String get propertyRooms => 'rooms';

  @override
  String get propertyNotNegotiable => 'Not negotiable';

  @override
  String get propertyVerifyStatus => 'Verification status';

  @override
  String get propertyVerified => 'Verified';

  @override
  String get propertyPartial => 'Partially verified';

  @override
  String get propertyNotVerified => 'Not verified';

  @override
  String get propertyFullyVerified => 'Fully verified';

  @override
  String get propertyVerificationStatus => 'Verification';

  @override
  String get propertyDisclaimer =>
      'Verification is based on documents provided and does not guarantee ownership.';

  @override
  String get propertyContactAgent => 'Contact agent';

  @override
  String get propertyWhatsapp => 'WhatsApp';

  @override
  String get propertyMessage => 'Message';

  @override
  String get propertyRequestVisit => 'Request visit';

  @override
  String get propertyApplyRent => 'Apply to rent';

  @override
  String get propertyReport => 'Report';

  @override
  String get propertyRelatedProperties => 'Related properties';

  @override
  String get propertyAboutThis => 'About this property';

  @override
  String get propertyMap => 'Location map';

  @override
  String get propertyMapApproxNote => 'Approximate location';

  @override
  String get propertyMapHidden =>
      'The exact location of this property is hidden.';

  @override
  String get propertyPrice => 'Price';

  @override
  String get propertySpecs => 'Quick specs';

  @override
  String get propertySpecsTitle => 'Description & specs';

  @override
  String get propertySaved => 'Saved to favorites';

  @override
  String get propertyRemoved => 'Removed from favorites';

  @override
  String get propertyLoginToFavorite => 'Log in to save this property';

  @override
  String get propertyLoginToContact => 'Log in to contact the agent';

  @override
  String get propertySaves => 'saves';

  @override
  String get propertyLikes => 'likes';

  @override
  String get propertyMultipleAgents => 'Multiple agents';

  @override
  String get propertyViewMore => 'View more';

  @override
  String get propertySameAgent => 'Same agent';

  @override
  String get propertySameNeighborhood => 'Same neighborhood';

  @override
  String get propertyNoRelated => 'No related properties found';

  @override
  String get propertyAgentCard => 'Agent';

  @override
  String get propertyTopAgent => 'Top agent';

  @override
  String get propertyViewProfile => 'View profile';

  @override
  String get propertyAsk => 'Ask';

  @override
  String get propertyAskPlaceholder => 'Ask the agent a question…';

  @override
  String get propertyPhotos => 'photos';

  @override
  String get propertyQuestions => 'Questions';

  @override
  String get propertyNoQuestionsYet =>
      'No questions yet — be the first to ask.';

  @override
  String get relToday => 'Today';

  @override
  String relDaysAgo(String days) {
    return '${days}d ago';
  }

  @override
  String relWeeksAgo(String weeks) {
    return '${weeks}w ago';
  }

  @override
  String relMonthsAgo(String months) {
    return '${months}mo ago';
  }

  @override
  String relYearsAgo(String years) {
    return '${years}y ago';
  }

  @override
  String get propertyReportTitle => 'Report this property';

  @override
  String get propertyReportSuccess =>
      'Thank you. Your report has been submitted.';

  @override
  String get propertyGalleryFullscreen => 'Toggle fullscreen';

  @override
  String get propertyGalleryZoom => 'Zoom image';

  @override
  String get propertyGalleryThumbnails => 'Thumbnails';

  @override
  String get propertyPrimary => 'Main';

  @override
  String get propertyHome => 'Home';

  @override
  String get propertyPropertyId => 'Property ID';

  @override
  String get propertytypeHOUSE => 'House';

  @override
  String get propertytypeOFFICE => 'Office';

  @override
  String get propertytypeFARM => 'Farm';

  @override
  String get propertytypeAPARTMENT => 'Apartment';

  @override
  String get propertytypeSHOP => 'Shop';

  @override
  String get propertytypeINDUSTRIAL => 'Industrial';

  @override
  String get propertytypeVILLA => 'Villa';

  @override
  String get propertytypeWAREHOUSE => 'Warehouse';

  @override
  String get propertytypeOTHER => 'Other';

  @override
  String get propertytypeLAND => 'Land';

  @override
  String get propertytypeHOTEL => 'Hotel';

  @override
  String get propertytypeCOMMERCIAL => 'Commercial';

  @override
  String get propertytypeGUESTHOUSE => 'Guest house';

  @override
  String get verificationTitle => 'Document verification';

  @override
  String get verificationLearnMore => 'Learn more';

  @override
  String get verificationLandTitle => 'Land title';

  @override
  String get verificationSaleAgreement => 'Sale agreement';

  @override
  String get verificationTop => 'Proof of payment (TOP)';

  @override
  String get verificationPropertyTax => 'Property tax';

  @override
  String get verificationOwnerId => 'Owner ID';

  @override
  String get verificationOther => 'Other document';

  @override
  String get verificationPassed => 'Verified';

  @override
  String get verificationFailed => 'Failed';

  @override
  String get verificationNotApplicable => 'Not applicable';

  @override
  String get verificationVerifiedAt => 'Verified on';

  @override
  String get authLogin => 'Log in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authEmail => 'Email address';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authPassword => 'Password';

  @override
  String get authFullName => 'Full name';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHasAccount => 'Already have an account?';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authLoginTabPhone => 'Phone';

  @override
  String get authLoginTabEmail => 'Email';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authRegisterWelcome => 'Join IMMO BURUNDI';

  @override
  String get authLoginSuccess => 'Logged in successfully';

  @override
  String get authRegisterSuccess => 'Account created successfully';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authTermsPrefix => 'By continuing you accept our';

  @override
  String get authTermsLink => 'Terms & Conditions';

  @override
  String get authPhoneRequired => 'Phone number is required';

  @override
  String get authNameRequired => 'Name is required';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authTerms => 'Terms & Conditions';

  @override
  String get authLogout => 'Log out';

  @override
  String get authSignUpEyebrow => 'JOIN IMMO BURUNDI';

  @override
  String get authSignUpTitle => 'Create your account';

  @override
  String get authSignUpSubtitle =>
      'Save your favorite properties, message agents and get notified about new listings.';

  @override
  String get authLogInEyebrow => 'WELCOME BACK';

  @override
  String get authLogInSubtitle =>
      'Log back in to manage your favorites, messages and visits.';

  @override
  String get authPasswordPlaceholder => 'At least 8 characters';

  @override
  String get authNamePlaceholder => 'Jean Ndayishimiye';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authPhonePlaceholder => '+257 79 000 000';

  @override
  String get dashboardTitle => 'My dashboard';

  @override
  String get dashboardAgentTitle => 'Agent dashboard';

  @override
  String get dashboardFavorites => 'My favorites';

  @override
  String get dashboardRecentViews => 'Recent watched';

  @override
  String get dashboardApplications => 'Applications';

  @override
  String get dashboardVisits => 'My visits';

  @override
  String get dashboardMessages => 'Messages';

  @override
  String get dashboardNotifications => 'Notifications';

  @override
  String get dashboardProfile => 'Profile';

  @override
  String get dashboardEditProfile => 'Edit profile';

  @override
  String get dashboardSaveChanges => 'Save changes';

  @override
  String get dashboardLanguage => 'Preferred language';

  @override
  String get dashboardCurrency => 'Preferred currency';

  @override
  String get dashboardSignedInAs => 'Signed in as';

  @override
  String get dashboardProfileUpdated => 'Profile updated';

  @override
  String get dashboardPasswordChanged => 'Password changed';

  @override
  String get dashboardSettings => 'Settings';

  @override
  String get dashboardMyProperties => 'Properties';

  @override
  String get dashboardPropFilterAll => 'All';

  @override
  String get dashboardPropFilterActive => 'Active';

  @override
  String get dashboardPropFilterReview => 'In review';

  @override
  String get dashboardPropFilterChanges => 'Needs changes';

  @override
  String get dashboardPropFilterRejected => 'Rejected';

  @override
  String get dashboardPropFilterDraft => 'Drafts';

  @override
  String get dashboardPropFilterArchive => 'Archive';

  @override
  String get dashboardPropFilterSold => 'Sold';

  @override
  String get dashboardPropFilterRented => 'Rented';

  @override
  String get dashboardRelistProperty => 'Publish again';

  @override
  String dashboardRelistPropertyConfirm(String title) {
    return 'Publish $title again? An admin must approve it before it goes back live.';
  }

  @override
  String get dashboardBookings => 'Bookings';

  @override
  String get dashboardAnalytics => 'Analytics';

  @override
  String get dashboardVerification => 'Verification';

  @override
  String get dashboardListProperty => 'List property';

  @override
  String get dashboardProperties => 'Properties';

  @override
  String get dashboardOverview => 'Overview';

  @override
  String get dashboardAgents => 'Agents';

  @override
  String get dashboardRequests => 'Requests';

  @override
  String get dashboardNoPropertiesDesc =>
      'List a property to start managing it here.';

  @override
  String get dashboardNoBookings => 'No bookings yet';

  @override
  String get dashboardNoBookingsDesc =>
      'Visit requests for your properties will appear here.';

  @override
  String get dashboardNoVerification => 'No verification requests';

  @override
  String get dashboardNoVerificationDesc =>
      'Request verification for a property to have it reviewed.';

  @override
  String get dashboardProperty => 'Property';

  @override
  String get dashboardConfirm => 'Confirm';

  @override
  String get dashboardCancel => 'Cancel';

  @override
  String get dashboardStatViews => 'Total views';

  @override
  String get dashboardStatLikes => 'Total likes';

  @override
  String get dashboardStatShares => 'Total shares';

  @override
  String get dashboardStatBookings => 'Visit bookings';

  @override
  String get dashboardStatEnquiries => 'Enquiries';

  @override
  String get dashboardPerProperty => 'Per property';

  @override
  String get navMyProperties => 'My properties';

  @override
  String get navHelp => 'Help';

  @override
  String get navFeedback => 'Send feedback';

  @override
  String get dashboardHome => 'Dashboard';

  @override
  String get dashboardInbox => 'Bookings & Inquiries';

  @override
  String get dashboardSidebarAgency => 'Your agency';

  @override
  String get dashboardSidebarProfile => 'Profile';

  @override
  String get dashboardAddNew => 'Add property';

  @override
  String get dashboardClearFilters => 'Clear all';

  @override
  String get dashboardSearchProperties =>
      'Search by title, reference or description';

  @override
  String dashboardResultsCount(String from, String to, num total) {
    return 'Showing $from-$to of $total';
  }

  @override
  String get dashboardNoSearchResults =>
      'No properties match your search. Try a different term or clear the search.';

  @override
  String get dashboardRequester => 'Requester';

  @override
  String get dashboardAllStatuses => 'All statuses ▾';

  @override
  String get dashboardCardsListTitle => 'List your first property';

  @override
  String get dashboardCardsListDesc =>
      'Publish a listing to start receiving views and inquiries.';

  @override
  String get dashboardCardsListCta => 'Add property';

  @override
  String get dashboardCardsAnalyticsTitle => 'Analytics';

  @override
  String get dashboardCardsAnalyticsDesc =>
      'Track views, favorites and lead enquiries for each property.';

  @override
  String get dashboardCardsAnalyticsCta => 'View analytics';

  @override
  String get dashboardCardsTipsTitle => 'Agent tips';

  @override
  String get dashboardCardsTip1 =>
      'High-quality photos can increase visits by up to 70%.';

  @override
  String get dashboardCardsTip2 => 'Reply to inquiries within the first hour.';

  @override
  String get dashboardCardsTip3 =>
      'Mark the deal as agreed before sending a payment link.';

  @override
  String get dashboardColProperty => 'Property';

  @override
  String get dashboardColFlags => 'Flags';

  @override
  String get dashboardColStatus => 'Status';

  @override
  String get dashboardColListed => 'Date listed';

  @override
  String get dashboardColViews => 'Views';

  @override
  String get dashboardColInquiries => 'Inquiries';

  @override
  String get dashboardEmptyProps => 'No properties yet';

  @override
  String get dashboardEmptyPropsDesc =>
      'Create your first listing to start building your portfolio.';

  @override
  String get dashboardColActions => 'Actions';

  @override
  String get dashboardEditProperty => 'Edit property';

  @override
  String get dashboardDeleteProperty => 'Delete property';

  @override
  String get dashboardRequestVerification => 'Request verification';

  @override
  String get dashboardRequestVerificationDesc =>
      'Send this property to the IMMO BURUNDI team for verification. An officer will review the documents and contact you if anything is missing.';

  @override
  String get dashboardVerificationRequested => 'Verification requested';

  @override
  String get dashboardVerificationCode => 'Reference';

  @override
  String get dashboardVerificationNote => 'Note for the verification team';

  @override
  String get dashboardVerificationNotePlaceholder =>
      'Anything the officer should know (optional)';

  @override
  String get dashboardVerificationPending => 'Verification already in progress';

  @override
  String get dashboardVerified => 'Verified';

  @override
  String get dashboardVerificationIntro =>
      'Track every property you manage: what is still waiting on a decision, what is already verified, and exactly what to fix before the administration accepts a listing.';

  @override
  String get dashboardVerificationPendingSection => 'Pending verification';

  @override
  String get dashboardVerificationVerifiedSection => 'Verified properties';

  @override
  String get dashboardVerificationActionSection => 'Needs your attention';

  @override
  String get dashboardVerificationNoPending =>
      'No property is waiting on a verification decision.';

  @override
  String get dashboardVerificationNoVerified =>
      'None of your properties are verified yet.';

  @override
  String get dashboardVerificationNoAction =>
      'Nothing to fix — every property you manage is complete.';

  @override
  String get dashboardVerificationEmpty =>
      'You do not manage any property yet. Add a property to start tracking its verification.';

  @override
  String get dashboardVerificationEmptyCta => 'Go to my properties';

  @override
  String get dashboardVerificationWhatToUpdate =>
      'What to update for acceptance';

  @override
  String get dashboardVerificationAllMet =>
      'Every requirement is met. This property is ready for a verification decision.';

  @override
  String get dashboardVerificationAdminNote => 'Note from the administration';

  @override
  String get dashboardVerificationReviewNote => 'Note from the review team';

  @override
  String get dashboardVerificationRequestedOn => 'Requested';

  @override
  String get dashboardVerificationReviewedBy => 'Reviewed by';

  @override
  String get dashboardVerificationDocuments => 'Attached documents';

  @override
  String get dashboardVerificationNoDocuments => 'No document attached yet.';

  @override
  String get dashboardVerificationMissing => 'missing';

  @override
  String get dashboardVerificationProvided => 'provided';

  @override
  String get dashboardVerificationCount => 'items to fix';

  @override
  String get dashboardVerificationAdminDecides =>
      'A system administrator reviews and decides the final verification. You cannot mark a property as verified yourself.';

  @override
  String get dashboardVerificationView => 'View details';

  @override
  String get verifyreqDocumentLANDTITLE => 'Land title (titre foncier)';

  @override
  String get verifyreqDocumentOWNERID => 'Owner identification';

  @override
  String get verifyreqDocumentSALEAGREEMENT => 'Signed sale agreement';

  @override
  String get verifyreqDocumentTOP => 'Town planning certificate (TOP)';

  @override
  String get verifyreqDocumentPROPERTYTAX => 'Property tax receipt';

  @override
  String get verifyreqDocumentOTHER => 'Other supporting document';

  @override
  String get verifyreqFieldTitle => 'Listing title';

  @override
  String get verifyreqFieldDescription => 'Description';

  @override
  String get verifyreqFieldPrice => 'Price';

  @override
  String get verifyreqFieldSurfaceArea => 'Surface area';

  @override
  String get verifyreqFieldLocation => 'Province and commune';

  @override
  String get verifyreqFieldMedia => 'At least one photo';

  @override
  String get verificationPropertiesTab => 'Properties';

  @override
  String get verificationAgentsTab => 'Agents';

  @override
  String get verificationShowCompleted => 'Show completed';

  @override
  String get verificationNoPendingProperties =>
      'No property awaiting verification';

  @override
  String get verificationNoPendingPropertiesDesc =>
      'New requests from agents will appear here for review.';

  @override
  String get verificationNoPendingAgents => 'No agent awaiting verification';

  @override
  String get verificationNoPendingAgentsDesc =>
      'New agents appear here until you verify them.';

  @override
  String verificationRequestedOn(String date) {
    return 'Requested $date';
  }

  @override
  String verificationRegisteredOn(String date) {
    return 'Joined $date';
  }

  @override
  String get verificationAgent => 'Listed agent';

  @override
  String get verificationNoAgent => 'No agent assigned to this property.';

  @override
  String get verificationVerify => 'Verify';

  @override
  String get verificationReject => 'Reject';

  @override
  String get verificationRejectTitle => 'Reject verification';

  @override
  String get verificationRejectDesc =>
      'The requester is notified with your reason, so make it clear and actionable.';

  @override
  String get verificationReason => 'Reason';

  @override
  String get verificationReasonPlaceholder => 'What is missing or wrong?';

  @override
  String get verificationReasonHint =>
      'This reason is sent to the agent and shown on the request.';

  @override
  String get verificationReasonRequired =>
      'A reason is required to reject a verification.';

  @override
  String get verificationConfirmReject => 'Confirm rejection';

  @override
  String get verificationRejectionReason => 'Rejection reason';

  @override
  String get verificationLicenseNumber => 'License number';

  @override
  String get verificationProvince => 'Province';

  @override
  String verificationAgentStatus(String status) {
    return 'Agent: $status';
  }

  @override
  String verificationAgentWhatsappMessage(String title) {
    return 'Hello, this is the IMMO BURUNDI verification team about \"$title\".';
  }

  @override
  String dashboardDeletePropertyConfirm(String title) {
    return 'Delete \"$title\"? This listing will be removed for good.';
  }

  @override
  String get dashboardBlockedByAdmin => 'Blocked by the administration';

  @override
  String get dashboardTabBookings => 'Viewing requests';

  @override
  String get dashboardTabEnquiries => 'Buying requests';

  @override
  String get dashboardTabMessages => 'Messages';

  @override
  String get dashboardContact => 'Contact';

  @override
  String get dashboardWhatsApp => 'Chat on WhatsApp';

  @override
  String get dashboardSendLink => 'Send payment link';

  @override
  String get dashboardCopyLink => 'Copy link';

  @override
  String get dashboardMarkDeal => 'Mark deal agreed';

  @override
  String get dashboardLinkCopied => 'Link copied to clipboard';

  @override
  String get dashboardNoInbox => 'No requests yet';

  @override
  String get dashboardNoInboxDesc =>
      'Visit requests and buying inquiries for your properties will appear here.';

  @override
  String get bookingStatusPENDING => 'Pending';

  @override
  String get bookingStatusCONFIRMED => 'Accepted';

  @override
  String get bookingStatusCOMPLETED => 'Deal agreed';

  @override
  String get bookingStatusCANCELLED => 'Declined';

  @override
  String get bookingStatusNOSHOW => 'No show';

  @override
  String get bookingStatusDEALAGREED => 'Deal agreed';

  @override
  String get enquiryStatusNEW => 'New';

  @override
  String get enquiryStatusOPEN => 'Open';

  @override
  String get enquiryStatusINPROGRESS => 'In progress';

  @override
  String get enquiryStatusRESPONDED => 'Responded';

  @override
  String get enquiryStatusDEALAGREED => 'Deal agreed';

  @override
  String get enquiryStatusCLOSED => 'Closed';

  @override
  String get dealAgreed => 'Agreed';

  @override
  String get dealTitle => 'Mark deal as agreed?';

  @override
  String get dealDesc =>
      'This unlocks sending a payment link to the requester.';

  @override
  String get dealConfirm => 'Yes, mark agreed';

  @override
  String get plinkStatusCREATED => 'Link sent';

  @override
  String get plinkStatusSENT => 'Link sent';

  @override
  String get plinkStatusOPENED => 'Opened';

  @override
  String get plinkStatusPAID => 'Paid';

  @override
  String get plinkStatusCANCELLED => 'Cancelled';

  @override
  String get plinkStatusEXPIRED => 'Expired';

  @override
  String get analyticsTabOverview => 'Overview';

  @override
  String get analyticsTabProperties => 'Properties';

  @override
  String get analyticsTabClients => 'Clients';

  @override
  String get analyticsTabTrends => 'Trends';

  @override
  String get analyticsPeriod => 'Last 28 days';

  @override
  String get analyticsAvgTime => 'Avg. time on listing';

  @override
  String get analyticsStatLeads => 'Leads';

  @override
  String get analyticsStatRealtime => 'Realtime';

  @override
  String get analyticsRealtimeDesc =>
      'Live activity on your published properties.';

  @override
  String get analyticsNoData => 'No activity yet in this period';

  @override
  String get analyticsViewsShort => 'Views';

  @override
  String get analyticsFavoritesShort => 'Favorites';

  @override
  String get analyticsInquiriesShort => 'Inquiries';

  @override
  String get listDropTitle => 'Upload property photos';

  @override
  String get listDropHint =>
      'Add one photo URL per line — the first image becomes the cover.';

  @override
  String get listSelectFiles => 'Select files';

  @override
  String get listNeedHelp => 'Need help? We\'re here to assist.';

  @override
  String get listUploadNotice =>
      'Photos are public. Do not include personal documents.';

  @override
  String listPhotoCountOk(num count) {
    return 'Enough photos ($count added).';
  }

  @override
  String listPhotoCountMissing(num count) {
    return 'Add $count more photo(s) — at least 4 are required.';
  }

  @override
  String get listPhotoUploading => 'Uploading photos…';

  @override
  String get listPhotoFailed => 'Failed';

  @override
  String get listRemovePhoto => 'Remove photo';

  @override
  String get listPropertyAdded => 'Property added';

  @override
  String get listPropertyAddedBody => 'It is now in your property list.';

  @override
  String get listPropertyUpdated => 'Property updated';

  @override
  String get listPropertyUpdatedBody => 'Your changes have been saved.';

  @override
  String listPropertyPhotosSaved(num count) {
    return '$count photo(s) saved';
  }

  @override
  String get listSavedAsDraft =>
      'Saved as a draft. Submit it for review when you are ready.';

  @override
  String get listSubmittedForReview =>
      'Submitted for review. An admin will check it before it goes live.';

  @override
  String get listDropzoneHint =>
      'Drag photos here, or choose files. You can drop several at once.';

  @override
  String get listDropActive => 'Drop your photos to upload them';

  @override
  String listPhotoLimit(num count) {
    return 'A listing can hold at most $count photos.';
  }

  @override
  String get payTitle => 'Payment';

  @override
  String get paySecure => 'Secure payment link';

  @override
  String get payAmountLabel => 'Amount to pay';

  @override
  String get payPropertyLabel => 'Property';

  @override
  String get payTo => 'For:';

  @override
  String get payConfirm => 'Confirm payment';

  @override
  String get payProcessing => 'Processing…';

  @override
  String get paySuccess => 'Payment received';

  @override
  String paySuccessDesc(String reference) {
    return 'Thank you. Your payment reference is $reference.';
  }

  @override
  String get payBackToHome => 'Back to home';

  @override
  String get payLoginPrompt => 'Sign in to continue';

  @override
  String get payLoginPromptDesc =>
      'This is a secure payment link. Sign in to the account it was sent to.';

  @override
  String get payNotForYou => 'This link is for a different account';

  @override
  String get payNotForYouDesc =>
      'Please sign in with the account that received this payment link.';

  @override
  String get payLinkInvalid => 'Invalid payment link';

  @override
  String get payLinkInvalidDesc =>
      'The link is missing, was removed, or has expired.';

  @override
  String get payAlreadyPaid => 'Already paid';

  @override
  String get payAlreadyPaidDesc => 'This payment link was already completed.';

  @override
  String get payGoToLogin => 'Go to sign in';

  @override
  String get payGoSignup => 'Create account';

  @override
  String get payChangeAccount => 'Switch account';

  @override
  String payPaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String get payPanelTitle => 'Pay with your mobile money';

  @override
  String get payPanelDesc =>
      'All mobile money services available in Burundi. Pick your wallet, then enter the number you want to charge on the left.';

  @override
  String get payPanelFootnote =>
      'You will get a prompt on your phone to confirm the payment with your PIN.';

  @override
  String get payProviderLabel => 'Mobile money service';

  @override
  String get payPickProvider => 'Choose a mobile money service';

  @override
  String get payPhoneLabel => 'Mobile money number';

  @override
  String get payPhoneHint =>
      'The number registered with your mobile money operator.';

  @override
  String get payInvalidNumber =>
      'Enter a valid Burundian mobile money number, for example 79 11 10 01.';

  @override
  String get payConfirmPrompt => 'Confirm on';

  @override
  String get payProviderLUMICASH => 'Lumicash';

  @override
  String get payProviderECOCASH => 'EcoCash';

  @override
  String get payProviderIHELA => 'iHela';

  @override
  String get listTitle => 'List your property';

  @override
  String get listSubtitle =>
      'Add your property details — it will be submitted for review by an admin.';

  @override
  String get listDetails => 'Property details';

  @override
  String get listTitleLabel => 'Title';

  @override
  String get listPropertyType => 'Property type';

  @override
  String get listListingType => 'Listing type';

  @override
  String get listPrice => 'Price';

  @override
  String get listCurrency => 'Currency';

  @override
  String get listSurface => 'Surface area (m²)';

  @override
  String get listBedrooms => 'Bedrooms';

  @override
  String get listBathrooms => 'Bathrooms';

  @override
  String get listLocation => 'Location';

  @override
  String get listProvince => 'Province';

  @override
  String get listCommune => 'Commune';

  @override
  String get listAddress => 'Address';

  @override
  String get listNegotiable => 'Price is negotiable';

  @override
  String get listPhotos => 'Photos';

  @override
  String get listPhotosPlaceholder =>
      'https://…/photo1.jpg\nhttps://…/photo2.jpg';

  @override
  String get listSubmit => 'Submit property';

  @override
  String get listCancel => 'Cancel';

  @override
  String get footerDescription =>
      'IMMO BURUNDI connects owners, buyers, tenants, investors and trusted agents across Burundi.';

  @override
  String get footerCompany => 'Company';

  @override
  String get footerServices => 'Services';

  @override
  String get footerLegal => 'Legal';

  @override
  String get footerSocial => 'Follow us';

  @override
  String get footerLinksAboutUs => 'About us';

  @override
  String get footerLinksContact => 'Contact';

  @override
  String get footerLinksCareers => 'Careers';

  @override
  String get footerLinksPartners => 'Partners';

  @override
  String get footerLinksBuy => 'Buy';

  @override
  String get footerLinksRent => 'Rent';

  @override
  String get footerLinksSell => 'Sell';

  @override
  String get footerLinksVerification => 'Verification';

  @override
  String get footerLinksPromotion => 'Promotion';

  @override
  String get footerLinksPrivacy => 'Privacy policy';

  @override
  String get footerLinksTerms => 'Terms & conditions';

  @override
  String get footerLinksVerificationDisclaimer => 'Verification disclaimer';

  @override
  String get footerLinksCookies => 'Cookie policy';

  @override
  String get footerTagline => 'Real Estate Marketplace';

  @override
  String get errorNotFound => 'Page not found';

  @override
  String get errorNotFoundDesc =>
      'The page you are looking for does not exist or has been moved.';

  @override
  String get errorNoPermission =>
      'You do not have permission to access this section.';

  @override
  String get errorTryAgain => 'Please try again';

  @override
  String get errorBackHome => 'Back to home';

  @override
  String get errorForbidden => 'Forbidden';

  @override
  String get errorInvalidData => 'Please check the information you entered.';

  @override
  String get errorLoadFailed => 'Failed to load data';

  @override
  String get errorPropertyLoadFail => 'Unable to load this property.';

  @override
  String get emptyNoProperties => 'No properties found';

  @override
  String get emptyNoPropertiesDesc =>
      'Try adjusting your filters or search for something else.';

  @override
  String get emptyNoFavorites => 'No favorites yet';

  @override
  String get emptyNoFavoritesDesc =>
      'Tap the heart on any property to save it here.';

  @override
  String get emptyNoResults => 'No results';

  @override
  String get emptyNoResultsDesc =>
      'We could not find anything matching your search.';

  @override
  String get emptyNoMessages => 'No conversations';

  @override
  String get emptyNoMessagesDesc =>
      'Message an agent about a property you like.';

  @override
  String get emptyNoNotifications => 'You are all caught up';

  @override
  String get emptyNoNotificationsDesc => 'Notifications will appear here.';

  @override
  String get emptyNoVisits => 'No upcoming visits';

  @override
  String get emptyNoVisitsDesc => 'Book a visit from any property page.';

  @override
  String get emptyNoApplications => 'No requests yet';

  @override
  String get emptyNoApplicationsDesc =>
      'Buy requests and rental applications you send will appear here.';

  @override
  String get applicationsBuyRequest => 'Buy request';

  @override
  String get applicationsRentApplication => 'Rent application';

  @override
  String get applicationsViewProperty => 'View property';

  @override
  String get requestsTitle => 'My requests';

  @override
  String get enquiriesTitle => 'My enquiries';

  @override
  String get enquiriesEmpty => 'No enquiries yet';

  @override
  String get enquiriesEmptyDesc =>
      'Enquiries you send about a property will appear here.';

  @override
  String get applicationsTitle => 'My applications';

  @override
  String get applicationsEmpty => 'No applications yet';

  @override
  String get applicationsEmptyDesc =>
      'Rental applications you send will appear here.';

  @override
  String get applyNotARental =>
      'This property is not available for rent, so an application cannot be sent.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationNumber => 'Enter a whole number';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get applyFullName => 'Full name';

  @override
  String get applyPhone => 'Phone number';

  @override
  String get applyEmail => 'Email';

  @override
  String get applyAddress => 'Current address';

  @override
  String get applyOccupants => 'People in total';

  @override
  String get applyChildren => 'Children';

  @override
  String get applyOccupation => 'Occupation';

  @override
  String get applyMoveInDate => 'Move-in date';

  @override
  String get applyMoveInPick => 'Choose a date';

  @override
  String get applyMoveInRequired => 'Choose a move-in date';

  @override
  String get applyAdvanceAvailable => 'I can pay the advance';

  @override
  String get applyAdvanceHint =>
      'Most landlords ask for one or more months up front.';

  @override
  String get applyAdvanceYes => 'Advance available';

  @override
  String get applyAdvanceNo => 'No advance available';

  @override
  String get applyReviewNotes => 'Agent\'\'s note';

  @override
  String get applyWithdraw => 'Withdraw';

  @override
  String get applyWithdrawTitle => 'Withdraw this application?';

  @override
  String get applyWithdrawBody =>
      'The agent will no longer see it. You can apply again later.';

  @override
  String get applyWithdrawConfirm => 'Withdraw';

  @override
  String get applyWithdrawn => 'Application withdrawn';

  @override
  String get applyStatusSubmitted => 'Submitted';

  @override
  String get applyStatusUnderReview => 'Under review';

  @override
  String get applyStatusShortlisted => 'Shortlisted';

  @override
  String get applyStatusAccepted => 'Accepted';

  @override
  String get applyStatusRejected => 'Not accepted';

  @override
  String get applyStatusWithdrawn => 'Withdrawn';

  @override
  String get emptyNoRecentViews => 'No recent views';

  @override
  String get emptyNoRecentViewsDesc => 'Properties you view will appear here.';

  @override
  String get homeTagline => 'Find your next home in Burundi';

  @override
  String get homeSubtitle =>
      'Verified properties, trusted agents, and transparent pricing from Bujumbura to Muyinga.';

  @override
  String get homeForYou => 'For You';

  @override
  String get homeSaved => 'Saved';

  @override
  String get feedTitle => 'Recommended for you';

  @override
  String get feedDesc =>
      'Hand-picked listings based on what people like you are searching.';

  @override
  String get feedPersonalize => 'Personalize your feed';

  @override
  String get feedPersonalizeDesc =>
      'Tell us what you are looking for and we will tailor your feed.';

  @override
  String get tilesApartments => 'Apartments';

  @override
  String get tilesHouses => 'Houses';

  @override
  String get tilesLand => 'Land';

  @override
  String get tilesCommercial => 'Commercial';

  @override
  String get tilesRentals => 'Rentals';

  @override
  String get tilesForSale => 'For Sale';

  @override
  String get tilesVillas => 'Villas';

  @override
  String get tilesExplore => 'Explore more';

  @override
  String get homeFeatured => 'Featured properties';

  @override
  String get homeRecent => 'Recently added';

  @override
  String get homeRecentDesc => 'Fresh listings published in the last 30 days.';

  @override
  String get homeVerified => 'Verified properties';

  @override
  String get homeVerifiedDesc => 'Documents checked by our verification team.';

  @override
  String get homePopularLocations => 'Popular locations';

  @override
  String get homePopularLocationsDesc =>
      'Where property seekers look the most.';

  @override
  String get homeHowItWorks => 'How IMMO BURUNDI works';

  @override
  String get homeStep1Title => 'Search';

  @override
  String get homeStep1Desc =>
      'Browse thousands of listings across every province of Burundi.';

  @override
  String get homeStep2Title => 'Verify';

  @override
  String get homeStep2Desc => 'Documents are checked by our verification team.';

  @override
  String get homeStep3Title => 'Visit';

  @override
  String get homeStep3Desc => 'Book a visit directly from the listing.';

  @override
  String get homeStep4Title => 'Buy or rent';

  @override
  String get homeStep4Desc => 'Close securely with a trusted agent.';

  @override
  String get heroLine1 => 'FIND YOUR';

  @override
  String get heroLine2 => 'PERFECT HOME';

  @override
  String get heroLine3 => 'TODAY';

  @override
  String get heroWelcome =>
      'Welcome to IMMO BURUNDI — start your search below.';

  @override
  String get heroDesc =>
      'We provide tailored real estate solutions, guiding you through every step with personalized experiences that meet your unique needs and aspirations.';

  @override
  String get heroStatsListings => 'Listings';

  @override
  String get heroStatsProvinces => 'Provinces';

  @override
  String get heroStatsVerified => 'Verified';

  @override
  String get heroAgentsLabel => 'Expert agents';

  @override
  String get aboutHeroTitle => 'About IMMO BURUNDI';

  @override
  String get aboutHeroSubtitle =>
      'A modern, trustworthy real estate marketplace for Burundi.';

  @override
  String get aboutMissionTitle => 'Our mission';

  @override
  String get aboutMissionBody =>
      'IMMO BURUNDI connects property owners, buyers, tenants, investors and professional agents on a single transparent platform. We make finding, verifying and transacting on property in Burundi simple and secure.';

  @override
  String get aboutValuesTitle => 'Our values';

  @override
  String get aboutValuesTrust => 'Trust';

  @override
  String get aboutValuesTrustDesc =>
      'Every listing is verified by a dedicated team before it is promoted.';

  @override
  String get aboutValuesTransparency => 'Transparency';

  @override
  String get aboutValuesTransparencyDesc =>
      'Original prices, verification status and document checks are always shown.';

  @override
  String get aboutValuesQuality => 'Quality';

  @override
  String get aboutValuesQualityDesc =>
      'We work with verified agents and complete, accurate property descriptions.';

  @override
  String get aboutValuesAccessibility => 'Accessibility';

  @override
  String get aboutValuesAccessibilityDesc =>
      'Available in French, English and Swahili, built for every device.';

  @override
  String get contactTitle => 'Contact us';

  @override
  String get contactSubtitle =>
      'Questions, feedback or partnership ideas — we would love to hear from you.';

  @override
  String get contactName => 'Full name';

  @override
  String get contactPhone => 'Phone number';

  @override
  String get contactEmail => 'Email address';

  @override
  String get contactSubject => 'Subject';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactSubmit => 'Send message';

  @override
  String get contactSendSuccess =>
      'Your message has been sent. We will reply shortly.';

  @override
  String get contactSendError =>
      'We could not send your message. Please try again.';

  @override
  String get contactOffice => 'Head office';

  @override
  String get contactHours => 'Business hours';

  @override
  String get contactHoursValue => 'Monday – Saturday, 8:00 – 18:00';

  @override
  String get contactPhoneLabel => 'Phone';

  @override
  String get contactWhatsappLabel => 'WhatsApp';

  @override
  String get contactEmailLabel => 'Email';

  @override
  String get contactAddressValue =>
      'Chaussée Prince Louis Rwagasore, Bujumbura, Burundi';

  @override
  String get contactWhatsappCta => 'Chat on WhatsApp';

  @override
  String get contactChatTitle => 'Contact the agent';

  @override
  String get contactAgent => 'Agent';

  @override
  String get contactCallCta => 'Call the agent';

  @override
  String get contactNoPhone =>
      'This agent has not published a phone number yet.';

  @override
  String contactWhatsappProperty(String title) {
    return 'Hello, I am interested in \"$title\". Is it still available?';
  }

  @override
  String get contactWhatsappGeneric =>
      'Hello, I would like to know more about this property.';

  @override
  String get contactVisitBooked =>
      'Your visit is booked. Contact the agent if anything changes.';

  @override
  String get contactBuyRequested =>
      'Request sent. Contact the agent to go further.';

  @override
  String get contactListTitle => 'List your property';

  @override
  String get contactListSubtitle =>
      'Selling or renting? Publish on IMMO BURUNDI in minutes and reach thousands of buyers and tenants.';

  @override
  String get contactListButton => 'Get started';

  @override
  String get contactListEmail => 'hello@immoburundi.bi';

  @override
  String get catEyebrow => 'EXPLORE';

  @override
  String get catBuyTitle => 'Properties for sale';

  @override
  String get catBuySubtitle =>
      'Houses, apartments, villas and more across every province of Burundi.';

  @override
  String get catRentTitle => 'Properties for rent';

  @override
  String get catRentSubtitle =>
      'Apartments, houses and villas available for rent.';

  @override
  String get catLandTitle => 'Land for sale';

  @override
  String get catLandSubtitle => 'Land plots across all provinces of Burundi.';

  @override
  String get catCommercialTitle => 'Commercial properties';

  @override
  String get catCommercialSubtitle =>
      'Shops, offices, warehouses and industrial spaces.';

  @override
  String get catFeaturedTitle => 'Featured properties';

  @override
  String get catFeaturedSubtitle =>
      'Hand-picked listings promoted by our team.';

  @override
  String get catVerifiedTitle => 'Verified properties';

  @override
  String get catVerifiedSubtitle =>
      'Documents checked by our verification team.';

  @override
  String get catOpenSearch => 'View all in search';

  @override
  String get agentsEyebrow => 'NETWORK';

  @override
  String get agentsTitle => 'Our trusted agents';

  @override
  String get agentsSubtitle =>
      'Verified professionals helping you buy, sell and rent with confidence.';

  @override
  String get agentsTop => 'Top agent';

  @override
  String get agentsListings => 'Listings';

  @override
  String get agentsEmpty => 'No agents found';

  @override
  String get agentsEmptyDesc =>
      'We could not find any agents matching your search.';

  @override
  String get agentLatest => 'Latest';

  @override
  String get agentPopular => 'Popular';

  @override
  String get agentPriceAsc => 'Lowest price';

  @override
  String get agentPriceDesc => 'Highest price';

  @override
  String get agentSubscribe => 'Subscribe';

  @override
  String get agentSubscribed => 'Subscribed';

  @override
  String get agentPublished => 'published assets';

  @override
  String get agentAgentCode => 'Agent code';

  @override
  String get agentRating => 'Rating';

  @override
  String get agentMemberSince => 'Member since';

  @override
  String get agentNoBio => 'This agent has not added a biography yet.';

  @override
  String get agentEmpty => 'No published assets yet';

  @override
  String get agentEmptyDesc => 'This agent has not published any property yet.';

  @override
  String get agentNotFound => 'Agent not found';

  @override
  String get agentNotFoundDesc =>
      'This agent may be inactive or the link may be wrong.';

  @override
  String get agentAgency => 'Agency';

  @override
  String get agentHome => 'Home';

  @override
  String get agentListings => 'Listings';

  @override
  String get agentReviews => 'Reviews';

  @override
  String get agentRecent => 'Recent listings';

  @override
  String get agentActiveListings => 'active listings';

  @override
  String agentReviewsCount(num count) {
    return '$count reviews';
  }

  @override
  String get agentSearchPlaceholder => 'Search this agent\'s listings';

  @override
  String agentMoreLinks(num count) {
    return 'and $count more';
  }

  @override
  String get agentReviewsEmpty => 'No written reviews yet';

  @override
  String get agentReviewsEmptyDesc =>
      'Ratings and transaction history are shown below; written reviews are coming soon.';

  @override
  String get agentSoldHidden =>
      'Sold listings are only shown to signed-in users.';

  @override
  String get agentSales => 'Sales';

  @override
  String get agentDeals => 'Deals closed';

  @override
  String get agentMore => 'more';

  @override
  String get visitBookVisit => 'Book visit';

  @override
  String get visitPlacesRemaining => 'places remaining';

  @override
  String get visitBookingClosesIn => 'Booking closes in';

  @override
  String get visitDate => 'Date';

  @override
  String get visitTime => 'Time';

  @override
  String get visitSessionFull => 'Session full';

  @override
  String get visitNoSessions => 'No visit sessions available right now.';

  @override
  String get visitBooked => 'Visit booked';

  @override
  String get visitBookedSuccess =>
      'Your visit has been booked. Check the dashboard for details.';

  @override
  String get visitBookError => 'Could not book this visit.';

  @override
  String get visitPeople => 'Number of people';

  @override
  String get visitLoginToBook => 'Log in to book a visit';

  @override
  String get visitScheduleUpdated => 'Availability updated live.';

  @override
  String get visitStepWhen => 'When';

  @override
  String get visitStepWho => 'Who';

  @override
  String get visitStepConfirm => 'Confirm';

  @override
  String get visitPickDateTime => 'Please pick a date and time for your visit.';

  @override
  String get visitGuestInfoRequired =>
      'Please fill in your details to continue.';

  @override
  String get visitUseScheduled => 'Browse scheduled sessions';

  @override
  String get visitAnyTime => 'Request any time';

  @override
  String get visitFirstName => 'First name';

  @override
  String get visitLastName => 'Last name';

  @override
  String get visitPhone => 'Phone';

  @override
  String get visitEmail => 'Email';

  @override
  String get visitPassword => 'Create a password';

  @override
  String get visitGuestNote =>
      'Continue as a guest — we will create an account and log you in automatically so your visit is saved.';

  @override
  String get visitVisitor => 'Visitor';

  @override
  String get visitNotes => 'Notes for the agent';

  @override
  String get visitBack => 'Back';

  @override
  String get visitContinue => 'Continue';

  @override
  String get visitCreateAccount => 'Create account';

  @override
  String get visitConfirmBooking => 'Confirm booking';

  @override
  String get visitStepPassword => 'Password';

  @override
  String get visitFullName => 'Full name';

  @override
  String get visitEmailOrPhone => 'Email or phone';

  @override
  String get visitConfirmPassword => 'Confirm password';

  @override
  String get visitPasswordMismatch => 'Passwords do not match.';

  @override
  String get visitPasswordHintStrong =>
      'Use a strong password — at least 8 characters.';

  @override
  String get visitFullNamePlaceholder => 'Full name';

  @override
  String get visitContactPlaceholder => '+257 … or you@mail.com';

  @override
  String get visitPlacedTitle => 'Visit placed!';

  @override
  String get visitPlacedSuccess =>
      'Your visit request has been received. The agent will contact you to confirm.';

  @override
  String get visitDone => 'Done';

  @override
  String get visitManageInDashboard =>
      'Manage or cancel it from your dashboard.';

  @override
  String get visitDetailsTitle => 'Visit details';

  @override
  String get visitStatusPending => 'Pending';

  @override
  String get visitStatusConfirmed => 'Confirmed';

  @override
  String get visitStatusCancelled => 'Cancelled';

  @override
  String get visitStatusNoShow => 'No-show';

  @override
  String get visitReference => 'Booking reference';

  @override
  String get visitPeopleCount => 'People';

  @override
  String get visitBookedOn => 'Booked on';

  @override
  String get visitViewProperty => 'View property';

  @override
  String get visitCancelVisit => 'Cancel visit';

  @override
  String get pickerSelectDate => 'Select a date';

  @override
  String get pickerSelectTime => 'Select a time';

  @override
  String get pickerToday => 'Today';

  @override
  String get pickerTomorrow => 'Tomorrow';

  @override
  String get pickerMorning => 'Morning';

  @override
  String get pickerAfternoon => 'Afternoon';

  @override
  String get pickerEvening => 'Evening';

  @override
  String get visitSelectDate => 'Select a date.';

  @override
  String get visitSelectTime => 'Select a time.';

  @override
  String get visitSelectSession => 'Choose a visit session.';

  @override
  String visitMissingFields(String fields) {
    return 'Required: $fields.';
  }

  @override
  String get visitPasswordHint => 'At least 8 characters.';

  @override
  String get mapApproximateLocation => 'Approximate location';

  @override
  String get mapLocationHidden => 'Exact location hidden for owner privacy.';

  @override
  String get mapShowOnMap => 'View on map';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationUnread => 'unread';

  @override
  String get notificationMarkAllRead => 'Mark all as read';

  @override
  String get modalBuyTitle => 'Express interest in buying';

  @override
  String get modalContactTitle => 'Contact the agent';

  @override
  String get modalContactName => 'Your name';

  @override
  String get modalContactPhone => 'Your phone';

  @override
  String get modalContactMessage => 'Message';

  @override
  String get modalMessageTitle => 'Send a message';

  @override
  String get modalApplyTitle => 'Apply to rent this property';

  @override
  String get modalApplyIncome => 'Monthly income (BIF)';

  @override
  String get modalApplyEmployment => 'Employment status';

  @override
  String get modalApplyReferences => 'References';

  @override
  String get modalContactSendSuccess => 'Your message was sent to the agent.';

  @override
  String get modalRequireLogin => 'Log in to continue';

  @override
  String get modalBuySuccess => 'Your request to buy was sent to the agent.';

  @override
  String get modalBuyOptionalMessage =>
      'Optional — tell the agent what you would like to know.';

  @override
  String get applySubmitted =>
      'Your rental application has been submitted to the agent.';

  @override
  String get legalVerificationTitle => 'Verification Disclaimer';

  @override
  String get legalCookiesTitle => 'Cookie Policy';

  @override
  String get legalUpdated => 'Last updated';

  @override
  String get loading => 'Loading…';
}
