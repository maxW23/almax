import 'package:lklk/core/constants/assets.dart';

String determineImage(int level, bool isGreen) {
  if (level >= 0 && level < 10) {
    return isGreen ? AssetsData.levelImage7 : AssetsData.levelImage1;
  }
  if (level >= 10 && level < 20) {
    return isGreen ? AssetsData.levelImage8 : AssetsData.levelImage2;
  }
  if (level >= 20 && level < 30) {
    return isGreen ? AssetsData.levelImage9 : AssetsData.levelImage3;
  }
  if (level >= 30 && level < 40) {
    return isGreen ? AssetsData.levelImage10 : AssetsData.levelImage4;
  }
  if (level >= 40 && level < 50) {
    return isGreen ? AssetsData.levelImage11 : AssetsData.levelImage5;
  }
  if (level >= 50) {
    return isGreen ? AssetsData.levelImage12 : AssetsData.levelImage6;
  }
  return '';
}
