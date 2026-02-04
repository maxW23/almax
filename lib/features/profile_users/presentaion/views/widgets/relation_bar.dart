import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/relationship_row.dart' show CustomDialog;

/// Relation bar redesigned to match the provided reference with better alignment
/// and proportions. The background keeps its original aspect ratio (1024x292),
/// and the left cluster is positioned responsively.
class RelationBar extends StatelessWidget {
  const RelationBar({
    super.key,
    this.leftUser1,
    this.leftUser2,
    this.rightImagePath,
    this.borderRadius = 20,
    this.scale = 1,
    this.bgScale = 1.01,
    this.onTap,
    this.onRequestUnlink,
    this.onVisitProfile,
  });

  final UserEntity? leftUser1;
  final UserEntity? leftUser2;
  final String? rightImagePath;
  final double borderRadius;
  final double scale;
  final double bgScale;
  final VoidCallback? onTap;
  final VoidCallback? onRequestUnlink;
  final VoidCallback? onVisitProfile;

  static const double _bgAspect = 1024 / 292; // preserve background ratio

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: _bgAspect,
        child: Container(
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              // Sizes based on background height for consistent look (slightly bigger)
              final s = scale.clamp(0.90, 1.20);
              final avatarSize =
                  h * 0.65 * s; // framed circle size (slightly bigger)
              final heartWidth = h * 0.48 * s; // heart stand width (bigger)
              final bottomHeart = h * 0.09; // slight lift from bottom
              // Raise avatars a bit more and keep them inside the bg
              final bottomAvatars =
                  (h * (0.24 - (s - 1.0) * 0.04)).clamp(h * 0.16, h * 0.28);

              // Horizontal positioning around center
              final centerX = w / 2;
              final offsetFromHeart = heartWidth / 2 + avatarSize * 0.45;
              final leftCenterX = centerX - offsetFromHeart - 4;
              final rightCenterX = centerX + offsetFromHeart + 4;

              return Stack(
                children: [
                  // Scaled background image to appear larger
                  Positioned.fill(
                    child: Transform.scale(
                      scale: bgScale,
                      child: Image.asset(
                        'assets/images/my_profile_icon/relation_bar/CP Box.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  // Hea,rt stand centered near bottom
                  Positioned(
                    bottom: bottomHeart,
                    left: centerX - heartWidth / 2,
                    width: heartWidth,
                    child: Image.asset(
                      'assets/images/my_profile_icon/relation_bar/relation_herat_stand.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // Left framed avatar
                  Positioned(
                    bottom: bottomAvatars,
                    left: leftCenterX - avatarSize / 2,
                    width: avatarSize,
                    height: avatarSize,
                    child: _FramedAvatar(
                      imageUrl: leftUser1?.img?.toString(),
                      size: avatarSize,
                      frameAsset:
                          'assets/images/my_profile_icon/relation_bar/relation_frame.png',
                    ),
                  ),

                  // Right framed avatar
                  Positioned(
                    bottom: bottomAvatars,
                    left: rightCenterX - avatarSize / 2,
                    width: avatarSize,
                    height: avatarSize,
                    child: _FramedAvatar(
                      imageUrl: rightImagePath ?? leftUser2?.img?.toString(),
                      size: avatarSize,
                      frameAsset:
                          'assets/images/my_profile_icon/relation_bar/relation_frame.png',
                    ),
                  ),

                  // Tap overlay to trigger relation dialog/actions
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (onTap != null) {
                            onTap!();
                          } else {
                            _showRelationDialog(context);
                          }
                        },
                        splashColor: Colors.white12,
                        highlightColor: Colors.white10,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRelationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final img = rightImagePath ?? leftUser2?.img?.toString() ?? leftUser1?.img?.toString();
        return CustomDialog(
          title: 'title',
          content: 'content',
          imagePath: img,
          onButton1Pressed: () {
            Navigator.of(ctx).pop();
            if (onVisitProfile != null) onVisitProfile!();
          },
          onButton2Pressed: () {
            Navigator.of(ctx).pop();
            if (onRequestUnlink != null) onRequestUnlink!();
          },
          onButton3Pressed: () {},
        );
      },
    );
  }
}

class _FramedAvatar extends StatelessWidget {
  const _FramedAvatar({
    required this.imageUrl,
    required this.size,
    required this.frameAsset,
  });

  final String? imageUrl;
  final double size;
  final String frameAsset;

  @override
  Widget build(BuildContext context) {
    // Inner user image should be smaller than the frame to avoid overflow
    // and to visually match the wings/halo space of the frame asset.
    final avatarInner = size * 0.645;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Avatar (underside) — slightly smaller and perfectly centered
          Transform.translate(
            offset: Offset(0, -size * 0.028),
            child: SizedBox(
              width: avatarInner,
              height: avatarInner,
              child: ClipOval(
                child: CircularUserImage(
                  imagePath: imageUrl,
                  isSquare: false,
                  radius: avatarInner / 2,
                ),
              ),
            ),
          ),
          // Frame overlay perfectly centered
          IgnorePointer(
            ignoring: true,
            child: Image.asset(
              frameAsset,
              width: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}
