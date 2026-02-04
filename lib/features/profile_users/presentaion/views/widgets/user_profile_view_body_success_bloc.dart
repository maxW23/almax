import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/utils/status_bar_util.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/out_of_wakala/out_from_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';

class UserProfileViewBodySuccessBloc extends StatefulWidget {
  const UserProfileViewBodySuccessBloc({
    super.key,
    required this.iduser,
    required this.userCubit,
    this.valueSearch,
    required this.roomCubit,
  });

  final String iduser;
  final UserCubit userCubit;
  final String? valueSearch;
  final RoomCubit roomCubit;

  @override
  State<UserProfileViewBodySuccessBloc> createState() =>
      _UserProfileViewBodySuccessBlocState();
}

class _UserProfileViewBodySuccessBlocState
    extends State<UserProfileViewBodySuccessBloc> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    StatusBarUtil.setStatusBarColor(Colors.grey);
  }

  @override
  void didUpdateWidget(covariant UserProfileViewBodySuccessBloc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iduser != widget.iduser) {
      _loadUserProfile();
    }
  }

  void _loadUserProfile() {
    if (widget.iduser.isNotEmpty && widget.iduser != "null") {
      widget.userCubit.getUserProfileById(widget.iduser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (canPop) {
        if (widget.valueSearch != null && widget.valueSearch!.isNotEmpty) {
          widget.userCubit.searchUserByIdOrName(id: widget.valueSearch);
        }
      },
      canPop: true,
      child: BlocProvider<OutFromWakalaCubit>(
        create: (context) => OutFromWakalaCubit(),
        child: SafeArea(
          top: false,
          child: Scaffold(
            body: BlocConsumer<UserCubit, UserCubitState>(
              listener: (context, state) {
                if (state.status.isError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    SnackbarHelper.showMessage(
                      context,
                      'UserCubitError: ${state.message}',
                    );
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state.status.isLoadedById) {
                  return OtherUserProfile(
                    user: state.userOther!,
                    entryList: state.entryListOther,
                    frameList: state.frameListOther,
                    giftList: state.giftListOther,
                    userCubit: widget.userCubit,
                    friendStatus: state.freindOther,
                    friendNumber: state.friendNumberOther!,
                    visitorNumber: state.visitorNumberOther!,
                    roomCubit: widget.roomCubit,
                  );
                } else if (state.status.isError) {
                  // في حالة الخطأ، يتم التعامل مع التنقل والعرض في listener
                  return const Center(child: SizedBox());
                } else {
                  // Navigator.pop(context);

                  return const Center(child: SizedBox());
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
