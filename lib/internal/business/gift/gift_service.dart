part of 'gift_controller.dart';

mixin GiftService {
  final _giftServiceImpl = GiftServiceImpl();
  GiftServiceImpl get service => _giftServiceImpl;
}

class GiftServiceImpl {
  late int _appID;
  late String _localUserID;
  late String _localUserName;

  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  final recvNotifier = ValueNotifier<ZegoGiftCommand?>(null);

  void init(
      {required int appID,
      required String localUserID,
      required String localUserName}) {
    _appID = appID;
    _localUserID = localUserID;
    _localUserName = localUserName;

    _subscriptions.add(ZEGOSDKManager()
        .zimService
        .onRoomCommandReceivedEventStreamCtrl
        .stream
        .listen((event) {
      onInRoomCommandMessageReceived(event);
    }));
  }

  void uninit() {
    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
    ZegoGiftController().destroyMediaPlayer();
  }

  Future<bool> sendGift({required String giftName}) async {
    final data = ZegoGiftCommand(
      appID: _appID,
      liveID: ZEGOSDKManager().expressService.currentRoomID,
      localUserID: _localUserID,
      localUserName: _localUserName,
      giftName: giftName,
    ).toJson();

    ///! This is just a demo for synchronous display effects.
    ///!
    ///! If it involves billing or your business logic,
    ///! please use the SERVER API to send a Message of type ZIMCommandMessage.
    ///!
    ///! https://docs.zegocloud.com/article/16201

    const warningTag = 'GiftService';
    AppLogger.warning('! ${'*' * 80}', tag: warningTag);
    AppLogger.warning(
        '! ** Warning: This is just a demo for synchronous display effects.',
        tag: warningTag);
    AppLogger.warning('! ** ', tag: warningTag);
    AppLogger.warning('! ** If it involves billing or your business logic,',
        tag: warningTag);
    AppLogger.warning(
        '! ** please use the SERVER API to send a Message of type ZIMCommandMessage.',
        tag: warningTag);
    AppLogger.warning('! ${'*' * 80}', tag: warningTag);

    AppLogger.debug('try send gift, giftName:$giftName, data:$data',
        tag: warningTag);
    ZEGOSDKManager().zimService.sendRoomCommand(data).then((result) {
      AppLogger.info('send gift success', tag: warningTag);
    });
    return true;
  }

  void onInRoomCommandMessageReceived(OnRoomCommandReceivedEvent event) {
    AppLogger.debug('onInRoomCommandMessageReceived: ${event.command}',
        tag: 'GiftService');
    final message = event.command;
    final senderUserID = event.senderID;
    // You can display different animations according to gift-type
    if (senderUserID != _localUserID) {
      final gift = ZegoGiftCommand.fromJson(message);
      recvNotifier.value = gift;
    }
  }
}

class ZegoGiftCommand {
  int appID = 0;
  String liveID = '';
  String localUserID = '';
  String localUserName = '';
  String giftName;

  ZegoGiftCommand({
    required this.appID,
    required this.liveID,
    required this.localUserID,
    required this.localUserName,
    required this.giftName,
  });

  String toJson() => json.encode({
        'app_id': appID,
        'room_id': liveID,
        'user_id': localUserID,
        'user_name': localUserName,
        'gift_name': giftName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

  factory ZegoGiftCommand.fromJson(String jsonData) {
    var json = <String, dynamic>{};
    try {
      json = jsonDecode(jsonData) as Map<String, dynamic>? ?? {};
    } catch (e) {
      AppLogger.error('protocol data is not json:$jsonData',
          tag: 'GiftService');
    }
    return ZegoGiftCommand(
      appID: json['app_id'] ?? 0,
      liveID: json['room_id'] ?? '',
      localUserID: json['user_id'] ?? '',
      localUserName: json['user_name'] ?? '',
      giftName: json['gift_name'] ?? '',
    );
  }
}
