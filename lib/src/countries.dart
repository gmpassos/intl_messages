import 'dart:collection';

/// A list with all the countries info.
final allCountries = {
  'AD': {'name': "Andorra", 'dial': 376},
  'AE': {'name': "United Arab Emirates", 'dial': 971},
  'AF': {'name': "Afghanistan", 'dial': 93},
  'AG': {'name': "Antigua and Barbuda", 'dial': 1268},
  'AI': {'name': "Anguilla", 'dial': 1264},
  'AL': {'name': "Albania", 'dial': 355},
  'AM': {'name': "Armenia", 'dial': 374},
  'AN': {'name': "Netherlands Antilles", 'dial': 599},
  'AO': {'name': "Angola", 'dial': 244},
  'AQ': {'name': "Antarctica", 'dial': 672},
  'AR': {'name': "Argentina", 'dial': 54},
  'AS': {'name': "AmericanSamoa", 'dial': 1684},
  'AT': {'name': "Austria", 'dial': 43},
  'AU': {'name': "Australia", 'dial': 61},
  'AW': {'name': "Aruba", 'dial': 297},
  'AX': {'name': "Aland Islands", 'dial': 358},
  'AZ': {'name': "Azerbaijan", 'dial': 994},
  'BA': {'name': "Bosnia and Herzegovina", 'dial': 387},
  'BB': {'name': "Barbados", 'dial': 1246},
  'BD': {'name': "Bangladesh", 'dial': 880},
  'BE': {'name': "Belgium", 'dial': 32},
  'BF': {'name': "Burkina Faso", 'dial': 226},
  'BG': {'name': "Bulgaria", 'dial': 359},
  'BH': {'name': "Bahrain", 'dial': 973},
  'BI': {'name': "Burundi", 'dial': 257},
  'BJ': {'name': "Benin", 'dial': 229},
  'BL': {'name': "Saint Barthelemy", 'dial': 590},
  'BM': {'name': "Bermuda", 'dial': 1441},
  'BN': {'name': "Brunei Darussalam", 'dial': 673},
  'BO': {'name': "Bolivia, Plurinational State of", 'dial': 591},
  'BR': {'name': "Brazil", 'dial': 55},
  'BS': {'name': "Bahamas", 'dial': 1242},
  'BT': {'name': "Bhutan", 'dial': 975},
  'BW': {'name': "Botswana", 'dial': 267},
  'BY': {'name': "Belarus", 'dial': 375},
  'BZ': {'name': "Belize", 'dial': 501},
  'CA': {'name': "Canada", 'dial': 1},
  'CC': {'name': "Cocos (Keeling) Islands", 'dial': 61},
  'CD': {'name': "Congo, The Democratic Republic of the Congo", 'dial': 243},
  'CF': {'name': "Central African Republic", 'dial': 236},
  'CG': {'name': "Congo", 'dial': 242},
  'CH': {'name': "Switzerland", 'dial': 41},
  'CI': {'name': "Cote d'Ivoire", 'dial': 225},
  'CK': {'name': "Cook Islands", 'dial': 682},
  'CL': {'name': "Chile", 'dial': 56},
  'CM': {'name': "Cameroon", 'dial': 237},
  'CN': {'name': "China", 'dial': 86},
  'CO': {'name': "Colombia", 'dial': 57},
  'CR': {'name': "Costa Rica", 'dial': 506},
  'CU': {'name': "Cuba", 'dial': 53},
  'CV': {'name': "Cape Verde", 'dial': 238},
  'CX': {'name': "Christmas Island", 'dial': 61},
  'CY': {'name': "Cyprus", 'dial': 357},
  'CZ': {'name': "Czech Republic", 'dial': 420},
  'DE': {'name': "Germany", 'dial': 49},
  'DJ': {'name': "Djibouti", 'dial': 253},
  'DK': {'name': "Denmark", 'dial': 45},
  'DM': {'name': "Dominica", 'dial': 1767},
  'DO': {'name': "Dominican Republic", 'dial': 1849},
  'DZ': {'name': "Algeria", 'dial': 213},
  'EC': {'name': "Ecuador", 'dial': 593},
  'EE': {'name': "Estonia", 'dial': 372},
  'EG': {'name': "Egypt", 'dial': 20},
  'ER': {'name': "Eritrea", 'dial': 291},
  'ES': {'name': "Spain", 'dial': 34},
  'ET': {'name': "Ethiopia", 'dial': 251},
  'FI': {'name': "Finland", 'dial': 358},
  'FJ': {'name': "Fiji", 'dial': 679},
  'FK': {'name': "Falkland Islands (Malvinas)", 'dial': 500},
  'FM': {'name': "Micronesia, Federated States of Micronesia", 'dial': 691},
  'FO': {'name': "Faroe Islands", 'dial': 298},
  'FR': {'name': "France", 'dial': 33},
  'GA': {'name': "Gabon", 'dial': 241},
  'GB': {'name': "United Kingdom", 'dial': 44},
  'GD': {'name': "Grenada", 'dial': 1473},
  'GE': {'name': "Georgia", 'dial': 995},
  'GF': {'name': "French Guiana", 'dial': 594},
  'GG': {'name': "Guernsey", 'dial': 44},
  'GH': {'name': "Ghana", 'dial': 233},
  'GI': {'name': "Gibraltar", 'dial': 350},
  'GL': {'name': "Greenland", 'dial': 299},
  'GM': {'name': "Gambia", 'dial': 220},
  'GN': {'name': "Guinea", 'dial': 224},
  'GP': {'name': "Guadeloupe", 'dial': 590},
  'GQ': {'name': "Equatorial Guinea", 'dial': 240},
  'GR': {'name': "Greece", 'dial': 30},
  'GS': {'name': "South Georgia and the South Sandwich Islands", 'dial': 500},
  'GT': {'name': "Guatemala", 'dial': 502},
  'GU': {'name': "Guam", 'dial': 1671},
  'GW': {'name': "Guinea-Bissau", 'dial': 245},
  'GY': {'name': "Guyana", 'dial': 595},
  'HK': {'name': "Hong Kong", 'dial': 852},
  'HN': {'name': "Honduras", 'dial': 504},
  'HR': {'name': "Croatia", 'dial': 385},
  'HT': {'name': "Haiti", 'dial': 509},
  'HU': {'name': "Hungary", 'dial': 36},
  'ID': {'name': "Indonesia", 'dial': 62},
  'IE': {'name': "Ireland", 'dial': 353},
  'IL': {'name': "Israel", 'dial': 972},
  'IM': {'name': "Isle of Man", 'dial': 44},
  'IN': {'name': "India", 'dial': 91},
  'IO': {'name': "British Indian Ocean Territory", 'dial': 246},
  'IQ': {'name': "Iraq", 'dial': 964},
  'IR': {'name': "Iran, Islamic Republic of Persian Gulf", 'dial': 98},
  'IS': {'name': "Iceland", 'dial': 354},
  'IT': {'name': "Italy", 'dial': 39},
  'JE': {'name': "Jersey", 'dial': 44},
  'JM': {'name': "Jamaica", 'dial': 1876},
  'JO': {'name': "Jordan", 'dial': 962},
  'JP': {'name': "Japan", 'dial': 81},
  'KE': {'name': "Kenya", 'dial': 254},
  'KG': {'name': "Kyrgyzstan", 'dial': 996},
  'KH': {'name': "Cambodia", 'dial': 855},
  'KI': {'name': "Kiribati", 'dial': 686},
  'KM': {'name': "Comoros", 'dial': 269},
  'KN': {'name': "Saint Kitts and Nevis", 'dial': 1869},
  'KP': {'name': "Korea, Democratic People's Republic of Korea", 'dial': 850},
  'KR': {'name': "Korea, Republic of South Korea", 'dial': 82},
  'KW': {'name': "Kuwait", 'dial': 965},
  'KY': {'name': "Cayman Islands", 'dial': 345},
  'KZ': {'name': "Kazakhstan", 'dial': 77},
  'LA': {'name': "Laos", 'dial': 856},
  'LB': {'name': "Lebanon", 'dial': 961},
  'LC': {'name': "Saint Lucia", 'dial': 1758},
  'LI': {'name': "Liechtenstein", 'dial': 423},
  'LK': {'name': "Sri Lanka", 'dial': 94},
  'LR': {'name': "Liberia", 'dial': 231},
  'LS': {'name': "Lesotho", 'dial': 266},
  'LT': {'name': "Lithuania", 'dial': 370},
  'LU': {'name': "Luxembourg", 'dial': 352},
  'LV': {'name': "Latvia", 'dial': 371},
  'LY': {'name': "Libyan Arab Jamahiriya", 'dial': 218},
  'MA': {'name': "Morocco", 'dial': 212},
  'MC': {'name': "Monaco", 'dial': 377},
  'MD': {'name': "Moldova", 'dial': 373},
  'ME': {'name': "Montenegro", 'dial': 382},
  'MF': {'name': "Saint Martin", 'dial': 590},
  'MG': {'name': "Madagascar", 'dial': 261},
  'MH': {'name': "Marshall Islands", 'dial': 692},
  'MK': {'name': "Macedonia", 'dial': 389},
  'ML': {'name': "Mali", 'dial': 223},
  'MM': {'name': "Myanmar", 'dial': 95},
  'MN': {'name': "Mongolia", 'dial': 976},
  'MO': {'name': "Macao", 'dial': 853},
  'MP': {'name': "Northern Mariana Islands", 'dial': 1670},
  'MQ': {'name': "Martinique", 'dial': 596},
  'MR': {'name': "Mauritania", 'dial': 222},
  'MS': {'name': "Montserrat", 'dial': 1664},
  'MT': {'name': "Malta", 'dial': 356},
  'MU': {'name': "Mauritius", 'dial': 230},
  'MV': {'name': "Maldives", 'dial': 960},
  'MW': {'name': "Malawi", 'dial': 265},
  'MX': {'name': "Mexico", 'dial': 52},
  'MY': {'name': "Malaysia", 'dial': 60},
  'MZ': {'name': "Mozambique", 'dial': 258},
  'NA': {'name': "Namibia", 'dial': 264},
  'NC': {'name': "New Caledonia", 'dial': 687},
  'NE': {'name': "Niger", 'dial': 227},
  'NF': {'name': "Norfolk Island", 'dial': 672},
  'NG': {'name': "Nigeria", 'dial': 234},
  'NI': {'name': "Nicaragua", 'dial': 505},
  'NL': {'name': "Netherlands", 'dial': 31},
  'NO': {'name': "Norway", 'dial': 47},
  'NP': {'name': "Nepal", 'dial': 977},
  'NR': {'name': "Nauru", 'dial': 674},
  'NU': {'name': "Niue", 'dial': 683},
  'NZ': {'name': "New Zealand", 'dial': 64},
  'OM': {'name': "Oman", 'dial': 968},
  'PA': {'name': "Panama", 'dial': 507},
  'PE': {'name': "Peru", 'dial': 51},
  'PF': {'name': "French Polynesia", 'dial': 689},
  'PG': {'name': "Papua New Guinea", 'dial': 675},
  'PH': {'name': "Philippines", 'dial': 63},
  'PK': {'name': "Pakistan", 'dial': 92},
  'PL': {'name': "Poland", 'dial': 48},
  'PM': {'name': "Saint Pierre and Miquelon", 'dial': 508},
  'PN': {'name': "Pitcairn", 'dial': 872},
  'PR': {'name': "Puerto Rico", 'dial': 1939},
  'PS': {'name': "Palestinian Territory, Occupied", 'dial': 970},
  'PT': {'name': "Portugal", 'dial': 351},
  'PW': {'name': "Palau", 'dial': 680},
  'PY': {'name': "Paraguay", 'dial': 595},
  'QA': {'name': "Qatar", 'dial': 974},
  'RE': {'name': "Reunion", 'dial': 262},
  'RO': {'name': "Romania", 'dial': 40},
  'RS': {'name': "Serbia", 'dial': 381},
  'RU': {'name': "Russia", 'dial': 7},
  'RW': {'name': "Rwanda", 'dial': 250},
  'SA': {'name': "Saudi Arabia", 'dial': 966},
  'SB': {'name': "Solomon Islands", 'dial': 677},
  'SC': {'name': "Seychelles", 'dial': 248},
  'SD': {'name': "Sudan", 'dial': 249},
  'SE': {'name': "Sweden", 'dial': 46},
  'SG': {'name': "Singapore", 'dial': 65},
  'SH': {'name': "Saint Helena, Ascension and Tristan Da Cunha", 'dial': 290},
  'SI': {'name': "Slovenia", 'dial': 386},
  'SJ': {'name': "Svalbard and Jan Mayen", 'dial': 47},
  'SK': {'name': "Slovakia", 'dial': 421},
  'SL': {'name': "Sierra Leone", 'dial': 232},
  'SM': {'name': "San Marino", 'dial': 378},
  'SN': {'name': "Senegal", 'dial': 221},
  'SO': {'name': "Somalia", 'dial': 252},
  'SR': {'name': "Suriname", 'dial': 597},
  'SS': {'name': "South Sudan", 'dial': 211},
  'ST': {'name': "Sao Tome and Principe", 'dial': 239},
  'SV': {'name': "El Salvador", 'dial': 503},
  'SY': {'name': "Syrian Arab Republic", 'dial': 963},
  'SZ': {'name': "Swaziland", 'dial': 268},
  'TC': {'name': "Turks and Caicos Islands", 'dial': 1649},
  'TD': {'name': "Chad", 'dial': 235},
  'TG': {'name': "Togo", 'dial': 228},
  'TH': {'name': "Thailand", 'dial': 66},
  'TJ': {'name': "Tajikistan", 'dial': 992},
  'TK': {'name': "Tokelau", 'dial': 690},
  'TL': {'name': "Timor-Leste", 'dial': 670},
  'TM': {'name': "Turkmenistan", 'dial': 993},
  'TN': {'name': "Tunisia", 'dial': 216},
  'TO': {'name': "Tonga", 'dial': 676},
  'TR': {'name': "Turkey", 'dial': 90},
  'TT': {'name': "Trinidad and Tobago", 'dial': 1868},
  'TV': {'name': "Tuvalu", 'dial': 688},
  'TW': {'name': "Taiwan", 'dial': 886},
  'TZ': {'name': "Tanzania, United Republic of Tanzania", 'dial': 255},
  'UA': {'name': "Ukraine", 'dial': 380},
  'UG': {'name': "Uganda", 'dial': 256},
  'US': {'name': "United States", 'dial': 1},
  'UY': {'name': "Uruguay", 'dial': 598},
  'UZ': {'name': "Uzbekistan", 'dial': 998},
  'VA': {'name': "Holy See (Vatican City State)", 'dial': 379},
  'VC': {'name': "Saint Vincent and the Grenadines", 'dial': 1784},
  'VE': {'name': "Venezuela, Bolivarian Republic of Venezuela", 'dial': 58},
  'VG': {'name': "Virgin Islands, British", 'dial': 1284},
  'VI': {'name': "Virgin Islands, U.S.", 'dial': 1340},
  'VN': {'name': "Vietnam", 'dial': 84},
  'VU': {'name': "Vanuatu", 'dial': 678},
  'WF': {'name': "Wallis and Futuna", 'dial': 681},
  'WS': {'name': "Samoa", 'dial': 685},
  'YE': {'name': "Yemen", 'dial': 967},
  'YT': {'name': "Mayotte", 'dial': 262},
  'ZA': {'name': "South Africa", 'dial': 27},
  'ZM': {'name': "Zambia", 'dial': 260},
  'ZW': {'name': "Zimbabwe", 'dial': 263},
}
    .entries
    .map((e) {
      var code = e.key;
      var name = e.value['name'] as String;
      var dial = e.value['dial'] as int;
      return CountryInfo(code.trim().toUpperCase(), name.trim(), dial);
    })
    .toList(growable: false)
    .asUnmodifiableView;

final allCountriesByCode =
    allCountries.map((e) => MapEntry(e.code, e)).toMapFromEntries();

final allCountriesByDialCode =
    allCountries.map((e) => MapEntry(e.dialCode, e)).toMapFromEntries();

final allCountriesByName = allCountries
    .map((e) => MapEntry(e.name.toLowerCase(), e))
    .toMapFromEntries();

/// A country info.
class CountryInfo {
  /// The code of the country in upper-case.
  final String code;

  /// The name of the country.
  final String name;

  /// The dial code of the country.
  final int dialCode;

  CountryInfo(this.code, this.name, this.dialCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryInfo &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          dialCode == other.dialCode;

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ dialCode.hashCode;

  @override
  String toString() {
    return 'CountryInfo{code: $code, name: $name, dialCode: $dialCode}';
  }
}

/// Returns a [CountryInfo] by [countryCode], [dialCode] or [countryName].
CountryInfo? getCountryInfo(
    {String? countryCode, int? dialCode, String? countryName}) {
  if (countryCode != null) {
    var e = allCountriesByCode[countryCode.trim().toUpperCase()];
    if (e != null) return e;
  }

  if (dialCode != null) {
    var e = allCountriesByDialCode[dialCode];
    if (e != null) return e;
  }

  if (countryName != null) {
    var e = allCountriesByName[countryName.trim().toLowerCase()];
    if (e != null) return e;
  }

  return null;
}

extension _ListExtension<T> on List<T> {
  List<T> get asUnmodifiableView => UnmodifiableListView(this);
}

extension _IterableMapEntryExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMapFromEntries() => Map<K, V>.fromEntries(this);
}
