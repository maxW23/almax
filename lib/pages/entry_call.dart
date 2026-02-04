part of 'home_page.dart';

class CallEntry extends StatefulWidget {
  const CallEntry({super.key});

  @override
  State<CallEntry> createState() => _CallEntryState();
}

class _CallEntryState extends State<CallEntry> {
  final inviteeIDController = TextEditingController();

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    subscriptions.addAll([]);
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in subscriptions) {
      element.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          AutoSizeText('Call Demo:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
        ]),
        Row(
          children: [
            const AutoSizeText('inviteeID:'),
            const SizedBox(width: 10, height: 20),
            Expanded(
              child: TextField(
                controller: inviteeIDController,
                decoration:
                    const InputDecoration(labelText: 'input invitee userID'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => startCall(ZegoCallType.voice),
                child: const AutoSizeText('voice call')),
            ElevatedButton(
                onPressed: () => startCall(ZegoCallType.video),
                child: const AutoSizeText('video call'))
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Future<void> startCall(ZegoCallType callType) async {
    final userIDList = inviteeIDController.text.split(',');
    if (callType == ZegoCallType.video) {
      if (userIDList.length > 1) {
        ZegoCallManager()
            .sendGroupVideoCallInvitation(userIDList)
            .then((value) {})
            .catchError((error) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: AutoSizeText('send call invitation failed: $error')),
          );
        });
      } else {
        ZegoCallManager()
            .sendVideoCallInvitation(inviteeIDController.text)
            .then((value) {
          final errorInvitees =
              value.info.errorInvitees.map((e) => e.userID).toList();
          if (errorInvitees.contains(inviteeIDController.text)) {
            ZegoCallManager.instance.clearCallData();
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AutoSizeText('user is not online: $value')),
            );
          } else {
            ZegoCallController().pushToCallWaitingPage();
            // pushToCallWaitingPage();
          }
        }).catchError((error) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: AutoSizeText('send call invitation failed: $error')),
          );
        });
      }
    } else {
      if (userIDList.length > 1) {
        ZegoCallManager()
            .sendGroupVoiceCallInvitation(userIDList)
            .then((value) {})
            .catchError((error) {});
      } else {
        ZegoCallManager()
            .sendVoiceCallInvitation(inviteeIDController.text)
            .then((value) {
          final errorInvitees =
              value.info.errorInvitees.map((e) => e.userID).toList();
          if (errorInvitees.contains(inviteeIDController.text)) {
            ZegoCallManager.instance.clearCallData();
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AutoSizeText('user is not online: $value')),
            );
          } else {
            ZegoCallController().pushToCallWaitingPage();
            // pushToCallWaitingPage();
          }
        }).catchError((error) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: AutoSizeText('send call invitation failed: $error')),
          );
        });
      }
    }
  }

  void pushToCallWaitingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) =>
            CallWaitingPage(callData: ZegoCallManager().currentCallData!),
      ),
    );
  }

  void pushToCallingPage() {
    if (ZegoCallManager().currentCallData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) =>
              CallingPage(callData: ZegoCallManager().currentCallData!),
        ),
      );
    }
  }
}
