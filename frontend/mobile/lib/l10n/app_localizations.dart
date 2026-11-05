import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'OctoSense'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu corpo agora'**
  String get dashboardTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @yourOctoSense.
  ///
  /// In pt, this message translates to:
  /// **'Seu OctoSense'**
  String get yourOctoSense;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta, dispositivos, acessibilidade, privacidade e ajuda.'**
  String get settingsSubtitle;

  /// No description provided for @account.
  ///
  /// In pt, this message translates to:
  /// **'Minha conta'**
  String get account;

  /// No description provided for @accountSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil, autenticação, sair e excluir conta'**
  String get accountSubtitle;

  /// No description provided for @devicesSources.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivos e fontes'**
  String get devicesSources;

  /// No description provided for @devicesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Relógios, plataformas e sincronização'**
  String get devicesSubtitle;

  /// No description provided for @accessibility.
  ///
  /// In pt, this message translates to:
  /// **'Acessibilidade'**
  String get accessibility;

  /// No description provided for @accessibilitySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Texto, contraste, movimento e leitura da interface'**
  String get accessibilitySubtitle;

  /// No description provided for @privacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e dados'**
  String get privacy;

  /// No description provided for @privacySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Permissões, retenção e controle dos seus dados'**
  String get privacySubtitle;

  /// No description provided for @help.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get help;

  /// No description provided for @helpSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Como usar, conectar e entender o OctoSense'**
  String get helpSubtitle;

  /// No description provided for @about.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Muitos sinais. Um só corpo.'**
  String get aboutSubtitle;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @addWatch.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar relógio'**
  String get addWatch;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get remove;

  /// No description provided for @removeDevice.
  ///
  /// In pt, this message translates to:
  /// **'Remover dispositivo'**
  String get removeDevice;

  /// No description provided for @confirmRemoveDevice.
  ///
  /// In pt, this message translates to:
  /// **'Remover dispositivo?'**
  String get confirmRemoveDevice;

  /// No description provided for @noRealDevices.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dispositivo conectado'**
  String get noRealDevices;

  /// No description provided for @addSourcesHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicione fontes para visualizar como o OctoSense gerenciará vários wearables.'**
  String get addSourcesHint;

  /// No description provided for @myDevices.
  ///
  /// In pt, this message translates to:
  /// **'Meus dispositivos'**
  String get myDevices;

  /// No description provided for @howItWorks.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona'**
  String get howItWorks;

  /// No description provided for @deviceVsSource.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivo ≠ fonte'**
  String get deviceVsSource;

  /// No description provided for @multipleDevices.
  ///
  /// In pt, this message translates to:
  /// **'Vários dispositivos'**
  String get multipleDevices;

  /// No description provided for @withoutDuplicates.
  ///
  /// In pt, this message translates to:
  /// **'Sem duplicar dados'**
  String get withoutDuplicates;

  /// No description provided for @healthConnect.
  ///
  /// In pt, this message translates to:
  /// **'Health Connect'**
  String get healthConnect;

  /// No description provided for @authorizeHealthConnect.
  ///
  /// In pt, this message translates to:
  /// **'Autorizar Health Connect'**
  String get authorizeHealthConnect;

  /// No description provided for @disableHealthConnect.
  ///
  /// In pt, this message translates to:
  /// **'Desativar Health Connect'**
  String get disableHealthConnect;

  /// No description provided for @disableHealthConnectQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Desativar Health Connect?'**
  String get disableHealthConnectQuestion;

  /// No description provided for @openSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get openSettings;

  /// No description provided for @healthConnectAuthorized.
  ///
  /// In pt, this message translates to:
  /// **'Health Connect autorizado com sucesso.'**
  String get healthConnectAuthorized;

  /// No description provided for @healthConnectUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Health Connect indisponível'**
  String get healthConnectUnavailable;

  /// No description provided for @androidHealthConnectPath.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes do Android → Health Connect.'**
  String get androidHealthConnectPath;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @appearanceHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha como o OctoSense deve aparecer.'**
  String get appearanceHint;

  /// No description provided for @textSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho do texto'**
  String get textSize;

  /// No description provided for @textSizeHint.
  ///
  /// In pt, this message translates to:
  /// **'O tamanho escolhido é aplicado em todo o OctoSense.'**
  String get textSizeHint;

  /// No description provided for @standard.
  ///
  /// In pt, this message translates to:
  /// **'Padrão'**
  String get standard;

  /// No description provided for @large.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get large;

  /// No description provided for @extraLarge.
  ///
  /// In pt, this message translates to:
  /// **'Muito grande'**
  String get extraLarge;

  /// No description provided for @system.
  ///
  /// In pt, this message translates to:
  /// **'Seguir sistema'**
  String get system;

  /// No description provided for @light.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get dark;

  /// No description provided for @highContrast.
  ///
  /// In pt, this message translates to:
  /// **'Contraste reforçado'**
  String get highContrast;

  /// No description provided for @highContrastSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aumenta a separação visual entre elementos da interface.'**
  String get highContrastSubtitle;

  /// No description provided for @reduceMotion.
  ///
  /// In pt, this message translates to:
  /// **'Reduzir animações'**
  String get reduceMotion;

  /// No description provided for @reduceMotionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Informa ao aplicativo que movimentos não essenciais devem ser reduzidos.'**
  String get reduceMotionSubtitle;

  /// No description provided for @preview.
  ///
  /// In pt, this message translates to:
  /// **'Prévia'**
  String get preview;

  /// No description provided for @previewText.
  ///
  /// In pt, this message translates to:
  /// **'Este texto muda junto com sua preferência.'**
  String get previewText;

  /// No description provided for @screenReaders.
  ///
  /// In pt, this message translates to:
  /// **'Leitores de tela'**
  String get screenReaders;

  /// No description provided for @informationBeyondColors.
  ///
  /// In pt, this message translates to:
  /// **'Informação além das cores'**
  String get informationBeyondColors;

  /// No description provided for @activeSession.
  ///
  /// In pt, this message translates to:
  /// **'Sessão ativa'**
  String get activeSession;

  /// No description provided for @noSession.
  ///
  /// In pt, this message translates to:
  /// **'Sem sessão'**
  String get noSession;

  /// No description provided for @noLinkedAccount.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta vinculada'**
  String get noLinkedAccount;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @signOutSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para a tela de entrada.'**
  String get signOutSubtitle;

  /// No description provided for @signOutQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta?'**
  String get signOutQuestion;

  /// No description provided for @deleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get deleteAccount;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta permanentemente?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteEverything.
  ///
  /// In pt, this message translates to:
  /// **'Excluir tudo'**
  String get deleteEverything;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In pt, this message translates to:
  /// **'Apaga permanentemente sua conta e todos os dados. Esta ação não pode ser desfeita.'**
  String get deleteAccountWarning;

  /// No description provided for @exploreDemo.
  ///
  /// In pt, this message translates to:
  /// **'Explorar OctoSense'**
  String get exploreDemo;

  /// No description provided for @learn.
  ///
  /// In pt, this message translates to:
  /// **'Aprender'**
  String get learn;

  /// No description provided for @trends.
  ///
  /// In pt, this message translates to:
  /// **'Tendências'**
  String get trends;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @now.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get now;

  /// No description provided for @nowNot.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get nowNot;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @continueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @science.
  ///
  /// In pt, this message translates to:
  /// **'Ciência'**
  String get science;

  /// No description provided for @learnAtYourPace.
  ///
  /// In pt, this message translates to:
  /// **'Aprenda no seu ritmo'**
  String get learnAtYourPace;

  /// No description provided for @understandSignals.
  ///
  /// In pt, this message translates to:
  /// **'Entenda seus sinais'**
  String get understandSignals;

  /// No description provided for @bodyToInformation.
  ///
  /// In pt, this message translates to:
  /// **'Do corpo até a informação'**
  String get bodyToInformation;

  /// No description provided for @biologyChemistryPhysiology.
  ///
  /// In pt, this message translates to:
  /// **'Biologia, Química e fisiologia'**
  String get biologyChemistryPhysiology;

  /// No description provided for @energyMetabolism.
  ///
  /// In pt, this message translates to:
  /// **'Energia e metabolismo'**
  String get energyMetabolism;

  /// No description provided for @hemoglobinOxygen.
  ///
  /// In pt, this message translates to:
  /// **'Hemoglobina e oxigênio'**
  String get hemoglobinOxygen;

  /// No description provided for @accelerometer.
  ///
  /// In pt, this message translates to:
  /// **'Acelerômetro'**
  String get accelerometer;

  /// No description provided for @heartRate.
  ///
  /// In pt, this message translates to:
  /// **'Frequência cardíaca'**
  String get heartRate;

  /// No description provided for @heartRateShort.
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get heartRateShort;

  /// No description provided for @calories.
  ///
  /// In pt, this message translates to:
  /// **'Calorias'**
  String get calories;

  /// No description provided for @days7.
  ///
  /// In pt, this message translates to:
  /// **'7 dias'**
  String get days7;

  /// No description provided for @days30.
  ///
  /// In pt, this message translates to:
  /// **'30 dias'**
  String get days30;

  /// No description provided for @days90.
  ///
  /// In pt, this message translates to:
  /// **'90 dias'**
  String get days90;

  /// No description provided for @addSourceHint.
  ///
  /// In pt, this message translates to:
  /// **'Escolha seu modelo. O OctoSense lê os dados do Health Connect do seu celular.'**
  String get addSourceHint;

  /// No description provided for @recommended.
  ///
  /// In pt, this message translates to:
  /// **'Recomendado — qualquer relógio Android'**
  String get recommended;

  /// No description provided for @comingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get comingSoon;

  /// No description provided for @android.
  ///
  /// In pt, this message translates to:
  /// **'Android'**
  String get android;

  /// No description provided for @removeDemoHint.
  ///
  /// In pt, this message translates to:
  /// **'será removido da lista de dispositivos conectados. Nenhum dado será apagado.'**
  String get removeDemoHint;

  /// No description provided for @prototypeLocal.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivo conectado'**
  String get prototypeLocal;

  /// No description provided for @googleHealthToday.
  ///
  /// In pt, this message translates to:
  /// **'Google Health · hoje'**
  String get googleHealthToday;

  /// No description provided for @healthConnectToday.
  ///
  /// In pt, this message translates to:
  /// **'Health Connect · hoje'**
  String get healthConnectToday;

  /// No description provided for @errorRequestPermission.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao pedir permissão: {error}'**
  String errorRequestPermission(Object error);

  /// No description provided for @errorDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao excluir conta: {error}'**
  String errorDeleteAccount(Object error);

  /// No description provided for @settingsHeading.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get settingsHeading;

  /// No description provided for @settingsHeadingEn.
  ///
  /// In pt, this message translates to:
  /// **'SETTINGS'**
  String get settingsHeadingEn;

  /// No description provided for @accountManagement.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie sua conta OctoSense.'**
  String get accountManagement;

  /// No description provided for @signOutPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Você voltará para a tela de entrada. Os tokens serão apagados deste aparelho.'**
  String get signOutPrompt;

  /// No description provided for @deleteAccountPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Isso apaga sua conta, todas as suas leituras e desconecta você de todos os aparelhos. Não tem como desfazer.\n\nTem certeza?'**
  String get deleteAccountPrompt;

  /// No description provided for @signOutOfAccount.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta?'**
  String get signOutOfAccount;

  /// No description provided for @signOutDescription.
  ///
  /// In pt, this message translates to:
  /// **'Voltar para a tela de entrada.'**
  String get signOutDescription;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In pt, this message translates to:
  /// **'Apaga permanentemente sua conta e todos os dados. Esta ação não pode ser desfeita.'**
  String get deleteAccountDescription;

  /// No description provided for @addWatchDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha seu modelo. O OctoSense lê os dados do Health Connect do seu celular.'**
  String get addWatchDescription;

  /// No description provided for @myDevicesDescription.
  ///
  /// In pt, this message translates to:
  /// **'Adicione fontes para visualizar como o OctoSense gerenciará vários wearables.'**
  String get myDevicesDescription;

  /// No description provided for @howSourcesWork.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie de onde vêm os sinais usados pelo OctoSense.'**
  String get howSourcesWork;

  /// No description provided for @noRealDeviceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dispositivo real'**
  String get noRealDeviceTitle;

  /// No description provided for @howSourcesWorkTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona'**
  String get howSourcesWorkTitle;

  /// No description provided for @deviceVsSourceText.
  ///
  /// In pt, this message translates to:
  /// **'Um Galaxy Watch é um dispositivo físico. Health Connect ou Samsung Health podem ser a fonte pela qual os dados chegam ao OctoSense.'**
  String get deviceVsSourceText;

  /// No description provided for @multipleDevicesText.
  ///
  /// In pt, this message translates to:
  /// **'Um usuário poderá possuir múltiplos wearables. Cada leitura manterá informação de origem, dispositivo e momento da medição.'**
  String get multipleDevicesText;

  /// No description provided for @withoutDuplicatesText.
  ///
  /// In pt, this message translates to:
  /// **'Quando o backend for implementado, leituras repetidas vindas de fontes diferentes precisarão ser identificadas e deduplicadas antes da persistência.'**
  String get withoutDuplicatesText;

  /// No description provided for @appearanceDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha como o OctoSense deve aparecer.'**
  String get appearanceDescription;

  /// No description provided for @textSizeDescription.
  ///
  /// In pt, this message translates to:
  /// **'O tamanho escolhido é aplicado em todo o OctoSense.'**
  String get textSizeDescription;

  /// No description provided for @readersText.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense utiliza componentes semânticos do Flutter e continuará recebendo descrições específicas para gráficos, métricas e controles.'**
  String get readersText;

  /// No description provided for @beyondColorsText.
  ///
  /// In pt, this message translates to:
  /// **'Informações importantes não devem depender somente de cores. Texto, ícones e descrições também comunicam estado.'**
  String get beyondColorsText;

  /// No description provided for @signalBehindNumber.
  ///
  /// In pt, this message translates to:
  /// **'O sinal por trás do número'**
  String get signalBehindNumber;

  /// No description provided for @learnDescription.
  ///
  /// In pt, this message translates to:
  /// **'Entenda como o corpo, os sensores e a ciência se conectam aos dados do OctoSense.'**
  String get learnDescription;

  /// No description provided for @overview.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral'**
  String get overview;

  /// No description provided for @overviewSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Do corpo até a informação'**
  String get overviewSubtitle;

  /// No description provided for @sensors.
  ///
  /// In pt, this message translates to:
  /// **'Sensores'**
  String get sensors;

  /// No description provided for @sensorsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'PPG, movimento, SpO₂ e wearables'**
  String get sensorsSubtitle;

  /// No description provided for @scienceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Biologia, Química e fisiologia'**
  String get scienceSubtitle;

  /// No description provided for @learnHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprenda no seu ritmo'**
  String get learnHeroTitle;

  /// No description provided for @learnHeroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um tema para entender melhor seus sinais.'**
  String get learnHeroSubtitle;

  /// No description provided for @periodAnalysis.
  ///
  /// In pt, this message translates to:
  /// **'Análise do período'**
  String get periodAnalysis;

  /// No description provided for @seeWhatChanged.
  ///
  /// In pt, this message translates to:
  /// **'Veja o que mudou'**
  String get seeWhatChanged;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get tryAgain;

  /// No description provided for @noHeartRateMeasurements.
  ///
  /// In pt, this message translates to:
  /// **'Sem medições de FC neste período.'**
  String get noHeartRateMeasurements;

  /// No description provided for @heartRateChartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Frequência cardíaca'**
  String get heartRateChartTitle;

  /// No description provided for @frequency.
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get frequency;

  /// No description provided for @steps.
  ///
  /// In pt, this message translates to:
  /// **'Passos'**
  String get steps;

  /// No description provided for @sleep.
  ///
  /// In pt, this message translates to:
  /// **'Sono'**
  String get sleep;

  /// No description provided for @activeCalories.
  ///
  /// In pt, this message translates to:
  /// **'Calorias ativas'**
  String get activeCalories;

  /// No description provided for @noMeasurement.
  ///
  /// In pt, this message translates to:
  /// **'Sem medição'**
  String get noMeasurement;

  /// No description provided for @noRecord.
  ///
  /// In pt, this message translates to:
  /// **'Sem registro'**
  String get noRecord;

  /// No description provided for @whyHeartAccelerates.
  ///
  /// In pt, this message translates to:
  /// **'Por que o coração acelera?'**
  String get whyHeartAccelerates;

  /// No description provided for @understandSignal.
  ///
  /// In pt, this message translates to:
  /// **'Entenda o sinal'**
  String get understandSignal;

  /// No description provided for @exerciseHeartText.
  ///
  /// In pt, this message translates to:
  /// **'Durante o exercício, o organismo aumenta o débito cardíaco para transportar mais oxigênio aos tecidos.'**
  String get exerciseHeartText;

  /// No description provided for @signInGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get signInGoogle;

  /// No description provided for @unexpectedError.
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado: {error}'**
  String unexpectedError(Object error);

  /// No description provided for @authorizeNow.
  ///
  /// In pt, this message translates to:
  /// **'Autorizar agora'**
  String get authorizeNow;

  /// No description provided for @notNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get notNow;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @waitingGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando o Google'**
  String get waitingGoogle;

  /// No description provided for @googleConsentError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar o consentimento Google.'**
  String get googleConsentError;

  /// No description provided for @googleBrowserError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o navegador para o Google.'**
  String get googleBrowserError;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma da interface.'**
  String get languageDescription;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @healthConnectDisableInstruction.
  ///
  /// In pt, this message translates to:
  /// **'Revogue a permissão do OctoSense nas configurações.'**
  String get healthConnectDisableInstruction;

  /// No description provided for @healthConnectSettingsError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir as configurações do Health Connect.'**
  String get healthConnectSettingsError;

  /// No description provided for @markRead.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como lido'**
  String get markRead;

  /// No description provided for @read.
  ///
  /// In pt, this message translates to:
  /// **'Lido'**
  String get read;

  /// No description provided for @listen.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir'**
  String get listen;

  /// No description provided for @privacyDescription.
  ///
  /// In pt, this message translates to:
  /// **'Você deve saber o que é coletado e por quê.'**
  String get privacyDescription;

  /// No description provided for @dataMinimization.
  ///
  /// In pt, this message translates to:
  /// **'Minimização de dados'**
  String get dataMinimization;

  /// No description provided for @dataMinimizationText.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense deverá coletar apenas o necessário para cada finalidade declarada.'**
  String get dataMinimizationText;

  /// No description provided for @realData.
  ///
  /// In pt, this message translates to:
  /// **'Dados reais'**
  String get realData;

  /// No description provided for @realDataText.
  ///
  /// In pt, this message translates to:
  /// **'O Showcase público não utilizará dados reais de participantes.'**
  String get realDataText;

  /// No description provided for @userControl.
  ///
  /// In pt, this message translates to:
  /// **'Controle do usuário'**
  String get userControl;

  /// No description provided for @userControlText.
  ///
  /// In pt, this message translates to:
  /// **'Permissões, retenção e exclusão serão tratadas explicitamente quando o piloto com wearables reais for implementado.'**
  String get userControlText;

  /// No description provided for @helpDescription.
  ///
  /// In pt, this message translates to:
  /// **'Respostas rápidas para usar o OctoSense.'**
  String get helpDescription;

  /// No description provided for @howToStart.
  ///
  /// In pt, this message translates to:
  /// **'Como começar?'**
  String get howToStart;

  /// No description provided for @howToStartText.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense acompanha as medições autorizadas no Health Connect e organiza os dados para você consultar.'**
  String get howToStartText;

  /// No description provided for @howToConnectWatch.
  ///
  /// In pt, this message translates to:
  /// **'Como conectar um relógio?'**
  String get howToConnectWatch;

  /// No description provided for @howToConnectWatchText.
  ///
  /// In pt, this message translates to:
  /// **'Em Dispositivos, autorize o Health Connect. Depois, use o relógio normalmente e acompanhe as métricas que chegarem.'**
  String get howToConnectWatchText;

  /// No description provided for @whereNumbersComeFrom.
  ///
  /// In pt, this message translates to:
  /// **'De onde vêm os números?'**
  String get whereNumbersComeFrom;

  /// No description provided for @whereNumbersComeFromText.
  ///
  /// In pt, this message translates to:
  /// **'Passos, frequência cardíaca, sono e calorias são recebidos do Health Connect a partir das fontes autorizadas no aparelho.'**
  String get whereNumbersComeFromText;

  /// No description provided for @diagnosisQuestion.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense faz diagnóstico?'**
  String get diagnosisQuestion;

  /// No description provided for @diagnosisText.
  ///
  /// In pt, this message translates to:
  /// **'Não. Uma leitura é uma estimativa e não substitui uma avaliação clínica.'**
  String get diagnosisText;

  /// No description provided for @aboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o OctoSense'**
  String get aboutTitle;

  /// No description provided for @projectInfo.
  ///
  /// In pt, this message translates to:
  /// **'Produto para acompanhar sinais de saúde e entender os dados dos wearables.'**
  String get projectInfo;

  /// No description provided for @currentVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão atual'**
  String get currentVersion;

  /// No description provided for @versionText.
  ///
  /// In pt, this message translates to:
  /// **'Versão 0.9.0 — OctoSense para Android.'**
  String get versionText;

  /// No description provided for @important.
  ///
  /// In pt, this message translates to:
  /// **'Importante'**
  String get important;

  /// No description provided for @medicalWarning.
  ///
  /// In pt, this message translates to:
  /// **'OctoSense não é um dispositivo médico e não realiza diagnóstico.'**
  String get medicalWarning;

  /// No description provided for @topic1Title.
  ///
  /// In pt, this message translates to:
  /// **'Sinais vitais e contexto'**
  String get topic1Title;

  /// No description provided for @topic1P1.
  ///
  /// In pt, this message translates to:
  /// **'O corpo produz sinais continuamente, como frequência cardíaca, movimento, sono e gasto energético.'**
  String get topic1P1;

  /// No description provided for @topic1P2.
  ///
  /// In pt, this message translates to:
  /// **'Um número isolado mostra apenas um instante e precisa de contexto para ser compreendido.'**
  String get topic1P2;

  /// No description provided for @topic1P3.
  ///
  /// In pt, this message translates to:
  /// **'Observar mudanças ao longo do tempo ajuda a perceber padrões naturais do organismo.'**
  String get topic1P3;

  /// No description provided for @topic1P4.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense organiza essas leituras para facilitar a compreensão e não transforma uma leitura em diagnóstico.'**
  String get topic1P4;

  /// No description provided for @topic2Title.
  ///
  /// In pt, this message translates to:
  /// **'Frequência cardíaca'**
  String get topic2Title;

  /// No description provided for @topic2P1.
  ///
  /// In pt, this message translates to:
  /// **'O coração bombeia sangue para distribuir oxigênio e nutrientes pelos tecidos.'**
  String get topic2P1;

  /// No description provided for @topic2P2.
  ///
  /// In pt, this message translates to:
  /// **'A frequência cardíaca pode mudar com exercício, repouso, emoções, temperatura e outros fatores.'**
  String get topic2P2;

  /// No description provided for @topic2P3.
  ///
  /// In pt, this message translates to:
  /// **'Relógios estimam essa frequência a partir de sinais captados na pele.'**
  String get topic2P3;

  /// No description provided for @topic2P4.
  ///
  /// In pt, this message translates to:
  /// **'Comparar períodos e situações diferentes ajuda a entender por que o número varia.'**
  String get topic2P4;

  /// No description provided for @topic3Title.
  ///
  /// In pt, this message translates to:
  /// **'Sono e recuperação'**
  String get topic3Title;

  /// No description provided for @topic3P1.
  ///
  /// In pt, this message translates to:
  /// **'Durante o sono, o organismo alterna diferentes estágios com funções importantes para recuperação.'**
  String get topic3P1;

  /// No description provided for @topic3P2.
  ///
  /// In pt, this message translates to:
  /// **'Wearables usam movimento e outros sinais para estimar períodos de sono.'**
  String get topic3P2;

  /// No description provided for @topic3P3.
  ///
  /// In pt, this message translates to:
  /// **'Essas estimativas não substituem exames especializados do sono.'**
  String get topic3P3;

  /// No description provided for @topic3P4.
  ///
  /// In pt, this message translates to:
  /// **'Observar regularidade, duração e contexto é mais informativo do que olhar uma única noite.'**
  String get topic3P4;

  /// No description provided for @topic4Title.
  ///
  /// In pt, this message translates to:
  /// **'Passos e movimento'**
  String get topic4Title;

  /// No description provided for @topic4P1.
  ///
  /// In pt, this message translates to:
  /// **'A contagem de passos é uma forma simples de representar movimento ao longo do dia.'**
  String get topic4P1;

  /// No description provided for @topic4P2.
  ///
  /// In pt, this message translates to:
  /// **'Acelerômetros detectam mudanças de movimento em vários eixos.'**
  String get topic4P2;

  /// No description provided for @topic4P3.
  ///
  /// In pt, this message translates to:
  /// **'Algoritmos filtram esses sinais para estimar eventos compatíveis com passos.'**
  String get topic4P3;

  /// No description provided for @topic4P4.
  ///
  /// In pt, this message translates to:
  /// **'O resultado é uma estimativa e pode variar conforme o dispositivo e a forma de caminhar.'**
  String get topic4P4;

  /// No description provided for @topic5Title.
  ///
  /// In pt, this message translates to:
  /// **'PPG e luz'**
  String get topic5Title;

  /// No description provided for @topic5P1.
  ///
  /// In pt, this message translates to:
  /// **'PPG significa fotopletismografia e usa luz para observar mudanças no volume de sangue próximo à pele.'**
  String get topic5P1;

  /// No description provided for @topic5P2.
  ///
  /// In pt, this message translates to:
  /// **'LEDs iluminam a pele enquanto um sensor mede a luz refletida ou recebida.'**
  String get topic5P2;

  /// No description provided for @topic5P3.
  ///
  /// In pt, this message translates to:
  /// **'O padrão dessa luz varia com cada batimento e pode ser processado para estimar frequência cardíaca.'**
  String get topic5P3;

  /// No description provided for @topic5P4.
  ///
  /// In pt, this message translates to:
  /// **'Movimento, ajuste da pulseira e características da pele podem afetar o sinal.'**
  String get topic5P4;

  /// No description provided for @topic6Title.
  ///
  /// In pt, this message translates to:
  /// **'Acelerômetro'**
  String get topic6Title;

  /// No description provided for @topic6P1.
  ///
  /// In pt, this message translates to:
  /// **'Um acelerômetro mede aceleração em diferentes eixos.'**
  String get topic6P1;

  /// No description provided for @topic6P2.
  ///
  /// In pt, this message translates to:
  /// **'Em um relógio, ele pode perceber mudanças associadas a passos, gestos e períodos de movimento.'**
  String get topic6P2;

  /// No description provided for @topic6P3.
  ///
  /// In pt, this message translates to:
  /// **'O sensor não entende sozinho o que a pessoa está fazendo: algoritmos interpretam os padrões.'**
  String get topic6P3;

  /// No description provided for @topic6P4.
  ///
  /// In pt, this message translates to:
  /// **'Por isso, diferentes atividades podem produzir sinais parecidos e exigir contexto adicional.'**
  String get topic6P4;

  /// No description provided for @topic7Title.
  ///
  /// In pt, this message translates to:
  /// **'Oxigenação e SpO₂'**
  String get topic7Title;

  /// No description provided for @topic7P1.
  ///
  /// In pt, this message translates to:
  /// **'A saturação periférica de oxigênio, conhecida como SpO₂, representa uma estimativa da proporção de hemoglobina ligada ao oxigênio.'**
  String get topic7P1;

  /// No description provided for @topic7P2.
  ///
  /// In pt, this message translates to:
  /// **'Sensores ópticos usam diferenças de absorção de luz para estimar essa proporção.'**
  String get topic7P2;

  /// No description provided for @topic7P3.
  ///
  /// In pt, this message translates to:
  /// **'O resultado depende da qualidade do sinal e das condições de medição.'**
  String get topic7P3;

  /// No description provided for @topic7P4.
  ///
  /// In pt, this message translates to:
  /// **'Uma leitura de wearable deve ser entendida como estimativa, não como diagnóstico clínico.'**
  String get topic7P4;

  /// No description provided for @topic8Title.
  ///
  /// In pt, this message translates to:
  /// **'Hemoglobina e oxigênio'**
  String get topic8Title;

  /// No description provided for @topic8P1.
  ///
  /// In pt, this message translates to:
  /// **'A hemoglobina é uma proteína presente nas células vermelhas do sangue.'**
  String get topic8P1;

  /// No description provided for @topic8P2.
  ///
  /// In pt, this message translates to:
  /// **'Ela consegue se ligar reversivelmente ao oxigênio e transportá-lo pelo organismo.'**
  String get topic8P2;

  /// No description provided for @topic8P3.
  ///
  /// In pt, this message translates to:
  /// **'A relação Hb + O₂ ⇌ HbO₂ ajuda a representar esse transporte reversível.'**
  String get topic8P3;

  /// No description provided for @topic8P4.
  ///
  /// In pt, this message translates to:
  /// **'Esse processo conecta química, biologia e fisiologia em um mesmo fenômeno.'**
  String get topic8P4;

  /// No description provided for @topic9Title.
  ///
  /// In pt, this message translates to:
  /// **'Energia e metabolismo'**
  String get topic9Title;

  /// No description provided for @topic9P1.
  ///
  /// In pt, this message translates to:
  /// **'As células precisam de energia continuamente para manter suas funções.'**
  String get topic9P1;

  /// No description provided for @topic9P2.
  ///
  /// In pt, this message translates to:
  /// **'O metabolismo reúne reações químicas que transformam nutrientes e sustentam processos celulares.'**
  String get topic9P2;

  /// No description provided for @topic9P3.
  ///
  /// In pt, this message translates to:
  /// **'Durante atividade física, a demanda energética aumenta e o organismo ajusta vários sistemas.'**
  String get topic9P3;

  /// No description provided for @topic9P4.
  ///
  /// In pt, this message translates to:
  /// **'Wearables podem estimar gasto energético usando sinais e modelos, mas não medem diretamente todas as reações metabólicas.'**
  String get topic9P4;

  /// No description provided for @topic10Title.
  ///
  /// In pt, this message translates to:
  /// **'Sistema cardiovascular'**
  String get topic10Title;

  /// No description provided for @topic10P1.
  ///
  /// In pt, this message translates to:
  /// **'O sistema cardiovascular integra coração, sangue e vasos sanguíneos.'**
  String get topic10P1;

  /// No description provided for @topic10P2.
  ///
  /// In pt, this message translates to:
  /// **'Ele distribui oxigênio, nutrientes, hormônios e calor enquanto remove produtos do metabolismo.'**
  String get topic10P2;

  /// No description provided for @topic10P3.
  ///
  /// In pt, this message translates to:
  /// **'O exercício aumenta a demanda dos músculos e provoca respostas cardiovasculares coordenadas.'**
  String get topic10P3;

  /// No description provided for @topic10P4.
  ///
  /// In pt, this message translates to:
  /// **'Dados de frequência cardíaca ajudam a visualizar parte desse processo em linguagem acessível.'**
  String get topic10P4;

  /// No description provided for @topic11Title.
  ///
  /// In pt, this message translates to:
  /// **'Do sensor ao dado'**
  String get topic11Title;

  /// No description provided for @topic11P1.
  ///
  /// In pt, this message translates to:
  /// **'O caminho começa com um sensor físico que transforma um fenômeno do corpo em sinal elétrico ou óptico.'**
  String get topic11P1;

  /// No description provided for @topic11P2.
  ///
  /// In pt, this message translates to:
  /// **'O dispositivo processa esse sinal e aplica algoritmos para estimar uma métrica.'**
  String get topic11P2;

  /// No description provided for @topic11P3.
  ///
  /// In pt, this message translates to:
  /// **'Depois, uma plataforma como Health Connect pode organizar e compartilhar dados autorizados com aplicativos.'**
  String get topic11P3;

  /// No description provided for @topic11P4.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense transforma essas métricas em visualizações e explicações claras.'**
  String get topic11P4;

  /// No description provided for @topic12Title.
  ///
  /// In pt, this message translates to:
  /// **'Como interpretar tendências'**
  String get topic12Title;

  /// No description provided for @topic12P1.
  ///
  /// In pt, this message translates to:
  /// **'Tendência é uma forma de observar mudanças ao longo de um período, não uma conclusão sobre uma pessoa.'**
  String get topic12P1;

  /// No description provided for @topic12P2.
  ///
  /// In pt, this message translates to:
  /// **'Médias, totais e séries temporais ajudam a reduzir o foco em um único valor.'**
  String get topic12P2;

  /// No description provided for @topic12P3.
  ///
  /// In pt, this message translates to:
  /// **'Também é importante considerar dias incompletos, mudanças de rotina e diferenças entre dispositivos.'**
  String get topic12P3;

  /// No description provided for @topic12P4.
  ///
  /// In pt, this message translates to:
  /// **'Uma boa interpretação combina dados, contexto e limites da medição.'**
  String get topic12P4;

  /// No description provided for @weeklyInsight.
  ///
  /// In pt, this message translates to:
  /// **'Insight da semana'**
  String get weeklyInsight;

  /// No description provided for @generatingInsight.
  ///
  /// In pt, this message translates to:
  /// **'Gerando seu insight...'**
  String get generatingInsight;

  /// No description provided for @feedbackUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar o insight agora.'**
  String get feedbackUnavailable;

  /// No description provided for @feedbackDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Resumo baseado nas medições recentes.'**
  String get feedbackDisclaimer;

  /// No description provided for @refreshInsight.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar insight'**
  String get refreshInsight;

  /// No description provided for @colorVision.
  ///
  /// In pt, this message translates to:
  /// **'Paleta para daltonismo'**
  String get colorVision;

  /// No description provided for @colorVisionDescription.
  ///
  /// In pt, this message translates to:
  /// **'Use uma paleta alternativa para diferenciar estados sem depender de vermelho e verde.'**
  String get colorVisionDescription;

  /// No description provided for @colorVisionStandard.
  ///
  /// In pt, this message translates to:
  /// **'Padrão'**
  String get colorVisionStandard;

  /// No description provided for @colorVisionAlternative.
  ///
  /// In pt, this message translates to:
  /// **'Alternativa'**
  String get colorVisionAlternative;

  /// No description provided for @colorVisionProtanopia.
  ///
  /// In pt, this message translates to:
  /// **'Protanopia (vermelho)'**
  String get colorVisionProtanopia;

  /// No description provided for @colorVisionDeuteranopia.
  ///
  /// In pt, this message translates to:
  /// **'Deuteranopia (verde)'**
  String get colorVisionDeuteranopia;

  /// No description provided for @colorVisionTritanopia.
  ///
  /// In pt, this message translates to:
  /// **'Tritanopia (azul)'**
  String get colorVisionTritanopia;

  /// No description provided for @colorVisionAchromatopsia.
  ///
  /// In pt, this message translates to:
  /// **'Acromatopsia (sem cores)'**
  String get colorVisionAchromatopsia;

  /// No description provided for @colorVisionAccessibleHint.
  ///
  /// In pt, this message translates to:
  /// **'Use texto e ícones junto com a cor. Escolha o modo que combina melhor com sua visão.'**
  String get colorVisionAccessibleHint;

  /// No description provided for @librasNote.
  ///
  /// In pt, this message translates to:
  /// **'O VLibras traduz conteúdo digital para Libras. A tradução automática é um apoio e não substitui um intérprete humano.'**
  String get librasNote;

  /// No description provided for @learnIntro.
  ///
  /// In pt, this message translates to:
  /// **'Explore. Toque. Gire. Ouça. Aprenda.'**
  String get learnIntro;

  /// No description provided for @learnIntroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma aula visual sobre o relógio, seus sensores e o que acontece dentro do corpo.'**
  String get learnIntroSubtitle;

  /// No description provided for @exploreWatch.
  ///
  /// In pt, this message translates to:
  /// **'Explorar o relógio'**
  String get exploreWatch;

  /// No description provided for @exploreWatchHint.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para girar o relógio e toque em uma parte.'**
  String get exploreWatchHint;

  /// No description provided for @demo.
  ///
  /// In pt, this message translates to:
  /// **'Demonstração'**
  String get demo;

  /// No description provided for @dragToRotate.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para girar'**
  String get dragToRotate;

  /// No description provided for @watchFace.
  ///
  /// In pt, this message translates to:
  /// **'Tela'**
  String get watchFace;

  /// No description provided for @watchSensors.
  ///
  /// In pt, this message translates to:
  /// **'Sensores'**
  String get watchSensors;

  /// No description provided for @watchBody.
  ///
  /// In pt, this message translates to:
  /// **'Corpo'**
  String get watchBody;

  /// No description provided for @watchPower.
  ///
  /// In pt, this message translates to:
  /// **'Energia'**
  String get watchPower;

  /// No description provided for @watchFaceText.
  ///
  /// In pt, this message translates to:
  /// **'A tela mostra uma métrica que veio dos sensores, mas o relógio não “enxerga” o corpo diretamente.'**
  String get watchFaceText;

  /// No description provided for @watchSensorsText.
  ///
  /// In pt, this message translates to:
  /// **'Os sensores captam luz, movimento e outros sinais. Algoritmos transformam esses sinais em estimativas.'**
  String get watchSensorsText;

  /// No description provided for @watchBodyText.
  ///
  /// In pt, this message translates to:
  /// **'O pulso, a pele e o movimento mudam o sinal medido. Por isso, contexto e ajuste importam.'**
  String get watchBodyText;

  /// No description provided for @watchPowerText.
  ///
  /// In pt, this message translates to:
  /// **'Bateria alimenta LEDs, sensores, processamento e comunicação. Mais medições podem consumir mais energia.'**
  String get watchPowerText;

  /// No description provided for @sensorTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que cada sensor percebe?'**
  String get sensorTitle;

  /// No description provided for @sensorSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Passe pelos sensores para ver o caminho do sinal.'**
  String get sensorSubtitle;

  /// No description provided for @ppg.
  ///
  /// In pt, this message translates to:
  /// **'PPG'**
  String get ppg;

  /// No description provided for @ppgSimple.
  ///
  /// In pt, this message translates to:
  /// **'Luz → sangue → pulso'**
  String get ppgSimple;

  /// No description provided for @ppgExplain.
  ///
  /// In pt, this message translates to:
  /// **'LEDs iluminam a pele. O sensor percebe mudanças na luz associadas ao volume de sangue perto do pulso.'**
  String get ppgExplain;

  /// No description provided for @motion.
  ///
  /// In pt, this message translates to:
  /// **'Movimento'**
  String get motion;

  /// No description provided for @motionSimple.
  ///
  /// In pt, this message translates to:
  /// **'Aceleração → padrão → passos'**
  String get motionSimple;

  /// No description provided for @motionExplain.
  ///
  /// In pt, this message translates to:
  /// **'O acelerômetro mede mudanças de movimento em eixos diferentes. O algoritmo reconhece padrões.'**
  String get motionExplain;

  /// No description provided for @spo2.
  ///
  /// In pt, this message translates to:
  /// **'SpO₂'**
  String get spo2;

  /// No description provided for @spo2Simple.
  ///
  /// In pt, this message translates to:
  /// **'Luz → hemoglobina → estimativa'**
  String get spo2Simple;

  /// No description provided for @spo2Explain.
  ///
  /// In pt, this message translates to:
  /// **'A luz interage de forma diferente com hemoglobina ligada ou não ao oxigênio. O relógio estima a saturação a partir disso.'**
  String get spo2Explain;

  /// No description provided for @scienceLab.
  ///
  /// In pt, this message translates to:
  /// **'Laboratório do corpo'**
  String get scienceLab;

  /// No description provided for @scienceLabSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O mesmo relógio conecta três ciências.'**
  String get scienceLabSubtitle;

  /// No description provided for @biology.
  ///
  /// In pt, this message translates to:
  /// **'Biologia'**
  String get biology;

  /// No description provided for @biologyExplain.
  ///
  /// In pt, this message translates to:
  /// **'Células, sangue, coração e tecidos formam o sistema que gera os sinais medidos.'**
  String get biologyExplain;

  /// No description provided for @chemistry.
  ///
  /// In pt, this message translates to:
  /// **'Química'**
  String get chemistry;

  /// No description provided for @chemistryExplain.
  ///
  /// In pt, this message translates to:
  /// **'Moléculas como hemoglobina participam de reações e ligações que transportam oxigênio.'**
  String get chemistryExplain;

  /// No description provided for @physics.
  ///
  /// In pt, this message translates to:
  /// **'Física'**
  String get physics;

  /// No description provided for @physicsExplain.
  ///
  /// In pt, this message translates to:
  /// **'Luz, aceleração, energia e eletricidade são fenômenos físicos que os sensores transformam em sinais.'**
  String get physicsExplain;

  /// No description provided for @signalPath.
  ///
  /// In pt, this message translates to:
  /// **'Do corpo ao número'**
  String get signalPath;

  /// No description provided for @signalPathSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Não existe mágica: existe uma cadeia de fenômenos.'**
  String get signalPathSubtitle;

  /// No description provided for @stepBody.
  ///
  /// In pt, this message translates to:
  /// **'1 · Corpo'**
  String get stepBody;

  /// No description provided for @stepSensor.
  ///
  /// In pt, this message translates to:
  /// **'2 · Sensor'**
  String get stepSensor;

  /// No description provided for @stepAlgorithm.
  ///
  /// In pt, this message translates to:
  /// **'3 · Algoritmo'**
  String get stepAlgorithm;

  /// No description provided for @stepApp.
  ///
  /// In pt, this message translates to:
  /// **'4 · OctoSense'**
  String get stepApp;

  /// No description provided for @stepBodyText.
  ///
  /// In pt, this message translates to:
  /// **'O coração bate, o sangue circula e o corpo se move.'**
  String get stepBodyText;

  /// No description provided for @stepSensorText.
  ///
  /// In pt, this message translates to:
  /// **'O hardware coleta um sinal físico.'**
  String get stepSensorText;

  /// No description provided for @stepAlgorithmText.
  ///
  /// In pt, this message translates to:
  /// **'O software encontra padrões e estima uma métrica.'**
  String get stepAlgorithmText;

  /// No description provided for @stepAppText.
  ///
  /// In pt, this message translates to:
  /// **'O OctoSense organiza o dado e explica o que ele significa.'**
  String get stepAppText;

  /// No description provided for @topicsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Explore outros temas'**
  String get topicsTitle;

  /// No description provided for @topicsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um cartão. A explicação aparece só quando você pedir.'**
  String get topicsSubtitle;

  /// No description provided for @explore.
  ///
  /// In pt, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// No description provided for @stopListening.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get stopListening;

  /// No description provided for @completed.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get completed;

  /// No description provided for @educationDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Uma leitura de wearable é uma estimativa e pode variar conforme ajuste, movimento e contexto.'**
  String get educationDisclaimer;

  /// No description provided for @signInTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu corpo, de um jeito fácil de entender.'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta e acompanhe seus sinais de saúde em uma visão clara.'**
  String get signInSubtitle;

  /// No description provided for @accountAccessNote.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta reúne suas preferências e os dados autorizados.'**
  String get accountAccessNote;

  /// No description provided for @onboarding1Title.
  ///
  /// In pt, this message translates to:
  /// **'Veja o sinal'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Text.
  ///
  /// In pt, this message translates to:
  /// **'Transforme medições de wearables em visualizações fáceis de explorar.'**
  String get onboarding1Text;

  /// No description provided for @onboarding2Title.
  ///
  /// In pt, this message translates to:
  /// **'Entenda o relógio'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Text.
  ///
  /// In pt, this message translates to:
  /// **'Descubra o que os sensores captam, o que acontece no corpo e como um número é formado.'**
  String get onboarding2Text;

  /// No description provided for @onboarding3Title.
  ///
  /// In pt, this message translates to:
  /// **'Do seu jeito'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Text.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste idioma, tamanho do texto, contraste, movimento, visão de cores e recursos assistivos.'**
  String get onboarding3Text;

  /// No description provided for @healthConnectTodaySource.
  ///
  /// In pt, this message translates to:
  /// **'Health Connect · hoje'**
  String get healthConnectTodaySource;

  /// No description provided for @connectHealthConnect.
  ///
  /// In pt, this message translates to:
  /// **'Conecte o Health Connect para ver suas medições.'**
  String get connectHealthConnect;

  /// No description provided for @daysWithDataLabel.
  ///
  /// In pt, this message translates to:
  /// **'{count} dias com dados'**
  String daysWithDataLabel(int count);

  /// No description provided for @averagePerDay.
  ///
  /// In pt, this message translates to:
  /// **'média/dia'**
  String get averagePerDay;

  /// No description provided for @periodTotal.
  ///
  /// In pt, this message translates to:
  /// **'total do período'**
  String get periodTotal;

  /// No description provided for @sourceHealthConnect.
  ///
  /// In pt, this message translates to:
  /// **'Health Connect'**
  String get sourceHealthConnect;

  /// No description provided for @watchPartPpg.
  ///
  /// In pt, this message translates to:
  /// **'Sensor óptico (PPG)'**
  String get watchPartPpg;

  /// No description provided for @watchPartMotion.
  ///
  /// In pt, this message translates to:
  /// **'Sensor de movimento'**
  String get watchPartMotion;

  /// No description provided for @watchPartOxygen.
  ///
  /// In pt, this message translates to:
  /// **'Sensor de oxigênio'**
  String get watchPartOxygen;

  /// No description provided for @watchPartCrown.
  ///
  /// In pt, this message translates to:
  /// **'Controle'**
  String get watchPartCrown;

  /// No description provided for @watchPartStrap.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste e contato'**
  String get watchPartStrap;

  /// No description provided for @watchPartBack.
  ///
  /// In pt, this message translates to:
  /// **'Sensores traseiros'**
  String get watchPartBack;

  /// No description provided for @watchPartScreen.
  ///
  /// In pt, this message translates to:
  /// **'Tela'**
  String get watchPartScreen;

  /// No description provided for @watchPartPpgText.
  ///
  /// In pt, this message translates to:
  /// **'A luz chega à pele e o sinal que retorna muda conforme o volume de sangue perto do pulso.'**
  String get watchPartPpgText;

  /// No description provided for @watchPartMotionText.
  ///
  /// In pt, this message translates to:
  /// **'O acelerômetro detecta mudanças de movimento em vários eixos.'**
  String get watchPartMotionText;

  /// No description provided for @watchPartOxygenText.
  ///
  /// In pt, this message translates to:
  /// **'Medições ópticas podem estimar a proporção de hemoglobina que carrega oxigênio.'**
  String get watchPartOxygenText;

  /// No description provided for @watchPartCrownText.
  ///
  /// In pt, this message translates to:
  /// **'Um controle físico ajuda na navegação e na interação sem depender só do toque.'**
  String get watchPartCrownText;

  /// No description provided for @watchPartStrapText.
  ///
  /// In pt, this message translates to:
  /// **'Um ajuste estável ajuda os sensores ópticos a manterem um sinal consistente na pele.'**
  String get watchPartStrapText;

  /// No description provided for @watchPartBackText.
  ///
  /// In pt, this message translates to:
  /// **'A parte de trás abriga sensores que ficam próximos da pele e coletam sinais do corpo.'**
  String get watchPartBackText;

  /// No description provided for @watchPartScreenText.
  ///
  /// In pt, this message translates to:
  /// **'A tela apresenta medições, contexto e respostas do relógio.'**
  String get watchPartScreenText;

  /// No description provided for @wearableStoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma volta em 30 segundos'**
  String get wearableStoryTitle;

  /// No description provided for @wearableStory1Title.
  ///
  /// In pt, this message translates to:
  /// **'Wearable'**
  String get wearableStory1Title;

  /// No description provided for @wearableStory1Text.
  ///
  /// In pt, this message translates to:
  /// **'O relógio fica no pulso e observa sinais sem abrir o corpo.'**
  String get wearableStory1Text;

  /// No description provided for @wearableStory2Title.
  ///
  /// In pt, this message translates to:
  /// **'Sensor'**
  String get wearableStory2Title;

  /// No description provided for @wearableStory2Text.
  ///
  /// In pt, this message translates to:
  /// **'Luz e movimento viram dados que o relógio consegue processar.'**
  String get wearableStory2Text;

  /// No description provided for @wearableStory3Title.
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
  String get wearableStory3Title;

  /// No description provided for @wearableStory3Text.
  ///
  /// In pt, this message translates to:
  /// **'O resultado vira uma métrica que você pode ler, comparar e entender.'**
  String get wearableStory3Text;

  /// No description provided for @challenges.
  ///
  /// In pt, this message translates to:
  /// **'Desafios'**
  String get challenges;

  /// No description provided for @challengesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Jogue com as mesmas ideias por trás das suas medições.'**
  String get challengesSubtitle;

  /// No description provided for @play.
  ///
  /// In pt, this message translates to:
  /// **'Jogar'**
  String get play;

  /// No description provided for @gameSignalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Monte o sinal'**
  String get gameSignalTitle;

  /// No description provided for @gameSignalText.
  ///
  /// In pt, this message translates to:
  /// **'Coloque as quatro etapas na ordem certa.'**
  String get gameSignalText;

  /// No description provided for @gameSensorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Combine o sensor'**
  String get gameSensorTitle;

  /// No description provided for @gameSensorText.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o sensor que combina melhor com a medição.'**
  String get gameSensorText;

  /// No description provided for @gameBodyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Corpo em movimento'**
  String get gameBodyTitle;

  /// No description provided for @gameBodyText.
  ///
  /// In pt, this message translates to:
  /// **'Responda perguntas rápidas sobre fisiologia e sinais de wearables.'**
  String get gameBodyText;

  /// No description provided for @gameCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Certo'**
  String get gameCorrect;

  /// No description provided for @gameTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get gameTryAgain;

  /// No description provided for @gameScore.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação'**
  String get gameScore;

  /// No description provided for @gameStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sequência'**
  String get gameStreak;

  /// No description provided for @gameNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get gameNext;

  /// No description provided for @gameFinish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get gameFinish;

  /// No description provided for @gameHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em uma resposta para continuar.'**
  String get gameHint;

  /// No description provided for @gameSignalBody.
  ///
  /// In pt, this message translates to:
  /// **'Corpo'**
  String get gameSignalBody;

  /// No description provided for @gameSignalSensor.
  ///
  /// In pt, this message translates to:
  /// **'Sensor'**
  String get gameSignalSensor;

  /// No description provided for @gameSignalAlgorithm.
  ///
  /// In pt, this message translates to:
  /// **'Algoritmo'**
  String get gameSignalAlgorithm;

  /// No description provided for @gameSignalMetric.
  ///
  /// In pt, this message translates to:
  /// **'Métrica'**
  String get gameSignalMetric;

  /// No description provided for @settingsPremiumTitle.
  ///
  /// In pt, this message translates to:
  /// **'Deixe o OctoSense com a sua cara'**
  String get settingsPremiumTitle;

  /// No description provided for @settingsPremiumSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Visual, acessibilidade e controles de dados em um só lugar.'**
  String get settingsPremiumSubtitle;

  /// No description provided for @accessibilityBasics.
  ///
  /// In pt, this message translates to:
  /// **'Essencial'**
  String get accessibilityBasics;

  /// No description provided for @accessibilityVisual.
  ///
  /// In pt, this message translates to:
  /// **'Visual'**
  String get accessibilityVisual;

  /// No description provided for @accessibilityAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio e idioma'**
  String get accessibilityAudio;

  /// No description provided for @accessibilityMotor.
  ///
  /// In pt, this message translates to:
  /// **'Movimento'**
  String get accessibilityMotor;

  /// No description provided for @librasAccess.
  ///
  /// In pt, this message translates to:
  /// **'Acesso em Libras'**
  String get librasAccess;

  /// No description provided for @librasAccessText.
  ///
  /// In pt, this message translates to:
  /// **'Abra o intérprete VLibras para conteúdo digital traduzido.'**
  String get librasAccessText;

  /// No description provided for @visualColorModes.
  ///
  /// In pt, this message translates to:
  /// **'Visão de cores'**
  String get visualColorModes;

  /// No description provided for @reduceMotionDetails.
  ///
  /// In pt, this message translates to:
  /// **'Reduza movimentos não essenciais em todo o app.'**
  String get reduceMotionDetails;

  /// No description provided for @highContrastDetails.
  ///
  /// In pt, this message translates to:
  /// **'Aumente a separação entre textos, controles e superfícies.'**
  String get highContrastDetails;

  /// No description provided for @screenReaderDetails.
  ///
  /// In pt, this message translates to:
  /// **'Use títulos, rótulos e anúncios de estado com leitores de tela.'**
  String get screenReaderDetails;

  /// No description provided for @premiumSecurityNote.
  ///
  /// In pt, this message translates to:
  /// **'Suas preferências ficam neste aparelho, salvo quando uma função indicar o contrário.'**
  String get premiumSecurityNote;

  /// No description provided for @healthEstimateNote.
  ///
  /// In pt, this message translates to:
  /// **'Leituras de wearables são estimativas e podem variar com ajuste, movimento e contexto.'**
  String get healthEstimateNote;

  /// No description provided for @aiInsightLabel.
  ///
  /// In pt, this message translates to:
  /// **'Insight da IA'**
  String get aiInsightLabel;

  /// No description provided for @aiInsightNote.
  ///
  /// In pt, this message translates to:
  /// **'Gerado a partir das suas medições recentes para ajudar você a perceber padrões.'**
  String get aiInsightNote;

  /// No description provided for @dashboardSourceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ao vivo pelo Health Connect'**
  String get dashboardSourceTitle;

  /// No description provided for @noLiveMeasurements.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há medições do Health Connect.'**
  String get noLiveMeasurements;

  /// No description provided for @loginExploreApp.
  ///
  /// In pt, this message translates to:
  /// **'Explorar OctoSense'**
  String get loginExploreApp;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma da interface.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @languageFlagPortuguese.
  ///
  /// In pt, this message translates to:
  /// **'🇧🇷 Português'**
  String get languageFlagPortuguese;

  /// No description provided for @languageFlagEnglish.
  ///
  /// In pt, this message translates to:
  /// **'🇺🇸 English'**
  String get languageFlagEnglish;

  /// No description provided for @languageFlagSpanish.
  ///
  /// In pt, this message translates to:
  /// **'🇪🇸 Español'**
  String get languageFlagSpanish;

  /// No description provided for @languageFlagFrench.
  ///
  /// In pt, this message translates to:
  /// **'🇫🇷 Français'**
  String get languageFlagFrench;

  /// No description provided for @languageFlagItalian.
  ///
  /// In pt, this message translates to:
  /// **'🇮🇹 Italiano'**
  String get languageFlagItalian;

  /// No description provided for @languageFlagGerman.
  ///
  /// In pt, this message translates to:
  /// **'🇩🇪 Deutsch'**
  String get languageFlagGerman;

  /// No description provided for @languageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In pt, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageItalian.
  ///
  /// In pt, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageGerman.
  ///
  /// In pt, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @gameQSensorOptical.
  ///
  /// In pt, this message translates to:
  /// **'Qual sensor usa luz para observar alterações próximas ao pulso?'**
  String get gameQSensorOptical;

  /// No description provided for @gameQSensorMotion.
  ///
  /// In pt, this message translates to:
  /// **'Qual sensor percebe aceleração e movimento?'**
  String get gameQSensorMotion;

  /// No description provided for @gameQSensorOxygen.
  ///
  /// In pt, this message translates to:
  /// **'Qual métrica estima o oxigênio ligado à hemoglobina?'**
  String get gameQSensorOxygen;

  /// No description provided for @gameQHeart.
  ///
  /// In pt, this message translates to:
  /// **'O que pode fazer a frequência cardíaca subir durante uma atividade?'**
  String get gameQHeart;

  /// No description provided for @gameOptExercise.
  ///
  /// In pt, this message translates to:
  /// **'Exercício e esforço'**
  String get gameOptExercise;

  /// No description provided for @gameOptSleep.
  ///
  /// In pt, this message translates to:
  /// **'Somente durante o sono'**
  String get gameOptSleep;

  /// No description provided for @gameOptColor.
  ///
  /// In pt, this message translates to:
  /// **'A cor do relógio'**
  String get gameOptColor;

  /// No description provided for @gamePlayAgain.
  ///
  /// In pt, this message translates to:
  /// **'Jogar novamente'**
  String get gamePlayAgain;

  /// No description provided for @privacyWhatWeCollect.
  ///
  /// In pt, this message translates to:
  /// **'O que coletamos'**
  String get privacyWhatWeCollect;

  /// No description provided for @privacyWhatWeCollectText.
  ///
  /// In pt, this message translates to:
  /// **'Passos, frequência cardíaca, calorias ativas, sono e oxigenação — lidos do Health Connect do seu celular e opcionalmente do Google Health.'**
  String get privacyWhatWeCollectText;

  /// No description provided for @privacyWhereItStays.
  ///
  /// In pt, this message translates to:
  /// **'Onde ficam seus dados'**
  String get privacyWhereItStays;

  /// No description provided for @privacyWhereItStaysText.
  ///
  /// In pt, this message translates to:
  /// **'Em um servidor próprio do OctoSense, protegido por HTTPS e autenticação JWT. Nenhum dado é vendido ou compartilhado com terceiros.'**
  String get privacyWhereItStaysText;

  /// No description provided for @privacyWhoCanSee.
  ///
  /// In pt, this message translates to:
  /// **'Quem pode ver'**
  String get privacyWhoCanSee;

  /// No description provided for @privacyWhoCanSeeText.
  ///
  /// In pt, this message translates to:
  /// **'Apenas você. Cada leitura é associada à sua conta Google e nunca é acessível por outro usuário.'**
  String get privacyWhoCanSeeText;

  /// No description provided for @privacyHowLong.
  ///
  /// In pt, this message translates to:
  /// **'Por quanto tempo'**
  String get privacyHowLong;

  /// No description provided for @privacyHowLongText.
  ///
  /// In pt, this message translates to:
  /// **'Enquanto sua conta existir. Sem prazo oculto — você pode excluir tudo a qualquer momento.'**
  String get privacyHowLongText;

  /// No description provided for @privacyYourRights.
  ///
  /// In pt, this message translates to:
  /// **'Seus direitos (LGPD)'**
  String get privacyYourRights;

  /// No description provided for @privacyYourRightsText.
  ///
  /// In pt, this message translates to:
  /// **'Acesso, correção, portabilidade e exclusão dos seus dados. Solicitados diretamente pelo app, sem burocracia.'**
  String get privacyYourRightsText;

  /// No description provided for @privacyDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get privacyDelete;

  /// No description provided for @privacyDeleteText.
  ///
  /// In pt, this message translates to:
  /// **'Em Ajustes → Minha conta, o botão Excluir remove permanentemente sua conta, suas leituras e seus tokens de acesso.'**
  String get privacyDeleteText;

  /// No description provided for @privacyContact.
  ///
  /// In pt, this message translates to:
  /// **'Dúvidas'**
  String get privacyContact;

  /// No description provided for @privacyContactText.
  ///
  /// In pt, this message translates to:
  /// **'Fale com o time do OctoSense pelo e-mail indicado na tela Sobre.'**
  String get privacyContactText;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
