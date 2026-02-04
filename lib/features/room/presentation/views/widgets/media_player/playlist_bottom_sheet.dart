// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lklk/core/constants/app_colors.dart';
// import 'package:lklk/features/room/presentation/views/widgets/media_player/player_assets.dart';
// import 'package:lklk/features/room/presentation/manger/player/playback_cubit.dart';
// import 'package:lklk/features/room/presentation/manger/player/playlist_cubit.dart';
// import 'package:lklk/generated/l10n.dart';

// /// BottomSheet مستقل لإدارة قائمة الأغاني
// class PlaylistBottomSheet extends StatelessWidget {
//   const PlaylistBottomSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppColors.playerGradientTop,
//             AppColors.playerGradientBottom,
//           ],
//         ),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: SizedBox(
//           height: 520,
//           child: Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Image.asset(
//                       PlayerAssets.musicListPng,
//                       height: 22,
//                       fit: BoxFit.contain,
//                     ),
//                     SizedBox(width: 8.w),
//                     Expanded(
//                       child: BlocBuilder<PlaylistCubit, PlaylistState>(
//                         builder: (context, s) => AutoSizeText(
//                           S.of(context).playlistTitle(s.paths.length),
//                           style: const TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       borderRadius: BorderRadius.circular(24),
//                       onTap: () => context.read<PlaylistCubit>().clearAll(),
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                         decoration: BoxDecoration(
//                           color: AppColors.glassFillStrong,
//                           borderRadius: BorderRadius.circular(24),
//                           border:
//                               Border.all(color: AppColors.glassBorder, width: 1),
//                         ),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.delete_sweep_rounded,
//                                 color: const Color(0xFFFF0000, size: 18),
//                             SizedBox(width: 6),
//                             Text('حذف الكل',
//                                 style: TextStyle(color: Colors.white)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: BlocBuilder<PlaylistCubit, PlaylistState>(
//                     builder: (context, state) {
//                       if (state.paths.isEmpty) {
//                         return Center(
//                           child: Text(
//                             S.of(context).emptyPlaylist,
//                             style: const TextStyle(color: Colors.white54),
//                           ),
//                         );
//                       }
//                       return ListView.builder(
//                         itemCount: state.paths.length,
//                         itemBuilder: (ctx, i) {
//                           final name = state.paths[i].split('/').last;
//                           final selected = state.selected.contains(i);
//                           return Container(
//                             margin: EdgeInsets.symmetric(vertical: 4.h),
//                             decoration: BoxDecoration(
//                               color: AppColors.glassFill,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                   color: AppColors.glassBorder, width: 1),
//                             ),
//                             child: ListTile(
//                               leading: Icon(
//                                 Icons.music_note,
//                                 color: selected
//                                     ? AppColors.secondColor
//                                     : AppColors.primary,
//                               ),
//                               title: Text(
//                                 name,
//                                 style: const TextStyle(color: Colors.white),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               trailing: Checkbox(
//                                 value: selected,
//                                 onChanged: (_) => context
//                                     .read<PlaylistCubit>()
//                                     .toggleSelection(i),
//                                 activeColor: AppColors.primary,
//                                 checkColor: Colors.white,
//                               ),
//                               onTap: () {
//                                 context
//                                     .read<PlaybackCubit>()
//                                     .playPath(state.paths[i], index: i);
//                               },
//                               onLongPress: () => context
//                                   .read<PlaylistCubit>()
//                                   .toggleSelection(i),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     InkWell(
//                       borderRadius: BorderRadius.circular(24),
//                       onTap: () => context.read<PlaylistCubit>().selectAll(),
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                         decoration: BoxDecoration(
//                           color: AppColors.glassFillStrong,
//                           borderRadius: BorderRadius.circular(24),
//                           border:
//                               Border.all(color: AppColors.glassBorder, width: 1),
//                         ),
//                         child: const Text('تحديد الكل',
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ),
//                     const Spacer(),
//                     InkWell(
//                       borderRadius: BorderRadius.circular(24),
//                       onTap: () =>
//                           context.read<PlaylistCubit>().removeSelected(),
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                         decoration: BoxDecoration(
//                           color: AppColors.glassFillStrong,
//                           borderRadius: BorderRadius.circular(24),
//                           border:
//                               Border.all(color: AppColors.glassBorder, width: 1),
//                         ),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.delete_forever_rounded,
//                                 color: const Color(0xFFFF0000),
//                             SizedBox(width: 8),
//                             Text('حذف المحدد',
//                                 style: TextStyle(color: Colors.white)),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
