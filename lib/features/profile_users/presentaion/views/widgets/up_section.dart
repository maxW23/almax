import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/custom_coins_button.dart';

class UpSection extends StatefulWidget {
  const UpSection({
    super.key,
    required this.wallet,
    required this.selectedTab,
    required this.diamond,
    required this.point,
    required this.onPressedCoins,
    required this.onPressedDiamond,
    required this.onPressedNova,
  });

  final int wallet;
  final int selectedTab; // 0 = Coins, 1 = Diamond, 2 = Nova
  final num diamond;
  final num point;
  final VoidCallback onPressedCoins;
  final VoidCallback onPressedDiamond;
  final VoidCallback onPressedNova;

  @override
  State<UpSection> createState() => _UpSectionState();
}

class _UpSectionState extends State<UpSection> with TickerProviderStateMixin {
  late AnimationController _colorAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.bounceOut,
    ));

    _scaleAnimationController.forward();
  }

  @override
  void didUpdateWidget(UpSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTab != widget.selectedTab) {
      if (widget.selectedTab == 1) {
        _colorAnimationController.forward();
      } else {
        _colorAnimationController.reverse();
      }

      // Bounce animation on tab change
      _scaleAnimationController.reset();
      _scaleAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _colorAnimationController,
        _scaleAnimationController,
      ]),
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 250,
            decoration: BoxDecoration(
              color: widget.selectedTab == 0
                  ? AppColors.golden
                  : widget.selectedTab == 1
                      ? AppColors.blue
                      : AppColors.purpleColor, // Nova color
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(200)),
              boxShadow: [
                BoxShadow(
                  color: (widget.selectedTab == 0
                          ? AppColors.golden
                          : widget.selectedTab == 1
                              ? AppColors.blue
                              : AppColors.purpleColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Animated Tab Selector
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: Container(
                    width: 260,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.black.withValues(alpha: .5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: AnimatedScale(
                            scale: widget.selectedTab == 0 ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: CustomCoinsButton(
                              isSelected: widget.selectedTab == 0,
                              text: S.of(context).coins,
                              onPressed: widget.onPressedCoins,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: AnimatedScale(
                            scale: widget.selectedTab == 1 ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: CustomCoinsButton(
                              isSelected: widget.selectedTab == 1,
                              text: S.of(context).diamond,
                              onPressed: widget.onPressedDiamond,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: AnimatedScale(
                            scale: widget.selectedTab == 2 ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: CustomCoinsButton(
                              isSelected: widget.selectedTab == 2,
                              text: 'Nova',
                              onPressed: widget.onPressedNova,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Animated Balance Display
                Row(
                  children: [
                    SizedBox(width: 25.w),

                    // Animated Icon
                    ScaleTransition(
                      scale: _bounceAnimation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: Tween<double>(begin: 0.0, end: 0.1)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          key: ValueKey(widget.selectedTab),
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            widget.selectedTab == 0
                                ? AssetsData.coins
                                : widget.selectedTab == 1
                                    ? AssetsData.diamondImg
                                    : AssetsData.novaImg,
                            width: 100,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 5.w),

                    // Animated Balance Text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: AutoSizeText(
                        key: ValueKey(
                            '${widget.selectedTab}_${widget.selectedTab == 0 ? widget.wallet : widget.selectedTab == 1 ? widget.diamond : widget.point}'),
                        widget.selectedTab == 0
                            ? '${widget.wallet}'
                            : widget.selectedTab == 1
                                ? '${widget.diamond}'
                                : '${widget.point}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: AppColors.black,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
