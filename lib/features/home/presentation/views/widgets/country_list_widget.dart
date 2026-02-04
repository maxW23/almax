import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/views/widgets/country_data.dart';
import 'package:lklk/features/home/presentation/views/widgets/country_item.dart';
import 'package:lklk/generated/l10n.dart';

const List<String> _countryCodes = [
  'null',
  'sy',
  'eg',
  'sa',
  'jo',
  'ae',
  'dz',
  'bh',
  'dj',
  'iq',
  'kw',
  'lb',
  'ly',
  'ma',
  'mr',
  'om',
  'ps',
  'qa',
  'sd',
  'tn',
  'ye',
  'lk',
  'in',
  'bd',
  'np',
  'pk',
];

class CountryListWidget extends StatelessWidget {
  final String? selectedCountry;
  final ValueChanged<String> onCountrySelected;
  final VoidCallback onAllCountriesSelected;

  const CountryListWidget({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
    required this.onAllCountriesSelected,
  });
  @override
  Widget build(BuildContext context) {
    final List<CountryData> countries = _getCountries(context);

    return SizedBox(
      height: 55,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        reverse: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final isSelected = selectedCountry == country.code;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CountryItem(
              country: country,
              isSelected: isSelected,
              onTap: () => country.code == "null"
                  ? onAllCountriesSelected()
                  : onCountrySelected(country.code),
            ),
          );
        },
      ),
    );
  }

  List<CountryData> _getCountries(BuildContext context) {
    final List<String> countryNames = [
      S.of(context).all,
      S.of(context).syria,
      S.of(context).egypt,
      S.of(context).saudi_arabia,
      S.of(context).jordan,
      S.of(context).united_arab_emirates,
      S.of(context).algeria,
      S.of(context).bahrain,
      S.of(context).djibouti,
      S.of(context).iraq,
      S.of(context).kuwait,
      S.of(context).lebanon,
      S.of(context).libya,
      S.of(context).morocco,
      S.of(context).mauritania,
      S.of(context).oman,
      S.of(context).palestine,
      S.of(context).qatar,
      S.of(context).sudan,
      S.of(context).tunisia,
      S.of(context).yemen,
      S.of(context).sri_lanka,
      S.of(context).india,
      S.of(context).bangladesh,
      S.of(context).nepal,
      S.of(context).pakistan,
    ];

    return List.generate(
      _countryCodes.length,
      (index) => CountryData(
        code: _countryCodes[index],
        name: countryNames[index],
      ),
    );
  }
}
