import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('uk'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Drone Detector'**
  String get appTitle;

  /// Support banner text
  ///
  /// In en, this message translates to:
  /// **'Work in progress, click here for support'**
  String get supportBanner;

  /// Main title of the app
  ///
  /// In en, this message translates to:
  /// **'Drone Sentinel'**
  String get droneSentinelTitle;

  /// Subtitle describing the app functionality
  ///
  /// In en, this message translates to:
  /// **'Advanced AI-Powered Drone Detection'**
  String get droneSentinelSubtitle;

  /// Button text to start drone detection
  ///
  /// In en, this message translates to:
  /// **'Start Listening'**
  String get startListening;

  /// Button text to stop drone detection
  ///
  /// In en, this message translates to:
  /// **'Stop Listening'**
  String get stopListening;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About Drone Sentinel'**
  String get aboutTitle;

  /// About section description
  ///
  /// In en, this message translates to:
  /// **'Drone Sentinel uses advanced AI technology to detect drone sounds in real-time. Our machine learning model analyzes audio patterns to identify potential drone activity with high accuracy.'**
  String get aboutDescription;

  /// Dashboard section title
  ///
  /// In en, this message translates to:
  /// **'Detection Dashboard'**
  String get detectionDashboard;

  /// Threshold setting label
  ///
  /// In en, this message translates to:
  /// **'Detection Threshold'**
  String get detectionThreshold;

  /// Alert message when drone is detected
  ///
  /// In en, this message translates to:
  /// **'DRONE DETECTED!'**
  String get droneDetected;

  /// Message when no drone is detected
  ///
  /// In en, this message translates to:
  /// **'No Drone Detected'**
  String get noDroneDetected;

  /// Confidence level label
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// Audio waveform section title
  ///
  /// In en, this message translates to:
  /// **'Audio Waveform'**
  String get audioWaveform;

  /// Frequency analysis section title
  ///
  /// In en, this message translates to:
  /// **'Frequency Analysis'**
  String get frequencyAnalysis;

  /// Prediction scores section title
  ///
  /// In en, this message translates to:
  /// **'Prediction Scores'**
  String get predictionScores;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Initialization error dialog title
  ///
  /// In en, this message translates to:
  /// **'Initialization Error'**
  String get initializationError;

  /// Permission denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// Microphone permission message
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to use this app.'**
  String get microphonePermissionRequired;

  /// Model loading error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load TensorFlow Lite model. Please check the model path and file.'**
  String get modelLoadError;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Sound detection meter title
  ///
  /// In en, this message translates to:
  /// **'Sound Detection Meter'**
  String get soundDetectionMeter;

  /// Status when listening for sounds
  ///
  /// In en, this message translates to:
  /// **'Listening for sounds...'**
  String get listeningForSounds;

  /// Short listening status
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// System status section title
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// Monitoring for label
  ///
  /// In en, this message translates to:
  /// **'Monitoring For'**
  String get monitoringFor;

  /// What the system monitors for
  ///
  /// In en, this message translates to:
  /// **'Background Noise, FPV Drone'**
  String get backgroundNoiseFpvDrone;

  /// Microphone status label
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Model status label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Loaded status
  ///
  /// In en, this message translates to:
  /// **'Loaded'**
  String get loaded;

  /// Detection status label
  ///
  /// In en, this message translates to:
  /// **'Detection Status'**
  String get detectionStatus;

  /// Status when waiting for sounds
  ///
  /// In en, this message translates to:
  /// **'Waiting for sounds...'**
  String get waitingForSounds;

  /// Loading model status
  ///
  /// In en, this message translates to:
  /// **'Loading sound detection model...'**
  String get loadingSoundDetectionModel;

  /// Slider label for more detections
  ///
  /// In en, this message translates to:
  /// **'More Detections'**
  String get moreDetections;

  /// Slider label for higher accuracy
  ///
  /// In en, this message translates to:
  /// **'Higher Accuracy'**
  String get higherAccuracy;

  /// Background noise detection label
  ///
  /// In en, this message translates to:
  /// **'Background Noise'**
  String get backgroundNoise;

  /// FPV drone detection label
  ///
  /// In en, this message translates to:
  /// **'FPV Drone'**
  String get fpvDrone;

  /// Warning modal title
  ///
  /// In en, this message translates to:
  /// **'Drone Detection Warning'**
  String get droneDetectionWarning;

  /// Warning modal message
  ///
  /// In en, this message translates to:
  /// **'A drone has been detected in the area! Please take appropriate safety measures.'**
  String get droneDetectedWarningMessage;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
