// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dataSavedSuccess => 'Data saved successfully';

  @override
  String get appTitle => 'Consular Assistant';

  @override
  String get officialGuide => 'Official Guide';

  @override
  String get heroTitle => 'Simplify Your Consular Process';

  @override
  String get heroSubtitle =>
      'Scan documents and simulate your interview to secure your visa.';

  @override
  String get howItWorks => 'How it Works';

  @override
  String get stepScan => 'Scan';

  @override
  String get stepScanSubtitle => 'Passport';

  @override
  String get stepSimulate => 'Simulate';

  @override
  String get stepSimulateSubtitle => 'AI Interview';

  @override
  String get stepResults => 'Results';

  @override
  String get stepResultsSubtitle => 'Get Report';

  @override
  String get popularServices => 'Popular Services';

  @override
  String get viewAll => 'View all';

  @override
  String get newVisaApplication => 'New Visa Application';

  @override
  String get newVisaSubtitle => 'Scan your ID to auto-fill forms.';

  @override
  String get badgeFast => 'FAST';

  @override
  String get interviewSimulator => 'Interview Simulator';

  @override
  String get interviewSimulatorSubtitle =>
      'Practice real questions with our AI.';

  @override
  String get documentAudit => 'Document Audit';

  @override
  String get documentAuditSubtitle =>
      'Personalized checklist for your visa type.';

  @override
  String get securityNote => 'Your data is secure and encrypted.';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginAppName => 'USA Visa Processing';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'SIGN IN / LOGIN';

  @override
  String get createAccountLink => 'Create an account / Create Account';

  @override
  String get quickFillTest => 'Quick Fill (Test User)';

  @override
  String get nonGovernmentDisclaimer => 'Non-government service provider';

  @override
  String get emailRequired => 'Please enter email';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordRequired => 'Please enter password';

  @override
  String get dashboardTitle => 'My Application';

  @override
  String get applicationStatus => 'Application Status';

  @override
  String get nextSteps => 'Next Steps';

  @override
  String percentComplete(int percent) {
    return '$percent% Complete';
  }

  @override
  String lastEdited(String date) {
    return 'Last edited: $date';
  }

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPendingPayment => 'Pending Payment';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusNotStarted => 'Not Started';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsOption => 'Settings';

  @override
  String get helpOption => 'Help & Support';

  @override
  String get logoutOption => 'Log Out';

  @override
  String get settingsComingSoon => 'Settings coming soon';

  @override
  String get contactSupport => 'Contact: support@usavpc.org';

  @override
  String get noEmail => 'No email';

  @override
  String get defaultUser => 'User';

  @override
  String get verificationTitle => 'Identity Verification';

  @override
  String get scanDocument => 'Scan Your Document';

  @override
  String get scanDocumentSubtitle =>
      'We need to capture your passport data to auto-fill your application.';

  @override
  String get useCamera => 'Use Camera';

  @override
  String get useCameraSubtitle => 'Scan directly';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get uploadImageSubtitle => 'From gallery';

  @override
  String get dataSecure => 'Your data is encrypted and secure';

  @override
  String get documentValidated => 'Document validated successfully';

  @override
  String get noValidPassport => 'No valid passport detected. Please try again.';

  @override
  String get ds160Assistant => 'DS-160 Assistant';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get typeYourResponse => 'Type your response...';

  @override
  String loadingQuestionsError(String error) {
    return 'Error loading questions: $error';
  }

  @override
  String get validationError =>
      'Hmm, that doesn\'t seem right. Can you verify?';

  @override
  String savingError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get intakeComplete =>
      '🎉 Excellent! You have completed all questions. Your information is saved and ready to generate your DS-160 form.';

  @override
  String get viewMyApplication => 'VIEW MY APPLICATION';

  @override
  String get tips => 'Tips:';

  @override
  String get example => 'Example';

  @override
  String get preliminaryAuditTitle => 'Preliminary Audit';

  @override
  String get eligibilityVerification => 'Eligibility Verification';

  @override
  String get eligibilitySubtitle =>
      'Before simulating your interview, we\'ll analyze your basic profile to detect obvious risks.';

  @override
  String get visaTypeLabel => 'Visa Type Requested';

  @override
  String get visaB1B2 => 'B1/B2 - Tourism and Business';

  @override
  String get visaF1 => 'F1 - Student';

  @override
  String get visaH2 => 'H2 - Temporary Work';

  @override
  String get ds160Question => 'Have you already completed your DS-160 form?';

  @override
  String get yesHaveCode => 'Yes, I have the code';

  @override
  String get notYet => 'No, not yet';

  @override
  String get ds160CodeLabel => 'DS-160 Confirmation Code';

  @override
  String get ds160CodeHint => 'E.g: AA00...';

  @override
  String get enterCode => 'Enter the code';

  @override
  String get codeStartAA => 'Must start with \"AA\"';

  @override
  String get noDs160Warning =>
      'For a precise audit, we recommend having the form ready. You can continue, but the analysis will be limited.';

  @override
  String get startAnalysis => 'START ANALYSIS';

  @override
  String get simulatorTitle => 'Interview Simulator';

  @override
  String get simulatorDescription =>
      'Practice with our AI Consular Officer. Respond verbally to evaluate your fluency and coherence.';

  @override
  String get enableMicrophone => 'ENABLE MICROPHONE';

  @override
  String get startInterview => 'START INTERVIEW';

  @override
  String get microphoneRequired =>
      'Microphone is required for the voice simulator.';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get registerTitle => 'Create Account';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get registerButton => 'SIGN UP / REGISTER';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get fieldRequired => 'Required';

  @override
  String passwordMinLength(int count) {
    return 'Minimum $count characters';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreated => 'Account Created! Welcome.';

  @override
  String get orderSummaryTitle => 'Order Summary';

  @override
  String get total => 'Total';

  @override
  String payButton(String amount) {
    return 'Pay \$$amount';
  }

  @override
  String get processing => 'Processing...';

  @override
  String get paymentCompleted => 'Payment completed successfully!';

  @override
  String paymentCancelled(String message) {
    return 'Payment cancelled: $message';
  }

  @override
  String get securePayment => 'Secure payment with Stripe';

  @override
  String get priorityProcessing => 'Priority Processing';

  @override
  String get noPlansAvailable => 'No plans available';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get approvalAuditTitle => 'Approval Audit';

  @override
  String get approvalProbability => 'Approval Probability';

  @override
  String riskLevel(String level) {
    return 'Risk $level';
  }

  @override
  String get factorAnalysis => 'Factor Analysis';

  @override
  String get continueToSimulator => 'CONTINUE TO SIMULATOR';

  @override
  String get backToHome => 'Back to home';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get confirmDataTitle => 'Confirm Data';

  @override
  String get passportScanned => 'Passport Scanned';

  @override
  String get verifyDataCorrect => 'Verify that the data is correct';

  @override
  String get surnameLabel => 'Surname(s)';

  @override
  String get givenNameLabel => 'Given Name(s)';

  @override
  String get birthDateLabel => 'Date of Birth';

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get passportNumberLabel => 'Passport Number';

  @override
  String get additionalQuestionsInfo =>
      'After confirming, I will ask you some additional questions not on your passport.';

  @override
  String get confirmAndContinue => 'CONFIRM AND CONTINUE';

  @override
  String get interviewInProgress => 'Interview in Progress';

  @override
  String get pressMicToSpeak => 'Press the microphone to speak...';

  @override
  String get connectingToOfficer => 'Connecting to Consular Officer...';

  @override
  String get listening => 'Listening...';

  @override
  String get ds160AutoFill => 'DS-160 Auto-fill';

  @override
  String get inject => 'INJECT';

  @override
  String get consoleOutput => '> CONSOLE OUTPUT';

  @override
  String get passportDetected => 'Passport Detected!';

  @override
  String get passportScanInstructions => 'Scan the passport data zone';

  @override
  String get searchingMRZ => 'Searching MRZ...';

  @override
  String get detected => 'Detected!';

  @override
  String get navigatingTo => 'Navigating to';

  @override
  String get pageLoaded => 'Page loaded';

  @override
  String get networkError => 'Network error';

  @override
  String get detectingFormFields => 'Detecting form fields...';

  @override
  String get injectingData => 'Injecting data into form...';

  @override
  String fieldsFilled(int filled, int notFound) {
    return 'Fields filled: $filled | Not found: $notFound';
  }

  @override
  String get injectionComplete => 'Injection completed';

  @override
  String get automationReady =>
      'Automation ready. Review the data and continue manually.';

  @override
  String get processComplete =>
      'PROCESS COMPLETED - Verify data before continuing';

  @override
  String get injectionError => 'Error during injection';

  @override
  String get costCalculatorTitle => 'Cost Calculator';

  @override
  String get costCalculatorSubtitle => 'Complete fee estimation';

  @override
  String get travelBanTitle => 'Check Restrictions';

  @override
  String get travelBanSubtitle => 'Check 2026 Travel Ban';
}
