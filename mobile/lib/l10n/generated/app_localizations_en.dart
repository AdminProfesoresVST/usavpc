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
  String get popularServices => 'Services';

  @override
  String get helpScanTitle => 'Document Scanning';

  @override
  String get helpScanDesc =>
      'Our OCR technology automatically extracts your data from your passport to avoid manual errors.';

  @override
  String get helpScanBullet1 => 'Place your passport on a flat surface.';

  @override
  String get helpScanBullet2 => 'Ensure good lighting without glare.';

  @override
  String get helpScanButton => 'Start Scanning';

  @override
  String get helpSimulateTitle => 'AI Interview Simulator';

  @override
  String get helpSimulateDesc =>
      'Practice with our Virtual Consular Agent trained on thousands of real cases.';

  @override
  String get helpSimulateBullet1 =>
      'Receive personalized questions based on your profile.';

  @override
  String get helpSimulateBullet2 => 'Get immediate feedback on your answers.';

  @override
  String get helpSimulateButton => 'Start Simulator';

  @override
  String get helpResultsTitle => 'Results & Analysis';

  @override
  String get helpResultsDesc =>
      'Get a detailed risk analysis before your real appointment.';

  @override
  String get helpResultsBullet1 =>
      'Identify potential red flags in your application.';

  @override
  String get helpResultsBullet2 =>
      'Receive recommendations to improve your chances.';

  @override
  String get helpResultsButton => 'View My Services';

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
  String get visaB1B2 => 'Visitor Business/Tourism';

  @override
  String get visaF1 => 'Academic Student';

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
  String get fieldRequired => 'This field is required';

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

  @override
  String get knowYourTotal => 'Know Your Total';

  @override
  String get knowYourTotalSubtitle =>
      'Calculate all fees for your visa application';

  @override
  String get yourNationality => 'Your Nationality';

  @override
  String get selectCountry => 'Select your country';

  @override
  String get visaCategory => 'Visa Category';

  @override
  String get selectCategory => 'Select visa category';

  @override
  String get additionalOptions => 'Additional Options';

  @override
  String get crossingByLand => 'Crossing by Land';

  @override
  String get crossingByLandSubtitle => 'Adds I-94 fee (\$24)';

  @override
  String get calculateTotalCost => 'Calculate Total Cost';

  @override
  String get feeSchedule => '2026 Fee Schedule';

  @override
  String get checkYourEligibility => 'Check Your Eligibility';

  @override
  String get checkYourEligibilitySubtitle =>
      'Verify if your nationality has any visa restrictions';

  @override
  String get checkRestrictions => 'Check Restrictions';

  @override
  String get currentRestrictions => 'Current Restrictions (2026)';

  @override
  String get totalBan => 'Total Ban';

  @override
  String get partial => 'Partial';

  @override
  String get paused => 'Paused';

  @override
  String get selectVisaType => 'Select Visa Type';

  @override
  String get nonImmigrant => 'Non-Immigrant';

  @override
  String get immigrant => 'Immigrant';

  @override
  String get mrvFee => 'MRV Fee';

  @override
  String get fiance => 'Fiancé(e)';

  @override
  String get petition => 'Petition';

  @override
  String get sevis => 'SEVIS';

  @override
  String get kVisa => 'K Visa';

  @override
  String get documentChecklist => 'Document Checklist';

  @override
  String get prerequisitesVerified => 'All required documents verified';

  @override
  String get missingDocuments => 'Missing required documents';

  @override
  String get progress => 'Progress';

  @override
  String get required => 'required';

  @override
  String get noPrerequisities => 'No Prerequisites Required';

  @override
  String get noPrerequisitiesDesc =>
      'This visa category does not require any prerequisite documents. You can proceed directly to fill out the application form.';

  @override
  String get continueToApp => 'Continue to Application';

  @override
  String get proceedingToApp =>
      'All prerequisites verified. Proceeding to application...';

  @override
  String get visaB1 => 'Business Visitor';

  @override
  String get visaB2 => 'Tourist';

  @override
  String get visaF2 => 'Student Dependent';

  @override
  String get visaM1 => 'Vocational Student';

  @override
  String get visaJ1 => 'Exchange Visitor';

  @override
  String get visaH1B => 'Specialty Occupation';

  @override
  String get visaL1 => 'Intracompany Transferee';

  @override
  String get visaO1 => 'Extraordinary Ability';

  @override
  String get visaK1 => 'Fiancé(e)';

  @override
  String get visaE1 => 'Treaty Trader';

  @override
  String get visaE2 => 'Treaty Investor';

  @override
  String get optional => 'Optional';

  @override
  String get doYouHaveDocument => 'Do you have this document?';

  @override
  String get yesHaveIt => 'Yes, I have it';

  @override
  String get noNotYet => 'No, not yet';

  @override
  String get enterDocDetails => 'Enter Document Details';

  @override
  String get saveDocInfo => 'Save Document Info';

  @override
  String get docInfoSaved => 'Document info saved';

  @override
  String get issuedBy => 'Issued by';

  @override
  String get issuedBySchool => 'Your School/University';

  @override
  String get issuedByUSCIS => 'USCIS';

  @override
  String get issuedBySponsor => 'Program Sponsor Organization';

  @override
  String get issuedByPetitioner => 'Your Petitioner (US Sponsor)';

  @override
  String get issuedByStateDept => 'US Department of State';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get visaB1Name => 'Business Visitor';

  @override
  String get visaB1Desc =>
      'Temporary business activities, meetings, conferences';

  @override
  String get visaB1B2Name => 'Visitor Business/Tourism';

  @override
  String get visaB1B2Desc => 'For temporary business or tourism purposes';

  @override
  String get visaB2Name => 'Tourist';

  @override
  String get visaB2Desc =>
      'Tourism, vacation, medical treatment, visiting family';

  @override
  String get visaCR1Name => 'Conditional Resident - Spouse';

  @override
  String get visaCR1Desc => 'Spouse married less than 2 years';

  @override
  String get visaCR2Name => 'Conditional Resident - Child';

  @override
  String get visaCR2Desc => 'Child of CR1';

  @override
  String get visaDVName => 'Diversity Visa';

  @override
  String get visaDVDesc => 'Diversity visa lottery winners';

  @override
  String get visaE1Name => 'Treaty Trader';

  @override
  String get visaE1Desc => 'Treaty traders engaged in substantial trade';

  @override
  String get visaE1E2Name => 'Treaty Trader/Investor';

  @override
  String get visaE1E2Desc => 'For investors from treaty countries';

  @override
  String get visaE2Name => 'Treaty Investor';

  @override
  String get visaE2Desc => 'Treaty investors with substantial investment';

  @override
  String get visaEB1Name => 'Employment First Pref';

  @override
  String get visaEB1Desc => 'Priority workers, extraordinary ability';

  @override
  String get visaEB2Name => 'Employment Second Pref';

  @override
  String get visaEB2Desc => 'Professionals with advanced degrees';

  @override
  String get visaEB3Name => 'Employment Third Pref';

  @override
  String get visaEB3Desc => 'Skilled workers, professionals';

  @override
  String get visaEB4Name => 'Employment Fourth Pref';

  @override
  String get visaEB4Desc => 'Special immigrants, religious workers';

  @override
  String get visaEB5Name => 'Employment Fifth Pref';

  @override
  String get visaEB5Desc => 'Immigrant investors';

  @override
  String get visaF1Name => 'Academic Student';

  @override
  String get visaF1Desc =>
      'Full-time academic studies at accredited institution';

  @override
  String get visaF1IMMName => 'First Preference Family';

  @override
  String get visaF1IMMDesc => 'Unmarried adult children of US citizens';

  @override
  String get visaH1BName => 'Specialty Occupation';

  @override
  String get visaH1BDesc =>
      'Professional workers requiring specialized knowledge';

  @override
  String get visaH2AName => 'Agricultural Worker';

  @override
  String get visaH2ADesc => 'Temporary agricultural workers';

  @override
  String get visaH2BName => 'Temporary Worker';

  @override
  String get visaH2BDesc => 'Temporary non-agricultural workers';

  @override
  String get visaIR1Name => 'Immediate Relative - Spouse';

  @override
  String get visaIR1Desc => 'Spouse of US citizen';

  @override
  String get visaIR2Name => 'Immediate Relative - Child';

  @override
  String get visaIR2Desc => 'Unmarried child under 21 of US citizen';

  @override
  String get visaIR5Name => 'Immediate Relative - Parent';

  @override
  String get visaIR5Desc => 'Parent of US citizen 21 or older';

  @override
  String get visaJ1Name => 'Exchange Visitor';

  @override
  String get visaJ1Desc =>
      'Exchange programs: au pair, intern, professor, work & travel';

  @override
  String get visaK1Name => 'Fiancé(e)';

  @override
  String get visaK1Desc => 'Fiancé(e) of US citizen, must marry within 90 days';

  @override
  String get visaK2Name => 'Child of K-1';

  @override
  String get visaK2Desc => 'Unmarried child of K-1 applicant';

  @override
  String get visaL1Name => 'Intracompany Transfer';

  @override
  String get visaL1Desc => 'Managers and executives transferred within company';

  @override
  String get visaM1Name => 'Vocational Student';

  @override
  String get visaM1Desc => 'Vocational or technical training programs';

  @override
  String get visaO1Name => 'Extraordinary Ability';

  @override
  String get visaO1Desc =>
      'Individuals with extraordinary ability in sciences, arts, etc.';

  @override
  String get visaP1Name => 'Athlete/Entertainer';

  @override
  String get visaP1Desc =>
      'Internationally recognized athletes or entertainers';

  @override
  String get visaQ1Name => 'Cultural Exchange';

  @override
  String get visaQ1Desc => 'International cultural exchange programs';

  @override
  String get visaR1Name => 'Religious Worker';

  @override
  String get visaR1Desc => 'Religious workers in religious capacity';

  @override
  String get visaTNName => 'NAFTA Professional';

  @override
  String get visaTNDesc => 'Canadian/Mexican professionals under USMCA';

  @override
  String get visaF2AName => 'Second Preference 2A';

  @override
  String get visaF2ADesc => 'Spouse and minor children of LPR';

  @override
  String get visaF2BName => 'Second Preference 2B';

  @override
  String get visaF2BDesc => 'Unmarried adult children of LPR';

  @override
  String get visaF3Name => 'Third Preference Family';

  @override
  String get visaF3Desc => 'Married adult children of US citizens';

  @override
  String get visaF4Name => 'Fourth Preference Family';

  @override
  String get visaF4Desc => 'Siblings of adult US citizens';

  @override
  String get runAudit => 'Run Audit';

  @override
  String get edit => 'Edit';

  @override
  String get addProfile => 'Add Profile';

  @override
  String get selectPlatform => 'Please select a platform';

  @override
  String get learnMore => 'Learn More';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get biometrics => 'Biometrics';

  @override
  String get biometricsEnabled => 'Biometrics enabled';

  @override
  String get biometricsDisabled => 'Biometrics disabled';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get noFormData => 'No form data';

  @override
  String get noDocuments => 'No documents';

  @override
  String get scannedPassport => 'Scanned Passport';

  @override
  String get noPracticeSessions => 'No practice sessions';

  @override
  String get startSimulation => 'Start Simulation';

  @override
  String get currentScore => 'Current Score';

  @override
  String get changePassword => 'Change Password';

  @override
  String recoveryLinkWillBeSent(Object email) {
    return 'A recovery link will be sent to:\n$email';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String linkSentTo(Object email) {
    return 'Link sent to $email';
  }

  @override
  String get send => 'Send';

  @override
  String get languageChangeRequiresRestart =>
      'Language change requires restart';

  @override
  String get openingTerms => 'Opening terms...';

  @override
  String get openingPrivacy => 'Opening privacy policy...';

  @override
  String get emailCopied => 'Email copied';

  @override
  String get loading => 'Loading...';

  @override
  String get formDS2019Name => 'Certificate of Eligibility';

  @override
  String get formDS2019Help =>
      'Issued by your program sponsor (e.g. Au Pair agency).';

  @override
  String get formI129SName => 'Blanket L Petition';

  @override
  String get formI129SHelp => 'Required for Blanket L applications.';

  @override
  String get formI20Name => 'Certificate of Eligibility';

  @override
  String get formI20HelpAcademic => 'Issued by your school after acceptance.';

  @override
  String get formI20HelpVocational =>
      'Issued by your vocational school after acceptance.';

  @override
  String get formI797Name => 'Notice of Action (Approval)';

  @override
  String get formI797Help => 'Approval notice from USCIS (I-797A or I-797B).';

  @override
  String get issuedByProgramSponsor => 'Program Sponsor';

  @override
  String get issuedByEmployer => 'Employer';

  @override
  String get issuedByDHSSEVPSchool => 'DHS/SEVP School';

  @override
  String get planDiyTitle => 'US Visa Strategy Review (DIY)';

  @override
  String get planDiyDesc =>
      'Comprehensive analysis and VisaScore™ report. Best for self-starters.';

  @override
  String get planFullTitle => 'US Visa Full Service';

  @override
  String get planFullDesc =>
      'Complete application management and priority review.';

  @override
  String get planSimulatorTitle => 'AI Interview Simulator';

  @override
  String get planSimulatorDesc =>
      '30 Days of unlimited practice with our AI Officer.';

  @override
  String get featureAIRiskAssessment => 'AI Risk Assessment';

  @override
  String get featureVisaScoreReport => 'VisaScore™ Report';

  @override
  String get featureDocumentChecklist => 'Document Checklist';

  @override
  String get featureEmailSupport => 'Email Support';

  @override
  String get featureEverythingInDIY => 'Everything in DIY';

  @override
  String get featureDS160AutoFill => 'DS-160 Auto-Fill';

  @override
  String get featureInterviewPrepGuide => 'Interview Prep Guide';

  @override
  String get featurePrioritySupport => 'Priority Support';

  @override
  String get featureMoneyBackGuarantee => 'Money-Back Guarantee';

  @override
  String get featureUnlimitedPracticeSessions => 'Unlimited Practice Sessions';

  @override
  String get featureRealConsulScenarios => 'Real Consul Scenarios';

  @override
  String get featurePerformanceAnalytics => 'Performance Analytics';

  @override
  String get featureWeaknessAnalysis => 'Weakness Analysis';

  @override
  String get restrictionTotalBan => 'Total Ban';

  @override
  String get restrictionPartialBan => 'Partial Restriction';

  @override
  String get restrictionEnhancedVetting => 'Enhanced Vetting';

  @override
  String get restrictionCompleteEntryProhibition =>
      'Complete entry prohibition';

  @override
  String get splashDisclaimer => 'Non-government service provider';

  @override
  String get profileIncomplete =>
      'Profile incomplete. Please scan your passport first.';

  @override
  String get digitalFile => 'Digital File';

  @override
  String get ds160Responses => 'DS-160 Responses';

  @override
  String fieldsCount(int count) {
    return '$count fields';
  }

  @override
  String get noData => 'No data';

  @override
  String get myDocuments => 'My Documents';

  @override
  String documentCount(int count) {
    return '$count Document';
  }

  @override
  String get simulatorHistory => 'Simulation History';

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get noSessions => 'No sessions';

  @override
  String get accountSection => 'Account';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get securitySection => 'Security';

  @override
  String get updateAccess => 'Update access';

  @override
  String get biometricsLabel => 'Biometrics';

  @override
  String get activated => 'Enabled';

  @override
  String get deactivated => 'Disabled';

  @override
  String get legal => 'Legal';

  @override
  String get termsAndPrivacy => 'Terms and privacy';

  @override
  String get verified => 'VERIFIED';

  @override
  String get passport => 'PASSPORT';

  @override
  String get nationality => 'NATIONALITY';

  @override
  String get birthDate => 'BIRTH DATE';

  @override
  String get ds160Data => 'DS-160 Data';

  @override
  String get socialMediaProfiles => 'Social Media Profiles';

  @override
  String get socialMediaDisclaimer =>
      'DS-160 requires disclosure of social media accounts used in the last 5 years.';

  @override
  String get addSocialProfile => 'Add Social Media Profile';

  @override
  String get platform => 'Platform';

  @override
  String get profileUrl => 'Profile URL';

  @override
  String get usernameOptional => 'Username (optional)';

  @override
  String get enterValidUrl => 'Enter a valid URL';

  @override
  String get discrepanciesDetected => 'Discrepancies Detected';

  @override
  String get pending => 'Pending';

  @override
  String get mismatch => 'Mismatch';

  @override
  String get alert => 'Alert';

  @override
  String get delete => 'Delete';

  @override
  String suggestedWaiver(String waiver) {
    return 'Suggested Waiver: $waiver';
  }

  @override
  String get detectedFrom => 'Detected from: ';

  @override
  String get iUnderstand => 'I Understand';

  @override
  String get detectedIssue => 'Detected Issue';

  @override
  String get profileUrlRequired => 'Profile URL is required';

  @override
  String get employmentHistoryMismatch =>
      'Employment history does not match DS-160 declaration';

  @override
  String sessionNumber(int number) {
    return 'Session $number';
  }

  @override
  String get accountInfo => 'Account Information';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get notRegistered => 'Not registered';

  @override
  String get role => 'Role';

  @override
  String passwordResetSent(String email) {
    return 'Link sent to $email';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String passwordResetDialogContent(String email) {
    return 'A recovery link will be sent to:\n$email';
  }

  @override
  String get legalDocuments => 'Legal Documents';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get viewDocument => 'View document';

  @override
  String get spanishLanguage => '🇪🇸  Español';

  @override
  String get englishLanguage => '🇺🇸  English';

  @override
  String get roundTrip => 'Round Trip';

  @override
  String get oneWay => 'One Way';

  @override
  String get flightCostEstimate => 'Flight Cost Estimate';

  @override
  String get includesHotelCosts => 'Includes average hotel costs for 2 nights';

  @override
  String get sevisFeeIncluded => 'SEVIS Fee Included';

  @override
  String get j1SevisFee => 'J-1 SEVIS: USD 220';

  @override
  String get fmSevisFee => 'F/M SEVIS: USD 350';

  @override
  String get mrvFeeLabel => 'MRV Fee';

  @override
  String get integrityFeeLabel => 'Integrity';

  @override
  String get sevisFeeLabel => 'SEVIS';

  @override
  String get i94LandFeeLabel => 'I-94 Land';

  @override
  String get understandingVisaFees => 'Understanding Visa Fees (2026)';

  @override
  String get mrvFeeInfoTitle => 'MRV Fee (Non-refundable)';

  @override
  String get mrvFeeInfoDescription =>
      'The Machine Readable Visa fee is paid when scheduling your interview. It varies by visa category.';

  @override
  String get integrityFeeInfoTitle => 'Visa Integrity Fee (NEW)';

  @override
  String get integrityFeeInfoDescription =>
      'A new USD 250 fee implemented in 2026 for most non-immigrant visas.';

  @override
  String get sevisFeeInfoTitle => 'SEVIS I-901 Fee';

  @override
  String get sevisFeeInfoDescription =>
      'Required for students and exchange visitors. Pay at fmjfee.com BEFORE your interview.';

  @override
  String get i94FeeInfoTitle => 'I-94 Land Border Fee';

  @override
  String get i94FeeInfoDescription =>
      'Increased from USD 6 to USD 24 in 2026. Only applies if entering the US by land.';

  @override
  String get guestLabel => 'Guest';

  @override
  String get notAvailableAndDash => '---';

  @override
  String get notAvailableShort => 'N/A';

  @override
  String get supportEmail => 'support@usavpc.org';

  @override
  String get languageLabel => 'ES / EN';

  @override
  String get formLabel => 'Form';

  @override
  String get errorCriticalNoQuestions =>
      'CRITICAL ERROR: No Questions found in Database (0). Seeding required.';

  @override
  String get errorNoQuestionsAvailable =>
      'CRITICAL: No questions available to render.';

  @override
  String errorDbAuth(Object error) {
    return 'DB Auth Error: Maybe RLS? $error';
  }

  @override
  String get errorMissingQuestionText => 'Error: Missing Question Text';

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get noStepsAvailable => 'No steps available.';

  @override
  String get sexLabel => 'Sex';

  @override
  String get expiryDateLabel => 'Expiry Date';

  @override
  String get errorDatabaseUnique =>
      'Database Error: Unique constraint missing. Fixed in logic.';

  @override
  String get uploadFormatInfo => 'PNG, JPG or PDF (max. 800x400px)';

  @override
  String get orSeparator => 'OR';

  @override
  String get scanIncompleteError =>
      '❌ Scan incomplete. Please rescan passport clearly.';

  @override
  String get subscriptionTitle => 'Premium Access';

  @override
  String get subscriptionSubtitle => 'Unlock all services';

  @override
  String get planMonthly => 'Monthly Plan';

  @override
  String get planYearly => 'Yearly Plan';

  @override
  String get priceMonthly => '\$100/mo';

  @override
  String get priceYearly => '\$250/yr';

  @override
  String get bestValue => 'Best Value';

  @override
  String get selectPlan => 'Select Plan';

  @override
  String get home => 'Home';

  @override
  String get services => 'Services';

  @override
  String get profile => 'Profile';

  @override
  String get ds260IntakeTitle => 'DS-260 INTAKE';
}
