import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'lucky_bag_types.dart';

class LuckyBagBuyBottomSheet extends StatefulWidget {
  const LuckyBagBuyBottomSheet({
    super.key,
    this.initialType = LuckyBagType.superr,
    this.initialAmount = 8000,
    this.initialMaxParticipants = 7,
  });

  final LuckyBagType initialType;
  final int initialAmount;
  final int initialMaxParticipants;

  @override
  State<LuckyBagBuyBottomSheet> createState() => _LuckyBagBuyBottomSheetState();
}

class _LuckyBagBuyBottomSheetState extends State<LuckyBagBuyBottomSheet> {
  late LuckyBagType _type;
  final List<int> _amountOptions = const [8000, 15000, 20000, 25000];
  late int _amount;
  late int _maxParticipants; // من 7 إلى 40
  int? userCoins = 0; // قيمة افتراضية
  @override
  void initState() {
    super.initState();
    _type = LuckyBagType.superr;
    _amount = widget.initialAmount;
    _maxParticipants = widget.initialMaxParticipants.clamp(7, 40);
    userCoinsGet();
  }

  // ودجت زر/كارت لقيمة الكوينز
  Widget _amountTile(int value) {
    final bool selected = _amount == value;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _amount = value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? (AppColors.danger).withValues(alpha: .15)
                : Colors.white.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? (AppColors.danger) : Colors.white24,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 8.h),
              Image.asset(
                AssetsData.bagCoins1,
                width: 40.w,
                height: 40.h,
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage(AssetsData.bagRec1),
                  fit: BoxFit.fill,
                )),
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // شريط تبديل النوع (عادية / سوبر)
  // Widget _typeSwitcher() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _typeChip(
  //           label: 'حقيبة حظ عادية',
  //           selected: _type == LuckyBagType.normal,
  //           onTap: () => setState(() => _type = LuckyBagType.normal),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: _typeChip(
  //           label: 'حقيبة حظ سوبر',
  //           selected: _type == LuckyBagType.superr,
  //           onTap: () => setState(() => _type = LuckyBagType.superr),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ودجت شبيه بزر كبسولة

  // رأسية الديالوغ

  @override
  Widget build(BuildContext context) {
    // للتأكد أن اتجاه الواجهة عربي (يمين-يسار)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 1.5,
        child: Stack(
          children: [
            // الكريستالات يمين ويسار
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                AssetsData.bagLCrystals,
                width: 200.w,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                AssetsData.bagRCrystals,
                width: 200.w,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 50.r,
              left: 0,
              right: 0,
              child: Image.asset(
                AssetsData.bagBg,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            // الإطار
            Positioned(
              top: 40.h,
              child: Image.asset(
                AssetsData.bagBorder,
                fit: BoxFit.fill,
              ),
            ),
            // العملات المتناثرة
            Positioned(
              top: 20.h,
              left: 0,
              right: 0,
              child: Image.asset(
                AssetsData.bagScatteredCoins,
                height: 80.h,
                fit: BoxFit.contain,
              ),
            ),

            // النصوص
            Positioned(
              top: 5.h,
              left: 0,
              right: 0,
              child: Image.asset(
                AssetsData.bagText,
                height: 60.h,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 50.h,
              left: 0,
              right: 0,
              child: Image.asset(
                AssetsData.bagLuckyText,
                height: 50.h,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 70.h),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Image.asset(AssetsData.bagCoin,
                            height: 30.h, width: 30.w),
                        Text(
                          "$userCoins",
                          style: TextStyle(
                            color: (AppColors.black),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // _typeSwitcher(),
                  const SizedBox(height: 16),

                  // عنوان: كمية حقيبة الحظ
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كمية حقيبة الحظ',
                      style: TextStyle(
                        color: (AppColors.black),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // شبكة القيم 777/477/277/177
                  Row(
                    children: [
                      _amountTile(_amountOptions[0]),
                      const SizedBox(width: 10),
                      _amountTile(_amountOptions[1]),
                      const SizedBox(width: 10),
                      _amountTile(_amountOptions[2]),
                      const SizedBox(width: 10),
                      _amountTile(_amountOptions[3]),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الحد الأقصى لعدد المشاركين',
                      style: TextStyle(
                        color: (AppColors.black),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // سلايدر 7 .. 40
                  Column(
                    children: [
                      Slider(
                        value: _maxParticipants.toDouble(),
                        thumbColor: AppColors.danger,
                        activeColor: AppColors.danger,
                        inactiveColor: Colors.white24,
                        min: 7,
                        max: 40,
                        divisions: (40 - 7),
                        label: '$_maxParticipants',
                        onChanged: (v) => setState(() {
                          _maxParticipants = v.round();
                        }),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    AssetsData.bagRoundedRectangleStroke2),
                                fit: BoxFit.fill)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '$_maxParticipants مشارك (النطاق 7 - 40)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // إرسال
                      GestureDetector(
                        onTap: () {
                          // نعيد النتيجة للأب
                          Navigator.of(context).pop(
                            LuckyBagResult(
                              type: _type,
                              amount: _amount, // how
                              maxParticipants: _maxParticipants, // who
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage(
                              AssetsData.bagRedButton,
                            ),
                            fit: BoxFit.fill,
                          )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'إرسال',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(null),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage(
                              AssetsData.bagOffwhiteButton,
                            ),
                            fit: BoxFit.fill,
                          )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'إلغاء',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void userCoinsGet() async {
    final UserEntity? currentUser =
        await AuthService.getUserFromSharedPreferences();

    setState(() {
      userCoins = currentUser?.wallet ?? 0;
    });
  }
}
