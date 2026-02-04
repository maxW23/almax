import 'dart:io';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/dialog_amont.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/post_charger/post_charger_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/features/profile_users/domain/entities/post_charger_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PostChargerItem extends StatefulWidget {
  const PostChargerItem({
    super.key,
    required this.user,
  });

  final PostCharger user;

  @override
  State<PostChargerItem> createState() => _PostChargerItemState();
}

class _PostChargerItemState extends State<PostChargerItem> {
  late final String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = context.read<LanguageCubit>().state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final double h = 640;

    return Directionality(
      textDirection: getTextDirection(_selectedLanguage),
      child: Container(
        height: h / 3.2,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(8),
        decoration: _buildDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _UserInfoSection(user: widget.user)),
            const SizedBox(height: 4),
            _WalletDisplay(wallet: widget.user.wallet.toString()),
            const SizedBox(height: 4),
            _ActionButtons(
              userId: widget.user.id.toString(),
              phoneNumber: widget.user.number,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(colors: [
        AppColors.white,
        AppColors.whiteIcon,
      ]),
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [
        BoxShadow(
          color: AppColors.grey,
          blurRadius: 1,
          spreadRadius: 0.4,
          blurStyle: BlurStyle.inner,
        ),
      ],
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection({required this.user});

  final PostCharger user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 6.0,
      child: Row(
        children: [
          const SizedBox(width: 10),
          CircularUserImage(
            imagePath: user.img ?? AssetsData.userTestNetwork,
            radius: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                Flexible(child: _buildName()),
                Flexible(child: _buildId()),
                Flexible(child: _buildCountry(context)),
                Flexible(child: _buildWhatsAppNumber()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildName() {
    return AutoSizeText(
      user.name,
      style: Styles.textStyle18,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildId() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AutoSizeText(
        'ID: ${user.id}',
        style: Styles.textStyle12gray,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCountry(BuildContext context) {
    return Row(
      children: [
        AutoSizeText(
          '${S.of(context).country} :',
          style: Styles.textStyle12gray,
        ),
        const SizedBox(width: 4),
        user.country == 'world'
            ? const Icon(FontAwesomeIcons.globe, size: 15)
            : CountryFlag.fromCountryCode(
                user.country!,
                shape: const RoundedRectangle(3),
                height: 17,
                width: 24,
              ),
      ],
    );
  }

  Widget _buildWhatsAppNumber() {
    return AutoSizeText(
      'whatsapp: ${user.number}',
      style: Styles.textStyle12gray,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _WalletDisplay extends StatelessWidget {
  const _WalletDisplay({required this.wallet});

  final String wallet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: AutoSizeText(
        ' ${S.of(context).amountcoins} $wallet',
        style: Styles.textStyle18,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.userId,
    required this.phoneNumber,
  });

  final String userId;
  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ConvertCoinsButton(userId: userId),
          const SizedBox(width: 10),
          _WhatsAppButton(phoneNumber: phoneNumber),
        ],
      ),
    );
  }
}

class _ConvertCoinsButton extends StatelessWidget {
  const _ConvertCoinsButton({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final amount = await showAmountDialog(context);
        if (amount != null) {
          String message = await context
              .read<PostChargerCubit>()
              .convertCoins(userId, '$amount');
          switch (message) {
            case 'done':
              message = S.of(context).done;
              // تحديث الملف الشخصي بعد نجاح التحويل
              await context.read<UserCubit>().getProfileUser('convertCoins');
              break;
            case 'error':
              message = S.of(context).error;
              break;
            case 'failed':
              message = S.of(context).fail;
              break;
          }
          SnackbarHelper.showMessage(context, message);
        }
      },
      label: AutoSizeText(
        S.of(context).postConvertCoins,
        style: const TextStyle(color: AppColors.golden),
      ),
      icon: const Icon(
        FontAwesomeIcons.arrowsRotate,
        color: AppColors.golden,
      ),
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({required this.phoneNumber});

  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: phoneNumber != null ? () => _launchWhatsApp(context) : null,
      icon: Icon(
        FontAwesomeIcons.whatsapp,
        color: AppColors.successColor,
      ),
      label: AutoSizeText(
        'WhatsApp',
        style: TextStyle(color: AppColors.successColor),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    try {
      final phone = int.parse(phoneNumber!.replaceAll(' ', ''));
      const message = 'Hello I want to buy Coins on LKLK App';

      final url = Platform.isAndroid
          ? 'https://wa.me/$phone/?text=${Uri.encodeComponent(message)}'
          : 'https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message)}';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoSizeText(S.of(context).whatsAppNotInstalled)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoSizeText(S.of(context).errorOccurred)),
      );
    }
  }
}
