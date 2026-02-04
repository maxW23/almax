import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @afghanistan.
  ///
  /// In en, this message translates to:
  /// **'Afghanistan'**
  String get afghanistan;

  /// No description provided for @albania.
  ///
  /// In en, this message translates to:
  /// **'Albania'**
  String get albania;

  /// No description provided for @algeria.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get algeria;

  /// No description provided for @andorra.
  ///
  /// In en, this message translates to:
  /// **'Andorra'**
  String get andorra;

  /// No description provided for @angola.
  ///
  /// In en, this message translates to:
  /// **'Angola'**
  String get angola;

  /// No description provided for @antigua_and_barbuda.
  ///
  /// In en, this message translates to:
  /// **'Antigua and Barbuda'**
  String get antigua_and_barbuda;

  /// No description provided for @argentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get argentina;

  /// No description provided for @armenia.
  ///
  /// In en, this message translates to:
  /// **'Armenia'**
  String get armenia;

  /// No description provided for @australia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get australia;

  /// No description provided for @austria.
  ///
  /// In en, this message translates to:
  /// **'Austria'**
  String get austria;

  /// No description provided for @azerbaijan.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijan'**
  String get azerbaijan;

  /// No description provided for @bahamas.
  ///
  /// In en, this message translates to:
  /// **'Bahamas'**
  String get bahamas;

  /// No description provided for @bahrain.
  ///
  /// In en, this message translates to:
  /// **'Bahrain'**
  String get bahrain;

  /// No description provided for @bangladesh.
  ///
  /// In en, this message translates to:
  /// **'Bangladesh'**
  String get bangladesh;

  /// No description provided for @barbados.
  ///
  /// In en, this message translates to:
  /// **'Barbados'**
  String get barbados;

  /// No description provided for @belarus.
  ///
  /// In en, this message translates to:
  /// **'Belarus'**
  String get belarus;

  /// No description provided for @belgium.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get belgium;

  /// No description provided for @belize.
  ///
  /// In en, this message translates to:
  /// **'Belize'**
  String get belize;

  /// No description provided for @benin.
  ///
  /// In en, this message translates to:
  /// **'Benin'**
  String get benin;

  /// No description provided for @bhutan.
  ///
  /// In en, this message translates to:
  /// **'Bhutan'**
  String get bhutan;

  /// No description provided for @bolivia.
  ///
  /// In en, this message translates to:
  /// **'Bolivia'**
  String get bolivia;

  /// No description provided for @bosnia_and_herzegovina.
  ///
  /// In en, this message translates to:
  /// **'Bosnia and Herzegovina'**
  String get bosnia_and_herzegovina;

  /// No description provided for @botswana.
  ///
  /// In en, this message translates to:
  /// **'Botswana'**
  String get botswana;

  /// No description provided for @brazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get brazil;

  /// No description provided for @brunei.
  ///
  /// In en, this message translates to:
  /// **'Brunei'**
  String get brunei;

  /// No description provided for @bulgaria.
  ///
  /// In en, this message translates to:
  /// **'Bulgaria'**
  String get bulgaria;

  /// No description provided for @burkina_faso.
  ///
  /// In en, this message translates to:
  /// **'Burkina Faso'**
  String get burkina_faso;

  /// No description provided for @burundi.
  ///
  /// In en, this message translates to:
  /// **'Burundi'**
  String get burundi;

  /// No description provided for @cambodia.
  ///
  /// In en, this message translates to:
  /// **'Cambodia'**
  String get cambodia;

  /// No description provided for @cameroon.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get cameroon;

  /// No description provided for @canada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get canada;

  /// No description provided for @cape_verde.
  ///
  /// In en, this message translates to:
  /// **'Cape Verde'**
  String get cape_verde;

  /// No description provided for @central_african_republic.
  ///
  /// In en, this message translates to:
  /// **'Central African Republic'**
  String get central_african_republic;

  /// No description provided for @chad.
  ///
  /// In en, this message translates to:
  /// **'Chad'**
  String get chad;

  /// No description provided for @chile.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get chile;

  /// No description provided for @china.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get china;

  /// No description provided for @colombia.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get colombia;

  /// No description provided for @comoros.
  ///
  /// In en, this message translates to:
  /// **'Comoros'**
  String get comoros;

  /// No description provided for @congo.
  ///
  /// In en, this message translates to:
  /// **'Congo'**
  String get congo;

  /// No description provided for @costa_rica.
  ///
  /// In en, this message translates to:
  /// **'Costa Rica'**
  String get costa_rica;

  /// No description provided for @croatia.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get croatia;

  /// No description provided for @cuba.
  ///
  /// In en, this message translates to:
  /// **'Cuba'**
  String get cuba;

  /// No description provided for @cyprus.
  ///
  /// In en, this message translates to:
  /// **'Cyprus'**
  String get cyprus;

  /// No description provided for @czech_republic.
  ///
  /// In en, this message translates to:
  /// **'Czech Republic'**
  String get czech_republic;

  /// No description provided for @denmark.
  ///
  /// In en, this message translates to:
  /// **'Denmark'**
  String get denmark;

  /// No description provided for @djibouti.
  ///
  /// In en, this message translates to:
  /// **'Djibouti'**
  String get djibouti;

  /// No description provided for @dominica.
  ///
  /// In en, this message translates to:
  /// **'Dominica'**
  String get dominica;

  /// No description provided for @dominican_republic.
  ///
  /// In en, this message translates to:
  /// **'Dominican Republic'**
  String get dominican_republic;

  /// No description provided for @ecuador.
  ///
  /// In en, this message translates to:
  /// **'Ecuador'**
  String get ecuador;

  /// No description provided for @egypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get egypt;

  /// No description provided for @el_salvador.
  ///
  /// In en, this message translates to:
  /// **'El Salvador'**
  String get el_salvador;

  /// No description provided for @equatorial_guinea.
  ///
  /// In en, this message translates to:
  /// **'Equatorial Guinea'**
  String get equatorial_guinea;

  /// No description provided for @eritrea.
  ///
  /// In en, this message translates to:
  /// **'Eritrea'**
  String get eritrea;

  /// No description provided for @estonia.
  ///
  /// In en, this message translates to:
  /// **'Estonia'**
  String get estonia;

  /// No description provided for @eswatini.
  ///
  /// In en, this message translates to:
  /// **'Eswatini'**
  String get eswatini;

  /// No description provided for @ethiopia.
  ///
  /// In en, this message translates to:
  /// **'Ethiopia'**
  String get ethiopia;

  /// No description provided for @fiji.
  ///
  /// In en, this message translates to:
  /// **'Fiji'**
  String get fiji;

  /// No description provided for @finland.
  ///
  /// In en, this message translates to:
  /// **'Finland'**
  String get finland;

  /// No description provided for @france.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get france;

  /// No description provided for @gabon.
  ///
  /// In en, this message translates to:
  /// **'Gabon'**
  String get gabon;

  /// No description provided for @gambia.
  ///
  /// In en, this message translates to:
  /// **'Gambia'**
  String get gambia;

  /// No description provided for @georgia.
  ///
  /// In en, this message translates to:
  /// **'Georgia'**
  String get georgia;

  /// No description provided for @germany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get germany;

  /// No description provided for @ghana.
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get ghana;

  /// No description provided for @greece.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get greece;

  /// No description provided for @grenada.
  ///
  /// In en, this message translates to:
  /// **'Grenada'**
  String get grenada;

  /// No description provided for @guatemala.
  ///
  /// In en, this message translates to:
  /// **'Guatemala'**
  String get guatemala;

  /// No description provided for @guinea.
  ///
  /// In en, this message translates to:
  /// **'Guinea'**
  String get guinea;

  /// No description provided for @guinea_bissau.
  ///
  /// In en, this message translates to:
  /// **'Guinea-Bissau'**
  String get guinea_bissau;

  /// No description provided for @guyana.
  ///
  /// In en, this message translates to:
  /// **'Guyana'**
  String get guyana;

  /// No description provided for @haiti.
  ///
  /// In en, this message translates to:
  /// **'Haiti'**
  String get haiti;

  /// No description provided for @honduras.
  ///
  /// In en, this message translates to:
  /// **'Honduras'**
  String get honduras;

  /// No description provided for @hungary.
  ///
  /// In en, this message translates to:
  /// **'Hungary'**
  String get hungary;

  /// No description provided for @iceland.
  ///
  /// In en, this message translates to:
  /// **'Iceland'**
  String get iceland;

  /// No description provided for @india.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get india;

  /// No description provided for @indonesia.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get indonesia;

  /// No description provided for @iran.
  ///
  /// In en, this message translates to:
  /// **'Iran'**
  String get iran;

  /// No description provided for @iraq.
  ///
  /// In en, this message translates to:
  /// **'Iraq'**
  String get iraq;

  /// No description provided for @ireland.
  ///
  /// In en, this message translates to:
  /// **'Ireland'**
  String get ireland;

  /// No description provided for @italy.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get italy;

  /// No description provided for @jamaica.
  ///
  /// In en, this message translates to:
  /// **'Jamaica'**
  String get jamaica;

  /// No description provided for @japan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get japan;

  /// No description provided for @jordan.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get jordan;

  /// No description provided for @kazakhstan.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstan'**
  String get kazakhstan;

  /// No description provided for @kenya.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get kenya;

  /// No description provided for @kiribati.
  ///
  /// In en, this message translates to:
  /// **'Kiribati'**
  String get kiribati;

  /// No description provided for @korea_north.
  ///
  /// In en, this message translates to:
  /// **'North Korea'**
  String get korea_north;

  /// No description provided for @korea_south.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get korea_south;

  /// No description provided for @kosovo.
  ///
  /// In en, this message translates to:
  /// **'Kosovo'**
  String get kosovo;

  /// No description provided for @kuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get kuwait;

  /// No description provided for @kyrgyzstan.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyzstan'**
  String get kyrgyzstan;

  /// No description provided for @laos.
  ///
  /// In en, this message translates to:
  /// **'Laos'**
  String get laos;

  /// No description provided for @latvia.
  ///
  /// In en, this message translates to:
  /// **'Latvia'**
  String get latvia;

  /// No description provided for @lebanon.
  ///
  /// In en, this message translates to:
  /// **'Lebanon'**
  String get lebanon;

  /// No description provided for @lesotho.
  ///
  /// In en, this message translates to:
  /// **'Lesotho'**
  String get lesotho;

  /// No description provided for @liberia.
  ///
  /// In en, this message translates to:
  /// **'Liberia'**
  String get liberia;

  /// No description provided for @libya.
  ///
  /// In en, this message translates to:
  /// **'Libya'**
  String get libya;

  /// No description provided for @liechtenstein.
  ///
  /// In en, this message translates to:
  /// **'Liechtenstein'**
  String get liechtenstein;

  /// No description provided for @lithuania.
  ///
  /// In en, this message translates to:
  /// **'Lithuania'**
  String get lithuania;

  /// No description provided for @luxembourg.
  ///
  /// In en, this message translates to:
  /// **'Luxembourg'**
  String get luxembourg;

  /// No description provided for @madagascar.
  ///
  /// In en, this message translates to:
  /// **'Madagascar'**
  String get madagascar;

  /// No description provided for @malawi.
  ///
  /// In en, this message translates to:
  /// **'Malawi'**
  String get malawi;

  /// No description provided for @malaysia.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get malaysia;

  /// No description provided for @maldives.
  ///
  /// In en, this message translates to:
  /// **'Maldives'**
  String get maldives;

  /// No description provided for @mali.
  ///
  /// In en, this message translates to:
  /// **'Mali'**
  String get mali;

  /// No description provided for @malta.
  ///
  /// In en, this message translates to:
  /// **'Malta'**
  String get malta;

  /// No description provided for @marshall_islands.
  ///
  /// In en, this message translates to:
  /// **'Marshall Islands'**
  String get marshall_islands;

  /// No description provided for @mauritania.
  ///
  /// In en, this message translates to:
  /// **'Mauritania'**
  String get mauritania;

  /// No description provided for @mauritius.
  ///
  /// In en, this message translates to:
  /// **'Mauritius'**
  String get mauritius;

  /// No description provided for @mexico.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get mexico;

  /// No description provided for @micronesia.
  ///
  /// In en, this message translates to:
  /// **'Micronesia'**
  String get micronesia;

  /// No description provided for @moldova.
  ///
  /// In en, this message translates to:
  /// **'Moldova'**
  String get moldova;

  /// No description provided for @monaco.
  ///
  /// In en, this message translates to:
  /// **'Monaco'**
  String get monaco;

  /// No description provided for @mongolia.
  ///
  /// In en, this message translates to:
  /// **'Mongolia'**
  String get mongolia;

  /// No description provided for @montenegro.
  ///
  /// In en, this message translates to:
  /// **'Montenegro'**
  String get montenegro;

  /// No description provided for @morocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get morocco;

  /// No description provided for @mozambique.
  ///
  /// In en, this message translates to:
  /// **'Mozambique'**
  String get mozambique;

  /// No description provided for @myanmar.
  ///
  /// In en, this message translates to:
  /// **'Myanmar'**
  String get myanmar;

  /// No description provided for @namibia.
  ///
  /// In en, this message translates to:
  /// **'Namibia'**
  String get namibia;

  /// No description provided for @nauru.
  ///
  /// In en, this message translates to:
  /// **'Nauru'**
  String get nauru;

  /// No description provided for @nepal.
  ///
  /// In en, this message translates to:
  /// **'Nepal'**
  String get nepal;

  /// No description provided for @netherlands.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get netherlands;

  /// No description provided for @new_zealand.
  ///
  /// In en, this message translates to:
  /// **'New Zealand'**
  String get new_zealand;

  /// No description provided for @nicaragua.
  ///
  /// In en, this message translates to:
  /// **'Nicaragua'**
  String get nicaragua;

  /// No description provided for @niger.
  ///
  /// In en, this message translates to:
  /// **'Niger'**
  String get niger;

  /// No description provided for @nigeria.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get nigeria;

  /// No description provided for @north_macedonia.
  ///
  /// In en, this message translates to:
  /// **'North Macedonia'**
  String get north_macedonia;

  /// No description provided for @norway.
  ///
  /// In en, this message translates to:
  /// **'Norway'**
  String get norway;

  /// No description provided for @oman.
  ///
  /// In en, this message translates to:
  /// **'Oman'**
  String get oman;

  /// No description provided for @pakistan.
  ///
  /// In en, this message translates to:
  /// **'Pakistan'**
  String get pakistan;

  /// No description provided for @palau.
  ///
  /// In en, this message translates to:
  /// **'Palau'**
  String get palau;

  /// No description provided for @panama.
  ///
  /// In en, this message translates to:
  /// **'Panama'**
  String get panama;

  /// No description provided for @papua_new_guinea.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinea'**
  String get papua_new_guinea;

  /// No description provided for @paraguay.
  ///
  /// In en, this message translates to:
  /// **'Paraguay'**
  String get paraguay;

  /// No description provided for @peru.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get peru;

  /// No description provided for @philippines.
  ///
  /// In en, this message translates to:
  /// **'Philippines'**
  String get philippines;

  /// No description provided for @poland.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get poland;

  /// No description provided for @portugal.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get portugal;

  /// No description provided for @qatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get qatar;

  /// No description provided for @romania.
  ///
  /// In en, this message translates to:
  /// **'Romania'**
  String get romania;

  /// No description provided for @russia.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get russia;

  /// No description provided for @rwanda.
  ///
  /// In en, this message translates to:
  /// **'Rwanda'**
  String get rwanda;

  /// No description provided for @saint_kitts_and_nevis.
  ///
  /// In en, this message translates to:
  /// **'Saint Kitts and Nevis'**
  String get saint_kitts_and_nevis;

  /// No description provided for @saint_lucia.
  ///
  /// In en, this message translates to:
  /// **'Saint Lucia'**
  String get saint_lucia;

  /// No description provided for @saint_vincent_and_the_grenadines.
  ///
  /// In en, this message translates to:
  /// **'Saint Vincent and the Grenadines'**
  String get saint_vincent_and_the_grenadines;

  /// No description provided for @samoa.
  ///
  /// In en, this message translates to:
  /// **'Samoa'**
  String get samoa;

  /// No description provided for @san_marino.
  ///
  /// In en, this message translates to:
  /// **'San Marino'**
  String get san_marino;

  /// No description provided for @sao_tome_and_principe.
  ///
  /// In en, this message translates to:
  /// **'Sao Tome and Principe'**
  String get sao_tome_and_principe;

  /// No description provided for @saudi_arabia.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get saudi_arabia;

  /// No description provided for @senegal.
  ///
  /// In en, this message translates to:
  /// **'Senegal'**
  String get senegal;

  /// No description provided for @serbia.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get serbia;

  /// No description provided for @seychelles.
  ///
  /// In en, this message translates to:
  /// **'Seychelles'**
  String get seychelles;

  /// No description provided for @sierra_leone.
  ///
  /// In en, this message translates to:
  /// **'Sierra Leone'**
  String get sierra_leone;

  /// No description provided for @singapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get singapore;

  /// No description provided for @slovakia.
  ///
  /// In en, this message translates to:
  /// **'Slovakia'**
  String get slovakia;

  /// No description provided for @slovenia.
  ///
  /// In en, this message translates to:
  /// **'Slovenia'**
  String get slovenia;

  /// No description provided for @solomon_islands.
  ///
  /// In en, this message translates to:
  /// **'Solomon Islands'**
  String get solomon_islands;

  /// No description provided for @somalia.
  ///
  /// In en, this message translates to:
  /// **'Somalia'**
  String get somalia;

  /// No description provided for @south_africa.
  ///
  /// In en, this message translates to:
  /// **'South Africa'**
  String get south_africa;

  /// No description provided for @south_sudan.
  ///
  /// In en, this message translates to:
  /// **'South Sudan'**
  String get south_sudan;

  /// No description provided for @spain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get spain;

  /// No description provided for @sri_lanka.
  ///
  /// In en, this message translates to:
  /// **'Sri Lanka'**
  String get sri_lanka;

  /// No description provided for @sudan.
  ///
  /// In en, this message translates to:
  /// **'Sudan'**
  String get sudan;

  /// No description provided for @suriname.
  ///
  /// In en, this message translates to:
  /// **'Suriname'**
  String get suriname;

  /// No description provided for @sweden.
  ///
  /// In en, this message translates to:
  /// **'Sweden'**
  String get sweden;

  /// No description provided for @switzerland.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get switzerland;

  /// No description provided for @syria.
  ///
  /// In en, this message translates to:
  /// **'Syria'**
  String get syria;

  /// No description provided for @taiwan.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get taiwan;

  /// No description provided for @tajikistan.
  ///
  /// In en, this message translates to:
  /// **'Tajikistan'**
  String get tajikistan;

  /// No description provided for @tanzania.
  ///
  /// In en, this message translates to:
  /// **'Tanzania'**
  String get tanzania;

  /// No description provided for @thailand.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get thailand;

  /// No description provided for @timor_leste.
  ///
  /// In en, this message translates to:
  /// **'Timor-Leste'**
  String get timor_leste;

  /// No description provided for @togo.
  ///
  /// In en, this message translates to:
  /// **'Togo'**
  String get togo;

  /// No description provided for @tonga.
  ///
  /// In en, this message translates to:
  /// **'Tonga'**
  String get tonga;

  /// No description provided for @trinidad_and_tobago.
  ///
  /// In en, this message translates to:
  /// **'Trinidad and Tobago'**
  String get trinidad_and_tobago;

  /// No description provided for @tunisia.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get tunisia;

  /// No description provided for @turkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get turkey;

  /// No description provided for @turkmenistan.
  ///
  /// In en, this message translates to:
  /// **'Turkmenistan'**
  String get turkmenistan;

  /// No description provided for @tuvalu.
  ///
  /// In en, this message translates to:
  /// **'Tuvalu'**
  String get tuvalu;

  /// No description provided for @uganda.
  ///
  /// In en, this message translates to:
  /// **'Uganda'**
  String get uganda;

  /// No description provided for @ukraine.
  ///
  /// In en, this message translates to:
  /// **'Ukraine'**
  String get ukraine;

  /// No description provided for @united_arab_emirates.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get united_arab_emirates;

  /// No description provided for @united_kingdom.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get united_kingdom;

  /// No description provided for @united_states.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get united_states;

  /// No description provided for @uruguay.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get uruguay;

  /// No description provided for @uzbekistan.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistan'**
  String get uzbekistan;

  /// No description provided for @vanuatu.
  ///
  /// In en, this message translates to:
  /// **'Vanuatu'**
  String get vanuatu;

  /// No description provided for @vatican_city.
  ///
  /// In en, this message translates to:
  /// **'Vatican City'**
  String get vatican_city;

  /// No description provided for @venezuela.
  ///
  /// In en, this message translates to:
  /// **'Venezuela'**
  String get venezuela;

  /// No description provided for @vietnam.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get vietnam;

  /// No description provided for @yemen.
  ///
  /// In en, this message translates to:
  /// **'Yemen'**
  String get yemen;

  /// No description provided for @zambia.
  ///
  /// In en, this message translates to:
  /// **'Zambia'**
  String get zambia;

  /// No description provided for @zimbabwe.
  ///
  /// In en, this message translates to:
  /// **'Zimbabwe'**
  String get zimbabwe;

  /// No description provided for @palestine.
  ///
  /// In en, this message translates to:
  /// **'Palestine'**
  String get palestine;

  /// No description provided for @taiwan_province_of_china.
  ///
  /// In en, this message translates to:
  /// **'Taiwan (Province of China)'**
  String get taiwan_province_of_china;

  /// No description provided for @hong_kong_sar_china.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong SAR China'**
  String get hong_kong_sar_china;

  /// No description provided for @macao_sar_china.
  ///
  /// In en, this message translates to:
  /// **'Macao SAR China'**
  String get macao_sar_china;

  /// No description provided for @cote_d_ivoire.
  ///
  /// In en, this message translates to:
  /// **'Côte d\'Ivoire'**
  String get cote_d_ivoire;

  /// No description provided for @republic_of_the_congo.
  ///
  /// In en, this message translates to:
  /// **'Republic of the Congo'**
  String get republic_of_the_congo;

  /// No description provided for @democratic_republic_of_the_congo.
  ///
  /// In en, this message translates to:
  /// **'Democratic Republic of the Congo'**
  String get democratic_republic_of_the_congo;

  /// No description provided for @mayotte.
  ///
  /// In en, this message translates to:
  /// **'Mayotte'**
  String get mayotte;

  /// No description provided for @british_virgin_islands.
  ///
  /// In en, this message translates to:
  /// **'British Virgin Islands'**
  String get british_virgin_islands;

  /// No description provided for @us_virgin_islands.
  ///
  /// In en, this message translates to:
  /// **'U.S. Virgin Islands'**
  String get us_virgin_islands;

  /// No description provided for @united_states_minor_outlying_islands.
  ///
  /// In en, this message translates to:
  /// **'U.S. Outlying Islands'**
  String get united_states_minor_outlying_islands;

  /// No description provided for @tokelau.
  ///
  /// In en, this message translates to:
  /// **'Tokelau'**
  String get tokelau;

  /// No description provided for @french_southern_territories.
  ///
  /// In en, this message translates to:
  /// **'French Southern Territories'**
  String get french_southern_territories;

  /// No description provided for @turks_and_caicos_islands.
  ///
  /// In en, this message translates to:
  /// **'Turks and Caicos Islands'**
  String get turks_and_caicos_islands;

  /// No description provided for @sint_maarten.
  ///
  /// In en, this message translates to:
  /// **'Sint Maarten'**
  String get sint_maarten;

  /// No description provided for @svalbard_and_jan_mayen.
  ///
  /// In en, this message translates to:
  /// **'Svalbard and Jan Mayen'**
  String get svalbard_and_jan_mayen;

  /// No description provided for @saint_helena.
  ///
  /// In en, this message translates to:
  /// **'Saint Helena'**
  String get saint_helena;

  /// No description provided for @french_polynesia.
  ///
  /// In en, this message translates to:
  /// **'French Polynesia'**
  String get french_polynesia;

  /// No description provided for @american_samoa.
  ///
  /// In en, this message translates to:
  /// **'American Samoa'**
  String get american_samoa;

  /// No description provided for @aruba.
  ///
  /// In en, this message translates to:
  /// **'Aruba'**
  String get aruba;

  /// No description provided for @aland_islands.
  ///
  /// In en, this message translates to:
  /// **'Åland Islands'**
  String get aland_islands;

  /// No description provided for @saint_barthelemy.
  ///
  /// In en, this message translates to:
  /// **'Saint Barthélemy'**
  String get saint_barthelemy;

  /// No description provided for @bermuda.
  ///
  /// In en, this message translates to:
  /// **'Bermuda'**
  String get bermuda;

  /// No description provided for @caribbean_netherlands.
  ///
  /// In en, this message translates to:
  /// **'Caribbean Netherlands'**
  String get caribbean_netherlands;

  /// No description provided for @bouvet_island.
  ///
  /// In en, this message translates to:
  /// **'Bouvet Island'**
  String get bouvet_island;

  /// No description provided for @cocos_islands.
  ///
  /// In en, this message translates to:
  /// **'Cocos (Keeling) Islands'**
  String get cocos_islands;

  /// No description provided for @curacao.
  ///
  /// In en, this message translates to:
  /// **'Curaçao'**
  String get curacao;

  /// No description provided for @christmas_island.
  ///
  /// In en, this message translates to:
  /// **'Christmas Island'**
  String get christmas_island;

  /// No description provided for @niue.
  ///
  /// In en, this message translates to:
  /// **'Niue'**
  String get niue;

  /// No description provided for @norfolk_island.
  ///
  /// In en, this message translates to:
  /// **'Norfolk Island'**
  String get norfolk_island;

  /// No description provided for @new_caledonia.
  ///
  /// In en, this message translates to:
  /// **'New Caledonia'**
  String get new_caledonia;

  /// No description provided for @wallis_and_futuna.
  ///
  /// In en, this message translates to:
  /// **'Wallis and Futuna'**
  String get wallis_and_futuna;

  /// No description provided for @antarctica.
  ///
  /// In en, this message translates to:
  /// **'Antarctica'**
  String get antarctica;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @enjoyWithChatingAandVoiceCallsRooms.
  ///
  /// In en, this message translates to:
  /// **'Enjoy with Chating\nand Voice Calls Rooms'**
  String get enjoyWithChatingAandVoiceCallsRooms;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get signIn;

  /// No description provided for @failedToInitializeZego.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize Zego'**
  String get failedToInitializeZego;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @lucky.
  ///
  /// In en, this message translates to:
  /// **'lucky'**
  String get lucky;

  /// No description provided for @couple.
  ///
  /// In en, this message translates to:
  /// **'couple'**
  String get couple;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'send'**
  String get send;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get error;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get done;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'okay'**
  String get okay;

  /// No description provided for @pleaseSelectUsers.
  ///
  /// In en, this message translates to:
  /// **'Please select users'**
  String get pleaseSelectUsers;

  /// No description provided for @notHaveEnoghtMoney.
  ///
  /// In en, this message translates to:
  /// **'Not have enough money'**
  String get notHaveEnoghtMoney;

  /// No description provided for @failedToCreateRoomPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to create room. Please try again.'**
  String get failedToCreateRoomPleaseTryAgain;

  /// No description provided for @errorCreatingRoom.
  ///
  /// In en, this message translates to:
  /// **'Error creating room Please try again later'**
  String get errorCreatingRoom;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'chat'**
  String get chat;

  /// No description provided for @official.
  ///
  /// In en, this message translates to:
  /// **'official'**
  String get official;

  /// No description provided for @exitOrKeep.
  ///
  /// In en, this message translates to:
  /// **'Exit or Keep'**
  String get exitOrKeep;

  /// No description provided for @wouldYouLikeToExitOrKeepTheApp.
  ///
  /// In en, this message translates to:
  /// **'Would you like to exit or keep the app?'**
  String get wouldYouLikeToExitOrKeepTheApp;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'keep'**
  String get keep;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'exit'**
  String get exit;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @wealth.
  ///
  /// In en, this message translates to:
  /// **'wealth'**
  String get wealth;

  /// No description provided for @attraction.
  ///
  /// In en, this message translates to:
  /// **'attraction'**
  String get attraction;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @chooseNumber.
  ///
  /// In en, this message translates to:
  /// **'Choose Number'**
  String get chooseNumber;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get days30;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get confirm;

  /// No description provided for @howToUpgrade.
  ///
  /// In en, this message translates to:
  /// **'How To Upgrade?'**
  String get howToUpgrade;

  /// No description provided for @numberOfMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Number of Microphone'**
  String get numberOfMicrophone;

  /// No description provided for @thePasswordIsWrong.
  ///
  /// In en, this message translates to:
  /// **'The Password is Wrong'**
  String get thePasswordIsWrong;

  /// No description provided for @microphonePermissionIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required'**
  String get microphonePermissionIsRequired;

  /// No description provided for @searchForRooms.
  ///
  /// In en, this message translates to:
  /// **'Search for rooms'**
  String get searchForRooms;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @failedToUpdateVIP5Status.
  ///
  /// In en, this message translates to:
  /// **'Failed to update VIP5 status'**
  String get failedToUpdateVIP5Status;

  /// No description provided for @showVIP5.
  ///
  /// In en, this message translates to:
  /// **'Show VIP5'**
  String get showVIP5;

  /// No description provided for @doneCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'copy to clipboard has done'**
  String get doneCopiedToClipboard;

  /// No description provided for @codeEvent.
  ///
  /// In en, this message translates to:
  /// **'Code (for events mode)'**
  String get codeEvent;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @frame.
  ///
  /// In en, this message translates to:
  /// **'Frame'**
  String get frame;

  /// No description provided for @gifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get gifts;

  /// No description provided for @codeIs.
  ///
  /// In en, this message translates to:
  /// **'code is'**
  String get codeIs;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @theUsernameRenamed.
  ///
  /// In en, this message translates to:
  /// **'The Username has been Renamed to:'**
  String get theUsernameRenamed;

  /// No description provided for @theGenderUpdated.
  ///
  /// In en, this message translates to:
  /// **'The Gender has been Updated to:'**
  String get theGenderUpdated;

  /// No description provided for @theBirthdayUpdated.
  ///
  /// In en, this message translates to:
  /// **'The Birthday has been Updated to'**
  String get theBirthdayUpdated;

  /// No description provided for @theFriendDeclarationRenamed.
  ///
  /// In en, this message translates to:
  /// **'The Friend Declaration has been Renamed to'**
  String get theFriendDeclarationRenamed;

  /// No description provided for @diamondGifts.
  ///
  /// In en, this message translates to:
  /// **'1 diamond = 4 received Gifts'**
  String get diamondGifts;

  /// No description provided for @diamondExperince.
  ///
  /// In en, this message translates to:
  /// **'1 diamond = 4 Experince'**
  String get diamondExperince;

  /// No description provided for @sVIPPrivilege.
  ///
  /// In en, this message translates to:
  /// **'SVIP Privilege'**
  String get sVIPPrivilege;

  /// No description provided for @kickOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Kick Out Successful'**
  String get kickOutSuccess;

  /// No description provided for @selectBirthday.
  ///
  /// In en, this message translates to:
  /// **'Select Birthday'**
  String get selectBirthday;

  /// No description provided for @seeYourVisitors.
  ///
  /// In en, this message translates to:
  /// **'You must be VIP 2 or higher to see your visitors.'**
  String get seeYourVisitors;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @unuse.
  ///
  /// In en, this message translates to:
  /// **'Unuse'**
  String get unuse;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Empty list'**
  String get emptyList;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @levelIcon.
  ///
  /// In en, this message translates to:
  /// **'level Icon'**
  String get levelIcon;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'level'**
  String get level;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get password;

  /// No description provided for @levelRange.
  ///
  /// In en, this message translates to:
  /// **'level range'**
  String get levelRange;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @showGifts.
  ///
  /// In en, this message translates to:
  /// **'Show gifts'**
  String get showGifts;

  /// No description provided for @muteRoom.
  ///
  /// In en, this message translates to:
  /// **'Mute Room'**
  String get muteRoom;

  /// No description provided for @theRoomOpened.
  ///
  /// In en, this message translates to:
  /// **'The Room has been opened'**
  String get theRoomOpened;

  /// No description provided for @animatedEmoji.
  ///
  /// In en, this message translates to:
  /// **'Animated Emoji'**
  String get animatedEmoji;

  /// No description provided for @dataMonth.
  ///
  /// In en, this message translates to:
  /// **'Data of this month'**
  String get dataMonth;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get ok;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @roomInfo.
  ///
  /// In en, this message translates to:
  /// **'Room Info'**
  String get roomInfo;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @takeSeatFailed.
  ///
  /// In en, this message translates to:
  /// **'take seat failed:'**
  String get takeSeatFailed;

  /// No description provided for @moveAnotherRoom.
  ///
  /// In en, this message translates to:
  /// **'Move to another room?'**
  String get moveAnotherRoom;

  /// No description provided for @areMoveAnotherRoom.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to move to another room?'**
  String get areMoveAnotherRoom;

  /// No description provided for @roomAvatar.
  ///
  /// In en, this message translates to:
  /// **'Room Avatar'**
  String get roomAvatar;

  /// No description provided for @getIt.
  ///
  /// In en, this message translates to:
  /// **'Get it'**
  String get getIt;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'balance'**
  String get balance;

  /// No description provided for @postCenter.
  ///
  /// In en, this message translates to:
  /// **'post center'**
  String get postCenter;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @bag.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get bag;

  /// No description provided for @coins4Expernice.
  ///
  /// In en, this message translates to:
  /// **'1 Coins = 4 Expernice'**
  String get coins4Expernice;

  /// No description provided for @coins2Expernice.
  ///
  /// In en, this message translates to:
  /// **'1 Coins = 2 Expernice'**
  String get coins2Expernice;

  /// No description provided for @coins4ExperniceTitle.
  ///
  /// In en, this message translates to:
  /// **'send lucky gifts for get 1000 expernice Maximum Daily, and There is not limit to other gifts'**
  String get coins4ExperniceTitle;

  /// No description provided for @playGame.
  ///
  /// In en, this message translates to:
  /// **'Play a Game'**
  String get playGame;

  /// No description provided for @buySVIP.
  ///
  /// In en, this message translates to:
  /// **'Buy a VIP'**
  String get buySVIP;

  /// No description provided for @buyFrame.
  ///
  /// In en, this message translates to:
  /// **'Buy a Frame'**
  String get buyFrame;

  /// No description provided for @buyCar.
  ///
  /// In en, this message translates to:
  /// **'Buy a Car'**
  String get buyCar;

  /// No description provided for @sendGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get sendGift;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @friendDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Friend Declaration'**
  String get friendDeclaration;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'buy'**
  String get buy;

  /// No description provided for @entry.
  ///
  /// In en, this message translates to:
  /// **'entry'**
  String get entry;

  /// No description provided for @yourFram.
  ///
  /// In en, this message translates to:
  /// **'your fram'**
  String get yourFram;

  /// No description provided for @yourEntry.
  ///
  /// In en, this message translates to:
  /// **'your entry'**
  String get yourEntry;

  /// No description provided for @visitors.
  ///
  /// In en, this message translates to:
  /// **'Visitors'**
  String get visitors;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @recived.
  ///
  /// In en, this message translates to:
  /// **'recived'**
  String get recived;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @lockRoom.
  ///
  /// In en, this message translates to:
  /// **'Lock room'**
  String get lockRoom;

  /// No description provided for @uniqueID.
  ///
  /// In en, this message translates to:
  /// **'unique ID'**
  String get uniqueID;

  /// No description provided for @checkVisitors.
  ///
  /// In en, this message translates to:
  /// **'check visitors'**
  String get checkVisitors;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'coins'**
  String get coins;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'diamond'**
  String get diamond;

  /// No description provided for @quickLevel.
  ///
  /// In en, this message translates to:
  /// **'Quick level'**
  String get quickLevel;

  /// No description provided for @antikick.
  ///
  /// In en, this message translates to:
  /// **'anti ban & kick'**
  String get antikick;

  /// No description provided for @imageGIF.
  ///
  /// In en, this message translates to:
  /// **'GIF Image'**
  String get imageGIF;

  /// No description provided for @hideAccess.
  ///
  /// In en, this message translates to:
  /// **'Hide Access'**
  String get hideAccess;

  /// No description provided for @postCharge.
  ///
  /// In en, this message translates to:
  /// **'post of Charge'**
  String get postCharge;

  /// No description provided for @yourLevel.
  ///
  /// In en, this message translates to:
  /// **'your level'**
  String get yourLevel;

  /// No description provided for @yourExperience.
  ///
  /// In en, this message translates to:
  /// **'your experience'**
  String get yourExperience;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'me'**
  String get me;

  /// No description provided for @amountcoins.
  ///
  /// In en, this message translates to:
  /// **'amount of coins :'**
  String get amountcoins;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @roomSettings.
  ///
  /// In en, this message translates to:
  /// **'Room Settings'**
  String get roomSettings;

  /// No description provided for @announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @roomAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Room Announcement'**
  String get roomAnnouncement;

  /// No description provided for @roomLock.
  ///
  /// In en, this message translates to:
  /// **'Room lock'**
  String get roomLock;

  /// No description provided for @yVIP1UPLockRoom.
  ///
  /// In en, this message translates to:
  /// **'You Must Be VIP 1 or UP to Use Lock Room'**
  String get yVIP1UPLockRoom;

  /// No description provided for @roomOpen.
  ///
  /// In en, this message translates to:
  /// **'Room open'**
  String get roomOpen;

  /// No description provided for @microphones.
  ///
  /// In en, this message translates to:
  /// **'Microphones'**
  String get microphones;

  /// No description provided for @roomWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Room Wallpaper'**
  String get roomWallpaper;

  /// No description provided for @roomAdmin.
  ///
  /// In en, this message translates to:
  /// **'Room Admin'**
  String get roomAdmin;

  /// No description provided for @addUserToAdminList.
  ///
  /// In en, this message translates to:
  /// **'add user to Admin List'**
  String get addUserToAdminList;

  /// No description provided for @roomBlockList.
  ///
  /// In en, this message translates to:
  /// **'Room Block List'**
  String get roomBlockList;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @signGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in Google'**
  String get signGoogle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading'**
  String get loading;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'fail'**
  String get fail;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get success;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select a Country'**
  String get selectCountry;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'log-out'**
  String get logOut;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get back;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @charm.
  ///
  /// In en, this message translates to:
  /// **'Charm'**
  String get charm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get clear;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'down'**
  String get down;

  /// No description provided for @clearGiftsCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Gift Data'**
  String get clearGiftsCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Gift data cleared successfully'**
  String get cacheCleared;

  /// No description provided for @cacheClearError.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear gift data'**
  String get cacheClearError;

  /// No description provided for @youarenotinwakala.
  ///
  /// In en, this message translates to:
  /// **'You are not join to any wakala'**
  String get youarenotinwakala;

  /// No description provided for @iDORName.
  ///
  /// In en, this message translates to:
  /// **'ID / Name'**
  String get iDORName;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'write a Message'**
  String get writeMessage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get theme;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @take.
  ///
  /// In en, this message translates to:
  /// **'take'**
  String get take;

  /// No description provided for @kickOut.
  ///
  /// In en, this message translates to:
  /// **'Kick'**
  String get kickOut;

  /// No description provided for @switchh.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchh;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'mute'**
  String get mute;

  /// No description provided for @leaveMic.
  ///
  /// In en, this message translates to:
  /// **'leave Mic'**
  String get leaveMic;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'lock'**
  String get lock;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @giveThePermissionPlease.
  ///
  /// In en, this message translates to:
  /// **'Give The Permission Please'**
  String get giveThePermissionPlease;

  /// No description provided for @youAreBannedFromEnterThisRoom.
  ///
  /// In en, this message translates to:
  /// **'You Are Banned From Enter This Room'**
  String get youAreBannedFromEnterThisRoom;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @batteryOptimizationAlreadyDisabled.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization is already disabled.'**
  String get batteryOptimizationAlreadyDisabled;

  /// No description provided for @openedBatteryOptimizationSettings.
  ///
  /// In en, this message translates to:
  /// **'Opened battery optimization settings.'**
  String get openedBatteryOptimizationSettings;

  /// No description provided for @failedToOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to open settings: {error}'**
  String failedToOpenSettings(Object error);

  /// No description provided for @manufacturerOptimizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Optimization'**
  String get manufacturerOptimizationTitle;

  /// No description provided for @manufacturerOptimizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the steps to disable manufacturer-specific optimizations.'**
  String get manufacturerOptimizationDescription;

  /// No description provided for @enableAutoStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Auto Start'**
  String get enableAutoStartTitle;

  /// No description provided for @enableAutoStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the steps and enable the auto start of this app.'**
  String get enableAutoStartDescription;

  /// No description provided for @openedManufacturerSettings.
  ///
  /// In en, this message translates to:
  /// **'Opened manufacturer battery optimization settings.'**
  String get openedManufacturerSettings;

  /// No description provided for @unUse.
  ///
  /// In en, this message translates to:
  /// **'UnUse'**
  String get unUse;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @notForSell.
  ///
  /// In en, this message translates to:
  /// **'not for sell'**
  String get notForSell;

  /// No description provided for @openedAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Opened all battery optimization settings.'**
  String get openedAllSettings;

  /// No description provided for @help_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Help Screen'**
  String get help_screen_title;

  /// No description provided for @dropdown_label.
  ///
  /// In en, this message translates to:
  /// **'Select Issue Category'**
  String get dropdown_label;

  /// No description provided for @description_label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description_label;

  /// No description provided for @submit_button.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submit_button;

  /// No description provided for @success_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Successfully Sent'**
  String get success_dialog_title;

  /// No description provided for @success_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback! Your request has been successfully submitted.'**
  String get success_dialog_content;

  /// No description provided for @error_message.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_message;

  /// No description provided for @privacypolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacypolicy;

  /// No description provided for @viewPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'view Privacy Policy'**
  String get viewPrivacyPolicy;

  /// No description provided for @pleaseAgreeToPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'please Agree To Privacy Policy'**
  String get pleaseAgreeToPrivacyPolicy;

  /// No description provided for @agreeToPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'agree To Privacy Policy'**
  String get agreeToPrivacyPolicy;

  /// No description provided for @sendToAllUsersInTheRoom.
  ///
  /// In en, this message translates to:
  /// **'Send To All Users In The Room'**
  String get sendToAllUsersInTheRoom;

  /// No description provided for @sendToAllUsersInMicrophones.
  ///
  /// In en, this message translates to:
  /// **'Send To All Users In Microphones'**
  String get sendToAllUsersInMicrophones;

  /// No description provided for @deleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Your Account'**
  String get deleteYourAccount;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMustBeAtLeast6Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Chars;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'player'**
  String get player;

  /// No description provided for @noSongSelected.
  ///
  /// In en, this message translates to:
  /// **'No Song Selected '**
  String get noSongSelected;

  /// No description provided for @playlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist ({count})'**
  String playlistTitle(Object count);

  /// No description provided for @emptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'No songs in playlist '**
  String get emptyPlaylist;

  /// No description provided for @muteLocal.
  ///
  /// In en, this message translates to:
  /// **'Mute\nLocal'**
  String get muteLocal;

  /// No description provided for @auxLabel.
  ///
  /// In en, this message translates to:
  /// **'AUX'**
  String get auxLabel;

  /// No description provided for @addSongs.
  ///
  /// In en, this message translates to:
  /// **'Add Songs'**
  String get addSongs;

  /// No description provided for @addSongsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add songs: {error}'**
  String addSongsError(Object error);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @unselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect All'**
  String get unselectAll;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @deviceSongsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Songs'**
  String get deviceSongsTitle;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @permissionAudioAndroid.
  ///
  /// In en, this message translates to:
  /// **'Please grant access to audio files to show device songs.'**
  String get permissionAudioAndroid;

  /// No description provided for @permissionAudioIOS.
  ///
  /// In en, this message translates to:
  /// **'Please grant access to the Music library.'**
  String get permissionAudioIOS;

  /// No description provided for @deviceReadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to read device songs: {error}'**
  String deviceReadError(Object error);

  /// No description provided for @deleteWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'All your data, progress, and coins will be permanently deleted and cannot be restored. Are you sure?'**
  String get deleteWarningMessage;

  /// No description provided for @sendto.
  ///
  /// In en, this message translates to:
  /// **' send to '**
  String get sendto;

  /// No description provided for @waitforcheckyouimage.
  ///
  /// In en, this message translates to:
  /// **'please wait for check your image in our server we will send to you in our chat'**
  String get waitforcheckyouimage;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get warningTitle;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @pleaseEnableStoragePermissionInSettings.
  ///
  /// In en, this message translates to:
  /// **'Please enable storage permission in settings'**
  String get pleaseEnableStoragePermissionInSettings;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @joinToWakala.
  ///
  /// In en, this message translates to:
  /// **'Join To Wakala'**
  String get joinToWakala;

  /// No description provided for @leaveWakala.
  ///
  /// In en, this message translates to:
  /// **'Leave Wakala'**
  String get leaveWakala;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copy;

  /// No description provided for @realtion.
  ///
  /// In en, this message translates to:
  /// **'relation'**
  String get realtion;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'track'**
  String get track;

  /// No description provided for @exiting.
  ///
  /// In en, this message translates to:
  /// **'... exiting ...'**
  String get exiting;

  /// No description provided for @theUserIsNotInAnyRoom.
  ///
  /// In en, this message translates to:
  /// **'the user is not in any room'**
  String get theUserIsNotInAnyRoom;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter New Name'**
  String get enterNewName;

  /// No description provided for @youAreInSameRoom.
  ///
  /// In en, this message translates to:
  /// **'you are in same room'**
  String get youAreInSameRoom;

  /// No description provided for @watchAdButton.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAdButton;

  /// No description provided for @adLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load ad. Please try again later.'**
  String get adLoadError;

  /// No description provided for @adShowError.
  ///
  /// In en, this message translates to:
  /// **'Error showing ad.'**
  String get adShowError;

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'Ad is not ready yet. Please wait...'**
  String get adNotReady;

  /// No description provided for @rewardReceived.
  ///
  /// In en, this message translates to:
  /// **'Reward received successfully!'**
  String get rewardReceived;

  /// No description provided for @rewardError.
  ///
  /// In en, this message translates to:
  /// **'Error adding coins'**
  String get rewardError;

  /// No description provided for @cooldownMessage.
  ///
  /// In en, this message translates to:
  /// **'Wait {minutes}:{seconds}'**
  String cooldownMessage(Object minutes, Object seconds);

  /// No description provided for @maxAdsReachedError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the daily ad limit. Please come back tomorrow.'**
  String get maxAdsReachedError;

  /// No description provided for @adsNumber.
  ///
  /// In en, this message translates to:
  /// **'number of watched ads ({number}/15)'**
  String adsNumber(Object number);

  /// No description provided for @ban.
  ///
  /// In en, this message translates to:
  /// **'ban'**
  String get ban;

  /// No description provided for @kickOutdone.
  ///
  /// In en, this message translates to:
  /// **'kickOut done'**
  String get kickOutdone;

  /// No description provided for @addAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin+'**
  String get addAdmin;

  /// No description provided for @removeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin-'**
  String get removeAdmin;

  /// No description provided for @suggestion_category.
  ///
  /// In en, this message translates to:
  /// **'App improvement suggestion'**
  String get suggestion_category;

  /// No description provided for @problem_category.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get problem_category;

  /// No description provided for @report_user_category.
  ///
  /// In en, this message translates to:
  /// **'Report a user'**
  String get report_user_category;

  /// No description provided for @charging_issue_category.
  ///
  /// In en, this message translates to:
  /// **'Charging issue'**
  String get charging_issue_category;

  /// No description provided for @other_category.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other_category;

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get unspecified;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Successfully sent'**
  String get success_title;

  /// No description provided for @success_message.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback! Your request has been successfully submitted.'**
  String get success_message;

  /// No description provided for @ok_button.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok_button;

  /// No description provided for @category_validation.
  ///
  /// In en, this message translates to:
  /// **'Please select a request category'**
  String get category_validation;

  /// No description provided for @description_validation.
  ///
  /// In en, this message translates to:
  /// **'Please write the description'**
  String get description_validation;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission Required'**
  String get microphonePermissionRequired;

  /// No description provided for @noValidFiles.
  ///
  /// In en, this message translates to:
  /// **'No Valid Files'**
  String get noValidFiles;

  /// No description provided for @enjoyWithFun.
  ///
  /// In en, this message translates to:
  /// **'Enjoy With Funny Show !'**
  String get enjoyWithFun;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get moreDetails;

  /// No description provided for @postConvertCoins.
  ///
  /// In en, this message translates to:
  /// **'post convert coins'**
  String get postConvertCoins;

  /// No description provided for @entrePrice.
  ///
  /// In en, this message translates to:
  /// **'Entre Price'**
  String get entrePrice;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 100'**
  String get priceHint;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @valueMustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Value must be a valid number'**
  String get valueMustBeNumber;

  /// No description provided for @whatsAppNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'whatsApp Not Installed'**
  String get whatsAppNotInstalled;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'error Occurred'**
  String get errorOccurred;

  /// No description provided for @wakalaNamee.
  ///
  /// In en, this message translates to:
  /// **'wakala Name'**
  String get wakalaNamee;

  /// No description provided for @wakala.
  ///
  /// In en, this message translates to:
  /// **'wakala'**
  String get wakala;

  /// No description provided for @wakelID.
  ///
  /// In en, this message translates to:
  /// **'wakel ID'**
  String get wakelID;

  /// No description provided for @wakelName.
  ///
  /// In en, this message translates to:
  /// **'wakel Name'**
  String get wakelName;

  /// No description provided for @joinToOtherWakala.
  ///
  /// In en, this message translates to:
  /// **'join To Other Wakala'**
  String get joinToOtherWakala;

  /// No description provided for @monthlyStats.
  ///
  /// In en, this message translates to:
  /// **'monthly Stats'**
  String get monthlyStats;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'gold'**
  String get gold;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'target'**
  String get target;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name Required'**
  String get nameRequired;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'try Again'**
  String get tryAgain;

  /// No description provided for @maybeTheChangesTakeAboutTenSeconds.
  ///
  /// In en, this message translates to:
  /// **'Maybe The Changes Take About 10 Seconds'**
  String get maybeTheChangesTakeAboutTenSeconds;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @showTopBar.
  ///
  /// In en, this message translates to:
  /// **'show topbar'**
  String get showTopBar;

  /// No description provided for @deleteAllMessagesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all messages?'**
  String get deleteAllMessagesConfirmation;

  /// No description provided for @texitingrack.
  ///
  /// In en, this message translates to:
  /// **'...exiting...'**
  String get texitingrack;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'hold'**
  String get hold;

  /// No description provided for @entered.
  ///
  /// In en, this message translates to:
  /// **'entered'**
  String get entered;

  /// No description provided for @famous.
  ///
  /// In en, this message translates to:
  /// **'famous'**
  String get famous;

  /// No description provided for @moneyBagTransferMessage.
  ///
  /// In en, this message translates to:
  /// **'moneyBagTransferMessage'**
  String get moneyBagTransferMessage;

  /// No description provided for @deleteAllMessagesConfirmationHost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all messages for everyone?'**
  String get deleteAllMessagesConfirmationHost;

  /// No description provided for @moneyBagTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'moneyBagTransferTitle'**
  String get moneyBagTransferTitle;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent successfully'**
  String get friendRequestSent;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @myLevel.
  ///
  /// In en, this message translates to:
  /// **'My Level'**
  String get myLevel;

  /// No description provided for @upgrades.
  ///
  /// In en, this message translates to:
  /// **'Upgrades'**
  String get upgrades;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @missions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missions;

  /// No description provided for @dailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get dailyTasks;

  /// No description provided for @weeklyTasks.
  ///
  /// In en, this message translates to:
  /// **'Weekly Tasks'**
  String get weeklyTasks;

  /// No description provided for @monthlyTasks.
  ///
  /// In en, this message translates to:
  /// **'Monthly Tasks'**
  String get monthlyTasks;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @pointsToUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Points to Upgrade'**
  String get pointsToUpgrade;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task Completed'**
  String get taskCompleted;

  /// No description provided for @taskInProgress.
  ///
  /// In en, this message translates to:
  /// **'Task In Progress'**
  String get taskInProgress;

  /// No description provided for @taskNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Task Not Started'**
  String get taskNotStarted;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users by name or ID'**
  String get searchUsers;

  /// No description provided for @noUsersToSearch.
  ///
  /// In en, this message translates to:
  /// **'No users to search'**
  String get noUsersToSearch;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \'{query}\''**
  String noResults(Object query);

  /// No description provided for @rawMissions.
  ///
  /// In en, this message translates to:
  /// **'Raw Missions'**
  String get rawMissions;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @noMissionsResponse.
  ///
  /// In en, this message translates to:
  /// **'No missions response yet'**
  String get noMissionsResponse;

  /// No description provided for @loadingTasks.
  ///
  /// In en, this message translates to:
  /// **'Loading tasks...'**
  String get loadingTasks;

  /// No description provided for @errorLoadingTasks.
  ///
  /// In en, this message translates to:
  /// **'Error loading tasks'**
  String get errorLoadingTasks;

  /// No description provided for @refreshTasks.
  ///
  /// In en, this message translates to:
  /// **'Refresh Tasks'**
  String get refreshTasks;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @topUsers.
  ///
  /// In en, this message translates to:
  /// **'Top Users'**
  String get topUsers;

  /// No description provided for @topAgencies.
  ///
  /// In en, this message translates to:
  /// **'Top Agencies'**
  String get topAgencies;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @invitationCentre.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get invitationCentre;

  /// No description provided for @detailedRecords.
  ///
  /// In en, this message translates to:
  /// **'Detailed Records'**
  String get detailedRecords;

  /// No description provided for @totalProfits.
  ///
  /// In en, this message translates to:
  /// **'Total Profits'**
  String get totalProfits;

  /// No description provided for @totalInvitees.
  ///
  /// In en, this message translates to:
  /// **'Total Number of Invitees'**
  String get totalInvitees;

  /// No description provided for @todaysProfits.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Profits'**
  String get todaysProfits;

  /// No description provided for @withdrawNote.
  ///
  /// In en, this message translates to:
  /// **'Withdrawable for the next day (GMT+3) 00:00'**
  String get withdrawNote;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAWAL'**
  String get withdrawal;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @earnMoreProfits.
  ///
  /// In en, this message translates to:
  /// **'EARN MORE PROFITS'**
  String get earnMoreProfits;

  /// No description provided for @inviteFriendsDesc.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and earn rewards'**
  String get inviteFriendsDesc;

  /// No description provided for @invitationTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Tasks'**
  String get invitationTasksTitle;

  /// No description provided for @invitationSystem.
  ///
  /// In en, this message translates to:
  /// **'Invitation System'**
  String get invitationSystem;

  /// No description provided for @invitationSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends via your personal invite link, and their accounts will be linked to you directly (as long as they are not already registered).'**
  String get invitationSystemDesc;

  /// No description provided for @yourRewards.
  ///
  /// In en, this message translates to:
  /// **'Your Rewards'**
  String get yourRewards;

  /// No description provided for @invitationRewardsDesc.
  ///
  /// In en, this message translates to:
  /// **'When the invited user recharges balance, you will receive 10% of the recharge value. When you receive your salary from your activity and points, you will also get 10% of the salary value directly.'**
  String get invitationRewardsDesc;

  /// No description provided for @inviteNowFooter.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends now and enjoy continuous rewards'**
  String get inviteNowFooter;

  /// No description provided for @invitationLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Link'**
  String get invitationLinkTitle;

  /// No description provided for @registerViaYourLink.
  ///
  /// In en, this message translates to:
  /// **'Register via your link'**
  String get registerViaYourLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @shareWith.
  ///
  /// In en, this message translates to:
  /// **'Share with'**
  String get shareWith;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'reload'**
  String get reload;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @copyFirstThenShare.
  ///
  /// In en, this message translates to:
  /// **'Copy the link first then choose a platform to share'**
  String get copyFirstThenShare;

  /// No description provided for @completeVariousTasks.
  ///
  /// In en, this message translates to:
  /// **'You need to complete various tasks'**
  String get completeVariousTasks;

  /// No description provided for @toReachLevelsAndRewards.
  ///
  /// In en, this message translates to:
  /// **'To reach levels and rewards for each task'**
  String get toReachLevelsAndRewards;

  /// No description provided for @clickHereToOpenTasksPage.
  ///
  /// In en, this message translates to:
  /// **'Click here to open tasks page'**
  String get clickHereToOpenTasksPage;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
