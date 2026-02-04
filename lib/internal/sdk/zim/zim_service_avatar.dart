part of 'zim_service.dart';

extension ZIMServiceAvatar on ZIMService {
  Future<ZIMUserAvatarUrlUpdatedResult> updateUserAvatarUrl(String url) async {
    final result = await ZIM.getInstance()!.updateUserAvatarUrl(url);
    userAvatarUrlMap[currentZimUserInfo!.userID] = result.userAvatarUrl;
    ZEGOSDKManager().currentUser!.avatarUrlNotifier.value =
        result.userAvatarUrl;

    return result;
  }

  Future<ZIMUserNameUpdatedResult> updateUserName(String name) async {
    final result = await ZIM.getInstance()!.updateUserName(name);
    userNameMap[currentZimUserInfo!.userID] = result.userName;
    ZEGOSDKManager().currentUser!.nameUser.value = result.userName;
    return result;
  }

  Future<ZIMUserExtendedDataUpdatedResult> updateUserExtendedData(
      String data) async {
    //log('frameZego updateUserExtendedData data : $data ');
    final result = await ZIM.getInstance()!.updateUserExtendedData(data);
    userMap[currentZimUserInfo!.userID] = result.extendedData;
    final String res = result.extendedData;
    final user = UserEntity.fromString(res);
    ZEGOSDKManager().currentUser!.framePathNotifier.value =
        user.elementFrame?.linkPathLocal ?? user.elementFrame?.linkPath;
    // Also publish the rich encoded data to avatarUrlNotifier so UI (seats) can decode frames/badges immediately
    ZEGOSDKManager().currentUser!.avatarUrlNotifier.value = result.extendedData;

    return result;
  }

  Future<ZIMUsersInfoQueriedResult> queryUsersInfo(
      List<String> userIDList) async {
    // log("UpdatedUsersInfo: Starting query for user IDs: $userIDList");

    final config = ZIMUserInfoQueryConfig()..isQueryFromServer = true;
    // log("UpdatedUsersInfo: Created ZIMUserInfoQueryConfig");

    final result = await ZIM.getInstance()!.queryUsersInfo(userIDList, config);
    // log("UpdatedUsersInfo: Successfully queried users info, result: $result");

    for (final userFullInfo in result.userList) {
      // log("UpdatedUsersInfo: Processing user ${userFullInfo.baseInfo.userID}");

      userAvatarUrlMap[userFullInfo.baseInfo.userID] =
          userFullInfo.userAvatarUrl;
      // log("UpdatedUsersInfo: Updated avatar URL for user ${userFullInfo.baseInfo.userID}");

      userNameMap[userFullInfo.baseInfo.userID] =
          userFullInfo.baseInfo.userName;
      // log("UpdatedUsersInfo: Updated user name for user ${userFullInfo.baseInfo.userID}");
      // log("UpdatedUsersInfo: userFullInfo.baseInfo.userAvatarUrl::: ${userFullInfo.baseInfo.userAvatarUrl}");
      // log("UpdatedUsersInfo: userFullInfo.baseInfo.userName::: ${userFullInfo.baseInfo.userName}");
      // // log("UpdatedUsersInfo: userFullInfo.baseInfo.userTrype::: ${userFullInfo.baseInfo.}");
      // log("UpdatedUsersInfo: userFullInfo.userAvatarUrl::: ${userFullInfo.userAvatarUrl}");
      // log("UpdatedUsersInfo: userFullInfo.extendedData::: ${userFullInfo.extendedData}");
      // log("UpdatedUsersInfo: userFullInfo.baseInfo::: ${userFullInfo.baseInfo}");

      // Prefer rich extendedData when available; fall back to avatarUrl
      if (userFullInfo.extendedData.isNotEmpty) {
        userMap[userFullInfo.baseInfo.userID] = userFullInfo.extendedData;
        ZEGOSDKManager()
            .getUser(userFullInfo.baseInfo.userID)
            ?.avatarUrlNotifier
            .value = userFullInfo.extendedData;
      } else {
        ZEGOSDKManager()
            .getUser(userFullInfo.baseInfo.userID)
            ?.avatarUrlNotifier
            .value = userFullInfo.userAvatarUrl;
      }
      // log("UpdatedUsersInfo: Updated avatar URL notifier for user ${userFullInfo.baseInfo.userID}");
      ZEGOSDKManager().getUser(userFullInfo.baseInfo.userID)?.nameUser.value =
          userFullInfo.baseInfo.userName;
      // Uncomment if needed
      // if (userFullInfo.baseInfo.userFramePath != null) {
      //   userMap[userFullInfo.baseInfo.userID] = userFullInfo.baseInfo.userFramePath!;
      //   log("UpdatedUsersInfo: Updated frame path for user ${userFullInfo.baseInfo.userID}");
      // }
    }

    // log("UpdatedUsersInfo: Completed processing all users");
    return result;
  }

  String? getUserAvatar(String userID) {
    return userAvatarUrlMap[userID];
  }

  String? getUserName(String userID) {
    return userNameMap[userID];
  }

  String? getUserMap(String userID) {
    return userMap[userID];
  }
}
