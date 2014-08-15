package Sisimai::ISO3166;
use strict;
use warnings;

my $CCTLD = {
    'af' => { 'shortname' => 'Afghanistan', 'alpha-2' => 'AF', 'alpha-3' => 'AFG', 'numeric' => '004' },
    'ax' => { 'shortname' => 'Åland Islands', 'alpha-2' => 'AX', 'alpha-3' => 'ALA', 'numeric' => '248' },
    'al' => { 'shortname' => 'Albania', 'alpha-2' => 'AL', 'alpha-3' => 'ALB', 'numeric' => '008' },
    'dz' => { 'shortname' => 'Algeria', 'alpha-2' => 'DZ', 'alpha-3' => 'DZA', 'numeric' => '012' },
    'as' => { 'shortname' => 'American Samoa', 'alpha-2' => 'AS', 'alpha-3' => 'ASM', 'numeric' => '016' },
    'ad' => { 'shortname' => 'Andorra', 'alpha-2' => 'AD', 'alpha-3' => 'AND', 'numeric' => '020' },
    'ao' => { 'shortname' => 'Angola', 'alpha-2' => 'AO', 'alpha-3' => 'AGO', 'numeric' => '024' },
    'ai' => { 'shortname' => 'Anguilla', 'alpha-2' => 'AI', 'alpha-3' => 'AIA', 'numeric' => '660' },
    'aq' => { 'shortname' => 'Antarctica', 'alpha-2' => 'AQ', 'alpha-3' => 'ATA', 'numeric' => '010' },
    'ag' => { 'shortname' => 'Antigua and Barbuda', 'alpha-2' => 'AG', 'alpha-3' => 'ATG', 'numeric' => '028' },
    'ar' => { 'shortname' => 'Argentina', 'alpha-2' => 'AR', 'alpha-3' => 'ARG', 'numeric' => '032' },
    'am' => { 'shortname' => 'Armenia', 'alpha-2' => 'AM', 'alpha-3' => 'ARM', 'numeric' => '051' },
    'aw' => { 'shortname' => 'Aruba', 'alpha-2' => 'AW', 'alpha-3' => 'ABW', 'numeric' => '533' },
    'au' => { 'shortname' => 'Australia', 'alpha-2' => 'AU', 'alpha-3' => 'AUS', 'numeric' => '036' },
    'at' => { 'shortname' => 'Austria', 'alpha-2' => 'AT', 'alpha-3' => 'AUT', 'numeric' => '040' },
    'az' => { 'shortname' => 'Azerbaijan', 'alpha-2' => 'AZ', 'alpha-3' => 'AZE', 'numeric' => '031' },
    'bs' => { 'shortname' => 'Bahamas', 'alpha-2' => 'BS', 'alpha-3' => 'BHS', 'numeric' => '044' },
    'bh' => { 'shortname' => 'Bahrain', 'alpha-2' => 'BH', 'alpha-3' => 'BHR', 'numeric' => '048' },
    'bd' => { 'shortname' => 'Bangladesh', 'alpha-2' => 'BD', 'alpha-3' => 'BGD', 'numeric' => '050' },
    'bb' => { 'shortname' => 'Barbados', 'alpha-2' => 'BB', 'alpha-3' => 'BRB', 'numeric' => '052' },
    'by' => { 'shortname' => 'Belarus', 'alpha-2' => 'BY', 'alpha-3' => 'BLR', 'numeric' => '112' },
    'be' => { 'shortname' => 'Belgium', 'alpha-2' => 'BE', 'alpha-3' => 'BEL', 'numeric' => '056' },
    'bz' => { 'shortname' => 'Belize', 'alpha-2' => 'BZ', 'alpha-3' => 'BLZ', 'numeric' => '084' },
    'bj' => { 'shortname' => 'Benin', 'alpha-2' => 'BJ', 'alpha-3' => 'BEN', 'numeric' => '204' },
    'bm' => { 'shortname' => 'Bermuda', 'alpha-2' => 'BM', 'alpha-3' => 'BMU', 'numeric' => '060' },
    'bt' => { 'shortname' => 'Bhutan', 'alpha-2' => 'BT', 'alpha-3' => 'BTN', 'numeric' => '064' },
    'bo' => { 'shortname' => 'Bolivia, Plurinational State of', 'alpha-2' => 'BO', 'alpha-3' => 'BOL', 'numeric' => '068' },
    'ba' => { 'shortname' => 'Bosnia and Herzegovina', 'alpha-2' => 'BA', 'alpha-3' => 'BIH', 'numeric' => '070' },
    'bw' => { 'shortname' => 'Botswana', 'alpha-2' => 'BW', 'alpha-3' => 'BWA', 'numeric' => '072' },
    'bv' => { 'shortname' => 'Bouvet Island', 'alpha-2' => 'BV', 'alpha-3' => 'BVT', 'numeric' => '074' },
    'br' => { 'shortname' => 'Brazil', 'alpha-2' => 'BR', 'alpha-3' => 'BRA', 'numeric' => '076' },
    'io' => { 'shortname' => 'British Indian Ocean Territory', 'alpha-2' => 'IO', 'alpha-3' => 'IOT', 'numeric' => '086' },
    'bn' => { 'shortname' => 'Brunei Darussalam', 'alpha-2' => 'BN', 'alpha-3' => 'BRN', 'numeric' => '096' },
    'bg' => { 'shortname' => 'Bulgaria', 'alpha-2' => 'BG', 'alpha-3' => 'BGR', 'numeric' => '100' },
    'bf' => { 'shortname' => 'Burkina Faso', 'alpha-2' => 'BF', 'alpha-3' => 'BFA', 'numeric' => '854' },
    'bi' => { 'shortname' => 'Burundi', 'alpha-2' => 'BI', 'alpha-3' => 'BDI', 'numeric' => '108' },
    'kh' => { 'shortname' => 'Cambodia', 'alpha-2' => 'KH', 'alpha-3' => 'KHM', 'numeric' => '116' },
    'cm' => { 'shortname' => 'Cameroon', 'alpha-2' => 'CM', 'alpha-3' => 'CMR', 'numeric' => '120' },
    'ca' => { 'shortname' => 'Canada', 'alpha-2' => 'CA', 'alpha-3' => 'CAN', 'numeric' => '124' },
    'cv' => { 'shortname' => 'Cape Verde', 'alpha-2' => 'CV', 'alpha-3' => 'CPV', 'numeric' => '132' },
    'ky' => { 'shortname' => 'Cayman Islands', 'alpha-2' => 'KY', 'alpha-3' => 'CYM', 'numeric' => '136' },
    'cf' => { 'shortname' => 'Central African Republic', 'alpha-2' => 'CF', 'alpha-3' => 'CAF', 'numeric' => '140' },
    'td' => { 'shortname' => 'Chad', 'alpha-2' => 'TD', 'alpha-3' => 'TCD', 'numeric' => '148' },
    'cl' => { 'shortname' => 'Chile', 'alpha-2' => 'CL', 'alpha-3' => 'CHL', 'numeric' => '152' },
    'cn' => { 'shortname' => 'China', 'alpha-2' => 'CN', 'alpha-3' => 'CHN', 'numeric' => '156' },
    'cx' => { 'shortname' => 'Christmas Island', 'alpha-2' => 'CX', 'alpha-3' => 'CXR', 'numeric' => '162' },
    'cc' => { 'shortname' => 'Cocos (Keeling) Islands', 'alpha-2' => 'CC', 'alpha-3' => 'CCK', 'numeric' => '166' },
    'co' => { 'shortname' => 'Colombia', 'alpha-2' => 'CO', 'alpha-3' => 'COL', 'numeric' => '170' },
    'km' => { 'shortname' => 'Comoros', 'alpha-2' => 'KM', 'alpha-3' => 'COM', 'numeric' => '174' },
    'cg' => { 'shortname' => 'Congo', 'alpha-2' => 'CG', 'alpha-3' => 'COG', 'numeric' => '178' },
    'cd' => { 'shortname' => 'Congo, the Democratic Republic of the', 'alpha-2' => 'CD', 'alpha-3' => 'COD', 'numeric' => '180' },
    'ck' => { 'shortname' => 'Cook Islands', 'alpha-2' => 'CK', 'alpha-3' => 'COK', 'numeric' => '184' },
    'cr' => { 'shortname' => 'Costa Rica', 'alpha-2' => 'CR', 'alpha-3' => 'CRI', 'numeric' => '188' },
    'ci' => { 'shortname' => q(Côte d'Ivoire), 'alpha-2' => 'CI', 'alpha-3' => 'CIV', 'numeric' => '384' },
    'hr' => { 'shortname' => 'Croatia', 'alpha-2' => 'HR', 'alpha-3' => 'HRV', 'numeric' => '191' },
    'cu' => { 'shortname' => 'Cuba', 'alpha-2' => 'CU', 'alpha-3' => 'CUB', 'numeric' => '192' },
    'cy' => { 'shortname' => 'Cyprus', 'alpha-2' => 'CY', 'alpha-3' => 'CYP', 'numeric' => '196' },
    'cz' => { 'shortname' => 'Czech Republic', 'alpha-2' => 'CZ', 'alpha-3' => 'CZE', 'numeric' => '203' },
    'dk' => { 'shortname' => 'Denmark', 'alpha-2' => 'DK', 'alpha-3' => 'DNK', 'numeric' => '208' },
    'dj' => { 'shortname' => 'Djibouti', 'alpha-2' => 'DJ', 'alpha-3' => 'DJI', 'numeric' => '262' },
    'dm' => { 'shortname' => 'Dominica', 'alpha-2' => 'DM', 'alpha-3' => 'DMA', 'numeric' => '212' },
    'do' => { 'shortname' => 'Dominican Republic', 'alpha-2' => 'DO', 'alpha-3' => 'DOM', 'numeric' => '214' },
    'ec' => { 'shortname' => 'Ecuador', 'alpha-2' => 'EC', 'alpha-3' => 'ECU', 'numeric' => '218' },
    'eg' => { 'shortname' => 'Egypt', 'alpha-2' => 'EG', 'alpha-3' => 'EGY', 'numeric' => '818' },
    'sv' => { 'shortname' => 'El Salvador', 'alpha-2' => 'SV', 'alpha-3' => 'SLV', 'numeric' => '222' },
    'gq' => { 'shortname' => 'Equatorial Guinea', 'alpha-2' => 'GQ', 'alpha-3' => 'GNQ', 'numeric' => '226' },
    'er' => { 'shortname' => 'Eritrea', 'alpha-2' => 'ER', 'alpha-3' => 'ERI', 'numeric' => '232' },
    'ee' => { 'shortname' => 'Estonia', 'alpha-2' => 'EE', 'alpha-3' => 'EST', 'numeric' => '233' },
    'et' => { 'shortname' => 'Ethiopia', 'alpha-2' => 'ET', 'alpha-3' => 'ETH', 'numeric' => '231' },
    'fk' => { 'shortname' => 'Falkland Islands (Malvinas)', 'alpha-2' => 'FK', 'alpha-3' => 'FLK', 'numeric' => '238' },
    'fo' => { 'shortname' => 'Faroe Islands', 'alpha-2' => 'FO', 'alpha-3' => 'FRO', 'numeric' => '234' },
    'fj' => { 'shortname' => 'Fiji', 'alpha-2' => 'FJ', 'alpha-3' => 'FJI', 'numeric' => '242' },
    'fi' => { 'shortname' => 'Finland', 'alpha-2' => 'FI', 'alpha-3' => 'FIN', 'numeric' => '246' },
    'fr' => { 'shortname' => 'France', 'alpha-2' => 'FR', 'alpha-3' => 'FRA', 'numeric' => '250' },
    'gf' => { 'shortname' => 'French Guiana', 'alpha-2' => 'GF', 'alpha-3' => 'GUF', 'numeric' => '254' },
    'pf' => { 'shortname' => 'French Polynesia', 'alpha-2' => 'PF', 'alpha-3' => 'PYF', 'numeric' => '258' },
    'tf' => { 'shortname' => 'French Southern Territories', 'alpha-2' => 'TF', 'alpha-3' => 'ATF', 'numeric' => '260' },
    'ga' => { 'shortname' => 'Gabon', 'alpha-2' => 'GA', 'alpha-3' => 'GAB', 'numeric' => '266' },
    'gm' => { 'shortname' => 'Gambia', 'alpha-2' => 'GM', 'alpha-3' => 'GMB', 'numeric' => '270' },
    'ge' => { 'shortname' => 'Georgia', 'alpha-2' => 'GE', 'alpha-3' => 'GEO', 'numeric' => '268' },
    'de' => { 'shortname' => 'Germany', 'alpha-2' => 'DE', 'alpha-3' => 'DEU', 'numeric' => '276' },
    'gh' => { 'shortname' => 'Ghana', 'alpha-2' => 'GH', 'alpha-3' => 'GHA', 'numeric' => '288' },
    'gi' => { 'shortname' => 'Gibraltar', 'alpha-2' => 'GI', 'alpha-3' => 'GIB', 'numeric' => '292' },
    'gr' => { 'shortname' => 'Greece', 'alpha-2' => 'GR', 'alpha-3' => 'GRC', 'numeric' => '300' },
    'gl' => { 'shortname' => 'Greenland', 'alpha-2' => 'GL', 'alpha-3' => 'GRL', 'numeric' => '304' },
    'gd' => { 'shortname' => 'Grenada', 'alpha-2' => 'GD', 'alpha-3' => 'GRD', 'numeric' => '308' },
    'gp' => { 'shortname' => 'Guadeloupe', 'alpha-2' => 'GP', 'alpha-3' => 'GLP', 'numeric' => '312' },
    'gu' => { 'shortname' => 'Guam', 'alpha-2' => 'GU', 'alpha-3' => 'GUM', 'numeric' => '316' },
    'gt' => { 'shortname' => 'Guatemala', 'alpha-2' => 'GT', 'alpha-3' => 'GTM', 'numeric' => '320' },
    'gg' => { 'shortname' => 'Guernsey', 'alpha-2' => 'GG', 'alpha-3' => 'GGY', 'numeric' => '831' },
    'gn' => { 'shortname' => 'Guinea', 'alpha-2' => 'GN', 'alpha-3' => 'GIN', 'numeric' => '324' },
    'gw' => { 'shortname' => 'Guinea-Bissau', 'alpha-2' => 'GW', 'alpha-3' => 'GNB', 'numeric' => '624' },
    'gy' => { 'shortname' => 'Guyana', 'alpha-2' => 'GY', 'alpha-3' => 'GUY', 'numeric' => '328' },
    'ht' => { 'shortname' => 'Haiti', 'alpha-2' => 'HT', 'alpha-3' => 'HTI', 'numeric' => '332' },
    'hm' => { 'shortname' => 'Heard Island and McDonald Islands', 'alpha-2' => 'HM', 'alpha-3' => 'HMD', 'numeric' => '334' },
    'va' => { 'shortname' => 'Holy See (Vatican City State)', 'alpha-2' => 'VA', 'alpha-3' => 'VAT', 'numeric' => '336' },
    'hn' => { 'shortname' => 'Honduras', 'alpha-2' => 'HN', 'alpha-3' => 'HND', 'numeric' => '340' },
    'hk' => { 'shortname' => 'Hong Kong', 'alpha-2' => 'HK', 'alpha-3' => 'HKG', 'numeric' => '344' },
    'hu' => { 'shortname' => 'Hungary', 'alpha-2' => 'HU', 'alpha-3' => 'HUN', 'numeric' => '348' },
    'is' => { 'shortname' => 'Iceland', 'alpha-2' => 'IS', 'alpha-3' => 'ISL', 'numeric' => '352' },
    'in' => { 'shortname' => 'India', 'alpha-2' => 'IN', 'alpha-3' => 'IND', 'numeric' => '356' },
    'id' => { 'shortname' => 'Indonesia', 'alpha-2' => 'ID', 'alpha-3' => 'IDN', 'numeric' => '360' },
    'ir' => { 'shortname' => 'Iran, Islamic Republic of', 'alpha-2' => 'IR', 'alpha-3' => 'IRN', 'numeric' => '364' },
    'iq' => { 'shortname' => 'Iraq', 'alpha-2' => 'IQ', 'alpha-3' => 'IRQ', 'numeric' => '368' },
    'ie' => { 'shortname' => 'Ireland', 'alpha-2' => 'IE', 'alpha-3' => 'IRL', 'numeric' => '372' },
    'im' => { 'shortname' => 'Isle of Man', 'alpha-2' => 'IM', 'alpha-3' => 'IMN', 'numeric' => '833' },
    'il' => { 'shortname' => 'Israel', 'alpha-2' => 'IL', 'alpha-3' => 'ISR', 'numeric' => '376' },
    'it' => { 'shortname' => 'Italy', 'alpha-2' => 'IT', 'alpha-3' => 'ITA', 'numeric' => '380' },
    'jm' => { 'shortname' => 'Jamaica', 'alpha-2' => 'JM', 'alpha-3' => 'JAM', 'numeric' => '388' },
    'jp' => { 'shortname' => 'Japan', 'alpha-2' => 'JP', 'alpha-3' => 'JPN', 'numeric' => '392' },
    'je' => { 'shortname' => 'Jersey', 'alpha-2' => 'JE', 'alpha-3' => 'JEY', 'numeric' => '832' },
    'jo' => { 'shortname' => 'Jordan', 'alpha-2' => 'JO', 'alpha-3' => 'JOR', 'numeric' => '400' },
    'kz' => { 'shortname' => 'Kazakhstan', 'alpha-2' => 'KZ', 'alpha-3' => 'KAZ', 'numeric' => '398' },
    'ke' => { 'shortname' => 'Kenya', 'alpha-2' => 'KE', 'alpha-3' => 'KEN', 'numeric' => '404' },
    'ki' => { 'shortname' => 'Kiribati', 'alpha-2' => 'KI', 'alpha-3' => 'KIR', 'numeric' => '296' },
    'kp' => { 'shortname' => q(Korea, Democratic People's Republic of), 'alpha-2' => 'KP', 'alpha-3' => 'PRK', 'numeric' => '408' },
    'kr' => { 'shortname' => 'Korea, Republic of', 'alpha-2' => 'KR', 'alpha-3' => 'KOR', 'numeric' => '410' },
    'kw' => { 'shortname' => 'Kuwait', 'alpha-2' => 'KW', 'alpha-3' => 'KWT', 'numeric' => '414' },
    'kg' => { 'shortname' => 'Kyrgyzstan', 'alpha-2' => 'KG', 'alpha-3' => 'KGZ', 'numeric' => '417' },
    'la' => { 'shortname' => q(Lao People's Democratic Republic), 'alpha-2' => 'LA', 'alpha-3' => 'LAO', 'numeric' => '418' },
    'lv' => { 'shortname' => 'Latvia', 'alpha-2' => 'LV', 'alpha-3' => 'LVA', 'numeric' => '428' },
    'lb' => { 'shortname' => 'Lebanon', 'alpha-2' => 'LB', 'alpha-3' => 'LBN', 'numeric' => '422' },
    'ls' => { 'shortname' => 'Lesotho', 'alpha-2' => 'LS', 'alpha-3' => 'LSO', 'numeric' => '426' },
    'lr' => { 'shortname' => 'Liberia', 'alpha-2' => 'LR', 'alpha-3' => 'LBR', 'numeric' => '430' },
    'ly' => { 'shortname' => 'Libyan Arab Jamahiriya', 'alpha-2' => 'LY', 'alpha-3' => 'LBY', 'numeric' => '434' },
    'li' => { 'shortname' => 'Liechtenstein', 'alpha-2' => 'LI', 'alpha-3' => 'LIE', 'numeric' => '438' },
    'lt' => { 'shortname' => 'Lithuania', 'alpha-2' => 'LT', 'alpha-3' => 'LTU', 'numeric' => '440' },
    'lu' => { 'shortname' => 'Luxembourg', 'alpha-2' => 'LU', 'alpha-3' => 'LUX', 'numeric' => '442' },
    'mo' => { 'shortname' => 'Macao', 'alpha-2' => 'MO', 'alpha-3' => 'MAC', 'numeric' => '446' },
    'mk' => { 'shortname' => 'Macedonia, the former Yugoslav Republic of', 'alpha-2' => 'MK', 'alpha-3' => 'MKD', 'numeric' => '807' },
    'mg' => { 'shortname' => 'Madagascar', 'alpha-2' => 'MG', 'alpha-3' => 'MDG', 'numeric' => '450' },
    'mw' => { 'shortname' => 'Malawi', 'alpha-2' => 'MW', 'alpha-3' => 'MWI', 'numeric' => '454' },
    'my' => { 'shortname' => 'Malaysia', 'alpha-2' => 'MY', 'alpha-3' => 'MYS', 'numeric' => '458' },
    'mv' => { 'shortname' => 'Maldives', 'alpha-2' => 'MV', 'alpha-3' => 'MDV', 'numeric' => '462' },
    'ml' => { 'shortname' => 'Mali', 'alpha-2' => 'ML', 'alpha-3' => 'MLI', 'numeric' => '466' },
    'mt' => { 'shortname' => 'Malta', 'alpha-2' => 'MT', 'alpha-3' => 'MLT', 'numeric' => '470' },
    'mh' => { 'shortname' => 'Marshall Islands', 'alpha-2' => 'MH', 'alpha-3' => 'MHL', 'numeric' => '584' },
    'mq' => { 'shortname' => 'Martinique', 'alpha-2' => 'MQ', 'alpha-3' => 'MTQ', 'numeric' => '474' },
    'mr' => { 'shortname' => 'Mauritania', 'alpha-2' => 'MR', 'alpha-3' => 'MRT', 'numeric' => '478' },
    'mu' => { 'shortname' => 'Mauritius', 'alpha-2' => 'MU', 'alpha-3' => 'MUS', 'numeric' => '480' },
    'yt' => { 'shortname' => 'Mayotte', 'alpha-2' => 'YT', 'alpha-3' => 'MYT', 'numeric' => '175' },
    'mx' => { 'shortname' => 'Mexico', 'alpha-2' => 'MX', 'alpha-3' => 'MEX', 'numeric' => '484' },
    'fm' => { 'shortname' => 'Micronesia, Federated States of', 'alpha-2' => 'FM', 'alpha-3' => 'FSM', 'numeric' => '583' },
    'md' => { 'shortname' => 'Moldova, Republic of', 'alpha-2' => 'MD', 'alpha-3' => 'MDA', 'numeric' => '498' },
    'mc' => { 'shortname' => 'Monaco', 'alpha-2' => 'MC', 'alpha-3' => 'MCO', 'numeric' => '492' },
    'mn' => { 'shortname' => 'Mongolia', 'alpha-2' => 'MN', 'alpha-3' => 'MNG', 'numeric' => '496' },
    'me' => { 'shortname' => 'Montenegro', 'alpha-2' => 'ME', 'alpha-3' => 'MNE', 'numeric' => '499' },
    'ms' => { 'shortname' => 'Montserrat', 'alpha-2' => 'MS', 'alpha-3' => 'MSR', 'numeric' => '500' },
    'ma' => { 'shortname' => 'Morocco', 'alpha-2' => 'MA', 'alpha-3' => 'MAR', 'numeric' => '504' },
    'mz' => { 'shortname' => 'Mozambique', 'alpha-2' => 'MZ', 'alpha-3' => 'MOZ', 'numeric' => '508' },
    'mm' => { 'shortname' => 'Myanmar', 'alpha-2' => 'MM', 'alpha-3' => 'MMR', 'numeric' => '104' },
    'na' => { 'shortname' => 'Namibia', 'alpha-2' => 'NA', 'alpha-3' => 'NAM', 'numeric' => '516' },
    'nr' => { 'shortname' => 'Nauru', 'alpha-2' => 'NR', 'alpha-3' => 'NRU', 'numeric' => '520' },
    'np' => { 'shortname' => 'Nepal', 'alpha-2' => 'NP', 'alpha-3' => 'NPL', 'numeric' => '524' },
    'nl' => { 'shortname' => 'Netherlands', 'alpha-2' => 'NL', 'alpha-3' => 'NLD', 'numeric' => '528' },
    'an' => { 'shortname' => 'Netherlands Antilles', 'alpha-2' => 'AN', 'alpha-3' => 'ANT', 'numeric' => '530' },
    'nc' => { 'shortname' => 'New Caledonia', 'alpha-2' => 'NC', 'alpha-3' => 'NCL', 'numeric' => '540' },
    'nz' => { 'shortname' => 'New Zealand', 'alpha-2' => 'NZ', 'alpha-3' => 'NZL', 'numeric' => '554' },
    'ni' => { 'shortname' => 'Nicaragua', 'alpha-2' => 'NI', 'alpha-3' => 'NIC', 'numeric' => '558' },
    'ne' => { 'shortname' => 'Niger', 'alpha-2' => 'NE', 'alpha-3' => 'NER', 'numeric' => '562' },
    'ng' => { 'shortname' => 'Nigeria', 'alpha-2' => 'NG', 'alpha-3' => 'NGA', 'numeric' => '566' },
    'nu' => { 'shortname' => 'Niue', 'alpha-2' => 'NU', 'alpha-3' => 'NIU', 'numeric' => '570' },
    'nf' => { 'shortname' => 'Norfolk Island', 'alpha-2' => 'NF', 'alpha-3' => 'NFK', 'numeric' => '574' },
    'mp' => { 'shortname' => 'Northern Mariana Islands', 'alpha-2' => 'MP', 'alpha-3' => 'MNP', 'numeric' => '580' },
    'no' => { 'shortname' => 'Norway', 'alpha-2' => 'NO', 'alpha-3' => 'NOR', 'numeric' => '578' },
    'om' => { 'shortname' => 'Oman', 'alpha-2' => 'OM', 'alpha-3' => 'OMN', 'numeric' => '512' },
    'pk' => { 'shortname' => 'Pakistan', 'alpha-2' => 'PK', 'alpha-3' => 'PAK', 'numeric' => '586' },
    'pw' => { 'shortname' => 'Palau', 'alpha-2' => 'PW', 'alpha-3' => 'PLW', 'numeric' => '585' },
    'ps' => { 'shortname' => 'Palestinian Territory, Occupied', 'alpha-2' => 'PS', 'alpha-3' => 'PSE', 'numeric' => '275' },
    'pa' => { 'shortname' => 'Panama', 'alpha-2' => 'PA', 'alpha-3' => 'PAN', 'numeric' => '591' },
    'pg' => { 'shortname' => 'Papua New Guinea', 'alpha-2' => 'PG', 'alpha-3' => 'PNG', 'numeric' => '598' },
    'py' => { 'shortname' => 'Paraguay', 'alpha-2' => 'PY', 'alpha-3' => 'PRY', 'numeric' => '600' },
    'pe' => { 'shortname' => 'Peru', 'alpha-2' => 'PE', 'alpha-3' => 'PER', 'numeric' => '604' },
    'ph' => { 'shortname' => 'Philippines', 'alpha-2' => 'PH', 'alpha-3' => 'PHL', 'numeric' => '608' },
    'pn' => { 'shortname' => 'Pitcairn', 'alpha-2' => 'PN', 'alpha-3' => 'PCN', 'numeric' => '612' },
    'pl' => { 'shortname' => 'Poland', 'alpha-2' => 'PL', 'alpha-3' => 'POL', 'numeric' => '616' },
    'pt' => { 'shortname' => 'Portugal', 'alpha-2' => 'PT', 'alpha-3' => 'PRT', 'numeric' => '620' },
    'pr' => { 'shortname' => 'Puerto Rico', 'alpha-2' => 'PR', 'alpha-3' => 'PRI', 'numeric' => '630' },
    'qa' => { 'shortname' => 'Qatar', 'alpha-2' => 'QA', 'alpha-3' => 'QAT', 'numeric' => '634' },
    're' => { 'shortname' => 'Réunion', 'alpha-2' => 'RE', 'alpha-3' => 'REU', 'numeric' => '638' },
    'ro' => { 'shortname' => 'Romania', 'alpha-2' => 'RO', 'alpha-3' => 'ROU', 'numeric' => '642' },
    'ru' => { 'shortname' => 'Russian Federation', 'alpha-2' => 'RU', 'alpha-3' => 'RUS', 'numeric' => '643' },
    'rw' => { 'shortname' => 'Rwanda', 'alpha-2' => 'RW', 'alpha-3' => 'RWA', 'numeric' => '646' },
    'bl' => { 'shortname' => 'Saint Barthélemy', 'alpha-2' => 'BL', 'alpha-3' => 'BLM', 'numeric' => '652' },
    'sh' => { 'shortname' => 'Saint Helena, Ascension and Tristan da Cunha', 'alpha-2' => 'SH', 'alpha-3' => 'SHN', 'numeric' => '654' },
    'kn' => { 'shortname' => 'Saint Kitts and Nevis', 'alpha-2' => 'KN', 'alpha-3' => 'KNA', 'numeric' => '659' },
    'lc' => { 'shortname' => 'Saint Lucia', 'alpha-2' => 'LC', 'alpha-3' => 'LCA', 'numeric' => '662' },
    'mf' => { 'shortname' => 'Saint Martin (French part)', 'alpha-2' => 'MF', 'alpha-3' => 'MAF', 'numeric' => '663' },
    'pm' => { 'shortname' => 'Saint Pierre and Miquelon', 'alpha-2' => 'PM', 'alpha-3' => 'SPM', 'numeric' => '666' },
    'vc' => { 'shortname' => 'Saint Vincent and the Grenadines', 'alpha-2' => 'VC', 'alpha-3' => 'VCT', 'numeric' => '670' },
    'ws' => { 'shortname' => 'Samoa', 'alpha-2' => 'WS', 'alpha-3' => 'WSM', 'numeric' => '882' },
    'sm' => { 'shortname' => 'San Marino', 'alpha-2' => 'SM', 'alpha-3' => 'SMR', 'numeric' => '674' },
    'st' => { 'shortname' => 'Sao Tome and Principe', 'alpha-2' => 'ST', 'alpha-3' => 'STP', 'numeric' => '678' },
    'sa' => { 'shortname' => 'Saudi Arabia', 'alpha-2' => 'SA', 'alpha-3' => 'SAU', 'numeric' => '682' },
    'sn' => { 'shortname' => 'Senegal', 'alpha-2' => 'SN', 'alpha-3' => 'SEN', 'numeric' => '686' },
    'rs' => { 'shortname' => 'Serbia', 'alpha-2' => 'RS', 'alpha-3' => 'SRB', 'numeric' => '688' },
    'sc' => { 'shortname' => 'Seychelles', 'alpha-2' => 'SC', 'alpha-3' => 'SYC', 'numeric' => '690' },
    'sl' => { 'shortname' => 'Sierra Leone', 'alpha-2' => 'SL', 'alpha-3' => 'SLE', 'numeric' => '694' },
    'sg' => { 'shortname' => 'Singapore', 'alpha-2' => 'SG', 'alpha-3' => 'SGP', 'numeric' => '702' },
    'sk' => { 'shortname' => 'Slovakia', 'alpha-2' => 'SK', 'alpha-3' => 'SVK', 'numeric' => '703' },
    'si' => { 'shortname' => 'Slovenia', 'alpha-2' => 'SI', 'alpha-3' => 'SVN', 'numeric' => '705' },
    'sb' => { 'shortname' => 'Solomon Islands', 'alpha-2' => 'SB', 'alpha-3' => 'SLB', 'numeric' => '090' },
    'so' => { 'shortname' => 'Somalia', 'alpha-2' => 'SO', 'alpha-3' => 'SOM', 'numeric' => '706' },
    'za' => { 'shortname' => 'South Africa', 'alpha-2' => 'ZA', 'alpha-3' => 'ZAF', 'numeric' => '710' },
    'gs' => { 'shortname' => 'South Georgia and the South Sandwich Islands', 'alpha-2' => 'GS', 'alpha-3' => 'SGS', 'numeric' => '239' },
    'es' => { 'shortname' => 'Spain', 'alpha-2' => 'ES', 'alpha-3' => 'ESP', 'numeric' => '724' },
    'lk' => { 'shortname' => 'Sri Lanka', 'alpha-2' => 'LK', 'alpha-3' => 'LKA', 'numeric' => '144' },
    'sd' => { 'shortname' => 'Sudan', 'alpha-2' => 'SD', 'alpha-3' => 'SDN', 'numeric' => '736' },
    'sr' => { 'shortname' => 'Suriname', 'alpha-2' => 'SR', 'alpha-3' => 'SUR', 'numeric' => '740' },
    'sj' => { 'shortname' => 'Svalbard and Jan Mayen', 'alpha-2' => 'SJ', 'alpha-3' => 'SJM', 'numeric' => '744' },
    'sz' => { 'shortname' => 'Swaziland', 'alpha-2' => 'SZ', 'alpha-3' => 'SWZ', 'numeric' => '748' },
    'se' => { 'shortname' => 'Sweden', 'alpha-2' => 'SE', 'alpha-3' => 'SWE', 'numeric' => '752' },
    'ch' => { 'shortname' => 'Switzerland', 'alpha-2' => 'CH', 'alpha-3' => 'CHE', 'numeric' => '756' },
    'sy' => { 'shortname' => 'Syrian Arab Republic', 'alpha-2' => 'SY', 'alpha-3' => 'SYR', 'numeric' => '760' },
    'tw' => { 'shortname' => 'Taiwan, Province of China', 'alpha-2' => 'TW', 'alpha-3' => 'TWN', 'numeric' => '158' },
    'tj' => { 'shortname' => 'Tajikistan', 'alpha-2' => 'TJ', 'alpha-3' => 'TJK', 'numeric' => '762' },
    'tz' => { 'shortname' => 'Tanzania, United Republic of', 'alpha-2' => 'TZ', 'alpha-3' => 'TZA', 'numeric' => '834' },
    'th' => { 'shortname' => 'Thailand', 'alpha-2' => 'TH', 'alpha-3' => 'THA', 'numeric' => '764' },
    'tl' => { 'shortname' => 'Timor-Leste', 'alpha-2' => 'TL', 'alpha-3' => 'TLS', 'numeric' => '626' },
    'tg' => { 'shortname' => 'Togo', 'alpha-2' => 'TG', 'alpha-3' => 'TGO', 'numeric' => '768' },
    'tk' => { 'shortname' => 'Tokelau', 'alpha-2' => 'TK', 'alpha-3' => 'TKL', 'numeric' => '772' },
    'to' => { 'shortname' => 'Tonga', 'alpha-2' => 'TO', 'alpha-3' => 'TON', 'numeric' => '776' },
    'tt' => { 'shortname' => 'Trinidad and Tobago', 'alpha-2' => 'TT', 'alpha-3' => 'TTO', 'numeric' => '780' },
    'tn' => { 'shortname' => 'Tunisia', 'alpha-2' => 'TN', 'alpha-3' => 'TUN', 'numeric' => '788' },
    'tr' => { 'shortname' => 'Turkey', 'alpha-2' => 'TR', 'alpha-3' => 'TUR', 'numeric' => '792' },
    'tm' => { 'shortname' => 'Turkmenistan', 'alpha-2' => 'TM', 'alpha-3' => 'TKM', 'numeric' => '795' },
    'tc' => { 'shortname' => 'Turks and Caicos Islands', 'alpha-2' => 'TC', 'alpha-3' => 'TCA', 'numeric' => '796' },
    'tv' => { 'shortname' => 'Tuvalu', 'alpha-2' => 'TV', 'alpha-3' => 'TUV', 'numeric' => '798' },
    'ug' => { 'shortname' => 'Uganda', 'alpha-2' => 'UG', 'alpha-3' => 'UGA', 'numeric' => '800' },
    'ua' => { 'shortname' => 'Ukraine', 'alpha-2' => 'UA', 'alpha-3' => 'UKR', 'numeric' => '804' },
    'ae' => { 'shortname' => 'United Arab Emirates', 'alpha-2' => 'AE', 'alpha-3' => 'ARE', 'numeric' => '784' },
    'gb' => { 'shortname' => 'United Kingdom', 'alpha-2' => 'GB', 'alpha-3' => 'GBR', 'numeric' => '826' },
    'us' => { 'shortname' => 'United States', 'alpha-2' => 'US', 'alpha-3' => 'USA', 'numeric' => '840' },
    'um' => { 'shortname' => 'United States Minor Outlying Islands', 'alpha-2' => 'UM', 'alpha-3' => 'UMI', 'numeric' => '581' },
    'uy' => { 'shortname' => 'Uruguay', 'alpha-2' => 'UY', 'alpha-3' => 'URY', 'numeric' => '858' },
    'uz' => { 'shortname' => 'Uzbekistan', 'alpha-2' => 'UZ', 'alpha-3' => 'UZB', 'numeric' => '860' },
    'vu' => { 'shortname' => 'Vanuatu', 'alpha-2' => 'VU', 'alpha-3' => 'VUT', 'numeric' => '548' },
    've' => { 'shortname' => 'Venezuela, Bolivarian Republic of', 'alpha-2' => 'VE', 'alpha-3' => 'VEN', 'numeric' => '862' },
    'vn' => { 'shortname' => 'Viet Nam', 'alpha-2' => 'VN', 'alpha-3' => 'VNM', 'numeric' => '704' },
    'vg' => { 'shortname' => 'Virgin Islands, British', 'alpha-2' => 'VG', 'alpha-3' => 'VGB', 'numeric' => '092' },
    'vi' => { 'shortname' => 'Virgin Islands, U.S.', 'alpha-2' => 'VI', 'alpha-3' => 'VIR', 'numeric' => '850' },
    'wf' => { 'shortname' => 'Wallis and Futuna', 'alpha-2' => 'WF', 'alpha-3' => 'WLF', 'numeric' => '876' },
    'eh' => { 'shortname' => 'Western Sahara', 'alpha-2' => 'EH', 'alpha-3' => 'ESH', 'numeric' => '732' },
    'ye' => { 'shortname' => 'Yemen', 'alpha-2' => 'YE', 'alpha-3' => 'YEM', 'numeric' => '887' },
    'zm' => { 'shortname' => 'Zambia', 'alpha-2' => 'ZM', 'alpha-3' => 'ZMB', 'numeric' => '894' },
    'zw' => { 'shortname' => 'Zimbabwe', 'alpha-2' => 'ZW', 'alpha-3' => 'ZWE', 'numeric' => '716' },
};

sub get {
    # @Description  Returns a country code
    # @Param <str>  (String) ccTLD string
    # @Param <str>  (String) 'alpha-2' or 'alpha-3' or 'numeric' or 'shortname'
    # @Return       (String) data
    #               (String) '' = did not match
    my $class = shift;
    my $cctld = shift || return undef;
    my $alpha = shift || 'alpha-2';

    $cctld = 'gb' if $cctld =~ m/\Auk\z/i;
    return $CCTLD->{ lc $cctld }->{ lc $alpha } // '';
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::ISO3166 - Look up the country code data

=head1 SYNOPSIS

    use Sisimai::ISO3166;
    print Sisimai::ISO3166->get('jp');    # JP

=head1 DESCRIPTION

Sisimai::ISO3166 returns ISO-3166 data: Short name, Alpha-2 code, Alpha-3 code,
and Numeric code looked up from C<ccTLD> string as the first argument of
C<get()> method.

=head1 CLASS METHODS

=head2 C<B<get( I<ccTLD> [, I<type>] )>>

C<get()> returns a Short name or Alpha-2 code, or Alpha-3 code, or Numeric code
of ISO-3166.

    print Sisimai::ISO3166->get('jp','aplha-3');    # JPN
    print Sisimai::ISO3166->get('us','shortname');  # United States

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut
