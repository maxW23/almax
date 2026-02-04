import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/profile_users/presentaion/manger/diamond/diamond_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/purchase/purchase_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/nova/nova_cubit.dart';
import 'package:lklk/core/utils/logger.dart';

class CoinsItem extends StatefulWidget {
  const CoinsItem({
    super.key,
    required this.price,
    required this.coins,
    required this.selectedTab,
    required this.userCubit,
    this.priceLabel,
    this.enableSnackbars = true,
  });

  final int price;
  final int coins;
  final int selectedTab; // 0 = Coins, 1 = Diamond, 2 = Nova
  final UserCubit userCubit;
  final String? priceLabel;
  final bool enableSnackbars;

  @override
  State<CoinsItem> createState() => _CoinsItemState();
}

class _CoinsItemState extends State<CoinsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;
  OverlayEntry? _loadingOverlay;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showBottomLoading(BuildContext ctx) {
    if (_loadingOverlay != null) return;
    final overlay = Overlay.maybeOf(ctx);
    if (overlay == null) return;
    _loadingOverlay = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        right: 16,
        bottom: 24,
        child: IgnorePointer(
          ignoring: true,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      S.of(ctx).loading,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_loadingOverlay!);
  }

  void _hideBottomLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  Future<void> _handleCoinsPurchase(BuildContext actionContext) async {
    try {
      // Get PurchaseCubit from context
      final purchaseCubit = BlocProvider.of<PurchaseCubit>(actionContext);

      // Check current state
      final currentState = purchaseCubit.state;

      // If still initializing, show message and wait
      if (currentState is PurchaseInitial) {
        AppLogger.warning('⏳ [CoinsItem] Still initializing, please wait...',
            tag: 'purchase');
        if (widget.enableSnackbars) {
          SnackbarHelper.showMessage(
              actionContext, 'جاري التحميل... يرجى الانتظار قليلاً');
        }
        return;
      }

      // Check if already initialized with products
      if (currentState is PurchaseError &&
          currentState.message.contains('Products not found')) {
        if (widget.enableSnackbars) {
          SnackbarHelper.showMessage(actionContext,
              'خطأ: المنتجات غير موجودة في Play Console\n${currentState.message}');
        }
        return;
      }

      // Check if not ready
      if (currentState is! PurchaseReady) {
        AppLogger.warning(
            '⚠️ [CoinsItem] Purchase not ready, current state: ${currentState.runtimeType}',
            tag: 'purchase');
        if (widget.enableSnackbars) {
          SnackbarHelper.showMessage(
              actionContext, 'يرجى الانتظار حتى يتم تحميل المنتجات');
        }
        return;
      }

      AppLogger.info(
          '🛒 [CoinsItem] Starting purchase for ${widget.coins} coins',
          tag: 'purchase');

      // Start purchase - this will trigger state changes that BlocListener will catch
      await purchaseCubit.purchaseCoins(widget.coins);

      AppLogger.info(
          '✅ [CoinsItem] Purchase initiated, waiting for Google Play dialog',
          tag: 'purchase');
    } catch (e) {
      AppLogger.error('❌ [CoinsItem] Coins purchase error: $e',
          tag: 'purchase');
      if (widget.enableSnackbars) {
        SnackbarHelper.showMessage(actionContext, 'خطأ: $e');
      }
    }
  }

  Future<void> _handleTap(BuildContext actionContext) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (widget.selectedTab == 0) {
      // Coins tab: Google Play purchase
      _handleCoinsPurchase(actionContext);
    } else if (widget.selectedTab == 1) {
      // Diamonds tab: call server and then refresh profile
      bool ok = false;
      // Log before balances
      final beforeDiamond = widget.userCubit.state.user?.diamond;
      final beforeWallet = widget.userCubit.state.user?.wallet;
      AppLogger.debug(
          'diamond_before ${beforeDiamond ?? 'null'} --wallet_before ${beforeWallet ?? 'null'}',
          tag: 'purchase');
      _showBottomLoading(actionContext);
      try {
        try {
          ok = await BlocProvider.of<DiamondCubit>(actionContext)
              .buyDiamond(widget.coins);
        } catch (_) {
          ok = false;
        }
        // Always refresh from server to get authoritative balance
        await widget.userCubit.getProfileUser("CoinsItem");
        // Log after balances
        final afterDiamond = widget.userCubit.state.user?.diamond;
        final afterWallet = widget.userCubit.state.user?.wallet;
        AppLogger.debug(
            'diamond_after ${afterDiamond ?? 'null'} --wallet_after ${afterWallet ?? 'null'}',
            tag: 'purchase');
        if (widget.enableSnackbars) {
          if (!ok) {
            SnackbarHelper.showMessage(
                actionContext, S.of(actionContext).errorOccurred);
          } else {
            SnackbarHelper.showMessage(
                actionContext, S.of(actionContext).success);
          }
        }
      } finally {
        _hideBottomLoading();
      }
    } else if (widget.selectedTab == 2) {
      // Nova tab: call coins to nova conversion
      bool ok = false;
      final beforePoint = widget.userCubit.state.user?.point;
      final beforeWallet = widget.userCubit.state.user?.wallet;
      AppLogger.debug(
          'point_before ${beforePoint ?? 'null'} --wallet_before ${beforeWallet ?? 'null'}',
          tag: 'nova');
      _showBottomLoading(actionContext);
      try {
        try {
          ok = await BlocProvider.of<NovaCubit>(actionContext)
              .coinsToNova(widget.coins);
        } catch (e) {
          AppLogger.error('Nova conversion error: $e', tag: 'nova');
          ok = false;
        }
        // Always refresh from server to get authoritative balance
        await widget.userCubit.getProfileUser("CoinsItem");
        // Log after balances
        final afterPoint = widget.userCubit.state.user?.point;
        final afterWallet = widget.userCubit.state.user?.wallet;
        AppLogger.debug(
            'point_after ${afterPoint ?? 'null'} --wallet_after ${afterWallet ?? 'null'}',
            tag: 'nova');
        if (widget.enableSnackbars) {
          if (!ok) {
            SnackbarHelper.showMessage(
                actionContext, S.of(actionContext).errorOccurred);
          } else {
            SnackbarHelper.showMessage(
                actionContext, S.of(actionContext).success);
          }
        }
      } finally {
        _hideBottomLoading();
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiamondCubit>(
        lazy: true,
        create: (context) => DiamondCubit(),
        child: BlocProvider<NovaCubit>(
            lazy: true,
            create: (context) => NovaCubit(),
            child: BlocBuilder<DiamondCubit, DiamondState>(
              builder: (context, diamondState) {
                // Listen to PurchaseCubit state to show loading indicator
                return BlocBuilder<PurchaseCubit, PurchaseState>(
                  builder: (context, purchaseState) {
                    final isInitializing = purchaseState is PurchaseInitial;
                    // For Diamonds tab: show coins-to-receive (conversion) while keeping
                    // widget.coins as the diamond amount for the backend call.
                    // Rate: 1200 diamonds -> 420 coins (7/20 per diamond)
                    final int displayValue = widget.selectedTab == 1
                        ? (widget.coins * 7 ~/ 20)
                        : widget.coins;

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: GestureDetector(
                            onTap: () => _handleTap(context),
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: widget.selectedTab == 0
                                        ? AppColors.golden.withValues(alpha: .3)
                                        : widget.selectedTab == 1
                                            ? AppColors.blue
                                                .withValues(alpha: .3)
                                            : AppColors.purpleColor
                                                .withValues(alpha: .3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: widget.selectedTab == 0
                                          ? AppColors.golden
                                          : widget.selectedTab == 1
                                              ? AppColors.blue
                                              : AppColors.purpleColor,
                                      width: _isProcessing ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (widget.selectedTab == 0
                                                ? AppColors.golden
                                                : widget.selectedTab == 1
                                                    ? AppColors.blue
                                                    : AppColors.purpleColor)
                                            .withValues(
                                                alpha:
                                                    _isProcessing ? 0.4 : 0.2),
                                        blurRadius: _isProcessing ? 12 : 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    height: 160.h,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h, horizontal: 8.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Animated Icon
                                          AnimatedScale(
                                            scale: _isProcessing ? 1.2 : 1.0,
                                            duration: const Duration(
                                                milliseconds: 200),
                                            child: Image.asset(
                                              widget.selectedTab == 0
                                                  ? AssetsData.coins
                                                  : widget.selectedTab == 1
                                                      ? AssetsData.coins
                                                      : AssetsData.novaImg,
                                              width: 35.w,
                                            ),
                                          ),

                                          // Animated Amount Text (Coins to receive on Diamonds tab)
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontSize: _isProcessing ? 19 : 17,
                                              fontWeight: _isProcessing
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            child: AutoSizeText(
                                              '$displayValue',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                          // Animated Price Container
                                          Flexible(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: widget.selectedTab == 0
                                                    ? AppColors.golden
                                                    : widget.selectedTab == 1
                                                        ? AppColors.blue
                                                        : AppColors.purpleColor,
                                                borderRadius:
                                                    BorderRadius.circular(19),
                                                boxShadow: _isProcessing
                                                    ? [
                                                        BoxShadow(
                                                          color: (widget.selectedTab ==
                                                                      0
                                                                  ? AppColors
                                                                      .golden
                                                                  : widget.selectedTab ==
                                                                          1
                                                                      ? AppColors
                                                                          .blue
                                                                      : AppColors
                                                                          .purpleColor)
                                                              .withValues(
                                                                  alpha: 0.5),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: widget.selectedTab == 0
                                                  ? AutoSizeText(
                                                      widget.priceLabel ??
                                                          '\$${widget.price} ',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Flexible(
                                                            child: AutoSizeText(
                                                              '${widget.price}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                color: AppColors
                                                                    .white,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 1),
                                                          AnimatedScale(
                                                            scale: _isProcessing
                                                                ? 1.1
                                                                : 1.0,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            child: Image.asset(
                                                              widget.selectedTab ==
                                                                      0
                                                                  ? AssetsData
                                                                      .coins
                                                                  : widget.selectedTab ==
                                                                          1
                                                                      ? AssetsData
                                                                          .diamondImg
                                                                      : AssetsData
                                                                          .coins,
                                                              width: 25.w,
                                                              height: 25.h,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Loading overlay for initialization
                                if (isInitializing && widget.selectedTab == 0)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                widget.selectedTab == 0
                                                    ? AppColors.golden
                                                    : widget.selectedTab == 1
                                                      ? AppColors.blue
                                                      : AppColors.purpleColor,
                                              ),
                                            ),
                                        ),
                                  ),
                                ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
              );
   } )));
  }
}
