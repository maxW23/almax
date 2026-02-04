// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// removed: color_button_with_image.dart (replaced by ImageButtonWithOverlay)
import 'package:lklk/features/profile_users/presentaion/views/widgets/image_button_with_overlay.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/count_profile_row.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_items_column.dart';
import '../pages/s_v_i_p_page.dart';
import 'coins_balance_page.dart';
import 'relation_icon_request.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_common_body.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_quick_actions_variants.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/profile_user_edits_page.dart';

class UserProfileViewBodySuccess extends StatefulWidget {
  const UserProfileViewBodySuccess({
    super.key,
    required this.user,
    required this.userCubit,
    required this.friendNumber,
    required this.visitorNumber,
    required this.friendRequest,
    required this.relationRequest,
    required this.giftList,
    required this.roomCubit,
    required this.frameList,
    required this.entryList,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final int friendNumber;
  final int visitorNumber;
  final int friendRequest;
  final int relationRequest;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? entryList;

  final RoomCubit roomCubit;
  @override
  State<UserProfileViewBodySuccess> createState() =>
      _UserProfileViewBodySuccessState();
}

class _UserProfileViewBodySuccessState
    extends State<UserProfileViewBodySuccess> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserCubitState>(
      listener: (context, state) {},
      builder: (context, state) {
        // log('visitorNumber in screen : ${widget.visitorNumber}');

        return SafeArea(
          child: Container(
            color: AppColors.white,
            child: SingleChildScrollView(
              child: ProfileCommonBody(
                user: state.user ?? widget.user,
                showRoom: false,
                userCubit: widget.userCubit,
                roomCubit: widget.roomCubit,
                room: state.myRoom,
                isOther: false,
                isWakel: true,
                showSvgaBadges: true,
                onUserTitleTap: () {
                  final u = state.user ?? widget.user;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileUserTitlesPage(
                        user: u,
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                        friendNumber: widget.friendNumber,
                        visitorNumber: widget.visitorNumber,
                        giftList: widget.giftList,
                        frameList: widget.frameList,
                        entryList: widget.entryList,
                      ),
                    ),
                  );
                },
                countsRow: CountProfileRow(
                  userCubit: widget.userCubit,
                  roomCubit: widget.roomCubit,
                  friendNumber: widget.friendNumber,
                  visitorNumber: widget.visitorNumber,
                  friendRequest: widget.friendRequest,
                  relationRequest: widget.relationRequest,
                  user: state.user ?? widget.user,
                ),
                trailing: RelationIconRequest(
                  userCubit: widget.userCubit,
                  roomCubit: widget.roomCubit,
                  user: state.user ?? widget.user,
                ),
                quickActions: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      balanceAndVipBtns(context, state),
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      ProfileItemsColumn(
                        user: state.user ?? widget.user,
                        roomCubit: widget.roomCubit,
                        userCubit: widget.userCubit,
                        giftList: widget.giftList,
                        frameList: widget.frameList,
                        entryList: widget.entryList,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Row balanceAndVipBtns(BuildContext context, UserCubitState state) {
    return Row(
      children: [
        Expanded(
          child: ImageButtonWithOverlay(
            image: 'assets/images/my_profile_icon/vip_btn.png',
            title: 'VIP',
            text: S.of(context).getIt,
            height: 80,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SVIPPage(
                  user: widget.user,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ImageButtonWithOverlay(
            image: 'assets/images/my_profile_icon/wallet_btn.png',
            height: 80,
            title: S.of(context).balance,
            text: state.user?.wallet != null
                ? (state.user!.wallet.toString())
                : (widget.user.wallet.toString()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoinsBalancePage(
                  wallet: state.user?.wallet != null
                      ? int.tryParse(state.user!.wallet.toString()) ?? 0
                      : int.tryParse(widget.user.wallet.toString()) ?? 0,
                  diamond: state.user?.diamond != null
                      ? int.tryParse(state.user!.diamond.toString()) ?? 0
                      : int.tryParse(widget.user.diamond.toString()) ?? 0,
                  userCubit: widget.userCubit,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
