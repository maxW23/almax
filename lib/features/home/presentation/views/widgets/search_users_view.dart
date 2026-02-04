import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/widgets/search_white_text_field.dart';
import 'package:lklk/features/profile_users/presentaion/manger/freind_progress/freind_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/generated/l10n.dart';
import '../../../../profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';

class SearchUsersView extends StatelessWidget {
  const SearchUsersView(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return BlocProvider<FreindProgressCubit>(
      lazy: true,
      create: (context) => FreindProgressCubit(),
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                SearchTextField(
                  controller: controller,
                  hintText: S.of(context).iDORName,
                  onSubmitted: (value) {
                    userCubit.searchUserByIdOrName(
                      id: value,
                    );
                  },
                ),
                Expanded(
                  child: BlocConsumer<UserCubit, UserCubitState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state.users != null) {
                        List<UserEntity> searchResults = state.users!;
                        return ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) => buildUsersItem(
                            context,
                            index,
                            searchResults,
                            userCubit,
                            roomCubit,
                            controller.text,
                          ),
                        );
                      } else if (state.status.isLoading) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: AppColors.black,
                        ));
                      }
                      if (state.status.isFriendRequestSent) {
                        return const Center(child: SizedBox());
                      } else {
                        return const Center(child: SizedBox());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUsersItem(
    BuildContext context,
    int index,
    List<UserEntity> users,
    UserCubit userCubit,
    RoomCubit roomCubit,
    String valueSearch,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: UserWidgetTitle(
        isRoomTypeUser: false,
        isWakel: true,
        isAnimatedIcon: true,
        isID: true,
        isLevel: true,
        iconColor: AppColors.black,
        isPressIcon: () async {
          final messenger = ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar();
          final status = await BlocProvider.of<FreindProgressCubit>(context)
              .addFriendStatus(users[index].iduser);
          switch (status) {
            case 'done':
              messenger.showSnackBar(const SnackBar(
                content: Text('تم ارسال طلب صداقة بنجاح'),
                behavior: SnackBarBehavior.floating,
              ));
              break;
            case 'waiting_accepting':
              messenger.showSnackBar(const SnackBar(
                content: Text('تم الارسال'),
                behavior: SnackBarBehavior.floating,
              ));
              break;
            case 'already_friend':
              messenger.showSnackBar(const SnackBar(
                content: Text('أنتما صديقان بالفعل'),
                behavior: SnackBarBehavior.floating,
              ));
              break;
            default:
              final msg = status.startsWith('error:')
                  ? status.substring(6)
                  : status;
              messenger.showSnackBar(SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
              ));
          }
        },
        isPressIcon2: () async {
          await userCubit.searchUserByIdOrName(
            name: valueSearch,
          );
          if (users[index].stringid != null) {
            await BlocProvider.of<FreindProgressCubit>(context)
                .deleteFriendOrFriendRequest(users[index].stringid!);
          }
        },
        icon: FontAwesomeIcons.userPlus,
        iconSecond: FontAwesomeIcons.userCheck,
        isIcon: true,
        user: users[index],
        userCubit: userCubit,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileViewBodySuccessBloc(
              iduser: users[index].iduser,
              userCubit: userCubit,
              roomCubit: roomCubit,
              valueSearch: valueSearch,
            ),
          ),
        ),
      ),
    );
  }
}
