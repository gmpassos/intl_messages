import 'dart:collection';

/// A list with all the countries info.
final allCountries = const {
  'AD': {
    'name': "Andorra",
    'dial': 376,
    'lang': ['ca']
  },
  'AE': {
    'name': "United Arab Emirates",
    'dial': 971,
    'lang': ['ar']
  },
  'AF': {
    'name': "Afghanistan",
    'dial': 93,
    'lang': ['ps', 'uz', 'tk']
  },
  'AG': {
    'name': "Antigua and Barbuda",
    'dial': 1268,
    'lang': ['en']
  },
  'AI': {
    'name': "Anguilla",
    'dial': 1264,
    'lang': ['en']
  },
  'AL': {
    'name': "Albania",
    'dial': 355,
    'lang': ['sq']
  },
  'AM': {
    'name': "Armenia",
    'dial': 374,
    'lang': ['hy']
  },
  'AN': {
    'name': "Netherlands Antilles",
    'dial': 599,
    'lang': ['nl', 'en', 'pap']
  },
  'AO': {
    'name': "Angola",
    'dial': 244,
    'lang': ['pt']
  },
  'AQ': {
    'name': "Antarctica",
    'dial': 672,
    'lang': ['en', 'ru']
  },
  'AR': {
    'name': "Argentina",
    'dial': 54,
    'lang': ['es']
  },
  'AS': {
    'name': "American Samoa",
    'dial': 1684,
    'lang': ['en', 'sm']
  },
  'AT': {
    'name': "Austria",
    'dial': 43,
    'lang': ['de']
  },
  'AU': {
    'name': "Australia",
    'dial': 61,
    'lang': ['en']
  },
  'AW': {
    'name': "Aruba",
    'dial': 297,
    'lang': ['nl', 'pap']
  },
  'AX': {
    'name': "Aland Islands",
    'dial': 358,
    'lang': ['sv']
  },
  'AZ': {
    'name': "Azerbaijan",
    'dial': 994,
    'lang': ['az']
  },
  'BA': {
    'name': "Bosnia and Herzegovina",
    'dial': 387,
    'lang': ['bs', 'hr', 'sr']
  },
  'BB': {
    'name': "Barbados",
    'dial': 1246,
    'lang': ['en']
  },
  'BD': {
    'name': "Bangladesh",
    'dial': 880,
    'lang': ['bn']
  },
  'BE': {
    'name': "Belgium",
    'dial': 32,
    'lang': ['nl', 'fr', 'de']
  },
  'BF': {
    'name': "Burkina Faso",
    'dial': 226,
    'lang': ['fr']
  },
  'BG': {
    'name': "Bulgaria",
    'dial': 359,
    'lang': ['bg']
  },
  'BH': {
    'name': "Bahrain",
    'dial': 973,
    'lang': ['ar']
  },
  'BI': {
    'name': "Burundi",
    'dial': 257,
    'lang': ['fr', 'rn']
  },
  'BJ': {
    'name': "Benin",
    'dial': 229,
    'lang': ['fr']
  },
  'BL': {
    'name': "Saint Barthelemy",
    'dial': 590,
    'lang': ['fr']
  },
  'BM': {
    'name': "Bermuda",
    'dial': 1441,
    'lang': ['en']
  },
  'BN': {
    'name': "Brunei Darussalam",
    'dial': 673,
    'lang': ['ms']
  },
  'BO': {
    'name': "Bolivia, Plurinational State of",
    'dial': 591,
    'lang': ['es', 'ay', 'qu']
  },
  'BR': {
    'name': "Brazil",
    'dial': 55,
    'lang': ['pt']
  },
  'BS': {
    'name': "Bahamas",
    'dial': 1242,
    'lang': ['en']
  },
  'BT': {
    'name': "Bhutan",
    'dial': 975,
    'lang': ['dz']
  },
  'BW': {
    'name': "Botswana",
    'dial': 267,
    'lang': ['en', 'tn']
  },
  'BY': {
    'name': "Belarus",
    'dial': 375,
    'lang': ['be', 'ru']
  },
  'BZ': {
    'name': "Belize",
    'dial': 501,
    'lang': ['en']
  },
  'CA': {
    'name': "Canada",
    'dial': 1,
    'lang': ['en', 'fr']
  },
  'CC': {
    'name': "Cocos (Keeling) Islands",
    'dial': 61,
    'lang': ['en']
  },
  'CD': {
    'name': "Congo, The Democratic Republic of the Congo",
    'dial': 243,
    'lang': ['fr', 'ln', 'kg', 'sw', 'lu']
  },
  'CF': {
    'name': "Central African Republic",
    'dial': 236,
    'lang': ['fr', 'sg']
  },
  'CG': {
    'name': "Congo",
    'dial': 242,
    'lang': ['fr', 'ln']
  },
  'CH': {
    'name': "Switzerland",
    'dial': 41,
    'lang': ['de', 'fr', 'it', 'rm']
  },
  'CI': {
    'name': "Cote d'Ivoire",
    'dial': 225,
    'lang': ['fr']
  },
  'CK': {
    'name': "Cook Islands",
    'dial': 682,
    'lang': ['en', 'rar']
  },
  'CL': {
    'name': "Chile",
    'dial': 56,
    'lang': ['es']
  },
  'CM': {
    'name': "Cameroon",
    'dial': 237,
    'lang': ['fr', 'en']
  },
  'CN': {
    'name': "China",
    'dial': 86,
    'lang': ['zh']
  },
  'CO': {
    'name': "Colombia",
    'dial': 57,
    'lang': ['es']
  },
  'CR': {
    'name': "Costa Rica",
    'dial': 506,
    'lang': ['es']
  },
  'CU': {
    'name': "Cuba",
    'dial': 53,
    'lang': ['es']
  },
  'CV': {
    'name': "Cape Verde",
    'dial': 238,
    'lang': ['pt']
  },
  'CX': {
    'name': "Christmas Island",
    'dial': 61,
    'lang': ['en']
  },
  'CY': {
    'name': "Cyprus",
    'dial': 357,
    'lang': ['el', 'tr']
  },
  'CZ': {
    'name': "Czech Republic",
    'dial': 420,
    'lang': ['cs']
  },
  'DE': {
    'name': "Germany",
    'dial': 49,
    'lang': ['de']
  },
  'DJ': {
    'name': "Djibouti",
    'dial': 253,
    'lang': ['fr', 'ar']
  },
  'DK': {
    'name': "Denmark",
    'dial': 45,
    'lang': ['da']
  },
  'DM': {
    'name': "Dominica",
    'dial': 1767,
    'lang': ['en']
  },
  'DO': {
    'name': "Dominican Republic",
    'dial': 1849,
    'lang': ['es']
  },
  'DZ': {
    'name': "Algeria",
    'dial': 213,
    'lang': ['ar']
  },
  'EC': {
    'name': "Ecuador",
    'dial': 593,
    'lang': ['es']
  },
  'EE': {
    'name': "Estonia",
    'dial': 372,
    'lang': ['et']
  },
  'EG': {
    'name': "Egypt",
    'dial': 20,
    'lang': ['ar']
  },
  'ER': {
    'name': "Eritrea",
    'dial': 291,
    'lang': ['ti', 'ar', 'en']
  },
  'ES': {
    'name': "Spain",
    'dial': 34,
    'lang': ['es']
  },
  'ET': {
    'name': "Ethiopia",
    'dial': 251,
    'lang': ['am']
  },
  'FI': {
    'name': "Finland",
    'dial': 358,
    'lang': ['fi', 'sv']
  },
  'FJ': {
    'name': "Fiji",
    'dial': 679,
    'lang': ['en', 'fj', 'hi', 'ur']
  },
  'FK': {
    'name': "Falkland Islands (Malvinas)",
    'dial': 500,
    'lang': ['en']
  },
  'FM': {
    'name': "Micronesia, Federated States of Micronesia",
    'dial': 691,
    'lang': ['en']
  },
  'FO': {
    'name': "Faroe Islands",
    'dial': 298,
    'lang': ['fo']
  },
  'FR': {
    'name': "France",
    'dial': 33,
    'lang': ['fr']
  },
  'GA': {
    'name': "Gabon",
    'dial': 241,
    'lang': ['fr']
  },
  'GB': {
    'name': "United Kingdom",
    'dial': 44,
    'lang': ['en']
  },
  'GD': {
    'name': "Grenada",
    'dial': 1473,
    'lang': ['en']
  },
  'GE': {
    'name': "Georgia",
    'dial': 995,
    'lang': ['ka']
  },
  'GF': {
    'name': "French Guiana",
    'dial': 594,
    'lang': ['fr']
  },
  'GG': {
    'name': "Guernsey",
    'dial': 44,
    'lang': ['en']
  },
  'GH': {
    'name': "Ghana",
    'dial': 233,
    'lang': ['en']
  },
  'GI': {
    'name': "Gibraltar",
    'dial': 350,
    'lang': ['en']
  },
  'GL': {
    'name': "Greenland",
    'dial': 299,
    'lang': ['kl']
  },
  'GM': {
    'name': "Gambia",
    'dial': 220,
    'lang': ['en']
  },
  'GN': {
    'name': "Guinea",
    'dial': 224,
    'lang': ['fr']
  },
  'GP': {
    'name': "Guadeloupe",
    'dial': 590,
    'lang': ['fr']
  },
  'GQ': {
    'name': "Equatorial Guinea",
    'dial': 240,
    'lang': ['es', 'fr']
  },
  'GR': {
    'name': "Greece",
    'dial': 30,
    'lang': ['el']
  },
  'GS': {
    'name': "South Georgia and the South Sandwich Islands",
    'dial': 500,
    'lang': ['en']
  },
  'GT': {
    'name': "Guatemala",
    'dial': 502,
    'lang': ['es']
  },
  'GU': {
    'name': "Guam",
    'dial': 1671,
    'lang': ['en', 'ch', 'es']
  },
  'GW': {
    'name': "Guinea-Bissau",
    'dial': 245,
    'lang': ['pt']
  },
  'GY': {
    'name': "Guyana",
    'dial': 592,
    'lang': ['en']
  },
  'HK': {
    'name': "Hong Kong",
    'dial': 852,
    'lang': ['zh', 'en']
  },
  'HM': {
    'name': "Heard Island and McDonald Islands",
    'dial': 672,
    'lang': ['en']
  },
  'HN': {
    'name': "Honduras",
    'dial': 504,
    'lang': ['es']
  },
  'HR': {
    'name': "Croatia",
    'dial': 385,
    'lang': ['hr']
  },
  'HT': {
    'name': "Haiti",
    'dial': 509,
    'lang': ['fr', 'ht']
  },
  'HU': {
    'name': "Hungary",
    'dial': 36,
    'lang': ['hu']
  },
  'ID': {
    'name': "Indonesia",
    'dial': 62,
    'lang': ['id']
  },
  'IE': {
    'name': "Ireland",
    'dial': 353,
    'lang': ['en', 'ga']
  },
  'IL': {
    'name': "Israel",
    'dial': 972,
    'lang': ['he']
  },
  'IM': {
    'name': "Isle of Man",
    'dial': 44,
    'lang': ['en', 'gv']
  },
  'IN': {
    'name': "India",
    'dial': 91,
    'lang': ['hi', 'en']
  },
  'IO': {
    'name': "British Indian Ocean Territory",
    'dial': 246,
    'lang': ['en']
  },
  'IQ': {
    'name': "Iraq",
    'dial': 964,
    'lang': ['ar', 'ku']
  },
  'IR': {
    'name': "Iran, Islamic Republic of Persian Gulf",
    'dial': 98,
    'lang': ['fa']
  },
  'IS': {
    'name': "Iceland",
    'dial': 354,
    'lang': ['is']
  },
  'IT': {
    'name': "Italy",
    'dial': 39,
    'lang': ['it']
  },
  'JE': {
    'name': "Jersey",
    'dial': 44,
    'lang': ['en']
  },
  'JM': {
    'name': "Jamaica",
    'dial': 1876,
    'lang': ['en']
  },
  'JO': {
    'name': "Jordan",
    'dial': 962,
    'lang': ['ar']
  },
  'JP': {
    'name': "Japan",
    'dial': 81,
    'lang': ['ja']
  },
  'KE': {
    'name': "Kenya",
    'dial': 254,
    'lang': ['en', 'sw']
  },
  'KG': {
    'name': "Kyrgyzstan",
    'dial': 996,
    'lang': ['ky', 'ru']
  },
  'KH': {
    'name': "Cambodia",
    'dial': 855,
    'lang': ['km']
  },
  'KI': {
    'name': "Kiribati",
    'dial': 686,
    'lang': ['en']
  },
  'KM': {
    'name': "Comoros",
    'dial': 269,
    'lang': ['ar', 'fr']
  },
  'KN': {
    'name': "Saint Kitts and Nevis",
    'dial': 1869,
    'lang': ['en']
  },
  'KP': {
    'name': "North Korea",
    'dial': 850,
    'lang': ['ko']
  },
  'KR': {
    'name': "South Korea",
    'dial': 82,
    'lang': ['ko']
  },
  'KW': {
    'name': "Kuwait",
    'dial': 965,
    'lang': ['ar']
  },
  'KY': {
    'name': "Cayman Islands",
    'dial': 1345,
    'lang': ['en']
  },
  'KZ': {
    'name': "Kazakhstan",
    'dial': 7,
    'lang': ['kk', 'ru']
  },
  'LA': {
    'name': "Lao People's Democratic Republic",
    'dial': 856,
    'lang': ['lo']
  },
  'LB': {
    'name': "Lebanon",
    'dial': 961,
    'lang': ['ar']
  },
  'LC': {
    'name': "Saint Lucia",
    'dial': 1758,
    'lang': ['en']
  },
  'LI': {
    'name': "Liechtenstein",
    'dial': 423,
    'lang': ['de']
  },
  'LK': {
    'name': "Sri Lanka",
    'dial': 94,
    'lang': ['si', 'ta']
  },
  'LR': {
    'name': "Liberia",
    'dial': 231,
    'lang': ['en']
  },
  'LS': {
    'name': "Lesotho",
    'dial': 266,
    'lang': ['en', 'st']
  },
  'LT': {
    'name': "Lithuania",
    'dial': 370,
    'lang': ['lt']
  },
  'LU': {
    'name': "Luxembourg",
    'dial': 352,
    'lang': ['lb', 'fr', 'de']
  },
  'LV': {
    'name': "Latvia",
    'dial': 371,
    'lang': ['lv']
  },
  'LY': {
    'name': "Libyan Arab Jamahiriya",
    'dial': 218,
    'lang': ['ar']
  },
  'MA': {
    'name': "Morocco",
    'dial': 212,
    'lang': ['ar']
  },
  'MC': {
    'name': "Monaco",
    'dial': 377,
    'lang': ['fr']
  },
  'MD': {
    'name': "Moldova",
    'dial': 373,
    'lang': ['ro']
  },
  'ME': {
    'name': "Montenegro",
    'dial': 382,
    'lang': ['sr', 'bs', 'sq', 'hr']
  },
  'MF': {
    'name': "Saint Martin",
    'dial': 1599,
    'lang': ['en', 'nl']
  },
  'MG': {
    'name': "Madagascar",
    'dial': 261,
    'lang': ['fr', 'mg']
  },
  'MH': {
    'name': "Marshall Islands",
    'dial': 692,
    'lang': ['en', 'mh']
  },
  'MK': {
    'name': "Macedonia",
    'dial': 389,
    'lang': ['mk']
  },
  'ML': {
    'name': "Mali",
    'dial': 223,
    'lang': ['fr']
  },
  'MM': {
    'name': "Myanmar",
    'dial': 95,
    'lang': ['my']
  },
  'MN': {
    'name': "Mongolia",
    'dial': 976,
    'lang': ['mn']
  },
  'MO': {
    'name': "Macao",
    'dial': 853,
    'lang': ['zh', 'pt']
  },
  'MP': {
    'name': "Northern Mariana Islands",
    'dial': 1670,
    'lang': ['en', 'ch']
  },
  'MQ': {
    'name': "Martinique",
    'dial': 596,
    'lang': ['fr']
  },
  'MR': {
    'name': "Mauritania",
    'dial': 222,
    'lang': ['ar']
  },
  'MS': {
    'name': "Montserrat",
    'dial': 1664,
    'lang': ['en']
  },
  'MT': {
    'name': "Malta",
    'dial': 356,
    'lang': ['mt', 'en']
  },
  'MU': {
    'name': "Mauritius",
    'dial': 230,
    'lang': ['en']
  },
  'MV': {
    'name': "Maldives",
    'dial': 960,
    'lang': ['dv']
  },
  'MW': {
    'name': "Malawi",
    'dial': 265,
    'lang': ['en', 'ny']
  },
  'MX': {
    'name': "Mexico",
    'dial': 52,
    'lang': ['es']
  },
  'MY': {
    'name': "Malaysia",
    'dial': 60,
    'lang': ['ms']
  },
  'MZ': {
    'name': "Mozambique",
    'dial': 258,
    'lang': ['pt']
  },
  'NA': {
    'name': "Namibia",
    'dial': 264,
    'lang': ['en', 'af']
  },
  'NC': {
    'name': "New Caledonia",
    'dial': 687,
    'lang': ['fr']
  },
  'NE': {
    'name': "Niger",
    'dial': 227,
    'lang': ['fr']
  },
  'NF': {
    'name': "Norfolk Island",
    'dial': 672,
    'lang': ['en']
  },
  'NG': {
    'name': "Nigeria",
    'dial': 234,
    'lang': ['en']
  },
  'NI': {
    'name': "Nicaragua",
    'dial': 505,
    'lang': ['es']
  },
  'NL': {
    'name': "Netherlands",
    'dial': 31,
    'lang': ['nl']
  },
  'NO': {
    'name': "Norway",
    'dial': 47,
    'lang': ['no']
  },
  'NP': {
    'name': "Nepal",
    'dial': 977,
    'lang': ['ne']
  },
  'NR': {
    'name': "Nauru",
    'dial': 674,
    'lang': ['na', 'en']
  },
  'NU': {
    'name': "Niue",
    'dial': 683,
    'lang': ['en']
  },
  'NZ': {
    'name': "New Zealand",
    'dial': 64,
    'lang': ['en', 'mi']
  },
  'OM': {
    'name': "Oman",
    'dial': 968,
    'lang': ['ar']
  },
  'PA': {
    'name': "Panama",
    'dial': 507,
    'lang': ['es']
  },
  'PE': {
    'name': "Peru",
    'dial': 51,
    'lang': ['es']
  },
  'PF': {
    'name': "French Polynesia",
    'dial': 689,
    'lang': ['fr']
  },
  'PG': {
    'name': "Papua New Guinea",
    'dial': 675,
    'lang': ['en']
  },
  'PH': {
    'name': "Philippines",
    'dial': 63,
    'lang': ['en', 'tl']
  },
  'PK': {
    'name': "Pakistan",
    'dial': 92,
    'lang': ['en', 'ur']
  },
  'PL': {
    'name': "Poland",
    'dial': 48,
    'lang': ['pl']
  },
  'PM': {
    'name': "Saint Pierre and Miquelon",
    'dial': 508,
    'lang': ['fr']
  },
  'PN': {
    'name': "Pitcairn",
    'dial': 870,
    'lang': ['en']
  },
  'PR': {
    'name': "Puerto Rico",
    'dial': 1939,
    'lang': ['en', 'es']
  },
  'PT': {
    'name': "Portugal",
    'dial': 351,
    'lang': ['pt']
  },
  'PW': {
    'name': "Palau",
    'dial': 680,
    'lang': ['en']
  },
  'PY': {
    'name': "Paraguay",
    'dial': 595,
    'lang': ['es', 'gn']
  },
  'QA': {
    'name': "Qatar",
    'dial': 974,
    'lang': ['ar']
  },
  'RE': {
    'name': "Réunion",
    'dial': 262,
    'lang': ['fr']
  },
  'RO': {
    'name': "Romania",
    'dial': 40,
    'lang': ['ro']
  },
  'RS': {
    'name': "Serbia",
    'dial': 381,
    'lang': ['sr']
  },
  'RU': {
    'name': "Russia",
    'dial': 7,
    'lang': ['ru']
  },
  'RW': {
    'name': "Rwanda",
    'dial': 250,
    'lang': ['rw', 'fr', 'en']
  },
  'SA': {
    'name': "Saudi Arabia",
    'dial': 966,
    'lang': ['ar']
  },
  'SB': {
    'name': "Solomon Islands",
    'dial': 677,
    'lang': ['en']
  },
  'SC': {
    'name': "Seychelles",
    'dial': 248,
    'lang': ['fr', 'en']
  },
  'SD': {
    'name': "Sudan",
    'dial': 249,
    'lang': ['ar']
  },
  'SE': {
    'name': "Sweden",
    'dial': 46,
    'lang': ['sv']
  },
  'SG': {
    'name': "Singapore",
    'dial': 65,
    'lang': ['en', 'zh', 'ms', 'ta']
  },
  'SH': {
    'name': "Saint Helena, Ascension and Tristan Da Cunha",
    'dial': 290,
    'lang': ['en']
  },
  'SI': {
    'name': "Slovenia",
    'dial': 386,
    'lang': ['sl']
  },
  'SJ': {
    'name': "Svalbard and Jan Mayen",
    'dial': 47,
    'lang': ['no']
  },
  'SK': {
    'name': "Slovakia",
    'dial': 421,
    'lang': ['sk']
  },
  'SL': {
    'name': "Sierra Leone",
    'dial': 232,
    'lang': ['en']
  },
  'SM': {
    'name': "San Marino",
    'dial': 378,
    'lang': ['it']
  },
  'SN': {
    'name': "Senegal",
    'dial': 221,
    'lang': ['fr']
  },
  'SO': {
    'name': "Somalia",
    'dial': 252,
    'lang': ['so', 'ar']
  },
  'SR': {
    'name': "Suriname",
    'dial': 597,
    'lang': ['nl']
  },
  'SS': {
    'name': "South Sudan",
    'dial': 211,
    'lang': ['en']
  },
  'ST': {
    'name': "Sao Tome and Principe",
    'dial': 239,
    'lang': ['pt']
  },
  'SV': {
    'name': "El Salvador",
    'dial': 503,
    'lang': ['es']
  },
  'SX': {
    'name': "Sint Maarten",
    'dial': 1721,
    'lang': ['nl', 'en']
  },
  'SY': {
    'name': "Syrian Arab Republic",
    'dial': 963,
    'lang': ['ar']
  },
  'SZ': {
    'name': "Swaziland",
    'dial': 268,
    'lang': ['en', 'ss']
  },
  'TC': {
    'name': "Turks and Caicos Islands",
    'dial': 1649,
    'lang': ['en']
  },
  'TD': {
    'name': "Chad",
    'dial': 235,
    'lang': ['fr', 'ar']
  },
  'TF': {
    'name': "French Southern Territories",
    'dial': 262,
    'lang': ['fr']
  },
  'TG': {
    'name': "Togo",
    'dial': 228,
    'lang': ['fr']
  },
  'TH': {
    'name': "Thailand",
    'dial': 66,
    'lang': ['th']
  },
  'TJ': {
    'name': "Tajikistan",
    'dial': 992,
    'lang': ['tg', 'ru']
  },
  'TK': {
    'name': "Tokelau",
    'dial': 690,
    'lang': ['en']
  },
  'TL': {
    'name': "Timor-Leste",
    'dial': 670,
    'lang': ['pt']
  },
  'TM': {
    'name': "Turkmenistan",
    'dial': 993,
    'lang': ['tk', 'ru']
  },
  'TN': {
    'name': "Tunisia",
    'dial': 216,
    'lang': ['ar']
  },
  'TO': {
    'name': "Tonga",
    'dial': 676,
    'lang': ['en', 'to']
  },
  'TR': {
    'name': "Turkey",
    'dial': 90,
    'lang': ['tr']
  },
  'TT': {
    'name': "Trinidad and Tobago",
    'dial': 1868,
    'lang': ['en']
  },
  'TV': {
    'name': "Tuvalu",
    'dial': 688,
    'lang': ['en']
  },
  'TW': {
    'name': "Taiwan",
    'dial': 886,
    'lang': ['zh']
  },
  'TZ': {
    'name': "Tanzania",
    'dial': 255,
    'lang': ['sw', 'en']
  },
  'UA': {
    'name': "Ukraine",
    'dial': 380,
    'lang': ['uk']
  },
  'UG': {
    'name': "Uganda",
    'dial': 256,
    'lang': ['en', 'sw']
  },
  'UM': {
    'name': "United States Minor Outlying Islands",
    'dial': 1,
    'lang': ['en']
  },
  'US': {
    'name': "United States of America",
    'dial': 1,
    'lang': ['en']
  },
  'UY': {
    'name': "Uruguay",
    'dial': 598,
    'lang': ['es']
  },
  'UZ': {
    'name': "Uzbekistan",
    'dial': 998,
    'lang': ['uz', 'ru']
  },
  'VA': {
    'name': "Holy See (Vatican City State)",
    'dial': 379,
    'lang': ['it', 'la']
  },
  'VC': {
    'name': "Saint Vincent and the Grenadines",
    'dial': 1784,
    'lang': ['en']
  },
  'VE': {
    'name': "Venezuela",
    'dial': 58,
    'lang': ['es']
  },
  'VG': {
    'name': "Virgin Islands, British",
    'dial': 1284,
    'lang': ['en']
  },
  'VI': {
    'name': "Virgin Islands, U.S.",
    'dial': 1340,
    'lang': ['en']
  },
  'VN': {
    'name': "Vietnam",
    'dial': 84,
    'lang': ['vi']
  },
  'VU': {
    'name': "Vanuatu",
    'dial': 678,
    'lang': ['bi', 'fr', 'en']
  },
  'WF': {
    'name': "Wallis and Futuna",
    'dial': 681,
    'lang': ['fr']
  },
  'WS': {
    'name': "Samoa",
    'dial': 685,
    'lang': ['sm', 'en']
  },
  'XK': {
    'name': "Kosovo",
    'dial': 381,
    'lang': ['sq', 'sr']
  },
  'YE': {
    'name': "Yemen",
    'dial': 967,
    'lang': ['ar']
  },
  'YT': {
    'name': "Mayotte",
    'dial': 262,
    'lang': ['fr']
  },
  'ZA': {
    'name': "South Africa",
    'dial': 27,
    'lang': ['af', 'en', 'zu', 'xh', 'tn', 'st']
  },
  'ZM': {
    'name': "Zambia",
    'dial': 260,
    'lang': ['en']
  },
  'ZW': {
    'name': "Zimbabwe",
    'dial': 263,
    'lang': ['en']
  },
}
    .entries
    .map((e) {
      var code = e.key;
      var name = e.value['name'] as String;
      var dial = e.value['dial'] as int;
      var lang = e.value['lang'] as List<String>;
      return CountryInfo(code.trim().toUpperCase(), name.trim(), dial, lang);
    })
    .toList(growable: false)
    .asUnmodifiableListView();

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

  /// The main languages of the country.
  final List<String> languages;

  CountryInfo(this.code, this.name, this.dialCode, [List<String>? languages])
      : languages = List.unmodifiable(languages ?? []);

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
  List<T> asUnmodifiableListView() => UnmodifiableListView(this);
}

extension _IterableMapEntryExtension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMapFromEntries() => Map<K, V>.fromEntries(this);
}
