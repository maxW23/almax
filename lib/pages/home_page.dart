import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

// import '../zego_live_streaming_manager.dart';
import 'audio_room/audio_room.dart';
import 'call/call.dart';
import 'live_streaming/live_page.dart';
import 'live_streaming/swiping/defines.dart';

part 'entry_audio_room.dart';
part 'entry_call.dart';
part 'entry_live_streaming.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const AutoSizeText('Home Page'),
          actions: [
            avatar(),
            AutoSizeText('ID:${ZEGOSDKManager().currentUser!.iduser}'),
            const SizedBox(width: 10),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: CustomScrollView(slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Divider(),
                  CallEntry(),
                  Divider(),
                  LiveStreamingEntry(),
                  Divider(),
                  AudioRoomEntry(),
                  Divider(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  ValueListenableBuilder<String?> avatar() {
    return ValueListenableBuilder(
      valueListenable: ZEGOSDKManager().currentUser!.avatarUrlNotifier,
      builder: (BuildContext context, String? avatarUrl, Widget? child) {
        return avatarUrl?.isNotEmpty ?? false
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                // حجم كاش محسن لصورة المستخدم في الصفحة الرئيسية
                memCacheWidth: 120,
                memCacheHeight: 120,
                maxWidthDiskCache: 120,
                maxHeightDiskCache: 120,
                progressIndicatorBuilder: (context, url, _) =>
                    const CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

Widget roomIDTextField(TextEditingController controller) {
  return Row(
    children: [
      const AutoSizeText('RoomID:'),
      const SizedBox(width: 10, height: 20),
      Expanded(
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Please Input RoomID'),
        ),
      ),
    ],
  );
}
