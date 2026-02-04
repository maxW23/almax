import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/generated/l10n.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = context.read<LanguageCubit>().state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<LanguageCubit, Locale>(
      listener: (context, locale) => setState(() {
        _selectedLanguage = locale.languageCode;
      }),
      child: Directionality(
        textDirection: getTextDirection(_selectedLanguage),
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/Settings_icon.svg',
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: 8),
                AutoSizeText(s.settings),
              ],
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              AutoSizeText(
                s.language,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _LanguageRow(
                label: 'Arabic',
                iconAsset: 'assets/icons/settings_icons/Language_icon.svg',
                value: _selectedLanguage == 'ar',
                onChanged: (val) {
                  if (val) context.read<LanguageCubit>().switchLanguage('ar');
                },
              ),
              _LanguageRow(
                label: 'English',
                iconAsset: 'assets/icons/settings_icons/Language_icon.svg',
                value: _selectedLanguage == 'en',
                onChanged: (val) {
                  if (val) context.read<LanguageCubit>().switchLanguage('en');
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _LanguageRow({
    required this.label,
    required this.iconAsset,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SvgPicture.asset(iconAsset, width: 30, height: 30),
          title: AutoSizeText(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          trailing: Switch(
            value: value,
            onChanged: (v) => onChanged(v),
          ),
        ),
        const Divider(height: 0, thickness: 0.3, indent: 20, endIndent: 30),
      ],
    );
  }
}
