import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/image_helper.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/chat/domain/enitity/message_entity.dart';
import 'package:lklk/features/chat/presentation/manger/message_cubit/message_cubit.dart';
import 'package:lklk/features/chat/presentation/manger/message_progress_cubit_cubit/message_progress_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:lklk/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widget/message_image.dart';
import 'widget/message_text.dart';

class ChatPrivatePageBloc extends StatelessWidget {
  const ChatPrivatePageBloc({
    super.key,
    required this.userId,
    this.userImg,
    this.userImgcurrent,
    required this.userName,
    this.isOfficial = false,
    required this.roomCubit,
    required this.userCubit,
  });
  final String userId;
  final String? userImg;
  final String? userImgcurrent;
  final String userName;
  final bool isOfficial;
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageProgressCubitCubit>(
      create: (context) => MessageProgressCubitCubit(),
      child: ChatPrivatePage(
          userId: userId,
          userImg: userImg,
          userImgcurrent: userImgcurrent,
          userName: userName,
          roomCubit: roomCubit,
          userCubit: userCubit,
          isOfficial: isOfficial),
    );
  }
}

class ChatPrivatePage extends StatefulWidget {
  const ChatPrivatePage({
    super.key,
    required this.userId,
    required this.userImg,
    required this.userName,
    this.isOfficial = false,
    this.userImgcurrent,
    required this.roomCubit,
    required this.userCubit,
  });
  final String userId;
  final String? userImg;
  final String? userImgcurrent;
  final String userName;
  final bool isOfficial;

  final RoomCubit roomCubit;
  final UserCubit userCubit;
  @override
  State<ChatPrivatePage> createState() => _ChatPrivatePageState();
}

class _ChatPrivatePageState extends State<ChatPrivatePage> {
  String? text;
  late TextEditingController _controller;
  late ScrollController scrollController;
  late bool isPlayingMsg = false,
      isRecording = false,
      isSending = false,
      emojiShowing = false;
  bool _shouldScrollToBottom = true;
  late FocusNode _focusNode;
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    scrollController = ScrollController();
    _focusNode = FocusNode();
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels ==
              scrollController.position.minScrollExtent) {
        _shouldScrollToBottom = true;
      } else {
        _shouldScrollToBottom = false;
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessageCubit()..fetchMessages(widget.userId),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppColors.graywhiteChat,
          appBar: AppbarChatPrivate(widget: widget),
          body: BlocConsumer<MessageCubit, MessageState>(
            listener: (context, state) {
              if (state.status.isLoaded && _shouldScrollToBottom) {
                _scrollToBottom();
              }
            },
            builder: (context, state) {
              if (state.status.isLoaded || state.messages != null) {
                return messageLoadedSection(state.messages!, context);
              } else {
                return const Center(child: AutoSizeText(''));
              }
            },
          ),
        ),
      ),
    );
  }

  Column messageLoadedSection(
      List<MessagePrivate> messages, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: listViewMessagesLoadedPart(messages)),
        Container(
          decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80), topRight: Radius.circular(80))),
          child: bottombarSection(context),
        )
      ],
    );
  }

  Column bottombarSection(BuildContext context) {
    //log('chatttt ${widget.isOfficial}  -- ${widget.userId}');
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.userId == '222' || widget.isOfficial)
          const SizedBox()
        else
          _buildBottomBar(context, widget.userId, _controller),
        emojiShowing
            ? _showEmojiPicker(context, _controller)
            : const SizedBox(),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  ListView listViewMessagesLoadedPart(List<MessagePrivate> messages) {
    return ListView.separated(
      reverse: true,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10),
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10.0);
      },
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        MessagePrivate m = messages[index];

        final String formattedDate = _formatDate(m.createdAt);

        if (m.receiverId == widget.userId) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FocusedMenuHolder(
                menuWidth: 110,
                blurSize: 5,
                menuItemExtent: 38,
                duration: const Duration(milliseconds: 300),
                animateMenuItems: true,
                blurBackgroundColor: Colors.transparent,
                openWithTap: true,
                menuOffset: -20, // Adjust as needed
                bottomOffsetHeight: 50, // Adjust as needed
                enableMenuScroll: false,
                menuItems: getMenuItemsList(m.id.toString(), m.message),
                onPressed: () {},
                child: _buildMessageRow(m,
                    current: true, formattedDate: formattedDate),
              ),
            ],
          );
        }
        return FocusedMenuHolder(
          menuWidth: 110,
          blurSize: 5,
          menuItemExtent: 38,
          duration: const Duration(milliseconds: 300),
          animateMenuItems: true,
          blurBackgroundColor: Colors.transparent,
          openWithTap: true,
          menuOffset: -20, // Adjust as needed
          bottomOffsetHeight: 50, // Adjust as needed
          enableMenuScroll: false,
          menuItems: getMenuItemsListOther(m.id.toString(), m.message),
          onPressed: () {},
          child:
              _buildMessageRow(m, current: false, formattedDate: formattedDate),
        );
      },
    );
  }

  Widget _buildBottomBar(
      BuildContext context, String userId, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20),
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle, color: AppColors.white),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () async {
              setState(() {
                emojiShowing = !emojiShowing;
              });
              //log('emojiShowing $emojiShowing');
            },
            icon: const Icon(
              FontAwesomeIcons.faceSmile,
              color: AppColors.grey,
              size: 30,
            ),
          ),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              controller: _controller,
              textDirection: ui.TextDirection
                  .rtl, // 12341234 must make ltr or rtl for languages
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                hintText: S.of(context).writeMessage,
              ),
              onEditingComplete: () async {
                await _save(userId);
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.paperPlane,
              color: AppColors.grey,
            ),
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              await _save(userId);
            },
          ),
          IconButton(
            onPressed: () async {
              PermissionStatus status = await Permission.storage.status;

              if (status.isGranted) {
                File? fileImage = await ImageHelper.pickImage(isCrop: false);
                if (fileImage == null) {
                  // Check if the selected file was a GIF (track this in your state)
                  // Show snackbar
                  final messnger = ScaffoldMessenger.of(context);
                  messnger.showSnackBar(
                    const SnackBar(
                        content:
                            AutoSizeText('الصورة كبيرة جدًا ولا يمكن تحميلها')),
                  );
                }
                if (fileImage != null) {
                  if (mounted) {
                    await BlocProvider.of<MessageProgressCubitCubit>(context)
                        .sendImage(widget.userId, fileImage);
                  }
                }
              } else if (status.isPermanentlyDenied) {
                // إذا رفض الإذن بشكل دائم، توجيه المستخدم إلى الإعدادات
                bool shouldOpenSettings = await showDialog(
                  context: context,
                  useSafeArea: true,
                  builder: (context) => SafeArea(
                    child: AlertDialog(
                      insetPadding: EdgeInsets.fromLTRB(
                        24,
                        24,
                        24,
                        24 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      title: AutoSizeText(S.of(context).permissionRequired),
                      content: AutoSizeText(
                          S.of(context).pleaseEnableStoragePermissionInSettings),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: AutoSizeText(S.of(context).cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: AutoSizeText(S.of(context).openSettings),
                        ),
                      ],
                    ),
                  ),
                );

                if (shouldOpenSettings == true) {
                  await openAppSettings();
                }
              } else {
                // إذا لم يكن الإذن ممنوحًا، اطلب الإذن مرة أخرى
                PermissionStatus newStatus = await Permission.storage.request();
                if (newStatus.isGranted) {
                  File? fileImage = await ImageHelper.pickImage(isCrop: false);
                  if (fileImage == null) {
                    // Check if the selected file was a GIF (track this in your state)
                    // Show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: AutoSizeText(
                              'الصورة كبيرة جدًا ولا يمكن تحميلها')),
                    );
                  }
                  if (fileImage != null) {
                    if (mounted) {
                      await BlocProvider.of<MessageProgressCubitCubit>(context)
                          .sendImage(widget.userId, fileImage);
                    }
                  }
                } else {
                  File? fileImage = await ImageHelper.pickImage(isCrop: false);
                  if (fileImage == null) {
                    // Check if the selected file was a GIF (track this in your state)
                    // Show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: AutoSizeText(
                              'الصورة كبيرة جدًا ولا يمكن تحميلها')),
                    );
                  }
                  if (fileImage != null) {
                    if (mounted) {
                      await BlocProvider.of<MessageProgressCubitCubit>(context)
                          .sendImage(widget.userId, fileImage);
                    }
                  }
                  SnackbarHelper.showMessage(
                      context, S.of(context).giveThePermissionPlease);
                }
              }
            },
            icon: const Icon(
              FontAwesomeIcons.image,
              color: AppColors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showEmojiPicker(
      BuildContext context, TextEditingController controller) {
    return SizedBox(
      height: 256, // Adjust height as needed
      child: EmojiPicker(
        onEmojiSelected: (Category? category, Emoji emoji) {
          controller.text += emoji.emoji;
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            backgroundColor: AppColors.white,
            columns: 8,
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.2
                    : 1.0),
          ),
          // swapCategoryAndBottomBar: false,
          skinToneConfig:
              const SkinToneConfig(dialogBackgroundColor: AppColors.grey),
          categoryViewConfig: const CategoryViewConfig(
            backgroundColor: AppColors.white,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: const SearchViewConfig(),
        ),
      ),
    );
  }

  _save(String userId) async {
    String message = _controller.text.trim();
    _controller.clear();
    if (message.isEmpty) return;
    // FocusScope.of(context).requestFocus(FocusNode());
    if (mounted) {
      await BlocProvider.of<MessageProgressCubitCubit>(context)
          .sendMessage(userId, message);
    }
    _scrollToBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  _buildMessageRow(MessagePrivate message,
      {required bool current, required String formattedDate}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          current ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          current ? CrossAxisAlignment.start : CrossAxisAlignment.start,
      children: [
        SizedBox(width: current ? 30.0 : 20.0),
        if (!current) ...[
          CircularUserImage(
            imagePath: widget.userImg,
            radius: 20,
          ),
          const SizedBox(width: 5.0),
        ],
        Container(
          padding: const EdgeInsets.only(
            bottom: 5,
            right: 5,
          ),
          child: Column(
            crossAxisAlignment:
                current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              if (message.message.contains('https://lklklive.com/imgchat'))
                MessageImage(
                  current: current,
                  message: message,
                )
              else
                MessageText(
                  current: current,
                  message: message,
                ),
              const SizedBox(
                height: 2,
              ),
              AutoSizeText(
                formattedDate,
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withValues(alpha: 0.5)),
              )
            ],
          ),
        ),
        if (current) ...[
          CircularUserImage(
            imagePath: widget.userImgcurrent,
            radius: 20,
          ),
          const SizedBox(width: 5.0),
        ],
        SizedBox(width: current ? 20.0 : 30.0),
      ],
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateTime now = DateTime.now();

    if (parsedDate.year == now.year &&
        parsedDate.month == now.month &&
        parsedDate.day == now.day) {
      return DateFormat.Hm().format(parsedDate);
    } else {
      return DateFormat.yMd().format(parsedDate);
    }
  }

  List<FocusedMenuItem> getMenuItemsListOther(
      String messageID, String message) {
    return <FocusedMenuItem>[
      copyMessage(message),
      back(),
    ];
  }

  List<FocusedMenuItem> getMenuItemsList(String messageID, String message) {
    return <FocusedMenuItem>[
      copyMessage(message),
      deleteMessage(messageID),
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

  FocusedMenuItem deleteMessage(String messageID) {
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
      onPressed: () {
        MessageCubit().deleteMessage(messageID);
      },
    );
  }

  FocusedMenuItem copyMessage(String message) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.copy,
            size: 12,
          ),
          const SizedBox(width: 4),
          AutoSizeText(
            S.of(context).copy,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: message));
        SnackbarHelper.showMessage(
          context,
          S.of(context).doneCopiedToClipboard,
        );
      },
    );
  }
}

class AppbarChatPrivate extends StatelessWidget implements PreferredSizeWidget {
  const AppbarChatPrivate({
    super.key,
    required this.widget,
  });

  final ChatPrivatePage widget;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileViewBodySuccessBloc(
                    iduser: widget.userId,
                    userCubit: widget.userCubit,
                    roomCubit: widget.roomCubit,
                  ),
                ),
              ),
              child: CircularUserImage(
                imagePath: widget.userImg,
                radius: 20,
              ),
            ),
          ),
          AutoSizeText(
            widget.userName,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
