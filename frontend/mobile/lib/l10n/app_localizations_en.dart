// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OctoSense';

  @override
  String get dashboardTitle => 'Your body right now';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get yourOctoSense => 'Your OctoSense';

  @override
  String get settingsSubtitle =>
      'Account, devices, accessibility, privacy, and help.';

  @override
  String get account => 'My account';

  @override
  String get accountSubtitle =>
      'Profile, sign-in, sign-out, and account deletion';

  @override
  String get devicesSources => 'Devices and sources';

  @override
  String get devicesSubtitle => 'Watches, platforms, and synchronization';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get accessibilitySubtitle =>
      'Text, contrast, motion, and interface readability';

  @override
  String get privacy => 'Privacy and data';

  @override
  String get privacySubtitle =>
      'Permissions, retention, and control of your data';

  @override
  String get help => 'Help';

  @override
  String get helpSubtitle => 'How to use, connect, and understand OctoSense';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'Many signals. One body.';

  @override
  String get back => 'Back';

  @override
  String get add => 'Add';

  @override
  String get addWatch => 'Add watch';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get removeDevice => 'Remove device';

  @override
  String get confirmRemoveDevice => 'Remove device?';

  @override
  String get noRealDevices => 'No connected device';

  @override
  String get addSourcesHint =>
      'Add sources to preview how OctoSense will manage multiple wearables.';

  @override
  String get myDevices => 'My devices';

  @override
  String get howItWorks => 'How it works';

  @override
  String get deviceVsSource => 'Device ≠ source';

  @override
  String get multipleDevices => 'Multiple devices';

  @override
  String get withoutDuplicates => 'Without duplicate data';

  @override
  String get healthConnect => 'Health Connect';

  @override
  String get authorizeHealthConnect => 'Authorize Health Connect';

  @override
  String get disableHealthConnect => 'Disable Health Connect';

  @override
  String get disableHealthConnectQuestion => 'Disable Health Connect?';

  @override
  String get openSettings => 'Open settings';

  @override
  String get healthConnectAuthorized =>
      'Health Connect authorized successfully.';

  @override
  String get healthConnectUnavailable => 'Health Connect unavailable';

  @override
  String get androidHealthConnectPath => 'Android Settings → Health Connect.';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceHint => 'Choose how OctoSense should look.';

  @override
  String get textSize => 'Text size';

  @override
  String get textSizeHint =>
      'Your chosen size is applied throughout OctoSense.';

  @override
  String get standard => 'Standard';

  @override
  String get large => 'Large';

  @override
  String get extraLarge => 'Extra large';

  @override
  String get system => 'Follow system';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get highContrast => 'Enhanced contrast';

  @override
  String get highContrastSubtitle =>
      'Increases visual separation between interface elements.';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionSubtitle =>
      'Tells the app to reduce non-essential motion.';

  @override
  String get preview => 'Preview';

  @override
  String get previewText => 'This text changes with your preference.';

  @override
  String get screenReaders => 'Screen readers';

  @override
  String get informationBeyondColors => 'Information beyond color';

  @override
  String get activeSession => 'Active session';

  @override
  String get noSession => 'No session';

  @override
  String get noLinkedAccount => 'No linked account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutSubtitle => 'Return to the sign-in screen.';

  @override
  String get signOutQuestion => 'Sign out of your account?';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountQuestion => 'Delete account permanently?';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get deleteAccountWarning =>
      'Permanently deletes your account and all data. This action cannot be undone.';

  @override
  String get exploreDemo => 'Explore OctoSense';

  @override
  String get learn => 'Learn';

  @override
  String get trends => 'Trends';

  @override
  String get today => 'Today';

  @override
  String get now => 'Now';

  @override
  String get nowNot => 'Not now';

  @override
  String get start => 'Start';

  @override
  String get continueLabel => 'Continue';

  @override
  String get science => 'Science';

  @override
  String get learnAtYourPace => 'Learn at your own pace';

  @override
  String get understandSignals => 'Understand your signals';

  @override
  String get bodyToInformation => 'From body to information';

  @override
  String get biologyChemistryPhysiology => 'Biology, Chemistry, and physiology';

  @override
  String get energyMetabolism => 'Energy and metabolism';

  @override
  String get hemoglobinOxygen => 'Hemoglobin and oxygen';

  @override
  String get accelerometer => 'Accelerometer';

  @override
  String get heartRate => 'Heart rate';

  @override
  String get heartRateShort => 'Heart rate';

  @override
  String get calories => 'Calories';

  @override
  String get days7 => '7 days';

  @override
  String get days30 => '30 days';

  @override
  String get days90 => '90 days';

  @override
  String get addSourceHint =>
      'Choose your model. OctoSense reads data from Health Connect on your phone.';

  @override
  String get recommended => 'Recommended — any Android watch';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get android => 'Android';

  @override
  String get removeDemoHint =>
      'will be removed from the connected-device list. No data will be deleted.';

  @override
  String get prototypeLocal => 'Connected device';

  @override
  String get googleHealthToday => 'Google Health · today';

  @override
  String get healthConnectToday => 'Health Connect · today';

  @override
  String errorRequestPermission(Object error) {
    return 'Error requesting permission: $error';
  }

  @override
  String errorDeleteAccount(Object error) {
    return 'Error deleting account: $error';
  }

  @override
  String get settingsHeading => 'SETTINGS';

  @override
  String get settingsHeadingEn => 'SETTINGS';

  @override
  String get accountManagement => 'Manage your OctoSense account.';

  @override
  String get signOutPrompt =>
      'You will return to the sign-in screen. Tokens will be removed from this device.';

  @override
  String get deleteAccountPrompt =>
      'This deletes your account, all readings, and disconnects you from all devices. This cannot be undone.\n\nAre you sure?';

  @override
  String get signOutOfAccount => 'Sign out of your account?';

  @override
  String get signOutDescription => 'Return to the sign-in screen.';

  @override
  String get deleteAccountDescription =>
      'Permanently deletes your account and all data. This action cannot be undone.';

  @override
  String get addWatchDescription =>
      'Choose your model. OctoSense reads data from Health Connect on your phone.';

  @override
  String get myDevicesDescription =>
      'Add sources to preview how OctoSense will manage multiple wearables.';

  @override
  String get howSourcesWork =>
      'Manage where the signals used by OctoSense come from.';

  @override
  String get noRealDeviceTitle => 'No real devices';

  @override
  String get howSourcesWorkTitle => 'How it works';

  @override
  String get deviceVsSourceText =>
      'A Galaxy Watch is a physical device. Health Connect or Samsung Health can be the source through which data reaches OctoSense.';

  @override
  String get multipleDevicesText =>
      'A user may have multiple wearables. Each reading keeps its source, device, and measurement time.';

  @override
  String get withoutDuplicatesText =>
      'When the backend is implemented, repeated readings from different sources will need to be identified and deduplicated before storage.';

  @override
  String get appearanceDescription => 'Choose how OctoSense should look.';

  @override
  String get textSizeDescription =>
      'Your chosen size is applied throughout OctoSense.';

  @override
  String get readersText =>
      'OctoSense uses Flutter semantic components and will continue adding specific descriptions for charts, metrics, and controls.';

  @override
  String get beyondColorsText =>
      'Important information should not rely on color alone. Text, icons, and descriptions also communicate state.';

  @override
  String get signalBehindNumber => 'The signal behind the number';

  @override
  String get learnDescription =>
      'Understand how the body, sensors, and science connect to OctoSense data.';

  @override
  String get overview => 'Overview';

  @override
  String get overviewSubtitle => 'From body to information';

  @override
  String get sensors => 'Sensors';

  @override
  String get sensorsSubtitle => 'PPG, motion, SpO₂, and wearables';

  @override
  String get scienceSubtitle => 'Biology, Chemistry, and physiology';

  @override
  String get learnHeroTitle => 'Learn at your own pace';

  @override
  String get learnHeroSubtitle =>
      'Choose a topic to better understand your signals.';

  @override
  String get periodAnalysis => 'Period analysis';

  @override
  String get seeWhatChanged => 'See what changed';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noHeartRateMeasurements =>
      'No heart-rate measurements in this period.';

  @override
  String get heartRateChartTitle => 'Heart rate';

  @override
  String get frequency => 'Heart rate';

  @override
  String get steps => 'Steps';

  @override
  String get sleep => 'Sleep';

  @override
  String get activeCalories => 'Active calories';

  @override
  String get noMeasurement => 'No measurement';

  @override
  String get noRecord => 'No record';

  @override
  String get whyHeartAccelerates => 'Why does the heart speed up?';

  @override
  String get understandSignal => 'Understand the signal';

  @override
  String get exerciseHeartText =>
      'During exercise, the body increases cardiac output to transport more oxygen to tissues.';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String unexpectedError(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String get authorizeNow => 'Authorize now';

  @override
  String get notNow => 'Not now';

  @override
  String get skip => 'Skip';

  @override
  String get waitingGoogle => 'Waiting for Google';

  @override
  String get googleConsentError => 'Could not start Google consent.';

  @override
  String get googleBrowserError => 'Could not open the browser for Google.';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the interface language.';

  @override
  String get languageSystem => 'System';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get healthConnectDisableInstruction =>
      'Revoke OctoSense permission in Settings.';

  @override
  String get healthConnectSettingsError =>
      'Could not open Health Connect settings.';

  @override
  String get markRead => 'Mark as read';

  @override
  String get read => 'Read';

  @override
  String get listen => 'Listen';

  @override
  String get privacyDescription => 'You should know what is collected and why.';

  @override
  String get dataMinimization => 'Data minimization';

  @override
  String get dataMinimizationText =>
      'OctoSense should collect only what is necessary for each stated purpose.';

  @override
  String get realData => 'Real data';

  @override
  String get realDataText =>
      'The public Showcase will not use real participant data.';

  @override
  String get userControl => 'User control';

  @override
  String get userControlText =>
      'Permissions, retention, and deletion will be handled explicitly when the real-wearable pilot is implemented.';

  @override
  String get helpDescription => 'Quick answers for using OctoSense.';

  @override
  String get howToStart => 'How do I get started?';

  @override
  String get howToStartText =>
      'OctoSense reads authorized measurements from Health Connect and organizes them into clear views.';

  @override
  String get howToConnectWatch => 'How do I connect a watch?';

  @override
  String get howToConnectWatchText =>
      'In Devices, authorize Health Connect. Then use your watch normally and follow the metrics that arrive.';

  @override
  String get whereNumbersComeFrom => 'Where do the numbers come from?';

  @override
  String get whereNumbersComeFromText =>
      'Steps, heart rate, sleep and calories come from Health Connect using the sources authorized on the device.';

  @override
  String get diagnosisQuestion => 'Does OctoSense diagnose conditions?';

  @override
  String get diagnosisText =>
      'No. A reading is an estimate and does not replace clinical evaluation.';

  @override
  String get aboutTitle => 'About OctoSense';

  @override
  String get projectInfo =>
      'A product for tracking health signals and understanding wearable data.';

  @override
  String get currentVersion => 'Current version';

  @override
  String get versionText => 'Version 0.9.0 — OctoSense for Android.';

  @override
  String get important => 'Important';

  @override
  String get medicalWarning =>
      'OctoSense is not a medical device and does not diagnose conditions.';

  @override
  String get topic1Title => 'Vital signs and context';

  @override
  String get topic1P1 =>
      'The body continuously produces signals such as heart rate, movement, sleep, and energy expenditure.';

  @override
  String get topic1P2 =>
      'A single number represents only one moment and needs context to be understood.';

  @override
  String get topic1P3 =>
      'Looking at changes over time can reveal natural patterns in the body.';

  @override
  String get topic1P4 =>
      'OctoSense organizes these readings to make them easier to understand and does not turn a reading into a diagnosis.';

  @override
  String get topic2Title => 'Heart rate';

  @override
  String get topic2P1 =>
      'The heart pumps blood to distribute oxygen and nutrients throughout the body.';

  @override
  String get topic2P2 =>
      'Heart rate can change with exercise, rest, emotions, temperature, and other factors.';

  @override
  String get topic2P3 =>
      'Watches estimate heart rate from signals captured at the skin.';

  @override
  String get topic2P4 =>
      'Comparing different periods and situations helps explain why the number changes.';

  @override
  String get topic3Title => 'Sleep and recovery';

  @override
  String get topic3P1 =>
      'During sleep, the body cycles through different stages with important roles in recovery.';

  @override
  String get topic3P2 =>
      'Wearables use movement and other signals to estimate sleep periods.';

  @override
  String get topic3P3 =>
      'These estimates do not replace specialized sleep testing.';

  @override
  String get topic3P4 =>
      'Regularity, duration, and context are more informative than a single night.';

  @override
  String get topic4Title => 'Steps and movement';

  @override
  String get topic4P1 =>
      'Step count is a simple way to represent movement throughout the day.';

  @override
  String get topic4P2 =>
      'Accelerometers detect changes in motion across multiple axes.';

  @override
  String get topic4P3 =>
      'Algorithms filter these signals to estimate events consistent with steps.';

  @override
  String get topic4P4 =>
      'The result is an estimate and can vary with the device and walking pattern.';

  @override
  String get topic5Title => 'PPG and light';

  @override
  String get topic5P1 =>
      'PPG stands for photoplethysmography and uses light to observe blood-volume changes near the skin.';

  @override
  String get topic5P2 =>
      'LEDs illuminate the skin while a sensor measures reflected or received light.';

  @override
  String get topic5P3 =>
      'The light pattern changes with each heartbeat and can be processed to estimate heart rate.';

  @override
  String get topic5P4 =>
      'Motion, strap fit, and skin characteristics can affect the signal.';

  @override
  String get topic6Title => 'Accelerometer';

  @override
  String get topic6P1 =>
      'An accelerometer measures acceleration across different axes.';

  @override
  String get topic6P2 =>
      'In a watch, it can detect changes associated with steps, gestures, and periods of movement.';

  @override
  String get topic6P3 =>
      'The sensor does not know what a person is doing by itself: algorithms interpret the patterns.';

  @override
  String get topic6P4 =>
      'Different activities can produce similar signals and may require additional context.';

  @override
  String get topic7Title => 'Oxygen saturation and SpO₂';

  @override
  String get topic7P1 =>
      'Peripheral oxygen saturation, known as SpO₂, estimates the proportion of hemoglobin bound to oxygen.';

  @override
  String get topic7P2 =>
      'Optical sensors use differences in light absorption to estimate that proportion.';

  @override
  String get topic7P3 =>
      'The result depends on signal quality and measurement conditions.';

  @override
  String get topic7P4 =>
      'A wearable reading should be understood as an estimate, not a clinical diagnosis.';

  @override
  String get topic8Title => 'Hemoglobin and oxygen';

  @override
  String get topic8P1 => 'Hemoglobin is a protein found in red blood cells.';

  @override
  String get topic8P2 =>
      'It can bind reversibly to oxygen and transport it through the body.';

  @override
  String get topic8P3 =>
      'The relationship Hb + O₂ ⇌ HbO₂ represents this reversible transport.';

  @override
  String get topic8P4 =>
      'This process connects chemistry, biology, and physiology in one phenomenon.';

  @override
  String get topic9Title => 'Energy and metabolism';

  @override
  String get topic9P1 =>
      'Cells need energy continuously to maintain their functions.';

  @override
  String get topic9P2 =>
      'Metabolism includes chemical reactions that transform nutrients and support cellular processes.';

  @override
  String get topic9P3 =>
      'During physical activity, energy demand increases and the body adjusts several systems.';

  @override
  String get topic9P4 =>
      'Wearables can estimate energy expenditure using signals and models, but they do not directly measure every metabolic reaction.';

  @override
  String get topic10Title => 'Cardiovascular system';

  @override
  String get topic10P1 =>
      'The cardiovascular system integrates the heart, blood, and blood vessels.';

  @override
  String get topic10P2 =>
      'It distributes oxygen, nutrients, hormones, and heat while removing metabolic products.';

  @override
  String get topic10P3 =>
      'Exercise increases muscle demand and triggers coordinated cardiovascular responses.';

  @override
  String get topic10P4 =>
      'Heart-rate data can help visualize part of this process in accessible language.';

  @override
  String get topic11Title => 'From sensor to data';

  @override
  String get topic11P1 =>
      'The path begins with a physical sensor that turns a body phenomenon into an electrical or optical signal.';

  @override
  String get topic11P2 =>
      'The device processes that signal and applies algorithms to estimate a metric.';

  @override
  String get topic11P3 =>
      'A platform such as Health Connect can organize and share authorized data with apps.';

  @override
  String get topic11P4 =>
      'OctoSense turns these metrics into clear visualizations and explanations.';

  @override
  String get topic12Title => 'How to interpret trends';

  @override
  String get topic12P1 =>
      'A trend looks at changes across a period rather than drawing a conclusion from one value.';

  @override
  String get topic12P2 =>
      'Averages, totals, and time series reduce the focus on a single measurement.';

  @override
  String get topic12P3 =>
      'It is also important to consider incomplete days, routine changes, and device differences.';

  @override
  String get topic12P4 =>
      'Good interpretation combines data, context, and measurement limits.';

  @override
  String get weeklyInsight => 'Weekly insight';

  @override
  String get generatingInsight => 'Generating your insight...';

  @override
  String get feedbackUnavailable =>
      'The insight could not be generated right now.';

  @override
  String get feedbackDisclaimer => 'Summary based on recent measurements.';

  @override
  String get refreshInsight => 'Refresh insight';

  @override
  String get colorVision => 'Color vision';

  @override
  String get colorVisionDescription =>
      'Use an alternative palette to distinguish states without relying on red and green.';

  @override
  String get colorVisionStandard => 'Standard';

  @override
  String get colorVisionAlternative => 'Alternative';

  @override
  String get colorVisionProtanopia => 'Protanopia (red)';

  @override
  String get colorVisionDeuteranopia => 'Deuteranopia (green)';

  @override
  String get colorVisionTritanopia => 'Tritanopia (blue)';

  @override
  String get colorVisionAchromatopsia => 'Achromatopsia (no color)';

  @override
  String get colorVisionAccessibleHint =>
      'Use text and icons together with color. Choose the mode that fits your vision best.';

  @override
  String get librasNote =>
      'VLibras translates digital content to Libras. Automatic translation is support and does not replace a human interpreter.';

  @override
  String get learnIntro => 'Explore. Tap. Rotate. Listen. Learn.';

  @override
  String get learnIntroSubtitle =>
      'A visual lesson about the watch, its sensors, and what happens inside the body.';

  @override
  String get exploreWatch => 'Explore the watch';

  @override
  String get exploreWatchHint => 'Drag to rotate the watch and tap a part.';

  @override
  String get demo => 'Demo';

  @override
  String get dragToRotate => 'Drag to rotate';

  @override
  String get watchFace => 'Display';

  @override
  String get watchSensors => 'Sensors';

  @override
  String get watchBody => 'Body';

  @override
  String get watchPower => 'Power';

  @override
  String get watchFaceText =>
      'The display shows a metric that came from sensors, but the watch does not directly “see” the body.';

  @override
  String get watchSensorsText =>
      'Sensors capture light, motion, and other signals. Algorithms turn those signals into estimates.';

  @override
  String get watchBodyText =>
      'Your pulse, skin, and movement change the measured signal. Context and fit therefore matter.';

  @override
  String get watchPowerText =>
      'The battery powers LEDs, sensors, processing, and communication. More measurements can use more energy.';

  @override
  String get sensorTitle => 'What does each sensor detect?';

  @override
  String get sensorSubtitle =>
      'Move across the sensors to see the signal path.';

  @override
  String get ppg => 'PPG';

  @override
  String get ppgSimple => 'Light → blood → pulse';

  @override
  String get ppgExplain =>
      'LEDs illuminate the skin. The sensor sees light changes linked to blood volume near the wrist.';

  @override
  String get motion => 'Motion';

  @override
  String get motionSimple => 'Acceleration → pattern → steps';

  @override
  String get motionExplain =>
      'The accelerometer measures movement changes across different axes. Algorithms recognize patterns.';

  @override
  String get spo2 => 'SpO₂';

  @override
  String get spo2Simple => 'Light → hemoglobin → estimate';

  @override
  String get spo2Explain =>
      'Light interacts differently with oxygen-bound and unbound hemoglobin. The watch estimates saturation from that signal.';

  @override
  String get scienceLab => 'Body lab';

  @override
  String get scienceLabSubtitle => 'The same watch connects three sciences.';

  @override
  String get biology => 'Biology';

  @override
  String get biologyExplain =>
      'Cells, blood, the heart, and tissues form the system that generates the measured signals.';

  @override
  String get chemistry => 'Chemistry';

  @override
  String get chemistryExplain =>
      'Molecules such as hemoglobin take part in reactions and bonds involved in oxygen transport.';

  @override
  String get physics => 'Physics';

  @override
  String get physicsExplain =>
      'Light, acceleration, energy, and electricity are physical phenomena that sensors turn into signals.';

  @override
  String get signalPath => 'From body to number';

  @override
  String get signalPathSubtitle =>
      'There is no magic: there is a chain of phenomena.';

  @override
  String get stepBody => '1 · Body';

  @override
  String get stepSensor => '2 · Sensor';

  @override
  String get stepAlgorithm => '3 · Algorithm';

  @override
  String get stepApp => '4 · OctoSense';

  @override
  String get stepBodyText =>
      'The heart beats, blood flows, and the body moves.';

  @override
  String get stepSensorText => 'Hardware captures a physical signal.';

  @override
  String get stepAlgorithmText =>
      'Software finds patterns and estimates a metric.';

  @override
  String get stepAppText =>
      'OctoSense organizes the data and explains what it means.';

  @override
  String get topicsTitle => 'Explore more topics';

  @override
  String get topicsSubtitle =>
      'Pick a card. The explanation appears only when you ask for it.';

  @override
  String get explore => 'Explore';

  @override
  String get stopListening => 'Stop';

  @override
  String get completed => 'Completed';

  @override
  String get educationDisclaimer =>
      'A wearable reading is an estimate and can vary with fit, movement and context.';

  @override
  String get signInTitle => 'Your body, made understandable.';

  @override
  String get signInSubtitle =>
      'Connect your account and explore your health signals in one clear view.';

  @override
  String get accountAccessNote =>
      'Your account keeps your preferences and authorized data together.';

  @override
  String get onboarding1Title => 'See the signal';

  @override
  String get onboarding1Text =>
      'Turn wearable measurements into clear views that are easy to explore.';

  @override
  String get onboarding2Title => 'Understand the watch';

  @override
  String get onboarding2Text =>
      'Discover what the sensors capture, what the body is doing, and how a number is formed.';

  @override
  String get onboarding3Title => 'Make it yours';

  @override
  String get onboarding3Text =>
      'Adjust language, text size, contrast, motion, color vision and assistive access.';

  @override
  String get healthConnectTodaySource => 'Health Connect · today';

  @override
  String get connectHealthConnect =>
      'Connect Health Connect to see your measurements.';

  @override
  String daysWithDataLabel(int count) {
    return '$count days with data';
  }

  @override
  String get averagePerDay => 'average/day';

  @override
  String get periodTotal => 'period total';

  @override
  String get sourceHealthConnect => 'Health Connect';

  @override
  String get watchPartPpg => 'Optical sensor (PPG)';

  @override
  String get watchPartMotion => 'Motion sensor';

  @override
  String get watchPartOxygen => 'Blood oxygen sensor';

  @override
  String get watchPartCrown => 'Control';

  @override
  String get watchPartStrap => 'Fit and contact';

  @override
  String get watchPartBack => 'Back sensors';

  @override
  String get watchPartScreen => 'Display';

  @override
  String get watchPartPpgText =>
      'Light reaches the skin and the returning signal changes with blood volume near the wrist.';

  @override
  String get watchPartMotionText =>
      'An accelerometer detects changes in movement across multiple axes.';

  @override
  String get watchPartOxygenText =>
      'Optical measurements can estimate the proportion of hemoglobin carrying oxygen.';

  @override
  String get watchPartCrownText =>
      'A physical control lets the user navigate and interact without relying only on touch.';

  @override
  String get watchPartStrapText =>
      'A stable fit helps the optical sensors maintain a consistent signal at the skin.';

  @override
  String get watchPartBackText =>
      'The underside houses sensors that sit close to the skin and collect body-related signals.';

  @override
  String get watchPartScreenText =>
      'The display presents measurements, context and feedback from the device.';

  @override
  String get wearableStoryTitle => 'A 30-second tour';

  @override
  String get wearableStory1Title => 'Wearable';

  @override
  String get wearableStory1Text =>
      'The watch sits on the wrist and observes signals without opening the body.';

  @override
  String get wearableStory2Title => 'Sensor';

  @override
  String get wearableStory2Text =>
      'Light and motion become electrical data that the device can process.';

  @override
  String get wearableStory3Title => 'Health';

  @override
  String get wearableStory3Text =>
      'The result becomes a metric you can read, compare and understand.';

  @override
  String get challenges => 'Challenges';

  @override
  String get challengesSubtitle =>
      'Play with the same ideas behind your measurements.';

  @override
  String get play => 'Play';

  @override
  String get gameSignalTitle => 'Build the signal';

  @override
  String get gameSignalText => 'Put the four stages in the right order.';

  @override
  String get gameSensorTitle => 'Match the sensor';

  @override
  String get gameSensorText =>
      'Pick the sensor that best fits the measurement.';

  @override
  String get gameBodyTitle => 'Body in motion';

  @override
  String get gameBodyText =>
      'Answer quick questions about physiology and wearable signals.';

  @override
  String get gameCorrect => 'Correct';

  @override
  String get gameTryAgain => 'Try again';

  @override
  String get gameScore => 'Score';

  @override
  String get gameStreak => 'Streak';

  @override
  String get gameNext => 'Next';

  @override
  String get gameFinish => 'Finish';

  @override
  String get gameHint => 'Tap an answer to continue.';

  @override
  String get gameSignalBody => 'Body';

  @override
  String get gameSignalSensor => 'Sensor';

  @override
  String get gameSignalAlgorithm => 'Algorithm';

  @override
  String get gameSignalMetric => 'Metric';

  @override
  String get settingsPremiumTitle => 'Make OctoSense yours';

  @override
  String get settingsPremiumSubtitle =>
      'Appearance, accessibility and data controls in one place.';

  @override
  String get accessibilityBasics => 'Basics';

  @override
  String get accessibilityVisual => 'Visual';

  @override
  String get accessibilityAudio => 'Audio and language';

  @override
  String get accessibilityMotor => 'Motion';

  @override
  String get librasAccess => 'Libras access';

  @override
  String get librasAccessText =>
      'Open the VLibras interpreter for translated digital content.';

  @override
  String get visualColorModes => 'Color vision';

  @override
  String get reduceMotionDetails =>
      'Reduce non-essential motion throughout the app.';

  @override
  String get highContrastDetails =>
      'Increase separation between text, controls and surfaces.';

  @override
  String get screenReaderDetails =>
      'Use headings, labels and state announcements with screen readers.';

  @override
  String get premiumSecurityNote =>
      'Your settings are stored on this device unless a feature says otherwise.';

  @override
  String get healthEstimateNote =>
      'Wearable readings are estimates and can vary with fit, movement and context.';

  @override
  String get aiInsightLabel => 'AI insight';

  @override
  String get aiInsightNote =>
      'Generated from your recent measurements to help you notice patterns.';

  @override
  String get dashboardSourceTitle => 'Live from Health Connect';

  @override
  String get noLiveMeasurements => 'No Health Connect measurements yet.';

  @override
  String get loginExploreApp => 'Explore OctoSense';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the interface language.';

  @override
  String get languageFlagPortuguese => '🇧🇷 Português';

  @override
  String get languageFlagEnglish => '🇺🇸 English';

  @override
  String get languageFlagSpanish => '🇪🇸 Español';

  @override
  String get languageFlagFrench => '🇫🇷 Français';

  @override
  String get languageFlagItalian => '🇮🇹 Italiano';

  @override
  String get languageFlagGerman => '🇩🇪 Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get gameQSensorOptical =>
      'Which sensor uses light to observe changes near the wrist?';

  @override
  String get gameQSensorMotion =>
      'Which sensor detects acceleration and movement?';

  @override
  String get gameQSensorOxygen =>
      'Which metric estimates oxygen bound to hemoglobin?';

  @override
  String get gameQHeart => 'What can raise heart rate during activity?';

  @override
  String get gameOptExercise => 'Exercise and effort';

  @override
  String get gameOptSleep => 'Only during sleep';

  @override
  String get gameOptColor => 'The watch color';

  @override
  String get gamePlayAgain => 'Play again';

  @override
  String get privacyWhatWeCollect => 'What we collect';

  @override
  String get privacyWhatWeCollectText =>
      'Steps, heart rate, active calories, sleep and oxygen — read from your phone\'s Health Connect and optionally from Google Health.';

  @override
  String get privacyWhereItStays => 'Where your data lives';

  @override
  String get privacyWhereItStaysText =>
      'On a self-hosted OctoSense server, protected by HTTPS and JWT authentication. No data is sold or shared with third parties.';

  @override
  String get privacyWhoCanSee => 'Who can see it';

  @override
  String get privacyWhoCanSeeText =>
      'Only you. Every reading is tied to your Google account and never accessible by another user.';

  @override
  String get privacyHowLong => 'How long we keep it';

  @override
  String get privacyHowLongText =>
      'As long as your account exists. No hidden retention — you can erase everything at any time.';

  @override
  String get privacyYourRights => 'Your rights';

  @override
  String get privacyYourRightsText =>
      'Access, correction, portability and deletion of your data. Requested directly in the app, no bureaucracy.';

  @override
  String get privacyDelete => 'Delete account';

  @override
  String get privacyDeleteText =>
      'In Settings → My account, the Delete button permanently removes your account, readings and access tokens.';

  @override
  String get privacyContact => 'Questions';

  @override
  String get privacyContactText =>
      'Reach the OctoSense team at the email shown on the About screen.';
}
