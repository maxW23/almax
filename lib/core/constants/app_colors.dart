import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFAF2E82);
  static const Color secondColor = Color(0xFF5B46BF);

  static const Color blue = Color(0xFF5470FF);

  static const Color primaryDark = Color(0xFF2E2F68);
  static const Color secondColorDark = Color(0xFF982888);
  static const Color secondColorsemi = Color(0xFF7D5CAD);

  static const Color primary10 = Color(0xFFA6E5FD);
  static const Color primary20 = Color(0xFFF1F7FC);
  // other
  static const Color blueColor = Color(0xFF00A8FF);
  static const Color thirdColorPurple = Color(0xFF8D89D5);
  static const Color fourthColor = Color(0xFF82D398);
  static const Color fifthColor = Color(0xFFECB65C);
  static const Color orageWhite = Color(0xFFFFB469);
  static const Color pinkWhiteOne = Color(0xFFF886F4);
  static const Color pinkWhiteTwo = Color(0xFFF974E8);

  static const Color darkColor = Color(0xFF0C1020); //0C1020
  //
  // white

  static const Color whiteIcon = Color(0xFFFBFAF7); //F4F6F9
  static const Color whiteGrey = Color(0xFFF4F6F9); //FEFEFD
  static const Color whitewhite = Color(0xFFFEFEFD); //FEFEFD
  static Color whiteWithOpacity5 = white.withValues(alpha: .5);
  static Color whiteWithOpacity2 = white.withValues(alpha: .2);
  static Color whiteWithOpacity25 = AppColors.white.withValues(alpha: .25);
  static const Color white = Colors.white;
  //
  //
  static Color blackWithOpacity5 = AppColors.black.withValues(alpha: .05);
  static Color blackWithOpacity1 = AppColors.black.withValues(alpha: .1);
  static Color primaryWithOpacity2 = AppColors.primary10.withValues(alpha: .2);
  static Color shadowColor = Colors.black.withValues(alpha: 0.1);
  static Color amberwithOpacity5 = Colors.amber.withValues(alpha: .5); //

  // ===== Player & Playlist theming (reused) =====
  // Gradient stops used across PlayerBottomSheet/Playlist
  static const Color playerGradientTop =
      Color(0xFF0B6D6F); // from (0.126, 0.278, 0.419)
  static const Color playerGradientBottom =
      Color(0xFF131D31); // from (0.075, 0.093, 0.163)

  // Glass-style fills and borders
  static Color glassFill = AppColors.white.withValues(alpha: 0.06);
  static Color glassFillStrong = AppColors.white.withValues(alpha: 0.08);
  static const Color glassBorder = Colors.white24;
  static const Color glassHandle = Colors.white24; // drag handle / dividers

  // Playing state backgrounds
  static Color playingBg = AppColors.primary.withValues(alpha: 0.15);
  static const Color brownshad1 = Color(0xFFA1703D); //242118
  static const Color goldenbrowncolor = Color(0xFF242118); //242118
  static const Color brownshad2 = Color(0xFFDEC071); //F6CC7B
  static const Color goldenhad1 = Color(0xFFF6CC7B); //E1C987
  static const Color goldenwhitecolor = Color(0xFFE1C987); //E1C987
  static const Color goldenhad2 = Color(0xFFFBE1A8); //592C6F
  static const Color purpleColor = Color(0xFF592C6F); //
  static const Color orangePinkColor = Color(0xFFF7C2A5); //
  static const Color orangePinkColorBlack = Color(0xFF9C7560); //

  static const Color orangePinkTwoColor = Color(0xFFFFE5D8);
  static const Color pinkwhiteColor = Color(0xFFFFCCFC); //
  static const Color pinkwhiteColorBlack = Color(0xFF795276); //

  static const Color pinkwhiteTwoColor = Color(0xFFFFE5FD);

  static const Color danger = Color(0xFFDB3018);
  static const Color warning = Color(0xFFDBBD2A);
  static const Color success = Color(0xFF58A517);
  static Color successColor = Colors.green.shade400;

  //Colors.green.shade400
  static const Color golden = Color(0xFFFFD700);
  static const Color goldenRoyal = Color(0xFFD4AF37);
  static const Color black = Colors.black; //21211F
  static const Color blackshade1 = Color(0xff21211F); //443C2B
  static const Color blackshade2 = Color(0xff443C2B); //443C2B

  static const Color transparent = Colors.transparent;
  static const Color brown = Colors.brown;

  static const Color amber = Colors.amber;
  static const Color grey = Colors.grey; //Color(0xFFDAD9D9)
  static const Color graywhite = Color(0xFFDAD9D9); //Color(0xFFDAD9D9)
  static const Color graywhiteChat = Color(0xFFF2F2F2); //Color(0xFFDAD9D9)

  static const Color grayAccent = Color(0xFFE1DAD6);

  /// shrild color level
  static const levelShieldOneG = Color(0xFFE89435); //FE6201
  static const levelShieldOneGColorTwo = Color(0xFFFE6201); //FE6201

  static const levelShieldTwoG = Color(0xFFAC140A);
  static const levelShieldTwoGColorTwo = Color(0xFFA50805);

  static const levelShieldThreeG = Color(0xFF3CAA18);
  static const levelShieldThreeGColorTwo = Color(0xFFB1F986);

  static const levelShieldFourG = Color(0xFFF9EF10);
  static const levelShieldFourGColorTwo = Color(0xFFE17D03);

  static const levelShieldFiveG = Color(0xFF3F0267);
  static const levelShieldFiveGColorTwo = Color(0xFFB467FE);
//

  static const levelShieldOneR = Color(0xFFA7E4FD); //1BC1FA
  static const levelShieldOneRColorTwo = Color(0xFF1BC1FA); //1BC1FA

  static const levelShieldTwoR = Color(0xFFE93E03);
  static const levelShieldTwoRColorTwo = Color(0xFFACB9C9);

  static const levelShieldThreeR = Color(0xFFEE318A);
  static const levelShieldThreeRColorTwo = Color(0xFFA2B2C4);

  static const levelShieldFourR = Color(0xFF9D50E9);
  static const levelShieldFourRColorTwo = Color(0xFF721FC6);

  static const levelShieldFiveR = Color(0xFFE05C57);
  static const levelShieldFiveRColorTwo = Color(0xFFA3011A);

  ////////////////////////////////////////
  ///
  static const svipFramColorFive = Color.fromARGB(255, 211, 45, 39);
  // static const svipFramColorFive = Color.fromARGB(255, 116, 20, 15);
  static const svipFramColorFive2 = Color.fromARGB(255, 116, 20, 15);
  static const svipFramColorFive3 = Color.fromARGB(255, 116, 20, 15);

  static const svipFramColorFour = Color.fromARGB(255, 89, 13, 116);
  // static const svipFramColorFour = Color(0xFF166481);
  static const svipFramColorFour2 = Color.fromARGB(255, 202, 122, 236);
  static const svipFramColorFour3 = Color.fromARGB(255, 176, 64, 246);

  static const svipFramColorThree = Color.fromARGB(255, 36, 87, 20);
  // static const svipFramColorTwo = Color(0xFF387C56);
  static const svipFramColorThree2 = Color.fromARGB(255, 91, 199, 111);
  static const svipFramColorThree3 = Color.fromARGB(255, 71, 159, 80);

  static const svipFramColorTwo = Color.fromARGB(255, 43, 101, 241);
  // static const svipFramColorThree = Color(0xFF7B1BA4);
  static const svipFramColorTwo2 = Color.fromARGB(255, 89, 82, 227);
  static const svipFramColorTwo3 = Color.fromARGB(255, 37, 48, 140);

  static const svipFramColorOne = Color.fromARGB(255, 45, 105, 129);
  // static const svipFramColorOne = Color(0xFF164F94);
  static const svipFramColorOne2 = Color.fromARGB(255, 104, 225, 230);

  static const svipFramColorOne3 = Color.fromARGB(255, 30, 75, 64);

  static const Gradient goldenGradient = LinearGradient(
    colors: [
      Color(0xFFAB7800),
      Color(0xFFFBE5AE),
      Color(0xFFF1D6A2),
      Color(0xFFFAECD2),
      Color(0xFFE6D1AE),
      Color(0xFFCBAD7F),
      Color(0xFFB9955F),
    ],
    stops: [0.0, 0.15, 0.32, 0.49, 0.67, 0.84, 1.0],
  );
}
// primary
// static const Color primary = Color(0xFF69BCCA);
//   5470FF
//  FF65C3
// static const Color primary = Color(0xFFED2A3A);
