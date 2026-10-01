// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get sortNewest => 'Plus récents';

  @override
  String get sortPriceAsc => 'Prix croissant';

  @override
  String get sortPriceDesc => 'Prix décroissant';

  @override
  String get sortViews => 'Plus consultés';

  @override
  String get sortFeatured => 'En vedette d\'abord';

  @override
  String get filterTitle => 'Filtres';

  @override
  String get filterApply => 'Appliquer les filtres';

  @override
  String get filterClearAll => 'Tout effacer';

  @override
  String get filterListingType => 'Type d\'annonce';

  @override
  String get filterPropertyType => 'Type de bien';

  @override
  String get filterVerification => 'Vérification';

  @override
  String get filterProvince => 'Province';

  @override
  String get filterCommune => 'Commune';

  @override
  String get filterMinBedrooms => 'Chambres';

  @override
  String get filterPriceRange => 'Fourchette de prix';

  @override
  String get filterMinPrice => 'Prix min';

  @override
  String get filterMaxPrice => 'Prix max';

  @override
  String filterActiveCount(num count) {
    return '{count, plural, =0{Aucun filtre} =1{1 filtre} other{$count filtres}\'}';
  }

  @override
  String get searchPlaceholder =>
      'Rechercher par ville, quartier ou référence…';

  @override
  String get searchNoResults => 'Aucun bien ne correspond à votre recherche';

  @override
  String get searchNoResultsHint =>
      'Essayez de retirer un filtre ou de chercher une autre commune.';

  @override
  String get searchRecent => 'Recherches récentes';

  @override
  String get searchClearHistory => 'Effacer';

  @override
  String searchResultsCount(num count) {
    return '{count, plural, =0{Aucun résultat} =1{1 résultat} other{$count résultats}\'}';
  }

  @override
  String get listingForSale => 'À vendre';

  @override
  String get listingForRent => 'À louer';

  @override
  String get listingForLease => 'À louer (bail)';

  @override
  String get listingAuction => 'Enchère';

  @override
  String get listingInvestment => 'Investissement';

  @override
  String get typeHouse => 'Maison';

  @override
  String get typeApartment => 'Appartement';

  @override
  String get typeVilla => 'Villa';

  @override
  String get typeLand => 'Terrain';

  @override
  String get typeShop => 'Boutique';

  @override
  String get typeOffice => 'Bureau';

  @override
  String get typeWarehouse => 'Entrepôt';

  @override
  String get typeCommercial => 'Local commercial';

  @override
  String get typeIndustrial => 'Local industriel';

  @override
  String get typeFarm => 'Ferme';

  @override
  String get typeHotel => 'Hôtel';

  @override
  String get typeGuestHouse => 'Maison d\'hôtes';

  @override
  String get typeOther => 'Autre';

  @override
  String get verificationNotVerified => 'Non vérifié';

  @override
  String get verificationPartial => 'Partiel';

  @override
  String get verificationVerified => 'Vérifié';

  @override
  String get verificationFullyVerified => 'Entièrement vérifié';

  @override
  String get badgeFeatured => 'En vedette';

  @override
  String get badgeNew => 'Nouveau';

  @override
  String get badgePromoted => 'Promu';

  @override
  String get savedEmptyTitle => 'Aucun bien enregistré';

  @override
  String get savedEmptyBody =>
      'Touchez le cœur sur un bien pour le retrouver ici.';

  @override
  String get savedRequiresSignIn => 'Connectez-vous pour enregistrer des biens';

  @override
  String get savedUpdateFailed =>
      'Impossible de mettre à jour vos biens enregistrés';

  @override
  String get propertyOverview => 'Aperçu';

  @override
  String get propertyFeatures => 'Caractéristiques';

  @override
  String get propertyLocation => 'Localisation';

  @override
  String get propertyAgent => 'Publié par';

  @override
  String get propertySimilar => 'Similaires';

  @override
  String get propertyEnquire => 'Envoyer une demande';

  @override
  String get propertyBookVisit => 'Réserver une visite';

  @override
  String get propertyApplyRental => 'Postuler';

  @override
  String get propertyShareTitle => 'Partager ce bien';

  @override
  String get propertyDescriptionEmpty =>
      'L\'agent n\'a pas ajouté de description.';

  @override
  String get propertyNotFound => 'Bien introuvable';

  @override
  String get propertyShare => 'Partager';

  @override
  String get propertySave => 'Enregistrer';

  @override
  String get propertySold => 'Vendu';

  @override
  String get propertyCall => 'Appeler';

  @override
  String get propertyNegotiable => 'Négociable';

  @override
  String get propertyVerificationNote =>
      'Notre équipe a vérifié les documents de ce bien.';

  @override
  String propertyCoordinates(String coordinates) {
    return 'Coordonnées : $coordinates';
  }

  @override
  String get propertyCoordinatesHidden => 'Position exacte masquée';

  @override
  String get enquiryTitle => 'Envoyer une demande';

  @override
  String get enquirySubject => 'Objet';

  @override
  String get enquiryMessage => 'Message';

  @override
  String get enquirySend => 'Envoyer la demande';

  @override
  String get enquirySent => 'Votre demande a été envoyée à l\'agent';

  @override
  String get enquirySignInRequired => 'Connectez-vous pour envoyer une demande';

  @override
  String get enquiryLabelOpen => 'Envoyée';

  @override
  String get enquiryLabelInProgress => 'Agent en cours';

  @override
  String get enquiryLabelResponded => 'Agent a répondu';

  @override
  String get enquiryLabelDealAgreed => 'Accord conclu';

  @override
  String get enquiryLabelClosed => 'Clôturée';

  @override
  String get enquiryAgentReply => 'Réponse de l\'agent';

  @override
  String get bookingNumberOfPeople => 'Combien de personnes ?';

  @override
  String get bookingNotes => 'Une information pour l\'agent ?';

  @override
  String get bookingConfirm => 'Confirmer la réservation';

  @override
  String get bookingNoSessions =>
      'Aucun créneau de visite n\'est disponible pour ce bien.';

  @override
  String get bookingSignInRequired => 'Connectez-vous pour réserver une visite';

  @override
  String get agentProperties => 'Biens';

  @override
  String get agentSold => 'Vendus';

  @override
  String get agentContact => 'Contact';

  @override
  String get agentCall => 'Appeler l\'agent';

  @override
  String get agentWhatsapp => 'WhatsApp l\'agent';

  @override
  String get agentAbout => 'À propos';

  @override
  String get agentLicense => 'Licence';

  @override
  String get bookingTitle => 'Réserver une visite';

  @override
  String get bookingAnyTime => 'N\'importe quelle date disponible';

  @override
  String get bookingPickDate => 'Choisir une date';

  @override
  String get bookingSuccess => 'Votre visite est réservée';

  @override
  String get bookingReference => 'Référence';

  @override
  String get bookingMyVisits => 'Mes visites';

  @override
  String get paymentTitle => 'Paiement';

  @override
  String get paymentMethod => 'Payer avec';

  @override
  String get paymentConfirm => 'Confirmer et payer';

  @override
  String get paymentSuccess => 'Paiement reçu';

  @override
  String get paymentPending => 'Le paiement est en cours de traitement';

  @override
  String get paymentAmountDue => 'Montant dû';

  @override
  String get paymentPayee => 'Bénéficiaire';

  @override
  String get paymentExpires => 'Expire le';

  @override
  String get paymentCancelled => 'Ce lien de paiement a été annulé';

  @override
  String get paymentPayerPhone => 'Votre numéro mobile money';

  @override
  String get paymentPhoneInvalid =>
      'Saisissez un numéro mobile money burundais valide';

  @override
  String get paymentReference => 'Référence';

  @override
  String get paymentRecordedNote =>
      'Aucun prestataire de paiement n\'est encore connecté, cette action enregistre votre paiement et marque le bien comme vendu. Ce n\'est pas une confirmation bancaire.';

  @override
  String get youTitle => 'Vous';

  @override
  String get youSignedOutTitle => 'Vous naviguez en invité';

  @override
  String get youSignedOutBody =>
      'Connectez-vous pour enregistrer des biens, contacter les agents et réserver des visites.';

  @override
  String get youMyPayments => 'Paiements';

  @override
  String get youMyVisits => 'Visites';

  @override
  String get youEditProfile => 'Modifier le profil';

  @override
  String get youAccountActivity => 'Votre activité';

  @override
  String get accountViews => 'Vues';

  @override
  String get accountEnquiries => 'Demandes';

  @override
  String get accountSaved => 'Enregistrés';

  @override
  String get authSetupRemaining => 'Terminez la création de votre compte';

  @override
  String get profilePhotoSection => 'Photo de profil';

  @override
  String get profilePhotoHint =>
      'Affichée à côté de votre nom sur toute la plateforme. JPEG, PNG, WEBP ou GIF, 5 Mo maximum.';

  @override
  String get profilePhotoChoose => 'Choisir une photo';

  @override
  String get profilePhotoRemove => 'Supprimer la photo';

  @override
  String get profilePhotoUploading => 'Envoi de la photo...';

  @override
  String get profilePhotoUpdated => 'Photo de profil mise à jour.';

  @override
  String get profilePhotoRemoved => 'Photo de profil supprimée.';

  @override
  String get profilePhotoInvalid =>
      'Choisissez une image JPEG, PNG, WEBP ou GIF.';

  @override
  String get profilePhotoTooLarge => 'L\'image doit faire 5 Mo ou moins.';

  @override
  String get profilePhotoFailed => 'Impossible de lire cette image.';

  @override
  String get profilePersonalSection => 'Informations personnelles';

  @override
  String get profilePersonalHint =>
      'Mettez à jour votre nom, votre numéro et votre e-mail.';

  @override
  String get profilePersonalSaved =>
      'Vos informations personnelles ont été enregistrées.';

  @override
  String get profileSecuritySection => 'Sécurité';

  @override
  String get profileSecurityHint =>
      'Changez le mot de passe utilisé pour vous connecter.';

  @override
  String get profileCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileNewPassword => 'Nouveau mot de passe';

  @override
  String get profilePasswordHint => 'Au moins 8 caractères';

  @override
  String get profilePasswordTooShort => 'Utilisez au moins 8 caractères.';

  @override
  String get profileEmailInvalid => 'Saisissez une adresse e-mail valide.';

  @override
  String get profileWrongPassword => 'Ce mot de passe actuel est incorrect.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsCurrency => 'Devise';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsRateApp => 'Noter IMMO BURUNDI';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutConfirm => 'Se déconnecter d\'IMMO BURUNDI ?';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageChanged => 'Langue modifiée';

  @override
  String get currencyChanged => 'Devise modifiée';

  @override
  String get notificationsEmpty => 'Aucune notification';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsRequiresSignIn =>
      'Connectez-vous pour voir vos notifications';

  @override
  String get legalTermsTitle => 'Conditions générales';

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get legalUnavailable =>
      'Ce document n\'est pas disponible hors ligne.';

  @override
  String get legalReadOnSite => 'Lire le document complet sur le site';

  @override
  String get offlineBanner =>
      'Hors ligne - certaines informations ne se mettent pas à jour';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String get errorNetwork => 'Network error — check your connection.';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabExplore => 'Explorer';

  @override
  String get tabSaved => 'Enregistrés';

  @override
  String get tabYou => 'Vous';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutMissionBodyLong =>
      'De Bujumbura à Muyinga, nous aidons les acheteurs, les locataires et les investisseurs à découvrir des propriétés vérifiées, tout en donnant aux propriétaires et aux agents professionnels les outils pour toucher le bon public. Chaque annonce affiche un statut de vérification transparent et un prix d\'origine, et notre équipe veille à ce que la place de marché reste exempte de fraude.';

  @override
  String get aboutContactTitle => 'Contactez-nous';

  @override
  String get aboutEmailSubject => 'Bonjour IMMO BURUNDI';

  @override
  String get aboutWebsite => 'Site web';

  @override
  String get aboutCopy => 'Copier';

  @override
  String get aboutCopied => 'Copié dans le presse-papiers';

  @override
  String get contactAddressLabel => 'Siège';

  @override
  String get errorNoAppForLink =>
      'Aucune application sur cet appareil ne peut ouvrir ce lien.';

  @override
  String get errorSomethingWrongTitle => 'Une erreur est survenue';

  @override
  String get errorRetry => 'Réessayer';

  @override
  String get settingsStorage => 'Stockage';

  @override
  String get settingsClearCache => 'Vider le cache des images';

  @override
  String get settingsCacheCleared => 'Cache vidé';

  @override
  String get settingsHelp => 'Aide';

  @override
  String get settingsCookiePolicy => 'Politique de cookies';

  @override
  String get commonCurrency => 'Devise';

  @override
  String get commonLanguage => 'Langue';

  @override
  String get commonYou => 'Vous';

  @override
  String get commonNow => 'maintenant';

  @override
  String get commonNotify => 'Activer les notifications';

  @override
  String get commonEstimate => 'estimation';

  @override
  String get commonEstimated => 'Estimé';

  @override
  String get commonLoading => 'Chargement';

  @override
  String get commonPrevious => 'Retour';

  @override
  String get navigationClose => 'Fermer';

  @override
  String get commonViewAll => 'Tout voir';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get mediaViewPhotos => 'Voir les photos';

  @override
  String get mediaOf => 'sur';

  @override
  String get mediaPhoto => 'Photo';

  @override
  String get mediaPreviousPhoto => 'Photo précédente';

  @override
  String get mediaNextPhoto => 'Photo suivante';

  @override
  String get mediaImageUnavailable => 'Image indisponible';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonPagination => 'Pagination';

  @override
  String get commonNext => 'Suivant';

  @override
  String get errorBoundaryBody =>
      'L\'application a rencontré une erreur inattendue. Vos données sont intactes - réessayez ou rechargez la page.';

  @override
  String get errorReload => 'Recharger la page';

  @override
  String get commonSend => 'Envoyer';

  @override
  String get commonSubmit => 'Valider';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get themeLightMode => 'Passer en mode clair';

  @override
  String get themeDarkMode => 'Passer en mode sombre';

  @override
  String get commonAll => 'Tous';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonFrom => 'de';

  @override
  String get commonTo => 'à';

  @override
  String get commonAnd => 'and';

  @override
  String get commonOr => 'or';

  @override
  String get commonMin => 'Min';

  @override
  String get commonMax => 'Max';

  @override
  String get commonAny => 'Indifférent';

  @override
  String get commonFilters => 'Filtres';

  @override
  String get commonClear => 'Effacer';

  @override
  String get commonApply => 'Appliquer';

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
  String get commonResults => 'résultats';

  @override
  String get commonProperty => 'bien';

  @override
  String get commonProperties => 'biens';

  @override
  String get commonViews => 'vues';

  @override
  String get commonShowMore => 'Voir plus';

  @override
  String get commonShowLess => 'Voir moins';

  @override
  String get commonMore => 'Plus';

  @override
  String get commonCopy => 'Copié dans le presse-papiers';

  @override
  String get navHome => 'Accueil';

  @override
  String get navBuy => 'Acheter';

  @override
  String get navRent => 'Louer';

  @override
  String get navLand => 'Terrain';

  @override
  String get navCommercial => 'Commercial';

  @override
  String get navFeatured => 'En vedette';

  @override
  String get navVerified => 'Vérifiés';

  @override
  String get navAgents => 'Agents';

  @override
  String get navAbout => 'À propos';

  @override
  String get navContact => 'Contact';

  @override
  String get navLogin => 'Connexion';

  @override
  String get navRegister => 'S\'inscrire';

  @override
  String get navLogout => 'Déconnexion';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navMessages => 'Messages';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navMenu => 'Menu';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navBrowse => 'Parcourir';

  @override
  String get navMore => 'Plus';

  @override
  String get navListProperty => 'Publier un bien';

  @override
  String get searchTitle => 'Search properties';

  @override
  String get searchPlaceholderShort => 'Rechercher des biens…';

  @override
  String get searchQuickLinks => 'Liens rapides';

  @override
  String get searchSegmentProperties => 'Biens';

  @override
  String get searchSegmentAgents => 'Agents';

  @override
  String get searchSegmentMore => 'Plus';

  @override
  String get searchSortBy => 'Trier par';

  @override
  String get searchAdvancedTitle => 'Recherche avancée';

  @override
  String get searchAdvancedDesc =>
      'Affinez votre recherche — lieu, budget et chambres.';

  @override
  String get searchPropertyAgent => 'Rechercher des agents';

  @override
  String get searchPerson => 'Rechercher des personnes ou des biens';

  @override
  String get searchButton => 'Rechercher';

  @override
  String get searchLocation => 'Localité';

  @override
  String get searchPropertyType => 'Type de bien';

  @override
  String get searchMinPrice => 'Prix min';

  @override
  String get searchMaxPrice => 'Prix max';

  @override
  String get searchBedrooms => 'Chambres';

  @override
  String get searchPropertyId => 'Référence du bien';

  @override
  String get searchTabBuy => 'Acheter';

  @override
  String get searchTabRent => 'Louer';

  @override
  String get searchTabLand => 'Terrain';

  @override
  String get searchTabCommercial => 'Commercial';

  @override
  String get searchTabInvestment => 'Investment';

  @override
  String get searchSort => 'Sort';

  @override
  String get searchSortNewest => 'Plus récent';

  @override
  String get searchSortPriceAsc => 'Prix croissant';

  @override
  String get searchSortPriceDesc => 'Prix décroissant';

  @override
  String get searchSortViews => 'Plus consultés';

  @override
  String get searchSortFeatured => 'En vedette';

  @override
  String get searchResults => 'Résultat';

  @override
  String get searchResultsPlural => 'Résultats';

  @override
  String get searchFilters => 'Filtrer les résultats';

  @override
  String get searchPersonalize => 'Personnaliser les résultats';

  @override
  String get searchResetFilters => 'Réinitialiser';

  @override
  String get searchProvince => 'Province';

  @override
  String get searchCommune => 'Commune';

  @override
  String get searchVerificationStatus => 'Vérification';

  @override
  String get searchFeatured => 'Vedettes uniquement';

  @override
  String get searchSurface => 'Surface area (m²)';

  @override
  String get searchMinSurface => 'Min surface';

  @override
  String get searchMaxSurface => 'Max surface';

  @override
  String get searchListingType => 'Type de transaction';

  @override
  String get searchPriceRange => 'Fourchette de prix';

  @override
  String get searchCleared => 'Filters cleared';

  @override
  String get propertyBuyHint =>
      'Dites à l’agent votre intérêt pour l’achat de ce bien';

  @override
  String get propertyBuy => 'Acheter';

  @override
  String get propertyForSale => 'À vendre';

  @override
  String get propertyForRent => 'À louer';

  @override
  String get propertyForLease => 'En bail';

  @override
  String get propertyForAuction => 'Aux enchères';

  @override
  String get propertyForInvestment => 'Investissement';

  @override
  String get propertyIsNew => 'Nouveau';

  @override
  String get propertyIsPromoted => 'Promu';

  @override
  String get propertyViews => 'vues';

  @override
  String get propertyFavorites => 'favoris';

  @override
  String get propertyBedrooms => 'ch';

  @override
  String get propertyBathrooms => 'sdb';

  @override
  String get propertySurface => 'm²';

  @override
  String get propertyFloors => 'étages';

  @override
  String get propertyParking => 'places';

  @override
  String get propertyYearBuilt => 'Construit';

  @override
  String get propertyRooms => 'rooms';

  @override
  String get propertyNotNegotiable => 'Non négociable';

  @override
  String get propertyVerifyStatus => 'Statut de vérification';

  @override
  String get propertyVerified => 'Vérifié';

  @override
  String get propertyPartial => 'Partiellement vérifié';

  @override
  String get propertyNotVerified => 'Non vérifié';

  @override
  String get propertyFullyVerified => 'Entièrement vérifié';

  @override
  String get propertyVerificationStatus => 'Vérification';

  @override
  String get propertyDisclaimer =>
      'La vérification repose sur les documents fournis et ne garantit pas la propriété.';

  @override
  String get propertyContactAgent => 'Contacter l’agent';

  @override
  String get propertyWhatsapp => 'WhatsApp';

  @override
  String get propertyMessage => 'Message';

  @override
  String get propertyRequestVisit => 'Demander une visite';

  @override
  String get propertyApplyRent => 'Postuler pour louer';

  @override
  String get propertyReport => 'Signaler';

  @override
  String get propertyRelatedProperties => 'Biens similaires';

  @override
  String get propertyAboutThis => 'À propos de ce bien';

  @override
  String get propertyMap => 'Localisation';

  @override
  String get propertyMapApproxNote => 'Approximate location';

  @override
  String get propertyMapHidden =>
      'The exact location of this property is hidden.';

  @override
  String get propertyPrice => 'Prix';

  @override
  String get propertySpecs => 'Caractéristiques';

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
  String get propertySaves => 'enregistrements';

  @override
  String get propertyLikes => 'j’aime';

  @override
  String get propertyMultipleAgents => 'Plusieurs agents';

  @override
  String get propertyViewMore => 'Voir plus';

  @override
  String get propertySameAgent => 'Même agent';

  @override
  String get propertySameNeighborhood => 'Même quartier';

  @override
  String get propertyNoRelated => 'Aucun bien similaire';

  @override
  String get propertyAgentCard => 'Agent';

  @override
  String get propertyTopAgent => 'Meilleur agent';

  @override
  String get propertyViewProfile => 'Voir le profil';

  @override
  String get propertyAsk => 'Demander';

  @override
  String get propertyAskPlaceholder => 'Posez une question à l’agent…';

  @override
  String get propertyPhotos => 'photos';

  @override
  String get propertyQuestions => 'Questions';

  @override
  String get propertyNoQuestionsYet =>
      'Aucune question pour le moment — soyez le premier à poser.';

  @override
  String get relToday => 'Aujourd\'hui';

  @override
  String relDaysAgo(String days) {
    return 'il y a $days j';
  }

  @override
  String relWeeksAgo(String weeks) {
    return 'il y a $weeks sem';
  }

  @override
  String relMonthsAgo(String months) {
    return 'il y a $months mois';
  }

  @override
  String relYearsAgo(String years) {
    return 'il y a $years ans';
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
  String get propertyPropertyId => 'Référence';

  @override
  String get propertytypeHOUSE => 'Maison';

  @override
  String get propertytypeOFFICE => 'Bureau';

  @override
  String get propertytypeFARM => 'Ferme';

  @override
  String get propertytypeAPARTMENT => 'Appartement';

  @override
  String get propertytypeSHOP => 'Boutique';

  @override
  String get propertytypeINDUSTRIAL => 'Industriel';

  @override
  String get propertytypeVILLA => 'Villa';

  @override
  String get propertytypeWAREHOUSE => 'Entrepôt';

  @override
  String get propertytypeOTHER => 'Autre';

  @override
  String get propertytypeLAND => 'Terrain';

  @override
  String get propertytypeHOTEL => 'Hôtel';

  @override
  String get propertytypeCOMMERCIAL => 'Commercial';

  @override
  String get propertytypeGUESTHOUSE => 'Guest house';

  @override
  String get verificationTitle => 'Vérification des documents';

  @override
  String get verificationLearnMore => 'En savoir plus';

  @override
  String get verificationLandTitle => 'Titre foncier';

  @override
  String get verificationSaleAgreement => 'Acte de vente';

  @override
  String get verificationTop => 'Précompte (TOP)';

  @override
  String get verificationPropertyTax => 'Taxe foncière';

  @override
  String get verificationOwnerId => 'Pièce d’identité du propriétaire';

  @override
  String get verificationOther => 'Other document';

  @override
  String get verificationPassed => 'Vérifié';

  @override
  String get verificationFailed => 'Échoué';

  @override
  String get verificationNotApplicable => 'Non applicable';

  @override
  String get verificationVerifiedAt => 'Verified on';

  @override
  String get authLogin => 'Connexion';

  @override
  String get authRegister => 'Créer un compte';

  @override
  String get authEmail => 'Adresse e-mail';

  @override
  String get authPhone => 'Numéro de téléphone';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authNoAccount => 'Vous n’avez pas de compte ?';

  @override
  String get authHasAccount => 'Vous avez déjà un compte ?';

  @override
  String get authCreateAccount => 'Créer le compte';

  @override
  String get authLoginTabPhone => 'Téléphone';

  @override
  String get authLoginTabEmail => 'E-mail';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authRegisterWelcome => 'Rejoindre IMMO BURUNDI';

  @override
  String get authLoginSuccess => 'Logged in successfully';

  @override
  String get authRegisterSuccess => 'Account created successfully';

  @override
  String get authPasswordMismatch => 'Les mots de passe ne correspondent pas';

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
  String get authLogout => 'Déconnexion';

  @override
  String get authSignUpEyebrow => 'REJOIGNEZ IMMO BURUNDI';

  @override
  String get authSignUpTitle => 'Créez votre compte';

  @override
  String get authSignUpSubtitle =>
      'Enregistrez vos biens favoris, échangez avec les agents et soyez alerté des nouvelles annonces.';

  @override
  String get authLogInEyebrow => 'BON RETOUR';

  @override
  String get authLogInSubtitle =>
      'Connectez-vous pour gérer vos favoris, messages et visites.';

  @override
  String get authPasswordPlaceholder => '8 caractères minimum';

  @override
  String get authNamePlaceholder => 'Jean Ndayishimiye';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authPhonePlaceholder => '+257 79 000 000';

  @override
  String get dashboardTitle => 'Mon tableau de bord';

  @override
  String get dashboardAgentTitle => 'Tableau de bord agent';

  @override
  String get dashboardFavorites => 'Mes favoris';

  @override
  String get dashboardRecentViews => 'Récemment consultés';

  @override
  String get dashboardApplications => 'Candidatures';

  @override
  String get dashboardVisits => 'Mes visites';

  @override
  String get dashboardMessages => 'Messages';

  @override
  String get dashboardNotifications => 'Notifications';

  @override
  String get dashboardProfile => 'Profil';

  @override
  String get dashboardEditProfile => 'Modifier le profil';

  @override
  String get dashboardSaveChanges => 'Enregistrer';

  @override
  String get dashboardLanguage => 'Langue préférée';

  @override
  String get dashboardCurrency => 'Devise préférée';

  @override
  String get dashboardSignedInAs => 'Signed in as';

  @override
  String get dashboardProfileUpdated => 'Profile updated';

  @override
  String get dashboardPasswordChanged => 'Password changed';

  @override
  String get dashboardSettings => 'Paramètres';

  @override
  String get dashboardMyProperties => 'Biens';

  @override
  String get dashboardPropFilterAll => 'Tous';

  @override
  String get dashboardPropFilterActive => 'En ligne';

  @override
  String get dashboardPropFilterReview => 'En validation';

  @override
  String get dashboardPropFilterChanges => 'À corriger';

  @override
  String get dashboardPropFilterRejected => 'Rejetés';

  @override
  String get dashboardPropFilterDraft => 'Brouillons';

  @override
  String get dashboardPropFilterArchive => 'Archives';

  @override
  String get dashboardPropFilterSold => 'Vendus';

  @override
  String get dashboardPropFilterRented => 'Lou';

  @override
  String get dashboardRelistProperty => 'Publier a nouveau';

  @override
  String dashboardRelistPropertyConfirm(String title) {
    return 'Republier $title ? Un administrateur doit le valider avant sa remise en ligne.';
  }

  @override
  String get dashboardBookings => 'Réservations';

  @override
  String get dashboardAnalytics => 'Statistiques';

  @override
  String get dashboardVerification => 'Vérification';

  @override
  String get dashboardListProperty => 'Publier un bien';

  @override
  String get dashboardProperties => 'Biens';

  @override
  String get dashboardOverview => 'Vue d’ensemble';

  @override
  String get dashboardAgents => 'Agents';

  @override
  String get dashboardRequests => 'Demandes';

  @override
  String get dashboardNoPropertiesDesc => 'Publiez un bien pour le gérer ici.';

  @override
  String get dashboardNoBookings => 'Aucune réservation';

  @override
  String get dashboardNoBookingsDesc =>
      'Les demandes de visite de vos biens apparaîtront ici.';

  @override
  String get dashboardNoVerification => 'Aucune demande de vérification';

  @override
  String get dashboardNoVerificationDesc =>
      'Demandez la vérification d’un bien pour qu’il soit examiné.';

  @override
  String get dashboardProperty => 'Bien';

  @override
  String get dashboardConfirm => 'Confirmer';

  @override
  String get dashboardCancel => 'Annuler';

  @override
  String get dashboardStatViews => 'Vues totales';

  @override
  String get dashboardStatLikes => 'J’aime totaux';

  @override
  String get dashboardStatShares => 'Partages totaux';

  @override
  String get dashboardStatBookings => 'Visites réservées';

  @override
  String get dashboardStatEnquiries => 'Demandes';

  @override
  String get dashboardPerProperty => 'Par bien';

  @override
  String get navMyProperties => 'Mes biens';

  @override
  String get navHelp => 'Aide';

  @override
  String get navFeedback => 'Envoyer un avis';

  @override
  String get dashboardHome => 'Tableau de bord';

  @override
  String get dashboardInbox => 'Réservations et demandes';

  @override
  String get dashboardSidebarAgency => 'Votre agence';

  @override
  String get dashboardSidebarProfile => 'Profile';

  @override
  String get dashboardAddNew => 'Ajouter un bien';

  @override
  String get dashboardClearFilters => 'Tout effacer';

  @override
  String get dashboardSearchProperties =>
      'Rechercher par titre, référence ou description';

  @override
  String dashboardResultsCount(String from, String to, num total) {
    return 'Affichage de $from-$to sur $total';
  }

  @override
  String get dashboardNoSearchResults =>
      'Aucune annonce ne correspond à votre recherche. Essayez un autre terme ou effacez la recherche.';

  @override
  String get dashboardRequester => 'Demandeur';

  @override
  String get dashboardAllStatuses => 'Tous les statuts ▾';

  @override
  String get dashboardCardsListTitle => 'Publiez votre premier bien';

  @override
  String get dashboardCardsListDesc =>
      'Mettez une annonce en ligne et recevez des vues et des demandes.';

  @override
  String get dashboardCardsListCta => 'Ajouter un bien';

  @override
  String get dashboardCardsAnalyticsTitle => 'Analyses';

  @override
  String get dashboardCardsAnalyticsDesc =>
      'Suivez vues, favoris et demandes pour chaque bien.';

  @override
  String get dashboardCardsAnalyticsCta => 'Voir les analyses';

  @override
  String get dashboardCardsTipsTitle => 'Conseils agents';

  @override
  String get dashboardCardsTip1 =>
      'De belles photos peuvent augmenter les visites de 70%.';

  @override
  String get dashboardCardsTip2 =>
      'Répondez aux demandes dans la première heure.';

  @override
  String get dashboardCardsTip3 =>
      'Marquez l\'accord conclu avant d\'envoyer un lien de paiement.';

  @override
  String get dashboardColProperty => 'Bien';

  @override
  String get dashboardColFlags => 'Signets';

  @override
  String get dashboardColStatus => 'Statut';

  @override
  String get dashboardColListed => 'Date de mise en ligne';

  @override
  String get dashboardColViews => 'Vues';

  @override
  String get dashboardColInquiries => 'Demandes';

  @override
  String get dashboardEmptyProps => 'Aucun bien';

  @override
  String get dashboardEmptyPropsDesc =>
      'Créez votre première annonce pour constituer votre portefeuille.';

  @override
  String get dashboardColActions => 'Actions';

  @override
  String get dashboardEditProperty => 'Modifier le bien';

  @override
  String get dashboardDeleteProperty => 'Supprimer le bien';

  @override
  String get dashboardRequestVerification => 'Demander la vérification';

  @override
  String get dashboardRequestVerificationDesc =>
      'Envoyez ce bien à l\'équipe IMMO BURUNDI pour vérification. Un agent examinera les documents et vous contactera s\'il manque quelque chose.';

  @override
  String get dashboardVerificationRequested => 'Vérification demandée';

  @override
  String get dashboardVerificationCode => 'Référence';

  @override
  String get dashboardVerificationNote => 'Note pour l\'équipe de vérification';

  @override
  String get dashboardVerificationNotePlaceholder =>
      'Ce que l\'agent doit savoir (facultatif)';

  @override
  String get dashboardVerificationPending => 'Vérification déjà en cours';

  @override
  String get dashboardVerified => 'Vérifié';

  @override
  String get dashboardVerificationIntro =>
      'Suivez tous les biens que vous gérez : ce qui est en attente de décision, ce qui est déjà vérifié, et exactement quoi corriger avant que l\'administration n\'accepte une annonce.';

  @override
  String get dashboardVerificationPendingSection => 'Vérifications en attente';

  @override
  String get dashboardVerificationVerifiedSection => 'Biens vérifiés';

  @override
  String get dashboardVerificationActionSection => 'Nécessite votre attention';

  @override
  String get dashboardVerificationNoPending =>
      'Aucun bien n\'est en attente d\'une décision de vérification.';

  @override
  String get dashboardVerificationNoVerified =>
      'Aucun de vos biens n\'est encore vérifié.';

  @override
  String get dashboardVerificationNoAction =>
      'Rien à corriger — tous les biens que vous gérez sont complets.';

  @override
  String get dashboardVerificationEmpty =>
      'Vous ne gérez encore aucun bien. Ajoutez un bien pour suivre sa vérification.';

  @override
  String get dashboardVerificationEmptyCta => 'Aller à mes biens';

  @override
  String get dashboardVerificationWhatToUpdate =>
      'À corriger pour l\'acceptation';

  @override
  String get dashboardVerificationAllMet =>
      'Toutes les conditions sont remplies. Ce bien est prêt pour une décision de vérification.';

  @override
  String get dashboardVerificationAdminNote => 'Note de l\'administration';

  @override
  String get dashboardVerificationReviewNote => 'Note de l’équipe de révision';

  @override
  String get dashboardVerificationRequestedOn => 'Demandée le';

  @override
  String get dashboardVerificationReviewedBy => 'Révisé par';

  @override
  String get dashboardVerificationDocuments => 'Documents joints';

  @override
  String get dashboardVerificationNoDocuments =>
      'Aucun document joint pour l\'instant.';

  @override
  String get dashboardVerificationMissing => 'manquant';

  @override
  String get dashboardVerificationProvided => 'fourni';

  @override
  String get dashboardVerificationCount => 'éléments à corriger';

  @override
  String get dashboardVerificationAdminDecides =>
      'Un administrateur système examine et décide la vérification finale. Vous ne pouvez pas marquer vous-même un bien comme vérifié.';

  @override
  String get dashboardVerificationView => 'Voir les détails';

  @override
  String get verifyreqDocumentLANDTITLE => 'Titre foncier';

  @override
  String get verifyreqDocumentOWNERID => 'Pièce d\'identité du propriétaire';

  @override
  String get verifyreqDocumentSALEAGREEMENT => 'Contrat de vente signé';

  @override
  String get verifyreqDocumentTOP => 'Certificat d’urbanisme (TOP)';

  @override
  String get verifyreqDocumentPROPERTYTAX => 'Reçu de taxe foncière';

  @override
  String get verifyreqDocumentOTHER => 'Autre document justificatif';

  @override
  String get verifyreqFieldTitle => 'Titre de l\'annonce';

  @override
  String get verifyreqFieldDescription => 'Description';

  @override
  String get verifyreqFieldPrice => 'Prix';

  @override
  String get verifyreqFieldSurfaceArea => 'Superficie';

  @override
  String get verifyreqFieldLocation => 'Province et commune';

  @override
  String get verifyreqFieldMedia => 'Au moins une photo';

  @override
  String get verificationPropertiesTab => 'Biens';

  @override
  String get verificationAgentsTab => 'Agents';

  @override
  String get verificationShowCompleted => 'Afficher les traités';

  @override
  String get verificationNoPendingProperties =>
      'Aucun bien en attente de vérification';

  @override
  String get verificationNoPendingPropertiesDesc =>
      'Les nouvelles demandes des agents s\'afficheront ici.';

  @override
  String get verificationNoPendingAgents =>
      'Aucun agent en attente de vérification';

  @override
  String get verificationNoPendingAgentsDesc =>
      'Les nouveaux agents apparaissent ici jusqu\'à ce que vous les vérifiiez.';

  @override
  String verificationRequestedOn(String date) {
    return 'Demandé le $date';
  }

  @override
  String verificationRegisteredOn(String date) {
    return 'Inscrit le $date';
  }

  @override
  String get verificationAgent => 'Agent en charge';

  @override
  String get verificationNoAgent => 'Aucun agent assigné à ce bien.';

  @override
  String get verificationVerify => 'Vérifier';

  @override
  String get verificationReject => 'Rejeter';

  @override
  String get verificationRejectTitle => 'Rejeter la vérification';

  @override
  String get verificationRejectDesc =>
      'Le demandeur reçoit votre motif, soyez donc clair et précis.';

  @override
  String get verificationReason => 'Motif';

  @override
  String get verificationReasonPlaceholder =>
      'Qu\'est-ce qui manque ou ne va pas ?';

  @override
  String get verificationReasonHint =>
      'Ce motif est envoyé à l\'agent et affiché sur la demande.';

  @override
  String get verificationReasonRequired =>
      'Un motif est obligatoire pour rejeter une vérification.';

  @override
  String get verificationConfirmReject => 'Confirmer le rejet';

  @override
  String get verificationRejectionReason => 'Motif du rejet';

  @override
  String get verificationLicenseNumber => 'Numéro de licence';

  @override
  String get verificationProvince => 'Province';

  @override
  String verificationAgentStatus(String status) {
    return 'Agent : $status';
  }

  @override
  String verificationAgentWhatsappMessage(String title) {
    return 'Bonjour, ici l\'équipe de vérification IMMO BURUNDI au sujet de « $title ».';
  }

  @override
  String dashboardDeletePropertyConfirm(String title) {
    return 'Supprimer « $title » ? Cette annonce sera définitivement retirée.';
  }

  @override
  String get dashboardBlockedByAdmin => 'Bloqué par l\'administration';

  @override
  String get dashboardTabBookings => 'Demandes de visite';

  @override
  String get dashboardTabEnquiries => 'Demandes d\'achat';

  @override
  String get dashboardTabMessages => 'Messages';

  @override
  String get dashboardContact => 'Contacter';

  @override
  String get dashboardWhatsApp => 'Discuter sur WhatsApp';

  @override
  String get dashboardSendLink => 'Envoyer le lien de paiement';

  @override
  String get dashboardCopyLink => 'Copier le lien';

  @override
  String get dashboardMarkDeal => 'Marquer accord conclu';

  @override
  String get dashboardLinkCopied => 'Lien copié dans le presse-papiers';

  @override
  String get dashboardNoInbox => 'Aucune demande';

  @override
  String get dashboardNoInboxDesc =>
      'Les demandes de visite et d\'achat pour vos biens apparaîtront ici.';

  @override
  String get bookingStatusPENDING => 'En attente';

  @override
  String get bookingStatusCONFIRMED => 'Acceptée';

  @override
  String get bookingStatusCOMPLETED => 'Accord conclu';

  @override
  String get bookingStatusCANCELLED => 'Refusée';

  @override
  String get bookingStatusNOSHOW => 'Absence';

  @override
  String get bookingStatusDEALAGREED => 'Accord conclu';

  @override
  String get enquiryStatusNEW => 'Nouvelle';

  @override
  String get enquiryStatusOPEN => 'Ouverte';

  @override
  String get enquiryStatusINPROGRESS => 'En cours';

  @override
  String get enquiryStatusRESPONDED => 'Répondue';

  @override
  String get enquiryStatusDEALAGREED => 'Accord conclu';

  @override
  String get enquiryStatusCLOSED => 'Fermée';

  @override
  String get dealAgreed => 'Conclu';

  @override
  String get dealTitle => 'Marquer l\'accord comme conclu ?';

  @override
  String get dealDesc =>
      'Cela permettra d\'envoyer un lien de paiement au demandeur.';

  @override
  String get dealConfirm => 'Oui, marquer conclu';

  @override
  String get plinkStatusCREATED => 'Lien envoyé';

  @override
  String get plinkStatusSENT => 'Lien envoyé';

  @override
  String get plinkStatusOPENED => 'Ouvert';

  @override
  String get plinkStatusPAID => 'Payé';

  @override
  String get plinkStatusCANCELLED => 'Annulé';

  @override
  String get plinkStatusEXPIRED => 'Expiré';

  @override
  String get analyticsTabOverview => 'Vue d\'ensemble';

  @override
  String get analyticsTabProperties => 'Biens';

  @override
  String get analyticsTabClients => 'Clients';

  @override
  String get analyticsTabTrends => 'Tendances';

  @override
  String get analyticsPeriod => '28 derniers jours';

  @override
  String get analyticsAvgTime => 'Temps moyen sur l\'annonce';

  @override
  String get analyticsStatLeads => 'Leads';

  @override
  String get analyticsStatRealtime => 'Temps réel';

  @override
  String get analyticsRealtimeDesc =>
      'Activité en direct sur vos biens publiés.';

  @override
  String get analyticsNoData => 'Aucune activité sur cette période';

  @override
  String get analyticsViewsShort => 'Vues';

  @override
  String get analyticsFavoritesShort => 'Favoris';

  @override
  String get analyticsInquiriesShort => 'Demandes';

  @override
  String get listDropTitle => 'Téléversez des photos du bien';

  @override
  String get listDropHint =>
      'Une URL de photo par ligne — la première devient la couverture.';

  @override
  String get listSelectFiles => 'Choisir des fichiers';

  @override
  String get listNeedHelp => 'Besoin d\'aide ? Nous sommes là.';

  @override
  String get listUploadNotice =>
      'Les photos sont publiques. N\'y incluez pas de documents personnels.';

  @override
  String listPhotoCountOk(num count) {
    return 'Photos suffisantes ($count ajoutées).';
  }

  @override
  String listPhotoCountMissing(num count) {
    return 'Ajoutez encore $count photo(s) — 4 au minimum sont requises.';
  }

  @override
  String get listPhotoUploading => 'Envoi des photos…';

  @override
  String get listPhotoFailed => 'Échec';

  @override
  String get listRemovePhoto => 'Retirer la photo';

  @override
  String get listPropertyAdded => 'Annonce ajoutée';

  @override
  String get listPropertyAddedBody =>
      'Elle figure maintenant dans vos annonces.';

  @override
  String get listPropertyUpdated => 'Annonce mise à jour';

  @override
  String get listPropertyUpdatedBody =>
      'Vos modifications ont été enregistrées.';

  @override
  String listPropertyPhotosSaved(num count) {
    return '$count photo(s) enregistrée(s)';
  }

  @override
  String get listSavedAsDraft =>
      'Enregistrée comme brouillon. Soumettez-la pour validation quand vous serez prêt.';

  @override
  String get listSubmittedForReview =>
      'Soumise pour validation. Un administrateur la vérifiera avant sa mise en ligne.';

  @override
  String get listDropzoneHint =>
      'Glissez vos photos ici, ou choisissez des fichiers. Vous pouvez en déposer plusieurs à la fois.';

  @override
  String get listDropActive => 'Déposez vos photos pour les envoyer';

  @override
  String listPhotoLimit(num count) {
    return 'Une annonce accepte au maximum $count photos.';
  }

  @override
  String get payTitle => 'Paiement';

  @override
  String get paySecure => 'Lien de paiement sécurisé';

  @override
  String get payAmountLabel => 'Montant à payer';

  @override
  String get payPropertyLabel => 'Bien';

  @override
  String get payTo => 'Pour :';

  @override
  String get payConfirm => 'Confirmer le paiement';

  @override
  String get payProcessing => 'Traitement…';

  @override
  String get paySuccess => 'Paiement reçu';

  @override
  String paySuccessDesc(String reference) {
    return 'Merci. Votre référence de paiement est $reference.';
  }

  @override
  String get payBackToHome => 'Retour à l\'accueil';

  @override
  String get payLoginPrompt => 'Connectez-vous pour continuer';

  @override
  String get payLoginPromptDesc =>
      'Ceci est un lien de paiement sécurisé. Connectez-vous avec le compte destinataire.';

  @override
  String get payNotForYou => 'Ce lien est destiné à un autre compte';

  @override
  String get payNotForYouDesc =>
      'Connectez-vous avec le compte qui a reçu ce lien de paiement.';

  @override
  String get payLinkInvalid => 'Lien de paiement invalide';

  @override
  String get payLinkInvalidDesc => 'Le lien manque, a été retiré ou a expiré.';

  @override
  String get payAlreadyPaid => 'Déjà payé';

  @override
  String get payAlreadyPaidDesc => 'Ce lien de paiement est déjà réglé.';

  @override
  String get payGoToLogin => 'Aller à la connexion';

  @override
  String get payGoSignup => 'Créer un compte';

  @override
  String get payChangeAccount => 'Changer de compte';

  @override
  String payPaidOn(String date) {
    return 'Payé le $date';
  }

  @override
  String get payPanelTitle => 'Payez avec votre mobile money';

  @override
  String get payPanelDesc =>
      'Tous les services de mobile money disponibles au Burundi. Choisissez votre portefeuille, puis saisissez le numéro à débiter à gauche.';

  @override
  String get payPanelFootnote =>
      'Vous recevrez une demande sur votre téléphone pour confirmer le paiement avec votre code secret.';

  @override
  String get payProviderLabel => 'Service de mobile money';

  @override
  String get payPickProvider => 'Choisissez un service de mobile money';

  @override
  String get payPhoneLabel => 'Numéro mobile money';

  @override
  String get payPhoneHint =>
      'Le numéro enregistré auprès de votre opérateur mobile money.';

  @override
  String get payInvalidNumber =>
      'Saisissez un numéro mobile money burundais valide, par exemple 79 11 10 01.';

  @override
  String get payConfirmPrompt => 'Confirmez sur';

  @override
  String get payProviderLUMICASH => 'Lumicash';

  @override
  String get payProviderECOCASH => 'EcoCash';

  @override
  String get payProviderIHELA => 'iHela';

  @override
  String get listTitle => 'Publier votre bien';

  @override
  String get listSubtitle =>
      'Ajoutez les détails de votre bien — il sera soumis à validation par un administrateur.';

  @override
  String get listDetails => 'Détails du bien';

  @override
  String get listTitleLabel => 'Titre';

  @override
  String get listPropertyType => 'Type de bien';

  @override
  String get listListingType => 'Type d’annonce';

  @override
  String get listPrice => 'Prix';

  @override
  String get listCurrency => 'Devise';

  @override
  String get listSurface => 'Surface (m²)';

  @override
  String get listBedrooms => 'Chambres';

  @override
  String get listBathrooms => 'Salles de bain';

  @override
  String get listLocation => 'Localisation';

  @override
  String get listProvince => 'Province';

  @override
  String get listCommune => 'Commune';

  @override
  String get listAddress => 'Adresse';

  @override
  String get listNegotiable => 'Prix négociable';

  @override
  String get listPhotos => 'Photos';

  @override
  String get listPhotosPlaceholder =>
      'https://…/photo1.jpg\nhttps://…/photo2.jpg';

  @override
  String get listSubmit => 'Soumettre le bien';

  @override
  String get listCancel => 'Annuler';

  @override
  String get footerDescription =>
      'IMMO BURUNDI connects owners, buyers, tenants, investors and trusted agents across Burundi.';

  @override
  String get footerCompany => 'Entreprise';

  @override
  String get footerServices => 'Services';

  @override
  String get footerLegal => 'Légal';

  @override
  String get footerSocial => 'Suivez-nous';

  @override
  String get footerLinksAboutUs => 'À propos de nous';

  @override
  String get footerLinksContact => 'Contact';

  @override
  String get footerLinksCareers => 'Carrières';

  @override
  String get footerLinksPartners => 'Partenaires';

  @override
  String get footerLinksBuy => 'Acheter';

  @override
  String get footerLinksRent => 'Louer';

  @override
  String get footerLinksSell => 'Vendre';

  @override
  String get footerLinksVerification => 'Vérification';

  @override
  String get footerLinksPromotion => 'Promotion';

  @override
  String get footerLinksPrivacy => 'Politique de confidentialité';

  @override
  String get footerLinksTerms => 'Conditions générales';

  @override
  String get footerLinksVerificationDisclaimer => 'Avis de vérification';

  @override
  String get footerLinksCookies => 'Politique de cookies';

  @override
  String get footerTagline => 'Real Estate Marketplace';

  @override
  String get errorNotFound => 'Page introuvable';

  @override
  String get errorNotFoundDesc =>
      'La page que vous cherchez n’existe pas ou a été déplacée.';

  @override
  String get errorNoPermission =>
      'Vous n’avez pas la permission d’accéder à cette section.';

  @override
  String get errorTryAgain => 'Please try again';

  @override
  String get errorBackHome => 'Retour à l\'accueil';

  @override
  String get errorForbidden => 'Forbidden';

  @override
  String get errorInvalidData => 'Please check the information you entered.';

  @override
  String get errorLoadFailed => 'Failed to load data';

  @override
  String get errorPropertyLoadFail => 'Unable to load this property.';

  @override
  String get emptyNoProperties => 'Aucun bien trouvé';

  @override
  String get emptyNoPropertiesDesc =>
      'Essayez d’ajuster vos filtres ou une autre recherche.';

  @override
  String get emptyNoFavorites => 'Aucun favori';

  @override
  String get emptyNoFavoritesDesc =>
      'Cliquez sur le cœur d’un bien pour le garder ici.';

  @override
  String get emptyNoResults => 'Aucun résultat';

  @override
  String get emptyNoResultsDesc => 'Rien ne correspond à votre recherche.';

  @override
  String get emptyNoMessages => 'No conversations';

  @override
  String get emptyNoMessagesDesc =>
      'Message an agent about a property you like.';

  @override
  String get emptyNoNotifications => 'Tout est à jour';

  @override
  String get emptyNoNotificationsDesc => 'Les notifications apparaîtront ici.';

  @override
  String get emptyNoVisits => 'Aucune visite à venir';

  @override
  String get emptyNoVisitsDesc => 'Book a visit from any property page.';

  @override
  String get emptyNoApplications => 'Aucune demande';

  @override
  String get emptyNoApplicationsDesc =>
      'Vos demandes d’achat et candidatures apparaîtront ici.';

  @override
  String get applicationsBuyRequest => 'Demande d’achat';

  @override
  String get applicationsRentApplication => 'Candidature de location';

  @override
  String get applicationsViewProperty => 'Voir le bien';

  @override
  String get emptyNoRecentViews => 'Aucune vue récente';

  @override
  String get emptyNoRecentViewsDesc => 'Properties you view will appear here.';

  @override
  String get homeTagline => 'Trouvez votre prochain bien au Burundi';

  @override
  String get homeSubtitle =>
      'Biens vérifiés, agents de confiance et prix transparents, de Bujumbura à Muyinga.';

  @override
  String get homeForYou => 'Pour vous';

  @override
  String get homeSaved => 'Enregistrés';

  @override
  String get feedTitle => 'Recommandé pour vous';

  @override
  String get feedDesc =>
      'Des biens sélectionnés selon ce que recherchent les visiteurs comme vous.';

  @override
  String get feedPersonalize => 'Personnaliser mon fil';

  @override
  String get feedPersonalizeDesc =>
      'Dites-nous ce que vous cherchez et nous adapterons votre fil.';

  @override
  String get tilesApartments => 'Appartements';

  @override
  String get tilesHouses => 'Maisons';

  @override
  String get tilesLand => 'Terrains';

  @override
  String get tilesCommercial => 'Commercial';

  @override
  String get tilesRentals => 'Locations';

  @override
  String get tilesForSale => 'À vendre';

  @override
  String get tilesVillas => 'Villas';

  @override
  String get tilesExplore => 'Explorer plus';

  @override
  String get homeFeatured => 'Biens en vedette';

  @override
  String get homeRecent => 'Nouveautés';

  @override
  String get homeRecentDesc => 'Fresh listings published in the last 30 days.';

  @override
  String get homeVerified => 'Biens vérifiés';

  @override
  String get homeVerifiedDesc => 'Documents checked by our verification team.';

  @override
  String get homePopularLocations => 'Localités populaires';

  @override
  String get homePopularLocationsDesc =>
      'Where property seekers look the most.';

  @override
  String get homeHowItWorks => 'Comment IMMO BURUNDI fonctionne';

  @override
  String get homeStep1Title => 'Rechercher';

  @override
  String get homeStep1Desc =>
      'Parcourez des milliers de biens dans chaque province du Burundi.';

  @override
  String get homeStep2Title => 'Vérifier';

  @override
  String get homeStep2Desc => 'Les documents sont contrôlés par notre équipe.';

  @override
  String get homeStep3Title => 'Visiter';

  @override
  String get homeStep3Desc =>
      'Réservez une visite directement depuis l’annonce.';

  @override
  String get homeStep4Title => 'Acheter ou louer';

  @override
  String get homeStep4Desc =>
      'Concluez en toute sécurité avec un agent de confiance.';

  @override
  String get heroLine1 => 'TROUVEZ VOTRE';

  @override
  String get heroLine2 => 'MAISON PARFAITE';

  @override
  String get heroLine3 => 'AUJOURD\'HUI';

  @override
  String get heroWelcome =>
      'Bienvenue chez IMMO BURUNDI — lancez votre recherche ci-dessous.';

  @override
  String get heroDesc =>
      'Nous proposons des solutions immobilières sur mesure, vous guidant à chaque étape avec des expériences personnalisées qui répondent à vos besoins et aspirations.';

  @override
  String get heroStatsListings => 'Annonces';

  @override
  String get heroStatsProvinces => 'Provinces';

  @override
  String get heroStatsVerified => 'Vérifiées';

  @override
  String get heroAgentsLabel => 'Agents experts';

  @override
  String get aboutHeroTitle => 'À propos d’IMMO BURUNDI';

  @override
  String get aboutHeroSubtitle =>
      'Une place de marché immobilière moderne et fiable pour le Burundi.';

  @override
  String get aboutMissionTitle => 'Notre mission';

  @override
  String get aboutMissionBody =>
      'IMMO BURUNDI met en relation propriétaires, acheteurs, locataires, investisseurs et agents professionnels sur une plateforme unique et transparente.';

  @override
  String get aboutValuesTitle => 'Nos valeurs';

  @override
  String get aboutValuesTrust => 'Confiance';

  @override
  String get aboutValuesTrustDesc =>
      'Chaque annonce est vérifiée par une équipe dédiée avant d\'être mise en avant.';

  @override
  String get aboutValuesTransparency => 'Transparence';

  @override
  String get aboutValuesTransparencyDesc =>
      'Les prix d\'origine, le statut de vérification et la vérification des documents sont toujours affichés.';

  @override
  String get aboutValuesQuality => 'Qualité';

  @override
  String get aboutValuesQualityDesc =>
      'Nous travaillons avec des agents vérifiés et des descriptions de biens complètes et exactes.';

  @override
  String get aboutValuesAccessibility => 'Accessibilité';

  @override
  String get aboutValuesAccessibilityDesc =>
      'Disponible en français, anglais et swahili, conçu pour tous les appareils.';

  @override
  String get contactTitle => 'Contactez-nous';

  @override
  String get contactSubtitle =>
      'Questions, retours ou idées de partenariat — nous serions ravis de vous lire.';

  @override
  String get contactName => 'Nom complet';

  @override
  String get contactPhone => 'Téléphone';

  @override
  String get contactEmail => 'E-mail';

  @override
  String get contactSubject => 'Objet';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactSubmit => 'Envoyer le message';

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
  String get contactHoursValue => 'Lundi – Samedi, 8h00 – 18h00';

  @override
  String get contactPhoneLabel => 'Téléphone';

  @override
  String get contactWhatsappLabel => 'WhatsApp';

  @override
  String get contactEmailLabel => 'E-mail';

  @override
  String get contactAddressValue =>
      'Chaussée Prince Louis Rwagasore, Bujumbura, Burundi';

  @override
  String get contactWhatsappCta => 'Discuter sur WhatsApp';

  @override
  String get contactChatTitle => 'Contacter l’agent';

  @override
  String get contactAgent => 'L\'agent';

  @override
  String get contactCallCta => 'Appeler l’agent';

  @override
  String get contactNoPhone => 'Cet agent n’a pas encore publié de numéro.';

  @override
  String contactWhatsappProperty(String title) {
    return 'Bonjour, « $title » m’intéresse. Est-il toujours disponible ?';
  }

  @override
  String get contactWhatsappGeneric =>
      'Bonjour, je souhaite en savoir plus sur ce bien.';

  @override
  String get contactVisitBooked =>
      'Votre visite est réservée. Contactez l’agent en cas de changement.';

  @override
  String get contactBuyRequested =>
      'Demande envoyée. Contactez l’agent pour aller plus loin.';

  @override
  String get contactListTitle => 'Publier votre bien';

  @override
  String get contactListSubtitle =>
      'Vous vendez ou louez ? Publiez sur IMMO BURUNDI en quelques minutes et touchez des milliers d’acheteurs et de locataires.';

  @override
  String get contactListButton => 'Commencer';

  @override
  String get contactListEmail => 'hello@immoburundi.bi';

  @override
  String get catEyebrow => 'EXPLORER';

  @override
  String get catBuyTitle => 'Biens à vendre';

  @override
  String get catBuySubtitle =>
      'Maisons, appartements, villas et plus dans toutes les provinces du Burundi.';

  @override
  String get catRentTitle => 'Biens à louer';

  @override
  String get catRentSubtitle =>
      'Appartements, maisons et villas disponibles à la location.';

  @override
  String get catLandTitle => 'Terrains à vendre';

  @override
  String get catLandSubtitle =>
      'Parcelles dans toutes les provinces du Burundi.';

  @override
  String get catCommercialTitle => 'Biens commerciaux';

  @override
  String get catCommercialSubtitle =>
      'Boutiques, bureaux, entrepôts et espaces industriels.';

  @override
  String get catFeaturedTitle => 'Biens en vedette';

  @override
  String get catFeaturedSubtitle => 'Annonces sélectionnées par notre équipe.';

  @override
  String get catVerifiedTitle => 'Biens vérifiés';

  @override
  String get catVerifiedSubtitle =>
      'Documents vérifiés par notre équipe de vérification.';

  @override
  String get catOpenSearch => 'Tout voir dans la recherche';

  @override
  String get agentsEyebrow => 'RÉSEAU';

  @override
  String get agentsTitle => 'Nos agents de confiance';

  @override
  String get agentsSubtitle =>
      'Professionnels vérifiés pour acheter, vendre et louer en toute confiance.';

  @override
  String get agentsTop => 'Top agent';

  @override
  String get agentsListings => 'Annonces';

  @override
  String get agentsEmpty => 'Aucun agent trouvé';

  @override
  String get agentsEmptyDesc => 'Aucun agent ne correspond à votre recherche.';

  @override
  String get agentLatest => 'Récentes';

  @override
  String get agentPopular => 'Populaires';

  @override
  String get agentPriceAsc => 'Prix croissant';

  @override
  String get agentPriceDesc => 'Prix décroissant';

  @override
  String get agentSubscribe => 'S\'abonner';

  @override
  String get agentSubscribed => 'Abonné(e)';

  @override
  String get agentPublished => 'biens publiés';

  @override
  String get agentAgentCode => 'Code agent';

  @override
  String get agentRating => 'Note';

  @override
  String get agentMemberSince => 'Membre depuis';

  @override
  String get agentNoBio => 'Cet agent n\'a pas encore ajouté de biographie.';

  @override
  String get agentEmpty => 'Aucun bien publié';

  @override
  String get agentEmptyDesc => 'Cet agent n\'a encore publié aucun bien.';

  @override
  String get agentNotFound => 'Agent introuvable';

  @override
  String get agentNotFoundDesc =>
      'Cet agent est peut-être inactif ou le lien est incorrect.';

  @override
  String get agentAgency => 'Agence';

  @override
  String get agentHome => 'Accueil';

  @override
  String get agentListings => 'Annonces';

  @override
  String get agentReviews => 'Avis';

  @override
  String get agentRecent => 'Annonces récentes';

  @override
  String get agentActiveListings => 'annonces actives';

  @override
  String agentReviewsCount(num count) {
    return '$count avis';
  }

  @override
  String get agentSearchPlaceholder => 'Rechercher les annonces de cet agent';

  @override
  String agentMoreLinks(num count) {
    return 'et $count autres';
  }

  @override
  String get agentReviewsEmpty => 'Pas encore d\'avis écrits';

  @override
  String get agentReviewsEmptyDesc =>
      'Les notes et l\'historique des transactions figurent ci-dessous ; les avis écrits arrivent bientôt.';

  @override
  String get agentSoldHidden =>
      'Les biens vendus ne sont visibles que pour les membres connectés.';

  @override
  String get agentSales => 'Ventes';

  @override
  String get agentDeals => 'Transactions conclues';

  @override
  String get agentMore => 'plus';

  @override
  String get visitBookVisit => 'Réserver une visite';

  @override
  String get visitPlacesRemaining => 'places restantes';

  @override
  String get visitBookingClosesIn => 'Fermeture des réservations';

  @override
  String get visitDate => 'Date';

  @override
  String get visitTime => 'Heure';

  @override
  String get visitSessionFull => 'Session complète';

  @override
  String get visitNoSessions => 'Aucune session de visite disponible.';

  @override
  String get visitBooked => 'Visite réservée';

  @override
  String get visitBookedSuccess =>
      'Your visit has been booked. Check the dashboard for details.';

  @override
  String get visitBookError => 'Could not book this visit.';

  @override
  String get visitPeople => 'Number of people';

  @override
  String get visitLoginToBook => 'Connectez-vous pour réserver une visite';

  @override
  String get visitScheduleUpdated => 'Availability updated live.';

  @override
  String get visitStepWhen => 'Quand';

  @override
  String get visitStepWho => 'Qui';

  @override
  String get visitStepConfirm => 'Confirmer';

  @override
  String get visitPickDateTime =>
      'Choisissez une date et une heure pour votre visite.';

  @override
  String get visitGuestInfoRequired =>
      'Renseignez vos informations pour continuer.';

  @override
  String get visitUseScheduled => 'Voir les sessions planifiées';

  @override
  String get visitAnyTime => 'Demander à tout moment';

  @override
  String get visitFirstName => 'Prénom';

  @override
  String get visitLastName => 'Nom';

  @override
  String get visitPhone => 'Téléphone';

  @override
  String get visitEmail => 'E-mail';

  @override
  String get visitPassword => 'Créer un mot de passe';

  @override
  String get visitGuestNote =>
      'Continuer en tant qu’invité — nous créons un compte et vous connectons automatiquement pour enregistrer votre visite.';

  @override
  String get visitVisitor => 'Visiteur';

  @override
  String get visitNotes => 'Notes pour l’agent';

  @override
  String get visitBack => 'Retour';

  @override
  String get visitContinue => 'Continuer';

  @override
  String get visitCreateAccount => 'Créer un compte';

  @override
  String get visitConfirmBooking => 'Confirmer la réservation';

  @override
  String get visitStepPassword => 'Mot de passe';

  @override
  String get visitFullName => 'Nom complet';

  @override
  String get visitEmailOrPhone => 'E-mail ou téléphone';

  @override
  String get visitConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get visitPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get visitPasswordHintStrong =>
      'Utilisez un mot de passe fort — 8 caractères minimum.';

  @override
  String get visitFullNamePlaceholder => 'Nom complet';

  @override
  String get visitContactPlaceholder => '+257 … ou vous@mail.com';

  @override
  String get visitPlacedTitle => 'Visite demandée !';

  @override
  String get visitPlacedSuccess =>
      'Votre demande de visite a été reçue. L’agent vous contactera pour la confirmer.';

  @override
  String get visitDone => 'Terminé';

  @override
  String get visitManageInDashboard =>
      'Gérez ou annulez-la depuis votre tableau de bord.';

  @override
  String get visitDetailsTitle => 'Détails de la visite';

  @override
  String get visitStatusPending => 'En attente';

  @override
  String get visitStatusConfirmed => 'Confirmée';

  @override
  String get visitStatusCancelled => 'Annulée';

  @override
  String get visitStatusNoShow => 'Absent';

  @override
  String get visitReference => 'Référence de réservation';

  @override
  String get visitPeopleCount => 'Personnes';

  @override
  String get visitBookedOn => 'Réservé le';

  @override
  String get visitViewProperty => 'Voir le bien';

  @override
  String get visitCancelVisit => 'Annuler la visite';

  @override
  String get pickerSelectDate => 'Choisir une date';

  @override
  String get pickerSelectTime => 'Choisir une heure';

  @override
  String get pickerToday => 'Aujourd\'hui';

  @override
  String get pickerTomorrow => 'Demain';

  @override
  String get pickerMorning => 'Matin';

  @override
  String get pickerAfternoon => 'Après-midi';

  @override
  String get pickerEvening => 'Soir';

  @override
  String get visitSelectDate => 'Choisissez une date.';

  @override
  String get visitSelectTime => 'Choisissez une heure.';

  @override
  String get visitSelectSession => 'Choisissez une session de visite.';

  @override
  String visitMissingFields(String fields) {
    return 'Champs requis : $fields.';
  }

  @override
  String get visitPasswordHint => 'Au moins 8 caractères.';

  @override
  String get mapApproximateLocation => 'Localisation approximative';

  @override
  String get mapLocationHidden =>
      'Localisation masquée pour la confidentialité du propriétaire.';

  @override
  String get mapShowOnMap => 'View on map';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationUnread => 'non lus';

  @override
  String get notificationMarkAllRead => 'Tout marquer lu';

  @override
  String get modalBuyTitle => 'Exprimer son intérêt d’achat';

  @override
  String get modalContactTitle => 'Contacter l’agent';

  @override
  String get modalContactName => 'Your name';

  @override
  String get modalContactPhone => 'Your phone';

  @override
  String get modalContactMessage => 'Message';

  @override
  String get modalMessageTitle => 'Envoyer un message';

  @override
  String get modalApplyTitle => 'Postuler pour ce bien';

  @override
  String get modalApplyIncome => 'Monthly income (BIF)';

  @override
  String get modalApplyEmployment => 'Employment status';

  @override
  String get modalApplyReferences => 'References';

  @override
  String get modalContactSendSuccess => 'Your message was sent to the agent.';

  @override
  String get modalRequireLogin => 'Connectez-vous pour continuer';

  @override
  String get modalBuySuccess =>
      'Votre demande d’achat a été envoyée à l’agent.';

  @override
  String get modalBuyOptionalMessage =>
      'Facultatif — dites à l’agent ce que vous souhaitez savoir.';

  @override
  String get applySubmitted =>
      'Your rental application has been submitted to the agent.';

  @override
  String get legalVerificationTitle => 'Avis de vérification';

  @override
  String get legalCookiesTitle => 'Politique de cookies';

  @override
  String get legalUpdated => 'Dernière mise à jour';

  @override
  String get loading => 'Chargement…';
}
