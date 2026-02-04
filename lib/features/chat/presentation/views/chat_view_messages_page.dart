import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/chat/domain/enitity/home_message_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/empty_screen.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/chat/presentation/manger/home_message_cubit/home_message_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'chat_item_messsage_private.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';

class ChatPageListMessagesChatPage extends StatefulWidget {
  const ChatPageListMessagesChatPage(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;

  final RoomCubit roomCubit;
  @override
  State<ChatPageListMessagesChatPage> createState() =>
      _ChatPageListMessagesChatPageState();
}

class _ChatPageListMessagesChatPageState
    extends State<ChatPageListMessagesChatPage> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    // Load current language from cubit
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  void _showSnackBar(BuildContext context, String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarHelper.showMessage(
          context,
          message,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const ChatAppbar(),

        Expanded(
          child: BlocBuilder<HomeMessageCubit, HomeMessageState>(
            // bloc: HomeMessageCubit()..fetchLastMessages(),
            bloc: BlocProvider.of<HomeMessageCubit>(context)
              ..fetchLastMessages(),
            builder: (context, state) {
              if (state.status.isError) {
                _showSnackBar(
                    context, '${S.of(context).error}: ${state.errorMessage}');
              }

              List<HomeMessageEntity> messages = state.messages ?? [];

              if (messages.isNotEmpty) {
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    HomeMessageEntity message = messages[index];
                    return Directionality(
                      textDirection: getTextDirection(_selectedLanguage),
                      child: FocusedMenuHolder(
                        menuWidth: 110,
                        blurSize: 5,
                        menuItemExtent: 38,
                        duration: const Duration(milliseconds: 300),
                        animateMenuItems: true,
                        blurBackgroundColor: Colors.transparent,
                        menuOffset: 0,
                        bottomOffsetHeight: 0,
                        enableMenuScroll: false,
                        menuItems: getMenuItemsList(message.other.toString()),
                        onPressed: () {},
                        child: ChatPageItemLastMesssage(
                          roomCubit: widget.roomCubit,
                          userCubit: widget.userCubit,
                          lastMessageEntity: message,
                          isOffical: message.senderId == '222',
                        ),
                      ),
                    );
                  },
                );
              }
              if (state.status.isLoading ||
                  state.status == HomeMessageStatus.loading) {
                return ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) => Skeletonizer(
                    child: ChatPageItemLastMesssage(
                      roomCubit: widget.roomCubit,
                      userCubit: widget.userCubit,
                      lastMessageEntity: HomeMessageEntity(
                          id: 0,
                          senderId: "senderId",
                          receiverId: "receiverId",
                          message: "message",
                          type: "type",
                          createdAt: "2025-04-24T09:10:06.000000Z",
                          updatedAt: "2025-04-24T09:10:06.000000Z",
                          sender: "sender",
                          otherImg: AssetsData.userTestNetwork,
                          gender: "gender",
                          user: "user",
                          idString: "idString",
                          other: "other"),
                      isOffical: false,
                    ),
                  ),
                );
              }
              if (state.status.isLoaded && messages.isEmpty) {
                return const EmptyScreen();
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  List<FocusedMenuItem> getMenuItemsList(String conversationID) {
    return <FocusedMenuItem>[
      deleteConversation(conversationID),
      back(),
    ];
  }

  FocusedMenuItem back() {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 2),
          const Icon(
            FontAwesomeIcons.xmark,
            size: 12,
          ),
          const SizedBox(width: 4),
          AutoSizeText(
            S.of(context).back,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  FocusedMenuItem deleteConversation(String conversationID) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.trash,
            size: 12,
          ),
          const SizedBox(width: 4),
          AutoSizeText(
            S.of(context).delete,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: () async {
        final cubit = BlocProvider.of<HomeMessageCubit>(context);
        await cubit.deleteConversation(conversationID);
        // await HomeMessageCubit().deleteConversation(conversationID);
        await cubit.fetchLastMessages();
      },
    );
  }
}
