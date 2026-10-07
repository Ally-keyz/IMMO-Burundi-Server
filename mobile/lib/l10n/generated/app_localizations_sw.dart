// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get sortNewest => 'Zilizojipya';

  @override
  String get sortPriceAsc => 'Bei: ya chini hadi ya juu';

  @override
  String get sortPriceDesc => 'Bei: ya juu hadi ya chini';

  @override
  String get sortViews => 'Zilizotazwa zaidi';

  @override
  String get sortFeatured => 'Maalumu kwanza';

  @override
  String get filterTitle => 'Vichujio';

  @override
  String get filterApply => 'Tumia vichujio';

  @override
  String get filterClearAll => 'Ondoa zote';

  @override
  String get filterListingType => 'Aina ya tangazo';

  @override
  String get filterPropertyType => 'Aina ya mali';

  @override
  String get filterVerification => 'Uthibitishaji';

  @override
  String get filterProvince => 'Mkoa';

  @override
  String get filterCommune => 'Jimbo';

  @override
  String get filterMinBedrooms => 'Vyumba';

  @override
  String get filterPriceRange => 'Bei kati ya';

  @override
  String get filterMinPrice => 'Bei ya chini';

  @override
  String get filterMaxPrice => 'Bei ya juu';

  @override
  String filterActiveCount(num count) {
    return '{count, plural, =0{Hakuna vichujio} =1{Kichujio 1} other{Vichujio $count}\'}';
  }

  @override
  String get searchPlaceholder => 'Tafuta kwa mji, mtaa au namba ya nyumba…';

  @override
  String get searchNoResults => 'Hakuna mali inayolingana na utafutaji wako';

  @override
  String get searchNoResultsHint =>
      'Jaribu kuondoa kichujio au kutafuta jimbo lingine.';

  @override
  String get searchRecent => 'Utafutaji wa hivi karibuni';

  @override
  String get searchClearHistory => 'Futa';

  @override
  String searchResultsCount(num count) {
    return '{count, plural, =0{Hakuna matokeo} =1{Matokeo 1} other{Matokeo $count}\'}';
  }

  @override
  String get listingForSale => 'Kwa sale';

  @override
  String get listingForRent => 'Kwa kulaza';

  @override
  String get listingForLease => 'Kwa kukodisha';

  @override
  String get listingAuction => 'Mnaganu';

  @override
  String get listingInvestment => 'Uwekezaji';

  @override
  String get typeHouse => 'Nyumba';

  @override
  String get typeApartment => 'Apartamenti';

  @override
  String get typeVilla => 'Villa';

  @override
  String get typeLand => 'Ardhi';

  @override
  String get typeShop => 'Duka';

  @override
  String get typeOffice => 'Ofisi';

  @override
  String get typeWarehouse => 'Hifadhi';

  @override
  String get typeCommercial => 'Biashara';

  @override
  String get typeIndustrial => 'Viwanda';

  @override
  String get typeFarm => 'Shamba';

  @override
  String get typeHotel => 'Hoteli';

  @override
  String get typeGuestHouse => 'Nyumba ya wageni';

  @override
  String get typeOther => 'Nyingine';

  @override
  String get verificationNotVerified => 'Haijathibitishwa';

  @override
  String get verificationPartial => 'Sehemu';

  @override
  String get verificationVerified => 'Imethibitishwa';

  @override
  String get verificationFullyVerified => 'Imethibitishwa kamili';

  @override
  String get badgeFeatured => 'Maalumu';

  @override
  String get badgeNew => 'Mpya';

  @override
  String get badgePromoted => 'Imepromovwa';

  @override
  String get savedEmptyTitle => 'Hakuna kilichohifadhiwa';

  @override
  String get savedEmptyBody => 'Bofya moyo kwenye mali ili kuihifadhi hapa.';

  @override
  String get savedRequiresSignIn => 'Ingia ili kuhifadhi mali';

  @override
  String get savedUpdateFailed =>
      'Imesasishwa hawezi kusasisha mali uliyohifadhi';

  @override
  String get savedAdd => 'Hifadhi mali hii';

  @override
  String get savedRemove => 'Ondoa kwenye zilizohifadhiwa';

  @override
  String get propertyOverview => 'Muhtasari';

  @override
  String get propertyFeatures => 'Vipengele';

  @override
  String get propertyLocation => 'Eneo';

  @override
  String get propertyAgent => 'Aliyeitangaza';

  @override
  String get propertySimilar => 'Similar';

  @override
  String get propertyEnquire => 'Tuma hoja';

  @override
  String get propertyBookVisit => 'Weka utembeleo';

  @override
  String get propertyApplyRental => 'omba';

  @override
  String get propertyShareTitle => 'Shiriki mali hii';

  @override
  String get propertyDescriptionEmpty => 'Mwakala hakuongeza maelezo.';

  @override
  String get propertyNotFound => 'Property not found';

  @override
  String get propertyShare => 'Shiriki';

  @override
  String get propertySave => 'Hifadhi';

  @override
  String get propertySold => 'Imeuzwa';

  @override
  String get propertyCall => 'Piga simu';

  @override
  String get propertyNegotiable => 'Negotiable';

  @override
  String get propertyVerificationNote =>
      'Timu yetu imethibitisha nyaraka za mali hii.';

  @override
  String propertyCoordinates(String coordinates) {
    return 'Viwakilishi: $coordinates';
  }

  @override
  String get propertyCoordinatesHidden => 'Mahali halisi yamefichwa';

  @override
  String get enquiryTitle => 'Tuma hoja';

  @override
  String get enquirySubject => 'Mada';

  @override
  String get enquiryMessage => 'Ujumbe';

  @override
  String get enquirySend => 'Tuma hoja';

  @override
  String get enquirySent => 'Hoja yako imetumwa kwa wakala';

  @override
  String get enquirySignInRequired => 'Ingia ili kutuma hoja';

  @override
  String get enquiryLabelOpen => 'Imetumwa';

  @override
  String get enquiryLabelInProgress => 'Wakala anashughulika';

  @override
  String get enquiryLabelResponded => 'Wakala amejibu';

  @override
  String get enquiryLabelDealAgreed => 'Makubaliano yamekubaliwa';

  @override
  String get enquiryLabelClosed => 'Imefungwa';

  @override
  String get enquiryAgentReply => 'Jibu la wakala';

  @override
  String get bookingNumberOfPeople => 'Ni watu wangapi?';

  @override
  String get bookingNotes => 'Kuna chochote wakala anachopenda kujua?';

  @override
  String get bookingConfirm => 'Thibitisha utaratibu';

  @override
  String get bookingNoSessions => 'Hakuna muda wa kutembelea mali hii.';

  @override
  String get bookingSignInRequired => 'Ingia ili kupanga kutembelea';

  @override
  String get agentProperties => 'Mali';

  @override
  String get agentSold => 'Yaliyouzwa';

  @override
  String get agentContact => 'Mawasiliano';

  @override
  String get agentCall => 'Mpigie mwakala';

  @override
  String get agentWhatsapp => 'WhatsApp mwakala';

  @override
  String get agentAbout => 'Kuhusu';

  @override
  String get agentLicense => 'Leseni';

  @override
  String get bookingTitle => 'Weka utembeleo';

  @override
  String get bookingAnyTime => 'Tarehe yoyote inayopatikana';

  @override
  String get bookingPickDate => 'Chagua tarehe';

  @override
  String get bookingSuccess => 'Utembeleo wako umewekwa';

  @override
  String get bookingReference => 'Kumbukumbu';

  @override
  String get bookingMyVisits => 'Vitembeleo vyangu';

  @override
  String get paymentTitle => 'Malipo';

  @override
  String get paymentMethod => 'Lipa kwa';

  @override
  String get paymentConfirm => 'Thibitisha na lipa';

  @override
  String get paymentSuccess => 'Malipo yamepokelewa';

  @override
  String get paymentPending => 'Malipo yanasitishwa';

  @override
  String get paymentAmountDue => 'Kiasi cha kulipa';

  @override
  String get paymentPayee => 'Mlipaji';

  @override
  String get paymentExpires => 'Inaisha';

  @override
  String get paymentCancelled => 'Kiungo hiki cha malipo kimefutwa';

  @override
  String get paymentPayerPhone => 'Namba yako ya pesa ya simu';

  @override
  String get paymentPhoneInvalid =>
      'Weka namba halali ya pesa ya simu ya Burundi';

  @override
  String get paymentReference => 'Kumbukumbu';

  @override
  String get paymentRecordedNote =>
      'Hakuna mtoaji wa malipo aliounganishwa bado, hivyo hatua hii inarekodi malipo yako na kuweka mali kuwa zimeuzwa. Si uthibitisho wa benki.';

  @override
  String get youTitle => 'Wewe';

  @override
  String get youSignedOutTitle => 'Unaingia kama mgeni';

  @override
  String get youSignedOutBody =>
      'Ingia ili kuhifadhi mali, kuwasiliana na wawakala na kuweka vitembeleo.';

  @override
  String get youMyPayments => 'Malipo';

  @override
  String get youMyVisits => 'Vitembeleo';

  @override
  String get youEditProfile => 'Hariri wasifu';

  @override
  String get youAccountActivity => 'Shughuli yako';

  @override
  String get accountViews => 'Mionekano';

  @override
  String get accountEnquiries => 'Hoja';

  @override
  String get accountSaved => 'Zilizohifadhiwa';

  @override
  String get authSetupRemaining => 'Kamilisha kusanidi akaunti yako';

  @override
  String get profilePhotoSection => 'Picha ya wasifu';

  @override
  String get profilePhotoHint =>
      'Inaonyeshwa karibu na jina lako kwenye tovuti nzima. JPEG, PNG, WEBP au GIF, hadi 5 MB.';

  @override
  String get profilePhotoChoose => 'Chagua picha';

  @override
  String get profilePhotoRemove => 'Ondoa picha';

  @override
  String get profilePhotoUploading => 'Inapakia picha...';

  @override
  String get profilePhotoUpdated => 'Picha ya wasifu imesasishwa.';

  @override
  String get profilePhotoRemoved => 'Picha ya wasifu imeondolewa.';

  @override
  String get profilePhotoInvalid => 'Chagua picha ya JPEG, PNG, WEBP au GIF.';

  @override
  String get profilePhotoTooLarge => 'Picha lazima iwe 5 MB au kidogo.';

  @override
  String get profilePhotoFailed => 'Impossible kusoma picha hii.';

  @override
  String get profilePersonalSection => 'Taarifa za binafsi';

  @override
  String get profilePersonalHint =>
      'Sasisha jina lako, namba ya simu na barua pepe.';

  @override
  String get profilePersonalSaved => 'Taarifa zako za binafsi zimehifadhiwa.';

  @override
  String get profileSecuritySection => 'Usalama';

  @override
  String get profileSecurityHint => 'Badilisha nenosiri unalotumia kuingia.';

  @override
  String get profileCurrentPassword => 'Nenosiri la sasa';

  @override
  String get profileNewPassword => 'Nenosiri jipya';

  @override
  String get profilePasswordHint => 'Angalau herufi 8';

  @override
  String get profilePasswordTooShort => 'Tumia angalau herufi 8.';

  @override
  String get profileEmailInvalid => 'Weka barua pepe halali.';

  @override
  String get profileWrongPassword => 'Nenosiri la sasa si sahihi.';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get settingsAccount => 'Akaunti';

  @override
  String get settingsGeneral => 'Jumla';

  @override
  String get settingsAppearance => 'Mwonekano';

  @override
  String get settingsThemeSystem => 'Mfumo';

  @override
  String get settingsThemeLight => 'Nyepesi';

  @override
  String get settingsThemeDark => 'Giza';

  @override
  String get settingsLanguage => 'Lugha';

  @override
  String get settingsCurrency => 'Safi';

  @override
  String get settingsNotifications => 'Arifa';

  @override
  String get settingsAbout => 'Kuhusu';

  @override
  String get settingsTerms => 'Sheria na Mashartiano';

  @override
  String get settingsPrivacy => 'Sera ya Faragha';

  @override
  String get settingsRateApp => 'Pima IMMO BURUNDI';

  @override
  String get settingsVersion => 'Toleo';

  @override
  String get settingsSignOut => 'Toka';

  @override
  String get settingsSignOutConfirm => 'Toka kwenye IMMO BURUNDI?';

  @override
  String get languageTitle => 'Lugha';

  @override
  String get languageChanged => 'Lugha imebadilishwa';

  @override
  String get currencyChanged => 'Safi imebadilishwa';

  @override
  String get notificationsEmpty => 'Hakuna arifa';

  @override
  String get notificationsMarkAllRead => 'Weka zote kuwa zilizosomwa';

  @override
  String get notificationsRequiresSignIn => 'Ingia ili kuona arifa zako';

  @override
  String get legalTermsTitle => 'Sheria na Masharti';

  @override
  String get legalPrivacyTitle => 'Sera ya Faragha';

  @override
  String get legalUnavailable => 'Hati hii haipatikani nje ya mtandao.';

  @override
  String get legalReadOnSite => 'Soma waraka kamili kwenye tovuti';

  @override
  String get offlineBanner => 'Hakuna mtandao - mambo mengine yatasaasishwa';

  @override
  String get errorGeneric => 'Tatizo limetokea';

  @override
  String get errorNetwork => 'Network error — check your connection.';

  @override
  String get tabHome => 'Nyumbani';

  @override
  String get tabExplore => 'Chunguza';

  @override
  String get tabSaved => 'Zilizohifadhiwa';

  @override
  String get tabYou => 'Wewe';

  @override
  String get aboutTitle => 'Kuhusu';

  @override
  String get aboutMissionBodyLong =>
      'Kutoka Bujumbura hadi Muyinga, tunamsaidia wazinunuzi, wapangaji na wawekezaji kupata mali iliyothibitishwa, huku tukiwapa wamiliki na mawakala wa kadi zana za kukifikia hadithi inayofaa. Kila orodha inaonyesha hali ya uthibitisho kwa uwazi na bei halisi, na timu yetu inahakikisha soko halina utaputaji.';

  @override
  String get aboutContactTitle => 'Wasiliana nasi';

  @override
  String get aboutEmailSubject => 'Habari IMMO BURUNDI';

  @override
  String get aboutWebsite => 'Tovuti';

  @override
  String get aboutCopy => 'Nakili';

  @override
  String get aboutCopied => 'Imenakiliwa';

  @override
  String get contactAddressLabel => 'Ofisi kuu';

  @override
  String get errorNoAppForLink =>
      'Hakuna programu kwenye kifaa hiki inayoweza kufungua kiungo hiki.';

  @override
  String get errorSomethingWrongTitle => 'Hitilafu imetokea';

  @override
  String get errorRetry => 'Jaribu tena';

  @override
  String get settingsStorage => 'Hifadhi';

  @override
  String get settingsClearCache => 'Futa picha zilizohifadhiwa';

  @override
  String get settingsCacheCleared => 'Kumbukumbu imefutwa';

  @override
  String get settingsHelp => 'Msaada';

  @override
  String get settingsCookiePolicy => 'Sera ya Vidakuzi';

  @override
  String get commonCurrency => 'Sarafu';

  @override
  String get commonLanguage => 'Lugha';

  @override
  String get commonYou => 'Wewe';

  @override
  String get commonNow => 'sasa';

  @override
  String get commonNotify => 'Arifu';

  @override
  String get commonEstimate => 'makadirio';

  @override
  String get commonEstimated => 'Inakadiriwa';

  @override
  String get commonLoading => 'Inapakia';

  @override
  String get commonPrevious => 'Rudi';

  @override
  String get navigationClose => 'Funga';

  @override
  String get commonViewAll => 'Ona zote';

  @override
  String get commonBack => 'Rudi';

  @override
  String get commonSave => 'Hifadhi';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get commonClose => 'Funga';

  @override
  String get mediaViewPhotos => 'Tazama picha';

  @override
  String get mediaOf => 'kati ya';

  @override
  String get mediaPhoto => 'Picha';

  @override
  String get mediaPreviousPhoto => 'Picha iliyotangulia';

  @override
  String get mediaNextPhoto => 'Picha inayofuata';

  @override
  String get mediaImageUnavailable => 'Picha haipatikani';

  @override
  String get commonDone => 'Imekamilika';

  @override
  String get commonPagination => 'Ukurasa';

  @override
  String get commonNext => 'Ifuatayo';

  @override
  String get errorBoundaryBody =>
      'Programu imekutana na hitilafu isiyotarajiwa. Data yako iko salama - jaribu tena, au onyesha upya ukurasa.';

  @override
  String get errorReload => 'Onyesha upya ukurasa';

  @override
  String get commonSend => 'Tuma';

  @override
  String get commonSubmit => 'Wasilisha';

  @override
  String get commonSearch => 'Tafuta';

  @override
  String get themeLightMode => 'Badilisha hadi mwanga wa siku';

  @override
  String get themeDarkMode => 'Badilisha hadi hali ya giza';

  @override
  String get commonAll => 'Zote';

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
  String get commonFilters => 'Vichujio';

  @override
  String get commonClear => 'Futa';

  @override
  String get commonApply => 'Tumia';

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
  String get commonResults => 'matokeo';

  @override
  String get commonProperty => 'property';

  @override
  String get commonProperties => 'majengo';

  @override
  String get commonViews => 'maoni';

  @override
  String get commonShowMore => 'Show more';

  @override
  String get commonShowLess => 'Show less';

  @override
  String get commonMore => 'More';

  @override
  String get commonCopy => 'Copied to clipboard';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navBuy => 'Nunua';

  @override
  String get navRent => 'Kodi';

  @override
  String get navLand => 'Ardhi';

  @override
  String get navCommercial => 'Biashara';

  @override
  String get navFeatured => 'Maalumu';

  @override
  String get navVerified => 'Imethibitishwa';

  @override
  String get navAgents => 'Agents';

  @override
  String get navAbout => 'Kuhusu';

  @override
  String get navContact => 'Wasiliana';

  @override
  String get navLogin => 'Ingia';

  @override
  String get navRegister => 'Jisajili';

  @override
  String get navLogout => 'Toka';

  @override
  String get navDashboard => 'Dashibodi';

  @override
  String get navMessages => 'Ujumbe';

  @override
  String get navNotifications => 'Arifa';

  @override
  String get navSearch => 'Search';

  @override
  String get navMenu => 'Menu';

  @override
  String get navExplore => 'Gundua';

  @override
  String get navBrowse => 'Vinjari';

  @override
  String get navMore => 'Zaidi';

  @override
  String get navListProperty => 'Tangaza jengo';

  @override
  String get searchTitle => 'Search properties';

  @override
  String get searchPlaceholderShort => 'Tafuta majengo…';

  @override
  String get searchQuickLinks => 'Viungo vya haraka';

  @override
  String get searchSegmentProperties => 'Majengo';

  @override
  String get searchSegmentAgents => 'Mawakala';

  @override
  String get searchSegmentMore => 'Zaidi';

  @override
  String get searchSortBy => 'Panga kwa';

  @override
  String get searchAdvancedTitle => 'Utafutaji wa kina';

  @override
  String get searchAdvancedDesc =>
      'Boresha utafutaji wako — mahali, bajeti na vyumba.';

  @override
  String get searchPropertyAgent => 'Tafuta mawakala';

  @override
  String get searchPerson => 'Tafuta watu au majengo';

  @override
  String get searchButton => 'Tafuta';

  @override
  String get searchLocation => 'Mahali';

  @override
  String get searchPropertyType => 'Aina ya jengo';

  @override
  String get searchMinPrice => 'Bei ndogo';

  @override
  String get searchMaxPrice => 'Bei kubwa';

  @override
  String get searchBedrooms => 'Vyumba';

  @override
  String get searchPropertyId => 'Property ID';

  @override
  String get searchTabBuy => 'Nunua';

  @override
  String get searchTabRent => 'Kodi';

  @override
  String get searchTabLand => 'Ardhi';

  @override
  String get searchTabCommercial => 'Biashara';

  @override
  String get searchTabInvestment => 'Investment';

  @override
  String get searchSort => 'Sort';

  @override
  String get searchSortNewest => 'Kipya kwanza';

  @override
  String get searchSortPriceAsc => 'Bei inayopanda';

  @override
  String get searchSortPriceDesc => 'Bei inayoshuka';

  @override
  String get searchSortViews => 'Most viewed';

  @override
  String get searchSortFeatured => 'Featured first';

  @override
  String get searchResults => 'Result';

  @override
  String get searchResultsPlural => 'Results';

  @override
  String get searchFilters => 'Vichujio';

  @override
  String get searchPersonalize => 'Boresha matokeo yako';

  @override
  String get searchResetFilters => 'Futa vichujio';

  @override
  String get searchProvince => 'Mkoa';

  @override
  String get searchCommune => 'Komun';

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
  String get propertyBuyHint => 'Mwambie wakala nia yako ya kununua mali hii';

  @override
  String get propertyBuy => 'Nunua';

  @override
  String get propertyForSale => 'Inauzwa';

  @override
  String get propertyForRent => 'Inakodishwa';

  @override
  String get propertyForLease => 'Kukodisha';

  @override
  String get propertyForAuction => 'Mnada';

  @override
  String get propertyForInvestment => 'Uwekezaji';

  @override
  String get propertyIsNew => 'Mpya';

  @override
  String get propertyIsPromoted => 'Imepandishwa';

  @override
  String get propertyViews => 'maoni';

  @override
  String get propertyFavorites => 'vipendwa';

  @override
  String get propertyBedrooms => 'vy';

  @override
  String get propertyBathrooms => 'baf';

  @override
  String get propertySurface => 'm²';

  @override
  String propertyBedroomsShort(String count) {
    return 'Vyumba $count';
  }

  @override
  String propertyBedroomsShortPlural(String count) {
    return 'Vyumba $count';
  }

  @override
  String propertyBathroomsShort(String count) {
    return 'Bafu $count';
  }

  @override
  String propertyBathroomsShortPlural(String count) {
    return 'Bafu $count';
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
  String get propertyVerified => 'Imethibitishwa';

  @override
  String get propertyPartial => 'Imethibitishwa kidogo';

  @override
  String get propertyNotVerified => 'Haijathibitishwa';

  @override
  String get propertyFullyVerified => 'Imethibitishwa kabisa';

  @override
  String get propertyVerificationStatus => 'Uthibitisho';

  @override
  String get propertyDisclaimer =>
      'Verification is based on documents provided and does not guarantee ownership.';

  @override
  String get propertyContactAgent => 'Wasiliana na wakala';

  @override
  String get propertyWhatsapp => 'WhatsApp';

  @override
  String get propertyMessage => 'Ujumbe';

  @override
  String get propertyRequestVisit => 'Omba ziara';

  @override
  String get propertyApplyRent => 'Omba kukodi';

  @override
  String get propertyReport => 'Ripoti';

  @override
  String get propertyRelatedProperties => 'Majengo yanayofanana';

  @override
  String get propertyAboutThis => 'Kuhusu jengo hili';

  @override
  String get propertyMap => 'Ramani';

  @override
  String get propertyMapApproxNote => 'Approximate location';

  @override
  String get propertyMapHidden =>
      'The exact location of this property is hidden.';

  @override
  String get propertyPrice => 'Bei';

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
  String get propertySaves => 'zimehifadhiwa';

  @override
  String get propertyLikes => 'zinazopendwa';

  @override
  String get propertyMultipleAgents => 'Mawakala wengi';

  @override
  String get propertyViewMore => 'Ona zaidi';

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
  String get propertyAsk => 'Uliza';

  @override
  String get propertyAskPlaceholder => 'Muulize wakala swali…';

  @override
  String get propertyPhotos => 'picha';

  @override
  String get propertyQuestions => 'Maswali';

  @override
  String get propertyNoQuestionsYet =>
      'Hakuna maswali bado — kuwa wa kwanza kuuliza.';

  @override
  String get relToday => 'Leo';

  @override
  String relDaysAgo(String days) {
    return 'siku $days zilizopita';
  }

  @override
  String relWeeksAgo(String weeks) {
    return 'wiki $weeks zilizopita';
  }

  @override
  String relMonthsAgo(String months) {
    return 'miezi $months iliyopita';
  }

  @override
  String relYearsAgo(String years) {
    return 'miaka $years iliyopita';
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
  String get propertyPropertyId => 'Namba';

  @override
  String get propertytypeHOUSE => 'Nyumba';

  @override
  String get propertytypeOFFICE => 'Ofisi';

  @override
  String get propertytypeFARM => 'Shamba';

  @override
  String get propertytypeAPARTMENT => 'Ghorofa';

  @override
  String get propertytypeSHOP => 'Duka';

  @override
  String get propertytypeINDUSTRIAL => 'Viwanda';

  @override
  String get propertytypeVILLA => 'Vila';

  @override
  String get propertytypeWAREHOUSE => 'Bohari';

  @override
  String get propertytypeOTHER => 'Nyingine';

  @override
  String get propertytypeLAND => 'Ardhi';

  @override
  String get propertytypeHOTEL => 'Hoteli';

  @override
  String get propertytypeCOMMERCIAL => 'Biashara';

  @override
  String get propertytypeGUESTHOUSE => 'Guest house';

  @override
  String get verificationTitle => 'Uthibitisho wa nyaraka';

  @override
  String get verificationLearnMore => 'Jifunze zaidi';

  @override
  String get verificationLandTitle => 'Hati ya ardhi';

  @override
  String get verificationSaleAgreement => 'Mkataba wa mauzo';

  @override
  String get verificationTop => 'Proof of payment (TOP)';

  @override
  String get verificationPropertyTax => 'Kodi ya nyumba';

  @override
  String get verificationOwnerId => 'Kitambulisho cha mmiliki';

  @override
  String get verificationOther => 'Other document';

  @override
  String get verificationPassed => 'Imethibitishwa';

  @override
  String get verificationFailed => 'Imeshindwa';

  @override
  String get verificationNotApplicable => 'Haifai';

  @override
  String get verificationVerifiedAt => 'Verified on';

  @override
  String get authLogin => 'Ingia';

  @override
  String get authRegister => 'Jisajili';

  @override
  String get authEmail => 'Barua pepe';

  @override
  String get authPhone => 'Namba ya simu';

  @override
  String get authPassword => 'Nenosiri';

  @override
  String get authFullName => 'Jina kamili';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authConfirmPassword => 'Thibitisha nenosiri';

  @override
  String get authForgotPassword => 'Umesahau nenosiri?';

  @override
  String get authNoAccount => 'Huna akaunti?';

  @override
  String get authHasAccount => 'Una akaunti tayari?';

  @override
  String get authCreateAccount => 'Fungua akaunti';

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
  String get authLogout => 'Toka';

  @override
  String get authSignUpEyebrow => 'JIUNGE NA IMMO BURUNDI';

  @override
  String get authSignUpTitle => 'Fungua akaunti yako';

  @override
  String get authSignUpSubtitle =>
      'Hifadhi mali unazozipenda, wasiliana na mawakala na upokee arifa za matangazo mapya.';

  @override
  String get authLogInEyebrow => 'KARIBU TENA';

  @override
  String get authLogInSubtitle =>
      'Ingia ili udhibiti vipendwa, jumbe na ziara zako.';

  @override
  String get authPasswordPlaceholder => 'Angalau herufi 8';

  @override
  String get authNamePlaceholder => 'Jean Ndayishimiye';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authPhonePlaceholder => '+257 79 000 000';

  @override
  String get dashboardTitle => 'My dashboard';

  @override
  String get dashboardAgentTitle => 'Dashibodi ya wakala';

  @override
  String get dashboardFavorites => 'Vipendwa vangu';

  @override
  String get dashboardRecentViews => 'Yaliyotazwa hivi karibuni';

  @override
  String get dashboardApplications => 'Maombi';

  @override
  String get dashboardVisits => 'Ziara zangu';

  @override
  String get dashboardMessages => 'Ujumbe';

  @override
  String get dashboardNotifications => 'Arifa';

  @override
  String get dashboardProfile => 'Wasifu';

  @override
  String get dashboardEditProfile => 'Hariri wasifu';

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
  String get dashboardSettings => 'Mipangilio';

  @override
  String get dashboardMyProperties => 'Mali';

  @override
  String get dashboardPropFilterAll => 'Zote';

  @override
  String get dashboardPropFilterActive => 'Zilizo hai';

  @override
  String get dashboardPropFilterReview => 'Katika ukaguzi';

  @override
  String get dashboardPropFilterChanges => 'Inahitaji mabadiliko';

  @override
  String get dashboardPropFilterRejected => 'Zilizokataliwa';

  @override
  String get dashboardPropFilterDraft => 'Rasimu';

  @override
  String get dashboardPropFilterArchive => 'Kumbukumbu';

  @override
  String get dashboardPropFilterSold => 'Byabiriye';

  @override
  String get dashboardPropFilterRented => 'Byasagiye';

  @override
  String get dashboardRelistProperty => 'Shyiramo kugaragaza';

  @override
  String dashboardRelistPropertyConfirm(String title) {
    return 'Shyiramo kugaragaza $title? Umudominijoti igomba kuy approvesha mbere yo kugaragazwa.';
  }

  @override
  String get dashboardBookings => 'Uhifadhi wa ziara';

  @override
  String get dashboardAnalytics => 'Takwimu';

  @override
  String get dashboardVerification => 'Uthibitishaji';

  @override
  String get dashboardListProperty => 'Tangaza mali';

  @override
  String get dashboardProperties => 'Mali';

  @override
  String get dashboardOverview => 'Muhtasari';

  @override
  String get dashboardAgents => 'Wakala';

  @override
  String get dashboardRequests => 'Maombi';

  @override
  String get dashboardNoPropertiesDesc =>
      'Tangaza mali kuanza kuidhibiti hapa.';

  @override
  String get dashboardNoBookings => 'Hakuna uhifadhi bado';

  @override
  String get dashboardNoBookingsDesc =>
      'Maombi ya ziara za mali zako yataonekana hapa.';

  @override
  String get dashboardNoVerification => 'Hakuna maombi ya uthibitishaji';

  @override
  String get dashboardNoVerificationDesc =>
      'Omba uthibitisho wa mali ili ikaguliwe.';

  @override
  String get dashboardProperty => 'Mali';

  @override
  String get dashboardConfirm => 'Thibitisha';

  @override
  String get dashboardCancel => 'Ghairi';

  @override
  String get dashboardStatViews => 'Maoni yote';

  @override
  String get dashboardStatLikes => 'Vipendwa vyote';

  @override
  String get dashboardStatShares => 'Kushiriki vyote';

  @override
  String get dashboardStatBookings => 'Ziara zilizohifadhiwa';

  @override
  String get dashboardStatEnquiries => 'Maulizo';

  @override
  String get dashboardPerProperty => 'Kwa mali';

  @override
  String get navMyProperties => 'Mali zangu';

  @override
  String get navHelp => 'Msaada';

  @override
  String get navFeedback => 'Tuma maoni';

  @override
  String get dashboardHome => 'Dashibodi';

  @override
  String get dashboardInbox => 'Kuhifadhi na maombi';

  @override
  String get dashboardSidebarAgency => 'Wakala wako';

  @override
  String get dashboardSidebarProfile => 'Profile';

  @override
  String get dashboardAddNew => 'Ongeza mali';

  @override
  String get dashboardClearFilters => 'Futa vyote';

  @override
  String get dashboardSearchProperties =>
      'Tafuta kwa jina, kumbukumbu au maelezo';

  @override
  String dashboardResultsCount(String from, String to, num total) {
    return 'Inaonyesha $from-$to kati ya $total';
  }

  @override
  String get dashboardNoSearchResults =>
      'Hakuna mali inayolingana na utafutaji wako. Jaribu nyingine au futa utafutaji.';

  @override
  String get dashboardRequester => 'Mwombaji';

  @override
  String get dashboardAllStatuses => 'Hali zote ▾';

  @override
  String get dashboardCardsListTitle => 'Tangaza mali yako ya kwanza';

  @override
  String get dashboardCardsListDesc =>
      'Chapisha tangazo kupata maoni na maombi.';

  @override
  String get dashboardCardsListCta => 'Ongeza mali';

  @override
  String get dashboardCardsAnalyticsTitle => 'Uchambuzi';

  @override
  String get dashboardCardsAnalyticsDesc =>
      'Fuatilia maoni, vipendwa na maombi kwa kila mali.';

  @override
  String get dashboardCardsAnalyticsCta => 'Angalia uchambuzi';

  @override
  String get dashboardCardsTipsTitle => 'Vidokezo kwa wakala';

  @override
  String get dashboardCardsTip1 =>
      'Picha bora zinaweza kuongeza ziara kwa 70%.';

  @override
  String get dashboardCardsTip2 => 'Jibu maombi ndani ya saa ya kwanza.';

  @override
  String get dashboardCardsTip3 =>
      'Weka makubaliano kabla ya kutuma kiungo cha malipo.';

  @override
  String get dashboardColProperty => 'Mali';

  @override
  String get dashboardColFlags => 'Vipengele';

  @override
  String get dashboardColStatus => 'Hali';

  @override
  String get dashboardColListed => 'Tarehe kuchapishwa';

  @override
  String get dashboardColViews => 'Maoni';

  @override
  String get dashboardColInquiries => 'Maombi';

  @override
  String get dashboardEmptyProps => 'Hakuna mali bado';

  @override
  String get dashboardEmptyPropsDesc =>
      'Unda tangazo lako la kwanza kuanzisha kwingineko yako.';

  @override
  String get dashboardColActions => 'Hatua';

  @override
  String get dashboardEditProperty => 'Hariri mali';

  @override
  String get dashboardDeleteProperty => 'Futa mali';

  @override
  String get dashboardRequestVerification => 'Omomba uthibitisho';

  @override
  String get dashboardRequestVerificationDesc =>
      'Tuma mali hii kwa timu ya IMMO BURUNDI ili kuthibitishwa. Msimamizi atakagua nyaraka na atakupigia simu kama kitu kimekosekana.';

  @override
  String get dashboardVerificationRequested => 'Uthibitisho umeombwa';

  @override
  String get dashboardVerificationCode => 'Kumbukumbu';

  @override
  String get dashboardVerificationNote => 'Noti kwa timu ya uthibitisho';

  @override
  String get dashboardVerificationNotePlaceholder =>
      'Kitu chochote msimamizi anapaswa kujua (hiari)';

  @override
  String get dashboardVerificationPending => 'Uthibitisho unaendelea';

  @override
  String get dashboardVerified => 'Imethibitishwa';

  @override
  String get dashboardVerificationIntro =>
      'Fuatilia kila mali unayosimamia: yale yaliyo subiri hoja, yale yaliyothibitishwa, na hasa unapaswa kurekebisha kabla ya kukubaliwa na utawala.';

  @override
  String get dashboardVerificationPendingSection => 'Uthibitisho unaosubiri';

  @override
  String get dashboardVerificationVerifiedSection => 'Mali zilizothibitishwa';

  @override
  String get dashboardVerificationActionSection => 'Inahitaji kushughulikiako';

  @override
  String get dashboardVerificationNoPending =>
      'Hakuna mali inayosubiri hoja ya uthibitisho.';

  @override
  String get dashboardVerificationNoVerified =>
      'Hakuna mali yako imethibitishwa bado.';

  @override
  String get dashboardVerificationNoAction =>
      'Hakuna kurekebisha — kila mali unayosimamia imekamilika.';

  @override
  String get dashboardVerificationEmpty =>
      'Bado hujasimamia mali yoyote. Ongeza mali ili kufuatilia uthibitisho wake.';

  @override
  String get dashboardVerificationEmptyCta => 'Nenda kwenye mali zangu';

  @override
  String get dashboardVerificationWhatToUpdate =>
      'Unapaswa kurekebisha ili kukubaliwa';

  @override
  String get dashboardVerificationAllMet =>
      'Mahitaji yote yametimizwa. Mali hii iko tayari kwa hoja ya uthibitisho.';

  @override
  String get dashboardVerificationAdminNote => 'Noti kutoka kwa utawala';

  @override
  String get dashboardVerificationReviewNote =>
      'Noti kutoka kwa timu ya mapitio';

  @override
  String get dashboardVerificationRequestedOn => 'Ilioombwa';

  @override
  String get dashboardVerificationReviewedBy => 'Ilirekebiwa na';

  @override
  String get dashboardVerificationDocuments => 'Nyaraka zilizounganishwa';

  @override
  String get dashboardVerificationNoDocuments =>
      'Hakuna nyaraka iliyounganishwa bado.';

  @override
  String get dashboardVerificationMissing => 'inakosekana';

  @override
  String get dashboardVerificationProvided => 'imeshatikishwa';

  @override
  String get dashboardVerificationCount => 'vitu vya kurekebisha';

  @override
  String get dashboardVerificationAdminDecides =>
      'Msimamizi wa mfumo ndio anayepagua na kuamua uthibitisho wa mwisho. Huwezi wewe mwenyewe kuweka mali kuwa imethibitishwa.';

  @override
  String get dashboardVerificationView => 'Ona maelezo';

  @override
  String get verifyreqDocumentLANDTITLE => 'Hati ya ardhi (titre foncier)';

  @override
  String get verifyreqDocumentOWNERID => 'Kitambulisho cha mmiliki';

  @override
  String get verifyreqDocumentSALEAGREEMENT => 'Mkataba wa mauzati uliosainiwa';

  @override
  String get verifyreqDocumentTOP => 'Cheti cha mipango (TOP)';

  @override
  String get verifyreqDocumentPROPERTYTAX => 'Risoti ya kodi ya ardhi';

  @override
  String get verifyreqDocumentOTHER => 'Nyaraka nyingine ya ushahidi';

  @override
  String get verifyreqFieldTitle => 'Kichwa cha tangazo';

  @override
  String get verifyreqFieldDescription => 'Maelezo';

  @override
  String get verifyreqFieldPrice => 'Bei';

  @override
  String get verifyreqFieldSurfaceArea => 'Eneo';

  @override
  String get verifyreqFieldLocation => 'Mkoa na kom';

  @override
  String get verifyreqFieldMedia => 'Kisha angalau moja';

  @override
  String get verificationPropertiesTab => 'Mali';

  @override
  String get verificationAgentsTab => 'Wakala';

  @override
  String get verificationShowCompleted => 'Onyesha zilizokamilika';

  @override
  String get verificationNoPendingProperties =>
      'Hakuna mali inayotarajiwa kuthibitishwa';

  @override
  String get verificationNoPendingPropertiesDesc =>
      'Maombi mapya kutoka kwa wakala yataonekana hapa.';

  @override
  String get verificationNoPendingAgents =>
      'Hakuna wakala anayotarajiwa kuthibitishwa';

  @override
  String get verificationNoPendingAgentsDesc =>
      'Wakala wapya huonekana hapa hadi utakapowathibitisha.';

  @override
  String verificationRequestedOn(String date) {
    return 'Aliombwa $date';
  }

  @override
  String verificationRegisteredOn(String date) {
    return 'Ajiunga $date';
  }

  @override
  String get verificationAgent => 'Wakala aliyewekwa';

  @override
  String get verificationNoAgent => 'Hakuna wakala aliyeteuliwa kwa mali hii.';

  @override
  String get verificationVerify => 'Thibitisha';

  @override
  String get verificationReject => 'Kataa';

  @override
  String get verificationRejectTitle => 'Kataa uthibitisho';

  @override
  String get verificationRejectDesc =>
      'Muombaji atapokea sababu yako, kwa hiyo andika wazi na inayofaa.';

  @override
  String get verificationReason => 'Sababu';

  @override
  String get verificationReasonPlaceholder =>
      'Kini kimekosekana au ni nini si sahihi?';

  @override
  String get verificationReasonHint =>
      'Sababu hii hutumwa kwa wakala na kuonyeshwa kwenye ombi.';

  @override
  String get verificationReasonRequired =>
      'Sababu inahitajika ili ku kataa uthibitisho.';

  @override
  String get verificationConfirmReject => 'Thibitisha ukataji';

  @override
  String get verificationRejectionReason => 'Sababu ya ukataji';

  @override
  String get verificationLicenseNumber => 'Namba ya leseni';

  @override
  String get verificationProvince => 'Mkoa';

  @override
  String verificationAgentStatus(String status) {
    return 'Wakala: $status';
  }

  @override
  String verificationAgentWhatsappMessage(String title) {
    return 'Habari, hii ni timu ya uthibitisho ya IMMO BURUNDI kuhusu \"$title\".';
  }

  @override
  String dashboardDeletePropertyConfirm(String title) {
    return 'Futa \"$title\"? Tangazo hili litafutwa kabisa.';
  }

  @override
  String get dashboardBlockedByAdmin => 'Imezuiwa na msimamizi';

  @override
  String get dashboardTabBookings => 'Ombi la ziara';

  @override
  String get dashboardTabEnquiries => 'Maombi ya ununuzi';

  @override
  String get dashboardTabMessages => 'Ujumbe';

  @override
  String get dashboardContact => 'Wasiliana';

  @override
  String get dashboardWhatsApp => 'Ongea kwa WhatsApp';

  @override
  String get dashboardSendLink => 'Tuma kiungo cha malipo';

  @override
  String get dashboardCopyLink => 'Nakili kiungo';

  @override
  String get dashboardMarkDeal => 'Weka makubaliano';

  @override
  String get dashboardLinkCopied => 'Kiungo kimenakiliwa';

  @override
  String get dashboardNoInbox => 'Hakuna maombi bado';

  @override
  String get dashboardNoInboxDesc =>
      'Maombi ya ziara na ununuzi wa mali zako yataonekana hapa.';

  @override
  String get bookingStatusPENDING => 'Inasubiri';

  @override
  String get bookingStatusCONFIRMED => 'Imekubaliwa';

  @override
  String get bookingStatusCOMPLETED => 'Makubaliano yamefikiwa';

  @override
  String get bookingStatusCANCELLED => 'Imekataliwa';

  @override
  String get bookingStatusNOSHOW => 'Hakujitokeza';

  @override
  String get bookingStatusDEALAGREED => 'Makubaliano yamefikiwa';

  @override
  String get enquiryStatusNEW => 'Mpya';

  @override
  String get enquiryStatusOPEN => 'Wazi';

  @override
  String get enquiryStatusINPROGRESS => 'Inaendelea';

  @override
  String get enquiryStatusRESPONDED => 'Imejibiwa';

  @override
  String get enquiryStatusDEALAGREED => 'Makubaliano yamefikiwa';

  @override
  String get enquiryStatusCLOSED => 'Imefungwa';

  @override
  String get dealAgreed => 'Imefikiwa';

  @override
  String get dealTitle => 'Weka makubaliano yamefikiwa?';

  @override
  String get dealDesc => 'Hii itafungua kutuma kiungo cha malipo kwa mwombaji.';

  @override
  String get dealConfirm => 'Ndiyo, weka imefikiwa';

  @override
  String get plinkStatusCREATED => 'Kiungo kimetumwa';

  @override
  String get plinkStatusSENT => 'Kiungo kimetumwa';

  @override
  String get plinkStatusOPENED => 'Imefunguliwa';

  @override
  String get plinkStatusPAID => 'Imelipwa';

  @override
  String get plinkStatusCANCELLED => 'Imeghairiwa';

  @override
  String get plinkStatusEXPIRED => 'Imeisha muda';

  @override
  String get analyticsTabOverview => 'Muhtasari';

  @override
  String get analyticsTabProperties => 'Mali';

  @override
  String get analyticsTabClients => 'Wateja';

  @override
  String get analyticsTabTrends => 'Mwenendo';

  @override
  String get analyticsPeriod => 'Siku 28 zilizopita';

  @override
  String get analyticsAvgTime => 'Muda wa wastani kwenye tangazo';

  @override
  String get analyticsStatLeads => 'Waongozaji';

  @override
  String get analyticsStatRealtime => 'Muda halisi';

  @override
  String get analyticsRealtimeDesc =>
      'Shughuli za moja kwa moja kwenye mali zako.';

  @override
  String get analyticsNoData => 'Hakuna shughuli katika kipindi hiki';

  @override
  String get analyticsViewsShort => 'Maoni';

  @override
  String get analyticsFavoritesShort => 'Vipendwa';

  @override
  String get analyticsInquiriesShort => 'Maombi';

  @override
  String get listDropTitle => 'Pakia picha za mali';

  @override
  String get listDropHint =>
      'Andika URL moja kwa kila mstari — picha ya kwanza ndiyo jalada.';

  @override
  String get listSelectFiles => 'Chagua faili';

  @override
  String get listNeedHelp => 'Unahitaji msaada? Tupo hapa.';

  @override
  String get listUploadNotice =>
      'Picha ni za umma. Usijumuishe nyaraka za kibinafsi.';

  @override
  String listPhotoCountOk(num count) {
    return 'Picha zinatosha ($count zimeongezwa).';
  }

  @override
  String listPhotoCountMissing(num count) {
    return 'Ongeza picha $count zaidi — angalau 4 zinahitajika.';
  }

  @override
  String get listPhotoUploading => 'Inapakia picha…';

  @override
  String get listPhotoFailed => 'Imeshindwa';

  @override
  String get listRemovePhoto => 'Ondoa picha';

  @override
  String get listPropertyAdded => 'Mali imeongezwa';

  @override
  String get listPropertyAddedBody => 'Iko sasa kwenye orodha yako ya mali.';

  @override
  String get listPropertyUpdated => 'Mali imesasishwa';

  @override
  String get listPropertyUpdatedBody => 'Mabadiliko yako yamehifadhiwa.';

  @override
  String listPropertyPhotosSaved(num count) {
    return 'Picha $count zimehifadhiwa';
  }

  @override
  String get listSavedAsDraft =>
      'Imehifadhiwa kama rasimu. Wasilisha kwa ukaguzi utakapokuwa tayari.';

  @override
  String get listSubmittedForReview =>
      'Imawasilishwa kwa ukaguzi. Msimamizi atakikagua kabla ya kuwekwa mtandaoni.';

  @override
  String get listDropzoneHint =>
      'Buruta picha hapa, au chagua faili. Unaweza kuweka nyingi kwa wakati mmoja.';

  @override
  String get listDropActive => 'Weka picha zako hapa ili zipakiwe';

  @override
  String listPhotoLimit(num count) {
    return 'Tangazo linaweza kuwa na picha $count tu.';
  }

  @override
  String get payTitle => 'Malipo';

  @override
  String get paySecure => 'Kiungo salama cha malipo';

  @override
  String get payAmountLabel => 'Kiasi cha kulipa';

  @override
  String get payPropertyLabel => 'Mali';

  @override
  String get payTo => 'Kwa:';

  @override
  String get payConfirm => 'Thibitisha malipo';

  @override
  String get payProcessing => 'Inachakatwa…';

  @override
  String get paySuccess => 'Malipo yamepokelewa';

  @override
  String paySuccessDesc(String reference) {
    return 'Asante. Rejeleo lako la malipo ni $reference.';
  }

  @override
  String get payBackToHome => 'Rudi nyumbani';

  @override
  String get payLoginPrompt => 'Ingia kuendelea';

  @override
  String get payLoginPromptDesc =>
      'Hiki ni kiungo salama cha malipo. Ingia kwa akaunti iliyopewa.';

  @override
  String get payNotForYou => 'Kiungo hiki ni cha akaunti nyingine';

  @override
  String get payNotForYouDesc =>
      'Tafadhali ingia kwa akaunti iliyopokea kiungo hiki.';

  @override
  String get payLinkInvalid => 'Kiungo batili cha malipo';

  @override
  String get payLinkInvalidDesc =>
      'Kiungo kinakosekana, kimeondolewa, au muda wake umeisha.';

  @override
  String get payAlreadyPaid => 'Imeshalipwa';

  @override
  String get payAlreadyPaidDesc =>
      'Kiungo hiki cha malipo tayari kimekamilika.';

  @override
  String get payGoToLogin => 'Nenda kuingia';

  @override
  String get payGoSignup => 'Unda akaunti';

  @override
  String get payChangeAccount => 'Badilisha akaunti';

  @override
  String payPaidOn(String date) {
    return 'Imelipwa $date';
  }

  @override
  String get payPanelTitle => 'Lipa kwa mobile money yako';

  @override
  String get payPanelDesc =>
      'Huduma zote za mobile money zilizopo Burundi. Chagua kadi yako, kisha andika namba ya kutoza kushoto.';

  @override
  String get payPanelFootnote =>
      'Utapokea ujumbe kwenye simu yako kuthibitisha malipo kwa kadi yako sirikali.';

  @override
  String get payProviderLabel => 'Huduma ya mobile money';

  @override
  String get payPickProvider => 'Chagua huduma ya mobile money';

  @override
  String get payPhoneLabel => 'Namba ya mobile money';

  @override
  String get payPhoneHint =>
      'Namba uliyoisajili kwa mwendeshaji wa mobile money wako.';

  @override
  String get payInvalidNumber =>
      'Andika namba halali ya mobile money ya Burundi, kwa mfano 79 11 10 01.';

  @override
  String get payConfirmPrompt => 'Thibitisha kwenye';

  @override
  String get payProviderLUMICASH => 'Lumicash';

  @override
  String get payProviderECOCASH => 'EcoCash';

  @override
  String get payProviderIHELA => 'iHela';

  @override
  String get listTitle => 'Tangaza mali yako';

  @override
  String get listSubtitle =>
      'Ongeza maelezo ya mali yako — itawasilishwa kwa ukaguzi na msimamizi.';

  @override
  String get listDetails => 'Maelezo ya mali';

  @override
  String get listTitleLabel => 'Jina';

  @override
  String get listPropertyType => 'Aina ya mali';

  @override
  String get listListingType => 'Aina ya tangazo';

  @override
  String get listPrice => 'Bei';

  @override
  String get listCurrency => 'Sarafu';

  @override
  String get listSurface => 'Eneo (m²)';

  @override
  String get listBedrooms => 'Vyumba vya kulala';

  @override
  String get listBathrooms => 'Bafu';

  @override
  String get listLocation => 'Eneo';

  @override
  String get listProvince => 'Mkoa';

  @override
  String get listCommune => 'Kommune';

  @override
  String get listAddress => 'Anwani';

  @override
  String get listNegotiable => 'Bei inajadiliwa';

  @override
  String get listPhotos => 'Picha';

  @override
  String get listPhotosPlaceholder =>
      'https://…/photo1.jpg\nhttps://…/photo2.jpg';

  @override
  String get listSubmit => 'Weka mali';

  @override
  String get listCancel => 'Ghairi';

  @override
  String get footerDescription =>
      'IMMO BURUNDI connects owners, buyers, tenants, investors and trusted agents across Burundi.';

  @override
  String get footerCompany => 'Kampuni';

  @override
  String get footerServices => 'Huduma';

  @override
  String get footerLegal => 'Sheria';

  @override
  String get footerSocial => 'Tufuate';

  @override
  String get footerLinksAboutUs => 'Kuhusu sisi';

  @override
  String get footerLinksContact => 'Wasiliana';

  @override
  String get footerLinksCareers => 'Fursa za kazi';

  @override
  String get footerLinksPartners => 'Washirika';

  @override
  String get footerLinksBuy => 'Nunua';

  @override
  String get footerLinksRent => 'Kodi';

  @override
  String get footerLinksSell => 'Uza';

  @override
  String get footerLinksVerification => 'Uthibitisho';

  @override
  String get footerLinksPromotion => 'Matangazo';

  @override
  String get footerLinksPrivacy => 'Sera ya faragha';

  @override
  String get footerLinksTerms => 'Sheria na masharti';

  @override
  String get footerLinksVerificationDisclaimer => 'Onyo la uthibitisho';

  @override
  String get footerLinksCookies => 'Sera ya kuki';

  @override
  String get footerTagline => 'Real Estate Marketplace';

  @override
  String get errorNotFound => 'Ukurasa haupatikani';

  @override
  String get errorNotFoundDesc =>
      'The page you are looking for does not exist or has been moved.';

  @override
  String get errorNoPermission => 'Huna ruhusa ya kufikia sehemu hii.';

  @override
  String get errorTryAgain => 'Please try again';

  @override
  String get errorBackHome => 'Rudi nyumbani';

  @override
  String get errorForbidden => 'Forbidden';

  @override
  String get errorInvalidData => 'Please check the information you entered.';

  @override
  String get errorLoadFailed => 'Failed to load data';

  @override
  String get errorPropertyLoadFail => 'Unable to load this property.';

  @override
  String get emptyNoProperties => 'Hakuna majengo';

  @override
  String get emptyNoPropertiesDesc =>
      'Tumia vichujio vingine au jaribu tafuta nyingine.';

  @override
  String get emptyNoFavorites => 'Hakuna vipendwa bado';

  @override
  String get emptyNoFavoritesDesc =>
      'Tap the heart on any property to save it here.';

  @override
  String get emptyNoResults => 'Hakuna matokeo';

  @override
  String get emptyNoResultsDesc =>
      'We could not find anything matching your search.';

  @override
  String get emptyNoMessages => 'No conversations';

  @override
  String get emptyNoMessagesDesc =>
      'Message an agent about a property you like.';

  @override
  String get emptyNoNotifications => 'Umefikia mwisho';

  @override
  String get emptyNoNotificationsDesc => 'Arifa zitaonekana hapa.';

  @override
  String get emptyNoVisits => 'No upcoming visits';

  @override
  String get emptyNoVisitsDesc => 'Book a visit from any property page.';

  @override
  String get emptyNoApplications => 'Hakuna ombi bado';

  @override
  String get emptyNoApplicationsDesc =>
      'Maombi yako ya kununua na ya kukodisha yataonekana hapa.';

  @override
  String get applicationsBuyRequest => 'Ombi la kununua';

  @override
  String get applicationsRentApplication => 'Ombi la kukodisha';

  @override
  String get applicationsViewProperty => 'Angalia mali';

  @override
  String get requestsTitle => 'Maombi yangu';

  @override
  String get enquiriesTitle => 'Maswali yangu';

  @override
  String get enquiriesEmpty => 'Hakuna maswali bado';

  @override
  String get enquiriesEmptyDesc =>
      'Maswali unayotuma kuhusu nyumba yataonekana hapa.';

  @override
  String get applicationsTitle => 'Maombi yangu ya kukodisha';

  @override
  String get applicationsEmpty => 'Hakuna maombi ya kukodisha bado';

  @override
  String get applicationsEmptyDesc =>
      'Maombi ya kukodisha unayotuma yataonekana hapa.';

  @override
  String get applyNotARental =>
      'Nyumba hii haipatikani kwa kukodisha, kwa hivyo ombi haliwezi kutuma.';

  @override
  String get validationRequired => 'Sehemu hii inahitajikwa';

  @override
  String get validationNumber => 'Weka namba kamili';

  @override
  String get commonError => 'Hitilafu imetokea';

  @override
  String get applyFullName => 'Jina kamili';

  @override
  String get applyPhone => 'Namba ya simu';

  @override
  String get applyEmail => 'Barua pepe';

  @override
  String get applyAddress => 'Anwani ya sasa';

  @override
  String get applyOccupants => 'Watu kwa jumla';

  @override
  String get applyChildren => 'Watoto';

  @override
  String get applyOccupation => 'Umoja';

  @override
  String get applyMoveInDate => 'Tarehe ya kuhamia';

  @override
  String get applyMoveInPick => 'Chagua tarehe';

  @override
  String get applyMoveInRequired => 'Chagua tarehe ya kuhamia';

  @override
  String get applyAdvanceAvailable => 'Naweza kulipa amana';

  @override
  String get applyAdvanceHint =>
      'Wamiliki wengi hupota mwezi mmoja au zaidi mapema.';

  @override
  String get applyAdvanceYes => 'Amana inapatikana';

  @override
  String get applyAdvanceNo => 'Hakuna amana';

  @override
  String get applyReviewNotes => 'Doa la wakala';

  @override
  String get applyWithdraw => 'Ondoa';

  @override
  String get applyWithdrawTitle => 'Ondoa ombi hili?';

  @override
  String get applyWithdrawBody =>
      'Wakala hatazaona. Unaweza kuomba tena baadaye.';

  @override
  String get applyWithdrawConfirm => 'Ondoa';

  @override
  String get applyWithdrawn => 'Ombi umeondolewa';

  @override
  String get applyStatusSubmitted => 'Umewasilisha';

  @override
  String get applyStatusUnderReview => 'Inapitiwa';

  @override
  String get applyStatusShortlisted => 'Umechaguliwa awali';

  @override
  String get applyStatusAccepted => 'Umekubaliwa';

  @override
  String get applyStatusRejected => 'Haujachaguliwa';

  @override
  String get applyStatusWithdrawn => 'Umeondoa';

  @override
  String get emptyNoRecentViews => 'No recent views';

  @override
  String get emptyNoRecentViewsDesc => 'Properties you view will appear here.';

  @override
  String get homeTagline => 'Pata nyumba yako inayofuata Burundi';

  @override
  String get homeSubtitle =>
      'Majengo yaliyothibitishwa, mawakala wa kuaminika, na bei wazi kutoka Bujumbura hadi Muyinga.';

  @override
  String get homeForYou => 'Kwako';

  @override
  String get homeSaved => 'Zimehifadhiwa';

  @override
  String get feedTitle => 'Yanayopendekezwa kwako';

  @override
  String get feedDesc =>
      'Majengo yaliyochaguliwa kulingana na kile wanaotafuta watu kama wewe.';

  @override
  String get feedPersonalize => 'Badilisha mlo wa matokeo';

  @override
  String get feedPersonalizeDesc =>
      'Tuambie unachotafuta na tutakubadilishia matokeo.';

  @override
  String get tilesApartments => 'Ghorofa';

  @override
  String get tilesHouses => 'Nyumba';

  @override
  String get tilesLand => 'Ardhi';

  @override
  String get tilesCommercial => 'Biashara';

  @override
  String get tilesRentals => 'Ukodishaji';

  @override
  String get tilesForSale => 'Inauzwa';

  @override
  String get tilesVillas => 'Vila';

  @override
  String get tilesExplore => 'Gundua zaidi';

  @override
  String get homeFeatured => 'Majengo maalumu';

  @override
  String get homeRecent => 'Majengo mapya';

  @override
  String get homeRecentDesc => 'Fresh listings published in the last 30 days.';

  @override
  String get homeVerified => 'Majengo yaliyothibitishwa';

  @override
  String get homeVerifiedDesc => 'Documents checked by our verification team.';

  @override
  String get homePopularLocations => 'Sehemu maarufu';

  @override
  String get homePopularLocationsDesc =>
      'Where property seekers look the most.';

  @override
  String get homeHowItWorks => 'IMMO BURUNDI inafanya kazi vipi';

  @override
  String get homeStep1Title => 'Tafuta';

  @override
  String get homeStep1Desc =>
      'Browse thousands of listings across every province of Burundi.';

  @override
  String get homeStep2Title => 'Thibitisha';

  @override
  String get homeStep2Desc => 'Documents are checked by our verification team.';

  @override
  String get homeStep3Title => 'Tembelea';

  @override
  String get homeStep3Desc => 'Book a visit directly from the listing.';

  @override
  String get homeStep4Title => 'Nunua au ukodishe';

  @override
  String get homeStep4Desc =>
      'Funga mkataba kwa usalama na wakala wa kuaminika.';

  @override
  String get heroLine1 => 'PATA NYUMBA';

  @override
  String get heroLine2 => 'YAKO BORA';

  @override
  String get heroLine3 => 'LEO';

  @override
  String get heroWelcome =>
      'Karibu kwenye IMMO BURUNDI — anza utafutaji wako hapa chini.';

  @override
  String get heroDesc =>
      'Tunatoa suluhisho za mali isiyohamishika zilizobinafsishwa, hukuelekeza kila hatua kwa uzoefu wa kibinafsi unaokidhi mahitaji na matarajio yako.';

  @override
  String get heroStatsListings => 'Mali';

  @override
  String get heroStatsProvinces => 'Mikoa';

  @override
  String get heroStatsVerified => 'Zimehakikiwa';

  @override
  String get heroAgentsLabel => 'Wataalamu wa mali';

  @override
  String get aboutHeroTitle => 'Kuhusu IMMO BURUNDI';

  @override
  String get aboutHeroSubtitle =>
      'Soko la kisasa na lenye uaminifu la mali isiyohamishika nchini Burundi.';

  @override
  String get aboutMissionTitle => 'Dhima yetu';

  @override
  String get aboutMissionBody =>
      'IMMO BURUNDI inaunganisha wamiliki wa mali, wanunuzi, wapangaji, wawekezaji na mawakala walioidhinishwa katika jukwaa moja la uwazi. Tunafanya kutafuta, kuthibitisha na kufanya biashara ya mali nchini Burundi kuwa rahisi na salama.';

  @override
  String get aboutValuesTitle => 'Thamani zetu';

  @override
  String get aboutValuesTrust => 'Uaminifu';

  @override
  String get aboutValuesTrustDesc =>
      'Orodha zote zinathibitishwa na timu maalum kabla ya kuonyeshwa.';

  @override
  String get aboutValuesTransparency => 'Uwazi';

  @override
  String get aboutValuesTransparencyDesc =>
      'Bei halisi, hali ya uthibitisho na ukaguzi wa nyaraka huonyeshwa kila mara.';

  @override
  String get aboutValuesQuality => 'Ubora';

  @override
  String get aboutValuesQualityDesc =>
      'Tunafanya kazi na mawakala walioidhinishwa na maelezo kamili na sahihi ya mali.';

  @override
  String get aboutValuesAccessibility => 'Upatikanaji';

  @override
  String get aboutValuesAccessibilityDesc =>
      'Inapatikana kwa Kifaransa, Kiingereza na Kiswahili, imeundwa kwa kila kifaa.';

  @override
  String get contactTitle => 'Wasiliana nasi';

  @override
  String get contactSubtitle =>
      'Maswali, maoni au mawazo ya ushirikiano — tunafurahi kusikia kutoka kwako.';

  @override
  String get contactName => 'Jina kamili';

  @override
  String get contactPhone => 'Namba ya simu';

  @override
  String get contactEmail => 'Barua pepe';

  @override
  String get contactSubject => 'Mada';

  @override
  String get contactMessage => 'Ujumbe';

  @override
  String get contactSubmit => 'Tuma ujumbe';

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
  String get contactWhatsappCta => 'Ongea kwenye WhatsApp';

  @override
  String get contactChatTitle => 'Wasiliana na wakala';

  @override
  String get contactAgent => 'Wakala';

  @override
  String get contactCallCta => 'Mpitie wakala';

  @override
  String get contactNoPhone => 'Wakala huyu bado hajaweka namba yake.';

  @override
  String contactWhatsappProperty(String title) {
    return 'Habari, “$title” inanivutia. Je, bopo inapatikana?';
  }

  @override
  String get contactWhatsappGeneric =>
      'Habari, ningependa kujua zaidi kuhusu mali hii.';

  @override
  String get contactVisitBooked =>
      'Ziara yako imewekwa. Wasiliana na wakala ikiwa kuna mabadiliko.';

  @override
  String get contactBuyRequested =>
      'Ombi limewasilishwa. Wasiliana na wakala ili kuendelea.';

  @override
  String get contactListTitle => 'Tangaza jengo lako';

  @override
  String get contactListSubtitle =>
      'Unauza au unakodisha? Chapisha kwenye IMMO BURUNDI kwa dakika chache na uwafikie wanunuzi na wapangaji wengi.';

  @override
  String get contactListButton => 'Anza';

  @override
  String get contactListEmail => 'hello@immoburundi.bi';

  @override
  String get catEyebrow => 'GUNDUA';

  @override
  String get catBuyTitle => 'Majengo yauzwayo';

  @override
  String get catBuySubtitle =>
      'Nyumba, vyumba na majengo mengine katika mikoa yote ya Burundi.';

  @override
  String get catRentTitle => 'Majengo ya kukodi';

  @override
  String get catRentSubtitle =>
      'Vyumba, nyumba na majengo yanayopatikana kwa kukodi.';

  @override
  String get catLandTitle => 'Ardhi ya kuuzwa';

  @override
  String get catLandSubtitle => 'Viwanja katika mikoa yote ya Burundi.';

  @override
  String get catCommercialTitle => 'Majengo ya biashara';

  @override
  String get catCommercialSubtitle =>
      'Maduka, ofisi, maghala na majengo ya viwanda.';

  @override
  String get catFeaturedTitle => 'Majengo maalumu';

  @override
  String get catFeaturedSubtitle => 'Majengo yaliyochaguliwa na timu yetu.';

  @override
  String get catVerifiedTitle => 'Majengo yaliyothibitishwa';

  @override
  String get catVerifiedSubtitle =>
      'Nyaraka ziliangaliwa na timu yetu ya uthibitisho.';

  @override
  String get catOpenSearch => 'Tazama yote katika utafutaji';

  @override
  String get agentsEyebrow => 'WAWASILIANO';

  @override
  String get agentsTitle => 'Mawakala wetu wanaoaminika';

  @override
  String get agentsSubtitle =>
      'Wataalamu waliothibitishwa wanakusaidia kununua, kuuza na kukodi kwa imani.';

  @override
  String get agentsTop => 'Top agent';

  @override
  String get agentsListings => 'Majengo';

  @override
  String get agentsEmpty => 'Hakuna mawakala waliopatikana';

  @override
  String get agentsEmptyDesc =>
      'Hatukupata mawakala wanaolingana na utafutaji wako.';

  @override
  String get agentLatest => 'Za hivi karibuni';

  @override
  String get agentPopular => 'Zinazopendwa';

  @override
  String get agentPriceAsc => 'Bei ya chini';

  @override
  String get agentPriceDesc => 'Bei ya juu';

  @override
  String get agentSubscribe => 'Jiandikishe';

  @override
  String get agentSubscribed => 'Umejiandikisha';

  @override
  String get agentPublished => 'mali zilizochapishwa';

  @override
  String get agentAgentCode => 'Nambari ya wakala';

  @override
  String get agentRating => 'Alama';

  @override
  String get agentMemberSince => 'Mwanachama tangu';

  @override
  String get agentNoBio => 'Wakala huyu bado hajaongeza wasifu.';

  @override
  String get agentEmpty => 'Hakuna mali iliyochapishwa';

  @override
  String get agentEmptyDesc => 'Wakala huyu bado hajachapisha mali yoyote.';

  @override
  String get agentNotFound => 'Wakala hajapatikana';

  @override
  String get agentNotFoundDesc =>
      'Wakala huyu huenda si kazi au kiungo si sahihi.';

  @override
  String get agentAgency => 'Kampuni';

  @override
  String get agentHome => 'Nyumbani';

  @override
  String get agentListings => 'Majengo';

  @override
  String get agentReviews => 'Maoni';

  @override
  String get agentRecent => 'Majengo ya hivi karibuni';

  @override
  String get agentActiveListings => 'majengo yanayoendelea';

  @override
  String agentReviewsCount(num count) {
    return 'maoni $count';
  }

  @override
  String get agentSearchPlaceholder => 'Tafuta majengo ya wakala huyu';

  @override
  String agentMoreLinks(num count) {
    return 'na $count zaidi';
  }

  @override
  String get agentReviewsEmpty => 'Bado hakuna maoni yaliyoandikwa';

  @override
  String get agentReviewsEmptyDesc =>
      'Alama na historia ya miamala zinaonyeshwa hapa chini; maoni yaliyoandikwa yanakuja hivi karibuni.';

  @override
  String get agentSoldHidden =>
      'Majengo yaliyouzwa yanaonekana kwa wanachama walioingia tu.';

  @override
  String get agentSales => 'Mauzo';

  @override
  String get agentDeals => 'Miamala iliyokamilika';

  @override
  String get agentMore => 'zaidi';

  @override
  String get visitBookVisit => 'Booki ziara';

  @override
  String get visitPlacesRemaining => 'nafasi zimesalia';

  @override
  String get visitBookingClosesIn => 'Kufungwa kwa booking';

  @override
  String get visitDate => 'Tarehe';

  @override
  String get visitTime => 'Saa';

  @override
  String get visitSessionFull => 'Kikao kimejaa';

  @override
  String get visitNoSessions => 'No visit sessions available right now.';

  @override
  String get visitBooked => 'Ziara imebookiwa';

  @override
  String get visitBookedSuccess =>
      'Your visit has been booked. Check the dashboard for details.';

  @override
  String get visitBookError => 'Could not book this visit.';

  @override
  String get visitPeople => 'Number of people';

  @override
  String get visitLoginToBook => 'Ingia kubooki ziara';

  @override
  String get visitScheduleUpdated => 'Availability updated live.';

  @override
  String get visitStepWhen => 'Lini';

  @override
  String get visitStepWho => 'Nani';

  @override
  String get visitStepConfirm => 'Thibitisha';

  @override
  String get visitPickDateTime => 'Chagua tarehe na saa ya ziara yako.';

  @override
  String get visitGuestInfoRequired => 'Tafadhali jaza taarifa zako kuendelea.';

  @override
  String get visitUseScheduled => 'Tazama vikao vilivyopangwa';

  @override
  String get visitAnyTime => 'Omba wakati wowote';

  @override
  String get visitFirstName => 'Jina la kwanza';

  @override
  String get visitLastName => 'Jina la mwisho';

  @override
  String get visitPhone => 'Simu';

  @override
  String get visitEmail => 'Barua pepe';

  @override
  String get visitPassword => 'Unda nenosiri';

  @override
  String get visitGuestNote =>
      'Endelea kama mgeni — tutaunda akaunti na kukuingiza kiotomatiki ili ziara yako ihifadhiwe.';

  @override
  String get visitVisitor => 'Mtembezi';

  @override
  String get visitNotes => 'Ujumbe kwa wakala';

  @override
  String get visitBack => 'Rudi';

  @override
  String get visitContinue => 'Endelea';

  @override
  String get visitCreateAccount => 'Fungua akaunti';

  @override
  String get visitConfirmBooking => 'Thibitisha booking';

  @override
  String get visitStepPassword => 'Nenosiri';

  @override
  String get visitFullName => 'Jina kamili';

  @override
  String get visitEmailOrPhone => 'Barua pepe au simu';

  @override
  String get visitConfirmPassword => 'Thibitisha nenosiri';

  @override
  String get visitPasswordMismatch => 'Manenosiri hayalingani.';

  @override
  String get visitPasswordHintStrong =>
      'Tumia nenosiri kali — angalau herufi 8.';

  @override
  String get visitFullNamePlaceholder => 'Jina kamili';

  @override
  String get visitContactPlaceholder => '+257 … au barua pepe';

  @override
  String get visitPlacedTitle => 'Ziara imewekwa!';

  @override
  String get visitPlacedSuccess =>
      'Ombi lako la ziara limepokelewa. Wakala atawasiliana nawe kulithibitisha.';

  @override
  String get visitDone => 'Imekamilika';

  @override
  String get visitManageInDashboard =>
      'Dhibiti au ughairi kutoka dashibodi yako.';

  @override
  String get visitDetailsTitle => 'Maelezo ya ziara';

  @override
  String get visitStatusPending => 'Inasubiri';

  @override
  String get visitStatusConfirmed => 'Imethibitishwa';

  @override
  String get visitStatusCancelled => 'Imeghairiwa';

  @override
  String get visitStatusNoShow => 'Hakujitokeza';

  @override
  String get visitReference => 'Rejea ya booking';

  @override
  String get visitPeopleCount => 'Watu';

  @override
  String get visitBookedOn => 'Ilibookiwa tarehe';

  @override
  String get visitViewProperty => 'Angalia mali';

  @override
  String get visitCancelVisit => 'Ghairi ziara';

  @override
  String get pickerSelectDate => 'Chagua tarehe';

  @override
  String get pickerSelectTime => 'Chagua saa';

  @override
  String get pickerToday => 'Leo';

  @override
  String get pickerTomorrow => 'Kesho';

  @override
  String get pickerMorning => 'Asubuhi';

  @override
  String get pickerAfternoon => 'Mchana';

  @override
  String get pickerEvening => 'Jioni';

  @override
  String get visitSelectDate => 'Chagua tarehe.';

  @override
  String get visitSelectTime => 'Chagua saa.';

  @override
  String get visitSelectSession => 'Chagua kikao cha ziara.';

  @override
  String visitMissingFields(String fields) {
    return 'Kinachohitajika: $fields.';
  }

  @override
  String get visitPasswordHint => 'Angalau herufi 8.';

  @override
  String get mapApproximateLocation => 'Approximate location';

  @override
  String get mapLocationHidden => 'Exact location hidden for owner privacy.';

  @override
  String get mapShowOnMap => 'View on map';

  @override
  String get notificationTitle => 'Arifa';

  @override
  String get notificationUnread => 'hazijasomwa';

  @override
  String get notificationMarkAllRead => 'Weka zote kuwa zimesomwa';

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
  String get modalRequireLogin => 'Ingia kuendelea';

  @override
  String get modalBuySuccess => 'Ombi lako la kununua limetumwa kwa wakala.';

  @override
  String get modalBuyOptionalMessage =>
      'Si lazima — sema kwa wakala unachotaka kujua.';

  @override
  String get applySubmitted =>
      'Your rental application has been submitted to the agent.';

  @override
  String get legalVerificationTitle => 'Taarifa ya Uthibitisho';

  @override
  String get legalCookiesTitle => 'Sera ya Vidakuzi';

  @override
  String get legalUpdated => 'Ilisasishwa mwisho';

  @override
  String get loading => 'Inapakia…';
}
