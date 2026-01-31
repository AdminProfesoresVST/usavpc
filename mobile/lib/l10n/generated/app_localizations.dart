import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es')
  ];

  /// No description provided for @dataSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get dataSavedSuccess;

  /// Application title in navbar
  ///
  /// In en, this message translates to:
  /// **'Consular Assistant'**
  String get appTitle;

  /// Badge text for official guide
  ///
  /// In en, this message translates to:
  /// **'Official Guide'**
  String get officialGuide;

  /// Main hero section title
  ///
  /// In en, this message translates to:
  /// **'Simplify Your Consular Process'**
  String get heroTitle;

  /// Main hero section subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan documents and simulate your interview to secure your visa.'**
  String get heroSubtitle;

  /// Section title for steps
  ///
  /// In en, this message translates to:
  /// **'How it Works'**
  String get howItWorks;

  /// Step 1 title
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get stepScan;

  /// Step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get stepScanSubtitle;

  /// Step 2 title
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get stepSimulate;

  /// Step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'AI Interview'**
  String get stepSimulateSubtitle;

  /// Step 3 title
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get stepResults;

  /// Step 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Get Report'**
  String get stepResultsSubtitle;

  /// No description provided for @successProbability.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get successProbability;

  /// No description provided for @seeRiskDetails.
  ///
  /// In en, this message translates to:
  /// **'See Details'**
  String get seeRiskDetails;

  /// Section title for services
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get popularServices;

  /// No description provided for @helpScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Scanning'**
  String get helpScanTitle;

  /// No description provided for @helpScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Our OCR technology automatically extracts your data from your passport to avoid manual errors.'**
  String get helpScanDesc;

  /// No description provided for @helpScanBullet1.
  ///
  /// In en, this message translates to:
  /// **'Place your passport on a flat surface.'**
  String get helpScanBullet1;

  /// No description provided for @helpScanBullet2.
  ///
  /// In en, this message translates to:
  /// **'Ensure good lighting without glare.'**
  String get helpScanBullet2;

  /// No description provided for @helpScanButton.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get helpScanButton;

  /// No description provided for @helpSimulateTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Interview Simulator'**
  String get helpSimulateTitle;

  /// No description provided for @helpSimulateDesc.
  ///
  /// In en, this message translates to:
  /// **'Practice with our Virtual Consular Agent trained on thousands of real cases.'**
  String get helpSimulateDesc;

  /// No description provided for @helpSimulateBullet1.
  ///
  /// In en, this message translates to:
  /// **'Receive personalized questions based on your profile.'**
  String get helpSimulateBullet1;

  /// No description provided for @helpSimulateBullet2.
  ///
  /// In en, this message translates to:
  /// **'Get immediate feedback on your answers.'**
  String get helpSimulateBullet2;

  /// No description provided for @helpSimulateButton.
  ///
  /// In en, this message translates to:
  /// **'Start Simulator'**
  String get helpSimulateButton;

  /// No description provided for @helpResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results & Analysis'**
  String get helpResultsTitle;

  /// No description provided for @helpResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a detailed risk analysis before your real appointment.'**
  String get helpResultsDesc;

  /// No description provided for @helpResultsBullet1.
  ///
  /// In en, this message translates to:
  /// **'Identify potential red flags in your application.'**
  String get helpResultsBullet1;

  /// No description provided for @helpResultsBullet2.
  ///
  /// In en, this message translates to:
  /// **'Receive recommendations to improve your chances.'**
  String get helpResultsBullet2;

  /// No description provided for @helpResultsButton.
  ///
  /// In en, this message translates to:
  /// **'View My Services'**
  String get helpResultsButton;

  /// Link to view all services
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'New Visa Application'**
  String get newVisaApplication;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan your ID to auto-fill forms.'**
  String get newVisaSubtitle;

  /// Badge text for fast service
  ///
  /// In en, this message translates to:
  /// **'FAST'**
  String get badgeFast;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Interview Simulator'**
  String get interviewSimulator;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Practice real questions with our AI.'**
  String get interviewSimulatorSubtitle;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Document Audit'**
  String get documentAudit;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Personalized checklist for your visa type.'**
  String get documentAuditSubtitle;

  /// Trust signal text
  ///
  /// In en, this message translates to:
  /// **'Your data is secure and encrypted.'**
  String get securityNote;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// App name on login screen
  ///
  /// In en, this message translates to:
  /// **'USA Visa Processing'**
  String get loginAppName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'SIGN IN / LOGIN'**
  String get loginButton;

  /// Register link text
  ///
  /// In en, this message translates to:
  /// **'Create an account / Create Account'**
  String get createAccountLink;

  /// Debug button for test credentials
  ///
  /// In en, this message translates to:
  /// **'Quick Fill (Test User)'**
  String get quickFillTest;

  /// Disclaimer text
  ///
  /// In en, this message translates to:
  /// **'Non-government service provider'**
  String get nonGovernmentDisclaimer;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get emailRequired;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get passwordRequired;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'My Application'**
  String get dashboardTitle;

  /// Status card title
  ///
  /// In en, this message translates to:
  /// **'Application Status'**
  String get applicationStatus;

  /// Section title for action tiles
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get nextSteps;

  /// Progress percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}% Complete'**
  String percentComplete(int percent);

  /// Last edit timestamp
  ///
  /// In en, this message translates to:
  /// **'Last edited: {date}'**
  String lastEdited(String date);

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get statusPendingPayment;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get statusNotStarted;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Settings menu option
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsOption;

  /// Help menu option
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpOption;

  /// Logout menu option
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutOption;

  /// Placeholder message
  ///
  /// In en, this message translates to:
  /// **'Settings coming soon'**
  String get settingsComingSoon;

  /// Support contact info
  ///
  /// In en, this message translates to:
  /// **'Contact: support@usavpc.org'**
  String get contactSupport;

  /// Fallback for missing email
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Fallback for missing user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// Verification landing screen title
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get verificationTitle;

  /// Verification header
  ///
  /// In en, this message translates to:
  /// **'Scan Your Document'**
  String get scanDocument;

  /// Verification subtitle
  ///
  /// In en, this message translates to:
  /// **'We need to capture your passport data to auto-fill your application.'**
  String get scanDocumentSubtitle;

  /// Camera action title
  ///
  /// In en, this message translates to:
  /// **'Use Camera'**
  String get useCamera;

  /// Camera action subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan directly'**
  String get useCameraSubtitle;

  /// Gallery action title
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// Gallery action subtitle
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get uploadImageSubtitle;

  /// Security trust signal
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and secure'**
  String get dataSecure;

  /// Success snackbar message
  ///
  /// In en, this message translates to:
  /// **'Document validated successfully'**
  String get documentValidated;

  /// Error snackbar message
  ///
  /// In en, this message translates to:
  /// **'No valid passport detected. Please try again.'**
  String get noValidPassport;

  /// AI intake screen title
  ///
  /// In en, this message translates to:
  /// **'DS-160 Assistant'**
  String get ds160Assistant;

  /// Question counter
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// Input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type your response...'**
  String get typeYourResponse;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error loading questions: {error}'**
  String loadingQuestionsError(String error);

  /// Default validation error
  ///
  /// In en, this message translates to:
  /// **'Hmm, that doesn\'t seem right. Can you verify?'**
  String get validationError;

  /// Save error message
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String savingError(String error);

  /// Intake completion message
  ///
  /// In en, this message translates to:
  /// **'🎉 Excellent! You have completed all questions. Your information is saved and ready to generate your DS-160 form.'**
  String get intakeComplete;

  /// Button to view completed application
  ///
  /// In en, this message translates to:
  /// **'VIEW MY APPLICATION'**
  String get viewMyApplication;

  /// Tips section header
  ///
  /// In en, this message translates to:
  /// **'Tips:'**
  String get tips;

  /// Example label
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// Quick check screen title
  ///
  /// In en, this message translates to:
  /// **'Preliminary Audit'**
  String get preliminaryAuditTitle;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Eligibility Verification'**
  String get eligibilityVerification;

  /// Section subtitle
  ///
  /// In en, this message translates to:
  /// **'Before simulating your interview, we\'ll analyze your basic profile to detect obvious risks.'**
  String get eligibilitySubtitle;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Visa Type Requested'**
  String get visaTypeLabel;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Visitor Business/Tourism'**
  String get visaB1B2;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Academic Student'**
  String get visaF1;

  /// Visa type option
  ///
  /// In en, this message translates to:
  /// **'H2 - Temporary Work'**
  String get visaH2;

  /// DS-160 question
  ///
  /// In en, this message translates to:
  /// **'Have you already completed your DS-160 form?'**
  String get ds160Question;

  /// Radio option
  ///
  /// In en, this message translates to:
  /// **'Yes, I have the code'**
  String get yesHaveCode;

  /// Radio option
  ///
  /// In en, this message translates to:
  /// **'No, not yet'**
  String get notYet;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'DS-160 Confirmation Code'**
  String get ds160CodeLabel;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'E.g: AA00...'**
  String get ds160CodeHint;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCode;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Must start with \"AA\"'**
  String get codeStartAA;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'For a precise audit, we recommend having the form ready. You can continue, but the analysis will be limited.'**
  String get noDs160Warning;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'START ANALYSIS'**
  String get startAnalysis;

  /// Simulator intro screen title
  ///
  /// In en, this message translates to:
  /// **'Interview Simulator'**
  String get simulatorTitle;

  /// Simulator description
  ///
  /// In en, this message translates to:
  /// **'Practice with our AI Consular Officer. Respond verbally to evaluate your fluency and coherence.'**
  String get simulatorDescription;

  /// Permission button
  ///
  /// In en, this message translates to:
  /// **'ENABLE MICROPHONE'**
  String get enableMicrophone;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'START INTERVIEW'**
  String get startInterview;

  /// Permission error snackbar
  ///
  /// In en, this message translates to:
  /// **'Microphone is required for the voice simulator.'**
  String get microphoneRequired;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// Language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// Generic error format
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'SIGN UP / REGISTER'**
  String get registerButton;

  /// Login link on register screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Password length error
  ///
  /// In en, this message translates to:
  /// **'Minimum {count} characters'**
  String passwordMinLength(int count);

  /// Password confirmation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Success message after registration
  ///
  /// In en, this message translates to:
  /// **'Account Created! Welcome.'**
  String get accountCreated;

  /// Order summary screen title
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummaryTitle;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Pay button with amount
  ///
  /// In en, this message translates to:
  /// **'Pay \${amount}'**
  String payButton(String amount);

  /// Processing state
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Payment success message
  ///
  /// In en, this message translates to:
  /// **'Payment completed successfully!'**
  String get paymentCompleted;

  /// Payment cancelled message
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled: {message}'**
  String paymentCancelled(String message);

  /// Stripe security badge
  ///
  /// In en, this message translates to:
  /// **'Secure payment with Stripe'**
  String get securePayment;

  /// Priority processing add-on
  ///
  /// In en, this message translates to:
  /// **'Priority Processing'**
  String get priorityProcessing;

  /// No plans message
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailable;

  /// Auth error message
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// Risk audit screen title
  ///
  /// In en, this message translates to:
  /// **'Approval Audit'**
  String get approvalAuditTitle;

  /// Score card title
  ///
  /// In en, this message translates to:
  /// **'Approval Probability'**
  String get approvalProbability;

  /// Risk level badge
  ///
  /// In en, this message translates to:
  /// **'Risk {level}'**
  String riskLevel(String level);

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Factor Analysis'**
  String get factorAnalysis;

  /// Action button
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO SIMULATOR'**
  String get continueToSimulator;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// Data loading error
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// Passport confirm screen title
  ///
  /// In en, this message translates to:
  /// **'Confirm Data'**
  String get confirmDataTitle;

  /// Success badge title
  ///
  /// In en, this message translates to:
  /// **'Passport Scanned'**
  String get passportScanned;

  /// Success badge subtitle
  ///
  /// In en, this message translates to:
  /// **'Verify that the data is correct'**
  String get verifyDataCorrect;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Surname(s)'**
  String get surnameLabel;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Given Name(s)'**
  String get givenNameLabel;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDateLabel;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationalityLabel;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Passport Number'**
  String get passportNumberLabel;

  /// Info box text
  ///
  /// In en, this message translates to:
  /// **'After confirming, I will ask you some additional questions not on your passport.'**
  String get additionalQuestionsInfo;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'CONFIRM AND CONTINUE'**
  String get confirmAndContinue;

  /// Chat interface screen title
  ///
  /// In en, this message translates to:
  /// **'Interview in Progress'**
  String get interviewInProgress;

  /// Initial transcript placeholder
  ///
  /// In en, this message translates to:
  /// **'Press the microphone to speak...'**
  String get pressMicToSpeak;

  /// Initial response placeholder
  ///
  /// In en, this message translates to:
  /// **'Connecting to Consular Officer...'**
  String get connectingToOfficer;

  /// Listening state text
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// Automation screen title
  ///
  /// In en, this message translates to:
  /// **'DS-160 Auto-fill'**
  String get ds160AutoFill;

  /// Manual inject button
  ///
  /// In en, this message translates to:
  /// **'INJECT'**
  String get inject;

  /// Console header
  ///
  /// In en, this message translates to:
  /// **'> CONSOLE OUTPUT'**
  String get consoleOutput;

  /// Success message when passport is detected
  ///
  /// In en, this message translates to:
  /// **'Passport Detected!'**
  String get passportDetected;

  /// Scanner instruction text
  ///
  /// In en, this message translates to:
  /// **'Scan the passport data zone'**
  String get passportScanInstructions;

  /// Scanning status text
  ///
  /// In en, this message translates to:
  /// **'Searching MRZ...'**
  String get searchingMRZ;

  /// Success status text
  ///
  /// In en, this message translates to:
  /// **'Detected!'**
  String get detected;

  /// Navigation progress message
  ///
  /// In en, this message translates to:
  /// **'Navigating to'**
  String get navigatingTo;

  /// Page load success message
  ///
  /// In en, this message translates to:
  /// **'Page loaded'**
  String get pageLoaded;

  /// Network error prefix
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// Form detection progress
  ///
  /// In en, this message translates to:
  /// **'Detecting form fields...'**
  String get detectingFormFields;

  /// Data injection progress
  ///
  /// In en, this message translates to:
  /// **'Injecting data into form...'**
  String get injectingData;

  /// Fill results
  ///
  /// In en, this message translates to:
  /// **'Fields filled: {filled} | Not found: {notFound}'**
  String fieldsFilled(int filled, int notFound);

  /// Injection success message
  ///
  /// In en, this message translates to:
  /// **'Injection completed'**
  String get injectionComplete;

  /// Automation ready message
  ///
  /// In en, this message translates to:
  /// **'Automation ready. Review the data and continue manually.'**
  String get automationReady;

  /// Process completion message
  ///
  /// In en, this message translates to:
  /// **'PROCESS COMPLETED - Verify data before continuing'**
  String get processComplete;

  /// Injection error prefix
  ///
  /// In en, this message translates to:
  /// **'Error during injection'**
  String get injectionError;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Cost Calculator'**
  String get costCalculatorTitle;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Complete fee estimation'**
  String get costCalculatorSubtitle;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Check Restrictions'**
  String get travelBanTitle;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Check 2026 Travel Ban'**
  String get travelBanSubtitle;

  /// Header title
  ///
  /// In en, this message translates to:
  /// **'Know Your Total'**
  String get knowYourTotal;

  /// Header subtitle
  ///
  /// In en, this message translates to:
  /// **'Calculate all fees for your visa application'**
  String get knowYourTotalSubtitle;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Your Nationality'**
  String get yourNationality;

  /// Dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectCountry;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Visa Category'**
  String get visaCategory;

  /// Dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select visa category'**
  String get selectCategory;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Additional Options'**
  String get additionalOptions;

  /// Option title
  ///
  /// In en, this message translates to:
  /// **'Crossing by Land'**
  String get crossingByLand;

  /// Option subtitle
  ///
  /// In en, this message translates to:
  /// **'Adds I-94 fee (\$24)'**
  String get crossingByLandSubtitle;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Calculate Total Cost'**
  String get calculateTotalCost;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'2026 Fee Schedule'**
  String get feeSchedule;

  /// Header title
  ///
  /// In en, this message translates to:
  /// **'Check Your Eligibility'**
  String get checkYourEligibility;

  /// Header subtitle
  ///
  /// In en, this message translates to:
  /// **'Verify if your nationality has any visa restrictions'**
  String get checkYourEligibilitySubtitle;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Check Restrictions'**
  String get checkRestrictions;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Current Restrictions (2026)'**
  String get currentRestrictions;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Total Ban'**
  String get totalBan;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Screen title
  ///
  /// In en, this message translates to:
  /// **'Select Visa Type'**
  String get selectVisaType;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Non-Immigrant'**
  String get nonImmigrant;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Immigrant'**
  String get immigrant;

  /// Fee label
  ///
  /// In en, this message translates to:
  /// **'MRV Fee'**
  String get mrvFee;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Fiancé(e)'**
  String get fiance;

  /// Badge label
  ///
  /// In en, this message translates to:
  /// **'Petition'**
  String get petition;

  /// Badge label
  ///
  /// In en, this message translates to:
  /// **'SEVIS'**
  String get sevis;

  /// Badge label
  ///
  /// In en, this message translates to:
  /// **'K Visa'**
  String get kVisa;

  /// Screen title
  ///
  /// In en, this message translates to:
  /// **'Document Checklist'**
  String get documentChecklist;

  /// Status message
  ///
  /// In en, this message translates to:
  /// **'All required documents verified'**
  String get prerequisitesVerified;

  /// Status message
  ///
  /// In en, this message translates to:
  /// **'Missing required documents'**
  String get missingDocuments;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Label suffix
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get required;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'No Prerequisites Required'**
  String get noPrerequisities;

  /// Description
  ///
  /// In en, this message translates to:
  /// **'This visa category does not require any prerequisite documents. You can proceed directly to fill out the application form.'**
  String get noPrerequisitiesDesc;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Continue to Application'**
  String get continueToApp;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'All prerequisites verified. Proceeding to application...'**
  String get proceedingToApp;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Business Visitor'**
  String get visaB1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get visaB2;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Student Dependent'**
  String get visaF2;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Vocational Student'**
  String get visaM1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Exchange Visitor'**
  String get visaJ1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Specialty Occupation'**
  String get visaH1B;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Intracompany Transferee'**
  String get visaL1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Extraordinary Ability'**
  String get visaO1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Fiancé(e)'**
  String get visaK1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Treaty Trader'**
  String get visaE1;

  /// Visa Name
  ///
  /// In en, this message translates to:
  /// **'Treaty Investor'**
  String get visaE2;

  /// Badge label
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Question
  ///
  /// In en, this message translates to:
  /// **'Do you have this document?'**
  String get doYouHaveDocument;

  /// Option
  ///
  /// In en, this message translates to:
  /// **'Yes, I have it'**
  String get yesHaveIt;

  /// Option
  ///
  /// In en, this message translates to:
  /// **'No, not yet'**
  String get noNotYet;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Enter Document Details'**
  String get enterDocDetails;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Save Document Info'**
  String get saveDocInfo;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Document info saved'**
  String get docInfoSaved;

  /// Label prefix
  ///
  /// In en, this message translates to:
  /// **'Issued by'**
  String get issuedBy;

  /// Issuer
  ///
  /// In en, this message translates to:
  /// **'Your School/University'**
  String get issuedBySchool;

  /// Issuer
  ///
  /// In en, this message translates to:
  /// **'USCIS'**
  String get issuedByUSCIS;

  /// Issuer
  ///
  /// In en, this message translates to:
  /// **'Program Sponsor Organization'**
  String get issuedBySponsor;

  /// Issuer
  ///
  /// In en, this message translates to:
  /// **'Your Petitioner (US Sponsor)'**
  String get issuedByPetitioner;

  /// Issuer
  ///
  /// In en, this message translates to:
  /// **'US Department of State'**
  String get issuedByStateDept;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// No description provided for @visaB1Name.
  ///
  /// In en, this message translates to:
  /// **'Business Visitor'**
  String get visaB1Name;

  /// No description provided for @visaB1Desc.
  ///
  /// In en, this message translates to:
  /// **'Temporary business activities, meetings, conferences'**
  String get visaB1Desc;

  /// No description provided for @visaB1B2Name.
  ///
  /// In en, this message translates to:
  /// **'Visitor Business/Tourism'**
  String get visaB1B2Name;

  /// No description provided for @visaB1B2Desc.
  ///
  /// In en, this message translates to:
  /// **'For temporary business or tourism purposes'**
  String get visaB1B2Desc;

  /// No description provided for @visaB2Name.
  ///
  /// In en, this message translates to:
  /// **'Tourist'**
  String get visaB2Name;

  /// No description provided for @visaB2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tourism, vacation, medical treatment, visiting family'**
  String get visaB2Desc;

  /// No description provided for @visaCR1Name.
  ///
  /// In en, this message translates to:
  /// **'Conditional Resident - Spouse'**
  String get visaCR1Name;

  /// No description provided for @visaCR1Desc.
  ///
  /// In en, this message translates to:
  /// **'Spouse married less than 2 years'**
  String get visaCR1Desc;

  /// No description provided for @visaCR2Name.
  ///
  /// In en, this message translates to:
  /// **'Conditional Resident - Child'**
  String get visaCR2Name;

  /// No description provided for @visaCR2Desc.
  ///
  /// In en, this message translates to:
  /// **'Child of CR1'**
  String get visaCR2Desc;

  /// No description provided for @visaDVName.
  ///
  /// In en, this message translates to:
  /// **'Diversity Visa'**
  String get visaDVName;

  /// No description provided for @visaDVDesc.
  ///
  /// In en, this message translates to:
  /// **'Diversity visa lottery winners'**
  String get visaDVDesc;

  /// No description provided for @visaE1Name.
  ///
  /// In en, this message translates to:
  /// **'Treaty Trader'**
  String get visaE1Name;

  /// No description provided for @visaE1Desc.
  ///
  /// In en, this message translates to:
  /// **'Treaty traders engaged in substantial trade'**
  String get visaE1Desc;

  /// No description provided for @visaE1E2Name.
  ///
  /// In en, this message translates to:
  /// **'Treaty Trader/Investor'**
  String get visaE1E2Name;

  /// No description provided for @visaE1E2Desc.
  ///
  /// In en, this message translates to:
  /// **'For investors from treaty countries'**
  String get visaE1E2Desc;

  /// No description provided for @visaE2Name.
  ///
  /// In en, this message translates to:
  /// **'Treaty Investor'**
  String get visaE2Name;

  /// No description provided for @visaE2Desc.
  ///
  /// In en, this message translates to:
  /// **'Treaty investors with substantial investment'**
  String get visaE2Desc;

  /// No description provided for @visaEB1Name.
  ///
  /// In en, this message translates to:
  /// **'Employment First Pref'**
  String get visaEB1Name;

  /// No description provided for @visaEB1Desc.
  ///
  /// In en, this message translates to:
  /// **'Priority workers, extraordinary ability'**
  String get visaEB1Desc;

  /// No description provided for @visaEB2Name.
  ///
  /// In en, this message translates to:
  /// **'Employment Second Pref'**
  String get visaEB2Name;

  /// No description provided for @visaEB2Desc.
  ///
  /// In en, this message translates to:
  /// **'Professionals with advanced degrees'**
  String get visaEB2Desc;

  /// No description provided for @visaEB3Name.
  ///
  /// In en, this message translates to:
  /// **'Employment Third Pref'**
  String get visaEB3Name;

  /// No description provided for @visaEB3Desc.
  ///
  /// In en, this message translates to:
  /// **'Skilled workers, professionals'**
  String get visaEB3Desc;

  /// No description provided for @visaEB4Name.
  ///
  /// In en, this message translates to:
  /// **'Employment Fourth Pref'**
  String get visaEB4Name;

  /// No description provided for @visaEB4Desc.
  ///
  /// In en, this message translates to:
  /// **'Special immigrants, religious workers'**
  String get visaEB4Desc;

  /// No description provided for @visaEB5Name.
  ///
  /// In en, this message translates to:
  /// **'Employment Fifth Pref'**
  String get visaEB5Name;

  /// No description provided for @visaEB5Desc.
  ///
  /// In en, this message translates to:
  /// **'Immigrant investors'**
  String get visaEB5Desc;

  /// No description provided for @visaF1Name.
  ///
  /// In en, this message translates to:
  /// **'Academic Student'**
  String get visaF1Name;

  /// No description provided for @visaF1Desc.
  ///
  /// In en, this message translates to:
  /// **'Full-time academic studies at accredited institution'**
  String get visaF1Desc;

  /// No description provided for @visaF1IMMName.
  ///
  /// In en, this message translates to:
  /// **'First Preference Family'**
  String get visaF1IMMName;

  /// No description provided for @visaF1IMMDesc.
  ///
  /// In en, this message translates to:
  /// **'Unmarried adult children of US citizens'**
  String get visaF1IMMDesc;

  /// No description provided for @visaH1BName.
  ///
  /// In en, this message translates to:
  /// **'Specialty Occupation'**
  String get visaH1BName;

  /// No description provided for @visaH1BDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional workers requiring specialized knowledge'**
  String get visaH1BDesc;

  /// No description provided for @visaH2AName.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Worker'**
  String get visaH2AName;

  /// No description provided for @visaH2ADesc.
  ///
  /// In en, this message translates to:
  /// **'Temporary agricultural workers'**
  String get visaH2ADesc;

  /// No description provided for @visaH2BName.
  ///
  /// In en, this message translates to:
  /// **'Temporary Worker'**
  String get visaH2BName;

  /// No description provided for @visaH2BDesc.
  ///
  /// In en, this message translates to:
  /// **'Temporary non-agricultural workers'**
  String get visaH2BDesc;

  /// No description provided for @visaIR1Name.
  ///
  /// In en, this message translates to:
  /// **'Immediate Relative - Spouse'**
  String get visaIR1Name;

  /// No description provided for @visaIR1Desc.
  ///
  /// In en, this message translates to:
  /// **'Spouse of US citizen'**
  String get visaIR1Desc;

  /// No description provided for @visaIR2Name.
  ///
  /// In en, this message translates to:
  /// **'Immediate Relative - Child'**
  String get visaIR2Name;

  /// No description provided for @visaIR2Desc.
  ///
  /// In en, this message translates to:
  /// **'Unmarried child under 21 of US citizen'**
  String get visaIR2Desc;

  /// No description provided for @visaIR5Name.
  ///
  /// In en, this message translates to:
  /// **'Immediate Relative - Parent'**
  String get visaIR5Name;

  /// No description provided for @visaIR5Desc.
  ///
  /// In en, this message translates to:
  /// **'Parent of US citizen 21 or older'**
  String get visaIR5Desc;

  /// No description provided for @visaJ1Name.
  ///
  /// In en, this message translates to:
  /// **'Exchange Visitor'**
  String get visaJ1Name;

  /// No description provided for @visaJ1Desc.
  ///
  /// In en, this message translates to:
  /// **'Exchange programs: au pair, intern, professor, work & travel'**
  String get visaJ1Desc;

  /// No description provided for @visaK1Name.
  ///
  /// In en, this message translates to:
  /// **'Fiancé(e)'**
  String get visaK1Name;

  /// No description provided for @visaK1Desc.
  ///
  /// In en, this message translates to:
  /// **'Fiancé(e) of US citizen, must marry within 90 days'**
  String get visaK1Desc;

  /// No description provided for @visaK2Name.
  ///
  /// In en, this message translates to:
  /// **'Child of K-1'**
  String get visaK2Name;

  /// No description provided for @visaK2Desc.
  ///
  /// In en, this message translates to:
  /// **'Unmarried child of K-1 applicant'**
  String get visaK2Desc;

  /// No description provided for @visaL1Name.
  ///
  /// In en, this message translates to:
  /// **'Intracompany Transfer'**
  String get visaL1Name;

  /// No description provided for @visaL1Desc.
  ///
  /// In en, this message translates to:
  /// **'Managers and executives transferred within company'**
  String get visaL1Desc;

  /// No description provided for @visaM1Name.
  ///
  /// In en, this message translates to:
  /// **'Vocational Student'**
  String get visaM1Name;

  /// No description provided for @visaM1Desc.
  ///
  /// In en, this message translates to:
  /// **'Vocational or technical training programs'**
  String get visaM1Desc;

  /// No description provided for @visaO1Name.
  ///
  /// In en, this message translates to:
  /// **'Extraordinary Ability'**
  String get visaO1Name;

  /// No description provided for @visaO1Desc.
  ///
  /// In en, this message translates to:
  /// **'Individuals with extraordinary ability in sciences, arts, etc.'**
  String get visaO1Desc;

  /// No description provided for @visaP1Name.
  ///
  /// In en, this message translates to:
  /// **'Athlete/Entertainer'**
  String get visaP1Name;

  /// No description provided for @visaP1Desc.
  ///
  /// In en, this message translates to:
  /// **'Internationally recognized athletes or entertainers'**
  String get visaP1Desc;

  /// No description provided for @visaQ1Name.
  ///
  /// In en, this message translates to:
  /// **'Cultural Exchange'**
  String get visaQ1Name;

  /// No description provided for @visaQ1Desc.
  ///
  /// In en, this message translates to:
  /// **'International cultural exchange programs'**
  String get visaQ1Desc;

  /// No description provided for @visaR1Name.
  ///
  /// In en, this message translates to:
  /// **'Religious Worker'**
  String get visaR1Name;

  /// No description provided for @visaR1Desc.
  ///
  /// In en, this message translates to:
  /// **'Religious workers in religious capacity'**
  String get visaR1Desc;

  /// No description provided for @visaTNName.
  ///
  /// In en, this message translates to:
  /// **'NAFTA Professional'**
  String get visaTNName;

  /// No description provided for @visaTNDesc.
  ///
  /// In en, this message translates to:
  /// **'Canadian/Mexican professionals under USMCA'**
  String get visaTNDesc;

  /// No description provided for @visaF2AName.
  ///
  /// In en, this message translates to:
  /// **'Second Preference 2A'**
  String get visaF2AName;

  /// No description provided for @visaF2ADesc.
  ///
  /// In en, this message translates to:
  /// **'Spouse and minor children of LPR'**
  String get visaF2ADesc;

  /// No description provided for @visaF2BName.
  ///
  /// In en, this message translates to:
  /// **'Second Preference 2B'**
  String get visaF2BName;

  /// No description provided for @visaF2BDesc.
  ///
  /// In en, this message translates to:
  /// **'Unmarried adult children of LPR'**
  String get visaF2BDesc;

  /// No description provided for @visaF3Name.
  ///
  /// In en, this message translates to:
  /// **'Third Preference Family'**
  String get visaF3Name;

  /// No description provided for @visaF3Desc.
  ///
  /// In en, this message translates to:
  /// **'Married adult children of US citizens'**
  String get visaF3Desc;

  /// No description provided for @visaF4Name.
  ///
  /// In en, this message translates to:
  /// **'Fourth Preference Family'**
  String get visaF4Name;

  /// No description provided for @visaF4Desc.
  ///
  /// In en, this message translates to:
  /// **'Siblings of adult US citizens'**
  String get visaF4Desc;

  /// No description provided for @runAudit.
  ///
  /// In en, this message translates to:
  /// **'Run Audit'**
  String get runAudit;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfile;

  /// No description provided for @selectPlatform.
  ///
  /// In en, this message translates to:
  /// **'Please select a platform'**
  String get selectPlatform;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @biometricsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometrics enabled'**
  String get biometricsEnabled;

  /// No description provided for @biometricsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometrics disabled'**
  String get biometricsDisabled;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @noFormData.
  ///
  /// In en, this message translates to:
  /// **'No form data'**
  String get noFormData;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents'**
  String get noDocuments;

  /// No description provided for @scannedPassport.
  ///
  /// In en, this message translates to:
  /// **'Scanned Passport'**
  String get scannedPassport;

  /// No description provided for @noPracticeSessions.
  ///
  /// In en, this message translates to:
  /// **'No practice sessions'**
  String get noPracticeSessions;

  /// No description provided for @startSimulation.
  ///
  /// In en, this message translates to:
  /// **'Start Simulation'**
  String get startSimulation;

  /// No description provided for @currentScore.
  ///
  /// In en, this message translates to:
  /// **'Current Score'**
  String get currentScore;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @recoveryLinkWillBeSent.
  ///
  /// In en, this message translates to:
  /// **'A recovery link will be sent to:\n{email}'**
  String recoveryLinkWillBeSent(Object email);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @linkSentTo.
  ///
  /// In en, this message translates to:
  /// **'Link sent to {email}'**
  String linkSentTo(Object email);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @languageChangeRequiresRestart.
  ///
  /// In en, this message translates to:
  /// **'Language change requires restart'**
  String get languageChangeRequiresRestart;

  /// No description provided for @openingTerms.
  ///
  /// In en, this message translates to:
  /// **'Opening terms...'**
  String get openingTerms;

  /// No description provided for @openingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Opening privacy policy...'**
  String get openingPrivacy;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopied;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @formDS2019Name.
  ///
  /// In en, this message translates to:
  /// **'Certificate of Eligibility'**
  String get formDS2019Name;

  /// No description provided for @formDS2019Help.
  ///
  /// In en, this message translates to:
  /// **'Issued by your program sponsor (e.g. Au Pair agency).'**
  String get formDS2019Help;

  /// No description provided for @formI129SName.
  ///
  /// In en, this message translates to:
  /// **'Blanket L Petition'**
  String get formI129SName;

  /// No description provided for @formI129SHelp.
  ///
  /// In en, this message translates to:
  /// **'Required for Blanket L applications.'**
  String get formI129SHelp;

  /// No description provided for @formI20Name.
  ///
  /// In en, this message translates to:
  /// **'Certificate of Eligibility'**
  String get formI20Name;

  /// No description provided for @formI20HelpAcademic.
  ///
  /// In en, this message translates to:
  /// **'Issued by your school after acceptance.'**
  String get formI20HelpAcademic;

  /// No description provided for @formI20HelpVocational.
  ///
  /// In en, this message translates to:
  /// **'Issued by your vocational school after acceptance.'**
  String get formI20HelpVocational;

  /// No description provided for @formI797Name.
  ///
  /// In en, this message translates to:
  /// **'Notice of Action (Approval)'**
  String get formI797Name;

  /// No description provided for @formI797Help.
  ///
  /// In en, this message translates to:
  /// **'Approval notice from USCIS (I-797A or I-797B).'**
  String get formI797Help;

  /// No description provided for @issuedByProgramSponsor.
  ///
  /// In en, this message translates to:
  /// **'Program Sponsor'**
  String get issuedByProgramSponsor;

  /// No description provided for @issuedByEmployer.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get issuedByEmployer;

  /// No description provided for @issuedByDHSSEVPSchool.
  ///
  /// In en, this message translates to:
  /// **'DHS/SEVP School'**
  String get issuedByDHSSEVPSchool;

  /// No description provided for @planDiyTitle.
  ///
  /// In en, this message translates to:
  /// **'US Visa Strategy Review (DIY)'**
  String get planDiyTitle;

  /// No description provided for @planDiyDesc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive analysis and VisaScore™ report. Best for self-starters.'**
  String get planDiyDesc;

  /// No description provided for @planFullTitle.
  ///
  /// In en, this message translates to:
  /// **'US Visa Full Service'**
  String get planFullTitle;

  /// No description provided for @planFullDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete application management and priority review.'**
  String get planFullDesc;

  /// No description provided for @planSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Interview Simulator'**
  String get planSimulatorTitle;

  /// No description provided for @planSimulatorDesc.
  ///
  /// In en, this message translates to:
  /// **'30 Days of unlimited practice with our AI Officer.'**
  String get planSimulatorDesc;

  /// No description provided for @featureAIRiskAssessment.
  ///
  /// In en, this message translates to:
  /// **'AI Risk Assessment'**
  String get featureAIRiskAssessment;

  /// No description provided for @featureVisaScoreReport.
  ///
  /// In en, this message translates to:
  /// **'VisaScore™ Report'**
  String get featureVisaScoreReport;

  /// No description provided for @featureDocumentChecklist.
  ///
  /// In en, this message translates to:
  /// **'Document Checklist'**
  String get featureDocumentChecklist;

  /// No description provided for @featureEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get featureEmailSupport;

  /// No description provided for @featureEverythingInDIY.
  ///
  /// In en, this message translates to:
  /// **'Everything in DIY'**
  String get featureEverythingInDIY;

  /// No description provided for @featureDS160AutoFill.
  ///
  /// In en, this message translates to:
  /// **'DS-160 Auto-Fill'**
  String get featureDS160AutoFill;

  /// No description provided for @featureInterviewPrepGuide.
  ///
  /// In en, this message translates to:
  /// **'Interview Prep Guide'**
  String get featureInterviewPrepGuide;

  /// No description provided for @featurePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get featurePrioritySupport;

  /// No description provided for @featureMoneyBackGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Money-Back Guarantee'**
  String get featureMoneyBackGuarantee;

  /// No description provided for @featureUnlimitedPracticeSessions.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Practice Sessions'**
  String get featureUnlimitedPracticeSessions;

  /// No description provided for @featureRealConsulScenarios.
  ///
  /// In en, this message translates to:
  /// **'Real Consul Scenarios'**
  String get featureRealConsulScenarios;

  /// No description provided for @featurePerformanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get featurePerformanceAnalytics;

  /// No description provided for @featureWeaknessAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Weakness Analysis'**
  String get featureWeaknessAnalysis;

  /// No description provided for @restrictionTotalBan.
  ///
  /// In en, this message translates to:
  /// **'Total Ban'**
  String get restrictionTotalBan;

  /// No description provided for @restrictionPartialBan.
  ///
  /// In en, this message translates to:
  /// **'Partial Restriction'**
  String get restrictionPartialBan;

  /// No description provided for @restrictionEnhancedVetting.
  ///
  /// In en, this message translates to:
  /// **'Enhanced Vetting'**
  String get restrictionEnhancedVetting;

  /// No description provided for @restrictionCompleteEntryProhibition.
  ///
  /// In en, this message translates to:
  /// **'Complete entry prohibition'**
  String get restrictionCompleteEntryProhibition;

  /// No description provided for @splashDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Non-government service provider'**
  String get splashDisclaimer;

  /// No description provided for @profileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Profile incomplete. Please scan your passport first.'**
  String get profileIncomplete;

  /// No description provided for @digitalFile.
  ///
  /// In en, this message translates to:
  /// **'Digital File'**
  String get digitalFile;

  /// No description provided for @ds160Responses.
  ///
  /// In en, this message translates to:
  /// **'DS-160 Responses'**
  String get ds160Responses;

  /// No description provided for @fieldsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} fields'**
  String fieldsCount(int count);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @documentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Document'**
  String documentCount(int count);

  /// No description provided for @simulatorHistory.
  ///
  /// In en, this message translates to:
  /// **'Simulation History'**
  String get simulatorHistory;

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String sessionsCount(int count);

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions'**
  String get noSessions;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @updateAccess.
  ///
  /// In en, this message translates to:
  /// **'Update access'**
  String get updateAccess;

  /// No description provided for @biometricsLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometricsLabel;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get activated;

  /// No description provided for @deactivated.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get deactivated;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms and privacy'**
  String get termsAndPrivacy;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get verified;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'PASSPORT'**
  String get passport;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'NATIONALITY'**
  String get nationality;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'BIRTH DATE'**
  String get birthDate;

  /// No description provided for @ds160Data.
  ///
  /// In en, this message translates to:
  /// **'DS-160 Data'**
  String get ds160Data;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Social Media Profiles'**
  String get socialMediaProfiles;

  /// Disclaimer text
  ///
  /// In en, this message translates to:
  /// **'DS-160 requires disclosure of social media accounts used in the last 5 years.'**
  String get socialMediaDisclaimer;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Social Media Profile'**
  String get addSocialProfile;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Profile URL'**
  String get profileUrl;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Username (optional)'**
  String get usernameOptional;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get enterValidUrl;

  /// Alert title
  ///
  /// In en, this message translates to:
  /// **'Discrepancies Detected'**
  String get discrepanciesDetected;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Mismatch'**
  String get mismatch;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Waiver text
  ///
  /// In en, this message translates to:
  /// **'Suggested Waiver: {waiver}'**
  String suggestedWaiver(String waiver);

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Detected from: '**
  String get detectedFrom;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Detected Issue'**
  String get detectedIssue;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Profile URL is required'**
  String get profileUrlRequired;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'Employment history does not match DS-160 declaration'**
  String get employmentHistoryMismatch;

  /// No description provided for @sessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session {number}'**
  String sessionNumber(int number);

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get notRegistered;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Link sent to {email}'**
  String passwordResetSent(String email);

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @passwordResetDialogContent.
  ///
  /// In en, this message translates to:
  /// **'A recovery link will be sent to:\n{email}'**
  String passwordResetDialogContent(String email);

  /// No description provided for @legalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get legalDocuments;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View document'**
  String get viewDocument;

  /// No description provided for @spanishLanguage.
  ///
  /// In en, this message translates to:
  /// **'🇪🇸  Español'**
  String get spanishLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'🇺🇸  English'**
  String get englishLanguage;

  /// No description provided for @roundTrip.
  ///
  /// In en, this message translates to:
  /// **'Round Trip'**
  String get roundTrip;

  /// No description provided for @oneWay.
  ///
  /// In en, this message translates to:
  /// **'One Way'**
  String get oneWay;

  /// No description provided for @flightCostEstimate.
  ///
  /// In en, this message translates to:
  /// **'Flight Cost Estimate'**
  String get flightCostEstimate;

  /// No description provided for @includesHotelCosts.
  ///
  /// In en, this message translates to:
  /// **'Includes average hotel costs for 2 nights'**
  String get includesHotelCosts;

  /// No description provided for @sevisFeeIncluded.
  ///
  /// In en, this message translates to:
  /// **'SEVIS Fee Included'**
  String get sevisFeeIncluded;

  /// No description provided for @j1SevisFee.
  ///
  /// In en, this message translates to:
  /// **'J-1 SEVIS: USD 220'**
  String get j1SevisFee;

  /// No description provided for @fmSevisFee.
  ///
  /// In en, this message translates to:
  /// **'F/M SEVIS: USD 350'**
  String get fmSevisFee;

  /// No description provided for @mrvFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'MRV Fee'**
  String get mrvFeeLabel;

  /// No description provided for @integrityFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Integrity'**
  String get integrityFeeLabel;

  /// No description provided for @sevisFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'SEVIS'**
  String get sevisFeeLabel;

  /// No description provided for @i94LandFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'I-94 Land'**
  String get i94LandFeeLabel;

  /// No description provided for @understandingVisaFees.
  ///
  /// In en, this message translates to:
  /// **'Understanding Visa Fees (2026)'**
  String get understandingVisaFees;

  /// No description provided for @mrvFeeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'MRV Fee (Non-refundable)'**
  String get mrvFeeInfoTitle;

  /// No description provided for @mrvFeeInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'The Machine Readable Visa fee is paid when scheduling your interview. It varies by visa category.'**
  String get mrvFeeInfoDescription;

  /// No description provided for @integrityFeeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Visa Integrity Fee (NEW)'**
  String get integrityFeeInfoTitle;

  /// No description provided for @integrityFeeInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'A new USD 250 fee implemented in 2026 for most non-immigrant visas.'**
  String get integrityFeeInfoDescription;

  /// No description provided for @sevisFeeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'SEVIS I-901 Fee'**
  String get sevisFeeInfoTitle;

  /// No description provided for @sevisFeeInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Required for students and exchange visitors. Pay at fmjfee.com BEFORE your interview.'**
  String get sevisFeeInfoDescription;

  /// No description provided for @i94FeeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'I-94 Land Border Fee'**
  String get i94FeeInfoTitle;

  /// No description provided for @i94FeeInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Increased from USD 6 to USD 24 in 2026. Only applies if entering the US by land.'**
  String get i94FeeInfoDescription;

  /// No description provided for @guestLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestLabel;

  /// No description provided for @notAvailableAndDash.
  ///
  /// In en, this message translates to:
  /// **'---'**
  String get notAvailableAndDash;

  /// No description provided for @notAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableShort;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@usavpc.org'**
  String get supportEmail;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'ES / EN'**
  String get languageLabel;

  /// No description provided for @formLabel.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get formLabel;

  /// No description provided for @errorCriticalNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL ERROR: No Questions found in Database (0). Seeding required.'**
  String get errorCriticalNoQuestions;

  /// No description provided for @errorNoQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: No questions available to render.'**
  String get errorNoQuestionsAvailable;

  /// No description provided for @errorDbAuth.
  ///
  /// In en, this message translates to:
  /// **'DB Auth Error: Maybe RLS? {error}'**
  String errorDbAuth(Object error);

  /// No description provided for @errorMissingQuestionText.
  ///
  /// In en, this message translates to:
  /// **'Error: Missing Question Text'**
  String get errorMissingQuestionText;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @noStepsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No steps available.'**
  String get noStepsAvailable;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDateLabel;

  /// No description provided for @errorDatabaseUnique.
  ///
  /// In en, this message translates to:
  /// **'Database Error: Unique constraint missing. Fixed in logic.'**
  String get errorDatabaseUnique;

  /// No description provided for @uploadFormatInfo.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG or PDF (max. 800x400px)'**
  String get uploadFormatInfo;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// No description provided for @scanIncompleteError.
  ///
  /// In en, this message translates to:
  /// **'❌ Scan incomplete. Please rescan passport clearly.'**
  String get scanIncompleteError;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Access'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all services'**
  String get subscriptionSubtitle;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get planYearly;

  /// No description provided for @priceMonthly.
  ///
  /// In en, this message translates to:
  /// **'\$100/mo'**
  String get priceMonthly;

  /// No description provided for @priceYearly.
  ///
  /// In en, this message translates to:
  /// **'\$250/yr'**
  String get priceYearly;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// Bottom navigation home label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom navigation services label
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// Bottom navigation profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// DS-260 intake screen title
  ///
  /// In en, this message translates to:
  /// **'DS-260 INTAKE'**
  String get ds260IntakeTitle;

  /// Bottom navigation risk command label
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get riskCommand;

  /// Risk dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Risk Command'**
  String get riskCommandTitle;

  /// Loading state in risk dashboard
  ///
  /// In en, this message translates to:
  /// **'Analyzing profile...'**
  String get analyzingProfile;

  /// Risk gauge title
  ///
  /// In en, this message translates to:
  /// **'VISA APPROVAL PROBABILITY'**
  String get visaApprovalProbability;

  /// Radar chart section title
  ///
  /// In en, this message translates to:
  /// **'FRICTION MAP'**
  String get frictionMap;

  /// Alerts section title
  ///
  /// In en, this message translates to:
  /// **'RED FLAG FEED'**
  String get redFlagFeed;

  /// No red flags badge
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get redFlagClear;

  /// Red flag count badge
  ///
  /// In en, this message translates to:
  /// **'{count} ALERTS'**
  String redFlagAlerts(int count);

  /// Empty red flags message
  ///
  /// In en, this message translates to:
  /// **'No red flags detected in current profile.'**
  String get noRedFlagsDetected;

  /// Simulator section title
  ///
  /// In en, this message translates to:
  /// **'Practice Interview'**
  String get practiceWithSimulator;

  /// Simulator section description
  ///
  /// In en, this message translates to:
  /// **'Practice with our AI Consular Officer to improve your interview skills.'**
  String get practiceWithSimulatorDesc;

  /// Navigate to simulator button
  ///
  /// In en, this message translates to:
  /// **'GO TO SIMULATOR'**
  String get goToSimulator;

  /// Risk category label
  ///
  /// In en, this message translates to:
  /// **'LOW RISK'**
  String get riskLow;

  /// Risk category label
  ///
  /// In en, this message translates to:
  /// **'MODERATE'**
  String get riskModerate;

  /// Risk category label
  ///
  /// In en, this message translates to:
  /// **'HIGH RISK'**
  String get riskHigh;

  /// Risk category label
  ///
  /// In en, this message translates to:
  /// **'214(b) IMMINENT'**
  String get riskCritical;

  /// Risk category description
  ///
  /// In en, this message translates to:
  /// **'Strong ties demonstrated. Favorable profile.'**
  String get riskLowDesc;

  /// Risk category description
  ///
  /// In en, this message translates to:
  /// **'Some concerns. Additional documentation recommended.'**
  String get riskModerateDesc;

  /// Risk category description
  ///
  /// In en, this message translates to:
  /// **'Multiple red flags detected. Review required.'**
  String get riskHighDesc;

  /// Risk category description
  ///
  /// In en, this message translates to:
  /// **'Profile indicates high probability of 214(b) refusal.'**
  String get riskCriticalDesc;

  /// Radar chart axis label
  ///
  /// In en, this message translates to:
  /// **'Economic'**
  String get axisEconomic;

  /// Radar chart axis label
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get axisSocial;

  /// Radar chart axis label
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get axisDocuments;

  /// Radar chart axis label
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get axisConsistency;

  /// Radar chart axis label
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get axisTravel;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
