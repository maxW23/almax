import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/purchase/purchase_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/coins_item.dart';

// Data model for balance options
class BalanceOption {
  final int price;
  final int coins;

  const BalanceOption({
    required this.price,
    required this.coins,
  });
}

  // Static data for coins and diamonds
class BalanceData {
  static const List<BalanceOption> coinsOptions = [
    // 1 EUR = 10000 Coins
    BalanceOption(price: 1, coins:  3000    ),
    BalanceOption(price: 5, coins:  15000   ),
    BalanceOption(price: 10, coins: 30000  ),
    BalanceOption(price: 15, coins: 45000  ),
    BalanceOption(price: 20, coins:  60000 ),
    BalanceOption(price: 25, coins: 75000 ),
  ];

  static const List<BalanceOption> diamondOptions = [
    // Adjusted to align with 1200 → 420 conversion (multiples of 600)
    BalanceOption(price: 600, coins: 600),
    BalanceOption(price: 2400, coins: 2400),
    BalanceOption(price: 6000, coins: 6000),
    BalanceOption(price: 7200, coins: 7200),
    BalanceOption(price: 12000, coins: 12000),
    BalanceOption(price: 120000, coins: 120000),
  ];

  static const List<BalanceOption> novaOptions = [
    BalanceOption(price: 100, coins: 100),
    BalanceOption(price: 500, coins: 500),
    BalanceOption(price: 1000, coins: 1000),
    BalanceOption(price: 2000, coins: 2000),
    BalanceOption(price: 5000, coins: 5000),
    BalanceOption(price: 10000, coins: 10000),
  ];
}

class PricesSection extends StatefulWidget {
  const PricesSection({
    super.key,
    required this.selectedTab,
    required this.userCubit,
  });

  final int selectedTab; // 0 = Coins, 1 = Diamond, 2 = Nova
  final UserCubit userCubit;

  @override
  State<PricesSection> createState() => _PricesSectionState();
}

class _PricesSectionState extends State<PricesSection>
    with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late List<Animation<double>> _itemAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for each grid item
    _itemAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.4;

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _gridAnimationController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      ));
    });

    _slideAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.4;

      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _gridAnimationController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _gridAnimationController.forward();
  }

  @override
  void didUpdateWidget(PricesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTab != widget.selectedTab) {
      // Restart animation when switching tabs
      _gridAnimationController.reset();
      _gridAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.selectedTab == 0
        ? BalanceData.coinsOptions
        : widget.selectedTab == 1
            ? BalanceData.diamondOptions
            : BalanceData.novaOptions;

    return BlocListener<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        // تمت إزالة جميع SnackBars. نحتفظ فقط بتحديث الملف الشخصي عند النجاح.
        if (state is PurchaseSuccess) {
          widget.userCubit.getProfileUser("PurchaseSuccess");
        }
      },
      child: AnimatedBuilder(
        animation: _gridAnimationController,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main grid
                GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 17,
                  ),
                  itemCount: options.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  addRepaintBoundaries: true,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options[index];

                    return RepaintBoundary(
                      child: SlideTransition(
                        position: _slideAnimations[index],
                        child: FadeTransition(
                          opacity: _itemAnimations[index],
                          child: ScaleTransition(
                            scale: _itemAnimations[index],
                            child: CoinsItem(
                              price: option.price,
                              coins: option.coins,
                              selectedTab: widget.selectedTab,
                              userCubit: widget.userCubit,
                              enableSnackbars: false,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
