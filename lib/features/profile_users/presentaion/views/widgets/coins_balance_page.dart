import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/services/purchase_service.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/purchase/purchase_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/nova/nova_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/prices_section.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/up_section.dart';

class CoinsBalancePage extends StatefulWidget {
  const CoinsBalancePage({
    super.key,
    required this.wallet,
    required this.diamond,
    required this.userCubit,
  });

  final int wallet;
  final num diamond;
  final UserCubit userCubit;
  @override
  State<CoinsBalancePage> createState() => _CoinsBalancePageState();
}

class _CoinsBalancePageState extends State<CoinsBalancePage>
    with TickerProviderStateMixin {
  // 0 = Coins, 1 = Diamond, 2 = Nova
  int _selectedTab = 0;
  late AnimationController _tabAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _tabAnimation;
  late Animation<double> _contentAnimation;
  late Animation<Offset> _slideAnimation;
  late PurchaseCubit _purchaseCubit;
  StreamSubscription<PurchaseUpdate>? _debugPurchaseSub;

  @override
  void initState() {
    super.initState();

    // Initialize PurchaseCubit once
    AppLogger.info('🎯 [CoinsBalancePage] Creating PurchaseCubit singleton',
        tag: 'purchase');
    _purchaseCubit = PurchaseCubit()..initialize();

    // Debug-only: Log purchase token and parameters (no SnackBar)
    _debugPurchaseSub = PurchaseService().purchaseStream.listen((u) {
      if (u.status == PurchaseUpdateStatus.purchased) {
        final token = u.purchaseToken ?? '';
        final msg =
            'purchase_token: $token\nproduct_id: ${u.productId}\npackage_name: com.bwmatbw.lklklivechatapp\ncoin_amount: ${u.coinAmount?.toString() ?? 'null'}\nprice: ${u.price?.toStringAsFixed(2) ?? 'null'}\ncurrency: ${u.currency ?? ''}\norder_id: ${u.orderId ?? 'null'}';
        AppLogger.info('[CoinsBalancePage] Purchase completed:\n$msg',
            tag: 'purchase');
      }
    });

    // Initialize animation controllers
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize animations
    _tabAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_contentAnimation);

    // Start initial animations
    _tabAnimationController.forward();
    _contentAnimationController.forward();

    // Load user profile data once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.userCubit.getProfileUser("CoinsBalancePage");
    });
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    _contentAnimationController.dispose();
    _debugPurchaseSub?.cancel();
    _purchaseCubit.close();
    super.dispose();
  }

  void _onPressedCoins() {
    if (_selectedTab == 0) return;

    setState(() {
      _selectedTab = 0;
    });

    // Animate content change
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  void _onPressedDiamond() {
    if (_selectedTab == 1) return;

    setState(() {
      _selectedTab = 1;
    });

    // Animate content change
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  void _onPressedNova() {
    if (_selectedTab == 2) return;

    setState(() {
      _selectedTab = 2;
    });

    // Animate content change
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  Color _themeColorForTab(int tab) {
    switch (tab) {
      case 0:
        return Colors.amber; // Coins
      case 1:
        return AppColors.blue; // Diamond
      case 2:
        return Colors.purple; // Nova
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserCubitState>(
      listener: (context, state) {
        if (state.status.isLoadedProfile) {
          final diamonds = state.user?.diamond ?? widget.diamond;
          final wallet = state.user?.wallet ?? widget.wallet;
          final point = state.user?.point ?? 0;
          log("diamond $diamonds --wallet $wallet --nova point $point");
        }
      },
      builder: (context, state) {
        final diamonds = state.user?.diamond ?? widget.diamond;
        final wallet = state.user?.wallet ?? widget.wallet;
       final String? rawPoint = state.user?.point;
final num? point =num.tryParse(rawPoint.toString());
        return SafeArea(
          top: false,
          child: Scaffold(
            body: BlocProvider<PurchaseCubit>.value(
              value: _purchaseCubit,
              child: AnimatedBuilder(
                animation: _tabAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Animated Up Section
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(_tabAnimation),
                        child: FadeTransition(
                          opacity: _tabAnimation,
                          child: UpSection(
                            wallet: wallet,
                            selectedTab: _selectedTab,
                            diamond: diamonds,
                            point: point??0,
                            onPressedCoins: _onPressedCoins,
                            onPressedDiamond: _onPressedDiamond,
                            onPressedNova: _onPressedNova,
                          ),
                        ),
                      ),

                      // Animated Prices Section
                      Expanded(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _contentAnimation,
                            child: PricesSection(
                              selectedTab: _selectedTab,
                              userCubit: widget.userCubit,
                            ),
                          ),
                        ),
                      ),

                      // Animated bottom section with icon-only Swap Currency button (hidden on Diamond tab)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _selectedTab == 1 ? 20 : 70,
                        child: _selectedTab == 1
                            ? const SizedBox.shrink()
                            : FadeTransition(
                                opacity: _contentAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: 'تبديل العملة الافتراضية',
                                        child: FloatingActionButton(
                                          heroTag: 'swap_currency_fab',
                                          mini: true,
                                          backgroundColor: _themeColorForTab(_selectedTab),
                                          foregroundColor: AppColors.white,
                                          onPressed: () async {
                                            final nova = NovaCubit();
                                            final String? used = _selectedTab == 0
                                                ? 'c'
                                                : (_selectedTab == 2 ? 'n' : null);
                                            final ok = await nova.swapCurrency(used: used);
                                            nova.close();
                                            if (ok) {
                                              widget.userCubit.getProfileUser("CoinsBalancePage_swap");
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('تم تبديل العملة الافتراضية')),
                                                );
                                              }
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('فشل تبديل العملة')),
                                                );
                                              }
                                            }
                                          },
                                          child: const Icon(Icons.swap_horiz),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
