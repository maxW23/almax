import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:flutter/services.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_rooms_cubit/top_rooms_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/timer_counter_acc.dart';
// import 'package:lklk/features/home/presentation/views/slide_view/top3rooms.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Top50roomspageBody extends StatefulWidget {
  const Top50roomspageBody({super.key});

  @override
  State<Top50roomspageBody> createState() => _Top50roomspageBodyState();
}

// ======== Exact Top 3 podium for Rooms (matches Page50GiverTaker) ========
class Top3RoomsPodiumExact extends StatelessWidget {
  const Top3RoomsPodiumExact({super.key, required this.rooms});

  final List<RoomEntity> rooms;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) return const SizedBox();
    final r1 = rooms.isNotEmpty ? rooms[0] : null;
    final r2 = rooms.length > 1 ? rooms[1] : null;
    final r3 = rooms.length > 2 ? rooms[2] : null;

    return SizedBox(
      height: 275,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // Base height depends on width (image aspect ratio), not container height
          final baseH = w * 0.2;

          // Fixed size for stands (same as Giver/Taker)
          final standW = 80.0;
          final standH = 180.0;

          // Center the middle stand
          final centerX = (w - standW) / 2;

          // Position side stands next to the center one
          final gap = 10.0;
          final leftX = centerX - standW - gap;
          final rightX = centerX + standW + gap;

          // Move stands down by 60 (identical behavior)
          final centerBottom = (baseH + 20) - 60;
          final sideBottom = (baseH + 5) - 60;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Base stand
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  AssetsData.podiumBaseStand,
                  width: w * 0.92,
                  fit: BoxFit.contain,
                ),
              ),

              // Left (2)
              if (r2 != null)
                Positioned(
                  left: leftX,
                  bottom: sideBottom,
                  child: _StandRoomCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.stand2,
                    frameAsset: AssetsData.roomframe2,
                    room: r2,
                    rank: 2,
                  ),
                ),

              // Center (1)
              if (r1 != null)
                Positioned(
                  left: centerX,
                  bottom: centerBottom,
                  child: _StandRoomCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.stand1,
                    frameAsset: AssetsData.roomframe1,
                    room: r1,
                    rank: 1,
                  ),
                ),

              // Right (3)
              if (r3 != null)
                Positioned(
                  left: rightX,
                  bottom: sideBottom,
                  child: _StandRoomCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.stand3,
                    frameAsset: AssetsData.roomframe3,
                    room: r3,
                    rank: 3,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StandRoomCardExact extends StatelessWidget {
  const _StandRoomCardExact({
    required this.width,
    required this.height,
    required this.standAsset,
    required this.frameAsset,
    required this.room,
    required this.rank,
  });

  final double width;
  final double height;
  final String standAsset;
  final String frameAsset;
  final RoomEntity room;
  final int rank; // 1,2,3

  @override
  Widget build(BuildContext context) {
    // Fixed image size (40x40 as per Giver/Taker)
    const double ringDia = 40.0;
    final dateStr = DateFormat('dd-MM-yy').format(DateTime.now());

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Stand/backplate
          Positioned.fill(
            child: Image.asset(
              standAsset,
              fit: BoxFit.fill,
            ),
          ),

          // Room image (circular) - centered above the stand
          Positioned(
            top:
                rank == 1 ? (-ringDia * 0.48) + 12 - 15 : (-ringDia * 0.48) + 4,
            left: (width - (ringDia * 1.05)) / 2,
            child: Container(
              width: ringDia * 1.05,
              height: ringDia * 1.05,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const ClipOval(
                child: SizedBox.shrink(),
              ),
            ),
          ),

          // Actual room image
          Positioned(
            top: rank == 1 ? (-ringDia * 0.48) + 12 - 7 : (-ringDia * 0.48) + 4,
            left: (width - (ringDia * 1.05)) / 2,
            child: SizedBox(
              width: ringDia * 1.05,
              height: ringDia * 1.05,
              child: ClipOval(
                child: _RoomAvatarImage(room: room),
              ),
            ),
          ),

          // Frame image - painted above room image
          Positioned(
            top: (-ringDia * 0.48) - (80 - ringDia * 1.85) / 2,
            left: rank != 3 ? (width - 80) / 2 : (width - 70) / 2,
            child: Image.asset(
              frameAsset,
              width: rank != 3 ? 80 : 70,
              height: rank != 3 ? 80 : 70,
              fit: BoxFit.cover,
            ),
          ),

          // Text block inside stand
          Positioned(
            top: 50,
            left: 4,
            right: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  room.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetsData.coins,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: AutoSizeText(
                        (room.coin ?? '0'),
                        maxLines: 1,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsData.timeIcon,
                        width: 20,
                        height: 20,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: AutoSizeText(
                          dateStr,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomAvatarImage extends StatelessWidget {
  const _RoomAvatarImage({required this.room});
  final RoomEntity room;

  @override
  Widget build(BuildContext context) {
    final url = _sanitizeRoomUrl(room.img);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
    );
  }
}

String _sanitizeRoomUrl(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return AssetsData.userTestNetwork;
  final u = Uri.tryParse(s);
  if (u != null &&
      (u.scheme == 'http' || u.scheme == 'https') &&
      u.host.isNotEmpty) {
    return s;
  }
  return 'https://lklklive.com/img/$s';
}

class _Top50roomspageBodyState extends State<Top50roomspageBody> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final TopRoomsCubit topRoomsCubit = BlocProvider.of<TopRoomsCubit>(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<TopRoomsCubit, TopRoomsState>(
          bloc: topRoomsCubit..fetchTopRooms(),
          builder: (context, state) {
            if (state is TopRoomsLoaded) {
              //log('roomstop ${state.rooms}');

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      // decoration: const BoxDecoration(
                      //     color: Colors.transparent,
                      //     image: DecorationImage(
                      //         image: AssetImage(
                      //             AssetsData.top50RoomBackgroundImage),
                      //         fit: BoxFit.cover)),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Center(child: TimerCounterAcc()),
                          ),
                          // Exact same header as Page50GiverTaker but with Rooms data
                          Top3RoomsPodiumExact(rooms: state.rooms),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  // SliverToBoxAdapter(
                  //   child: ClipRRect(
                  //     borderRadius: const BorderRadius.only(
                  //       topLeft: Radius.circular(100),
                  //       topRight: Radius.circular(100),
                  //     ),
                  //     child: Container(
                  //       color: AppColors.white,
                  //       child: const SizedBox(
                  //         height: 40,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF030617),
                        ),
                        child: Column(
                          children: [
                            Directionality(
                              textDirection:
                                  getTextDirection(_selectedLanguage),
                              child: RoomRankListItem(
                                rank: index + 4,
                                room: state.rooms[index + 3],
                              ),
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Divider(
                                  color: AppColors.grey.withValues(alpha: .2),
                                  indent: 12,
                                  endIndent: 12,
                                  thickness: .5,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // childCount: 10,
                      childCount: state.rooms.length - 3,
                    ),
                  ),
                ],
              );
            } else if (state is TopRoomsError) {
              return Center(
                child: AutoSizeText('Error ${state.message}'),
              );
            } else if (state is TopRoomsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.black,
                ),
              );
            } else {
              return const Center(
                // child: AutoSizeText('state $state'),
                child: SizedBox(),
              );
            }
          },
        ),
      ),
    );
  }
}

// ======== Room list item (matches screenshot) ========
class RoomRankListItem extends StatelessWidget {
  const RoomRankListItem({super.key, required this.rank, required this.room});

  final int rank;
  final RoomEntity room;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE dd MMM').format(DateTime.now());
    final timeStr = DateFormat('hh:mm a').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          // Rank number (plain, as in screenshot)
          SizedBox(
            width: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                '$rank',
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar with subtle border to mimic framed look
          _Avatar(url: "https://lklklive.com/img/${room.img}"),
          const SizedBox(width: 10),
          // Title and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                AutoSizeText(
                  room.name,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                Row(
                  children: [
                    AutoSizeText(
                      'ID: ${room.id}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: room.id.toString()));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ID Copied')),
                          );
                        }
                      },
                      child: const Icon(Icons.copy_rounded,
                          size: 14, color: AppColors.grey),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right: coins + date/time
          SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientText(
                      (room.coin ?? '0'),
                      gradient: const LinearGradient(colors: [
                        AppColors.golden,
                        AppColors.brownshad1,
                        AppColors.golden,
                        AppColors.brownshad1,
                      ]),
                      style: Styles.textStyle12bold,
                    ),
                    const SizedBox(width: 4),
                    Image.asset(AssetsData.coins, width: 14, height: 14),
                  ],
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  dateStr,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: AppColors.grey, fontSize: 10),
                ),
                AutoSizeText(
                  timeStr,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: AppColors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Border frame (rounded-rect gradient)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFD7E3B).withOpacity(.9),
                  const Color(0xFFFFC371).withOpacity(.9),
                ],
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Top50roomspage extends StatelessWidget {
  const Top50roomspage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TopRoomsCubit>(
      create: (context) => TopRoomsCubit(),
      child: const Top50roomspageBody(),
    );
  }
}
