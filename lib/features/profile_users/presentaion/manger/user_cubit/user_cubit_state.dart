part of 'user_cubit_cubit.dart';

enum UserCubitStatus {
  initial,
  loading,
  authenticated,
  error,
  empty,
  loaded,
  loadedProfile,
  loadedProfileCached,
  searching,
  searchingSuccess,
  friendRequestSent,
  friendRequestAccepted,
  youAreFriend,
  relationRequestAccepted,
  relationRequestDeleted,
  waitingFriendRequestsLoaded,
  friendDeleted,
  relationRequestSent,
  loadedById,
  deleteAccount,
  trackUserSuccess,
}

extension UserCubitStatusX on UserCubitStatus {
  bool get isInitial => this == UserCubitStatus.initial;
  bool get isLoading => this == UserCubitStatus.loading;
  bool get isAuthenticated => this == UserCubitStatus.authenticated;
  bool get isError => this == UserCubitStatus.error;

  bool get isEmpty => this == UserCubitStatus.empty;
  bool get isLoaded => this == UserCubitStatus.loaded;
  bool get isLoadedProfile => this == UserCubitStatus.loadedProfile;
  bool get isLoadedProfileCached => this == UserCubitStatus.loadedProfileCached;
  bool get isSearching => this == UserCubitStatus.searching;
  bool get isSearchingSuccess => this == UserCubitStatus.searchingSuccess;
  bool get isFriendRequestSent => this == UserCubitStatus.friendRequestSent;
  bool get isFriendRequestAccepted =>
      this == UserCubitStatus.friendRequestAccepted;
  bool get isYouAreFriend => this == UserCubitStatus.youAreFriend;
  bool get isRelationRequestAccepted =>
      this == UserCubitStatus.relationRequestAccepted;
  bool get isRelationRequestDeleted =>
      this == UserCubitStatus.relationRequestDeleted;
  bool get isWaitingFriendRequestsLoaded =>
      this == UserCubitStatus.waitingFriendRequestsLoaded;
  bool get isFriendDeleted => this == UserCubitStatus.friendDeleted;
  bool get isRelationRequestSent => this == UserCubitStatus.relationRequestSent;
  bool get isLoadedById => this == UserCubitStatus.loadedById;
  bool get isDeleteAccount => this == UserCubitStatus.deleteAccount;
  bool get isTrackUserSuccess => this == UserCubitStatus.trackUserSuccess;
}

class UserCubitState extends Equatable {
  final UserCubitStatus status;
  final UserEntity? user;
  final UserEntity? userOther;
  final List<UserEntity>? users;
  final List<FriendshipEntity>? friendshipEntity;
  final int? friendNumber;
  final int? friendNumberOther;
  final int? visitorNumber;
  final int? visitorNumberOther;
  final int? friendRequest;
  final int? friendRequestOther;
  final int? relationRequest;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? giftListOther;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? frameListOther;
  final List<ElementEntity>? entryList;
  final List<ElementEntity>? entryListOther;
  final String? message;
  final String? token;
  final RoomEntity? trackUserSuccessRoom;
  // New: room data returned in profile responses
  final RoomEntity? myRoom;
  final RoomEntity? otherRoom;

  // أضفت هنا متغير freindOther (نوعه String? زي المثال القديم)
  final String? freindOther;

  const UserCubitState({
    this.status = UserCubitStatus.initial,
    this.user,
    this.userOther,
    this.users,
    this.friendshipEntity,
    this.friendNumber,
    this.friendNumberOther,
    this.visitorNumber,
    this.visitorNumberOther,
    this.friendRequest,
    this.friendRequestOther,
    this.relationRequest,
    this.giftList,
    this.giftListOther,
    this.frameList,
    this.frameListOther,
    this.entryList,
    this.entryListOther,
    this.message,
    this.token,
    this.trackUserSuccessRoom,
    this.freindOther, // أضفت المتغير في constructor
    this.myRoom,
    this.otherRoom,
  });

  UserCubitState copyWith({
    UserCubitStatus? status,
    UserEntity? user,
    UserEntity? userOther,
    List<UserEntity>? users,
    List<FriendshipEntity>? friendshipEntity,
    int? friendNumber,
    int? friendNumberOther,
    int? visitorNumber,
    int? visitorNumberOther,
    int? friendRequest,
    int? friendRequestOther,
    int? relationRequest,
    List<ElementEntity>? giftList,
    List<ElementEntity>? giftListOther,
    List<ElementEntity>? frameList,
    List<ElementEntity>? frameListOther,
    List<ElementEntity>? entryList,
    List<ElementEntity>? entryListOther,
    String? message,
    String? token,
    RoomEntity? trackUserSuccessRoom,
    String? freindOther, // أضفت المتغير في copyWith
    RoomEntity? myRoom,
    RoomEntity? otherRoom,
  }) {
    return UserCubitState(
      status: status ?? this.status,
      user: user ?? this.user,
      userOther: userOther ?? this.userOther,
      users: users ?? this.users,
      friendshipEntity: friendshipEntity ?? this.friendshipEntity,
      friendNumber: friendNumber ?? this.friendNumber,
      friendNumberOther: friendNumberOther ?? this.friendNumberOther,
      visitorNumber: visitorNumber ?? this.visitorNumber,
      visitorNumberOther: visitorNumberOther ?? this.visitorNumberOther,
      friendRequest: friendRequest ?? this.friendRequest,
      friendRequestOther: friendRequestOther ?? this.friendRequestOther,
      relationRequest: relationRequest ?? this.relationRequest,
      giftList: giftList ?? this.giftList,
      giftListOther: giftListOther ?? this.giftListOther,
      frameList: frameList ?? this.frameList,
      frameListOther: frameListOther ?? this.frameListOther,
      entryList: entryList ?? this.entryList,
      entryListOther: entryListOther ?? this.entryListOther,
      message: message ?? this.message,
      token: token ?? this.token,
      trackUserSuccessRoom: trackUserSuccessRoom ?? this.trackUserSuccessRoom,
      freindOther: freindOther ?? this.freindOther, // هنا التعيين
      myRoom: myRoom ?? this.myRoom,
      otherRoom: otherRoom ?? this.otherRoom,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        userOther,
        users,
        friendshipEntity,
        friendNumber,
        friendNumberOther,
        visitorNumber,
        visitorNumberOther,
        friendRequest,
        friendRequestOther,
        relationRequest,
        giftList,
        giftListOther,
        frameList,
        frameListOther,
        entryList,
        entryListOther,
        message,
        token,
        trackUserSuccessRoom,
        freindOther, // أضفت المتغير في props
        myRoom,
        otherRoom,
      ];
}
