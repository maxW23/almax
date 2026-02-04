import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/room/presentation/views/widgets/flages_countrys.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/rename_room_dialog.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/cover_image_profile_user.dart';
import '../widgets/birthday_selection_dialog.dart';
import '../widgets/image_user_section.dart';
import '../widgets/user_profile_edit_page_appbar.dart';

class UserProfileEditPage extends StatelessWidget {
  const UserProfileEditPage({
    super.key,
    required this.user,
    required this.userCubit,
  });

  final UserEntity user;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    String selectedLanguage = context.read<LanguageCubit>().state.languageCode;
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.2;
    String safe(String? v) {
      final t = (v ?? '').trim();
      return t.isEmpty || t.toLowerCase() == 'null' ? '—' : t;
    }

    String fieldValue(String? v) {
      final t = (v ?? '').trim();
      return t.isEmpty || t.toLowerCase() == 'null' ? '' : t;
    }

    return Directionality(
      textDirection: getTextDirection(selectedLanguage),
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: const UserProfileEditPageAppbar(),
          backgroundColor: Colors.white,
          body: BlocBuilder<UserCubit, UserCubitState>(
            builder: (context, state) {
              final currentUserData = userCubit.user ?? user;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header as in design: cover + white arc + summary card
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        CoverImageProfileUser(
                          imagePath: currentUserData.img,
                          isOther: false,
                          power: currentUserData.power,
                        ),
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        Directionality(
                          textDirection: getTextDirection(selectedLanguage),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 170,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                // Summary content inside card
                                Positioned(
                                  top: -24,
                                  left: 14,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.18),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ImageUserSectionWithEdit(
                                      userCubit: userCubit,
                                      user: currentUserData,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 105,
                                  left: 40,
                                  right: 40,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        safe(currentUserData.name),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${safe(currentUserData.iduser)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Gender selector
                          const _SectionLabel(text: 'Gender'),
                          const SizedBox(height: 8),
                          _GenderSelectorRow(
                            selected:
                                (currentUserData.gender ?? '').toLowerCase(),
                            onSelect: (g) async {
                              await userCubit.editUserProfile(gender: g);
                              await userCubit
                                  .getProfileUser("UserProfileEditPage gender");
                              SnackbarHelper.showMessage(
                                context,
                                '${S.of(context).theGenderUpdated} $g',
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Name
                          const _SectionLabel(text: 'Name'),
                          const SizedBox(height: 8),
                          _OutlinedActionField(
                            value: fieldValue(currentUserData.name),
                            hint: S.of(context).username,
                            icon: FontAwesomeIcons.pen,
                            onTap: () async {
                              String? newName = await showDialog<String>(
                                context: context,
                                builder: (context) => const RenameNameDialog(),
                              );
                              if (newName != null) {
                                await userCubit.editUserProfile(name: newName);
                                await userCubit
                                    .getProfileUser("UserProfileEditPage");
                                SnackbarHelper.showMessage(
                                  context,
                                  '${S.of(context).theUsernameRenamed} $newName',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Birthday
                          const _SectionLabel(text: 'Birthday'),
                          const SizedBox(height: 8),
                          _OutlinedActionField(
                            value: fieldValue(currentUserData.birth),
                            hint: S.of(context).birthday,
                            icon: FontAwesomeIcons.calendar,
                            onTap: () async {
                              String? newBirth = await showDialog<String>(
                                context: context,
                                builder: (context) =>
                                    const BirthdaySelectionDialog(),
                              );
                              if (newBirth != null) {
                                await userCubit.editUserProfile(
                                    birth: newBirth);
                                await userCubit.getProfileUser(
                                    "UserProfileEditPage newBirth");
                                SnackbarHelper.showMessage(
                                  context,
                                  '${S.of(context).theBirthdayUpdated} $newBirth',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Country
                          const _SectionLabel(text: 'Country'),
                          const SizedBox(height: 8),
                          _OutlinedActionField(
                            value: fieldValue(currentUserData.country),
                            hint: S.of(context).country,
                            icon: FontAwesomeIcons.chevronDown,
                            onTap: () async {
                              String? newCountry = await showDialog<String>(
                                context: context,
                                builder: (context) => const CountryFlagPicker(),
                              );
                              if (newCountry != null) {
                                await userCubit.editUserCountry(newCountry);
                                userCubit.getProfileUser(
                                    "UserProfileEditPage country ");
                                SnackbarHelper.showMessage(
                                  context,
                                  '${S.of(context).country} $newCountry \n${S.of(context).maybeTheChangesTakeAboutTenSeconds}',
                                  durationinMilli: 3500,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Declaration
                          const _SectionLabel(text: 'Declaration'),
                          const SizedBox(height: 8),
                          _OutlinedActionField(
                            value: fieldValue(currentUserData.profile_state),
                            hint: S.of(context).friendDeclaration,
                            icon: FontAwesomeIcons.pen,
                            onTap: () async {
                              String? newDeclaration = await showDialog<String>(
                                context: context,
                                builder: (context) => const RenameNameDialog(),
                              );
                              if (newDeclaration != null) {
                                await userCubit.editUserProfile(
                                    profileState: newDeclaration);
                                await userCubit.getProfileUser(
                                    "UserProfileEditPage newDeclaration ");
                                SnackbarHelper.showMessage(
                                  context,
                                  '${S.of(context).theFriendDeclarationRenamed} $newDeclaration',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                        ],
                      ), // end inner Column
                    ), // end Padding
                  ], // end outer Column children
                ), // end outer Column
              ); // end SingleChildScrollView return
            },
          ), // end BlocBuilder
        ), // end Scaffold
      ), // end SafeArea
    ); // end Directionality
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.black.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OutlinedActionField extends StatelessWidget {
  const _OutlinedActionField({
    required this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.trim().isEmpty || value == '-';
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isEmpty ? hint : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isEmpty
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
                color: Colors.white,
              ),
              child: Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderSelectorRow extends StatelessWidget {
  const _GenderSelectorRow({
    required this.selected,
    required this.onSelect,
  });

  final String selected; // 'male' | 'female'
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final selText = selected.startsWith('f')
        ? 'Female'
        : selected.startsWith('m')
            ? 'Male'
            : '—';

    return Row(
      children: [
        // display current selection
        Expanded(
          child: Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              selText,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _GenderIconButton(
          icon: FontAwesomeIcons.mars,
          selected: selected.startsWith('m'),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondColor],
          ),
          onTap: () => onSelect('male'),
        ),
        const SizedBox(width: 10),
        _GenderIconButton(
          icon: FontAwesomeIcons.venus,
          selected: selected.startsWith('f'),
          gradient: const LinearGradient(
            colors: [Colors.pinkAccent, Color(0xFFE91E63)],
          ),
          onTap: () => onSelect('female'),
        ),
      ],
    );
  }
}

class _GenderIconButton extends StatelessWidget {
  const _GenderIconButton({
    required this.icon,
    required this.selected,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Icon(icon, color: Colors.black.withValues(alpha: 0.55), size: 16),
    );

    if (!selected)
      return InkWell(
          onTap: onTap, customBorder: const CircleBorder(), child: base);

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      ),
    );
  }
}

 
