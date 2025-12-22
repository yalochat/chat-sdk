import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'yalo_sdk_localizations_en.g.dart';
import 'yalo_sdk_localizations_es.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of YaloSdkLocalizations
/// returned by `YaloSdkLocalizations.of(context)`.
///
/// Applications need to include `YaloSdkLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/yalo_sdk_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: YaloSdkLocalizations.localizationsDelegates,
///   supportedLocales: YaloSdkLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the YaloSdkLocalizations.supportedLocales
/// property.
abstract class YaloSdkLocalizations {
  YaloSdkLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static YaloSdkLocalizations? of(BuildContext context) {
    return Localizations.of<YaloSdkLocalizations>(
      context,
      YaloSdkLocalizations,
    );
  }

  static const LocalizationsDelegate<YaloSdkLocalizations> delegate =
      _YaloSdkLocalizationsDelegate();

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
    Locale('es'),
  ];

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @sendImage.
  ///
  /// In en, this message translates to:
  /// **'Send an image'**
  String get sendImage;

  /// A button to take a photo
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// A button to take a photo from the gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;
}

class _YaloSdkLocalizationsDelegate
    extends LocalizationsDelegate<YaloSdkLocalizations> {
  const _YaloSdkLocalizationsDelegate();

  @override
  Future<YaloSdkLocalizations> load(Locale locale) {
    return SynchronousFuture<YaloSdkLocalizations>(
      lookupYaloSdkLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_YaloSdkLocalizationsDelegate old) => false;
}

YaloSdkLocalizations lookupYaloSdkLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return YaloSdkLocalizationsEn();
    case 'es':
      return YaloSdkLocalizationsEs();
  }

  throw FlutterError(
    'YaloSdkLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
