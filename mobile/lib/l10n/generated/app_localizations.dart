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

  /// Section title for services
  ///
  /// In en, this message translates to:
  /// **'Popular Services'**
  String get popularServices;

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
