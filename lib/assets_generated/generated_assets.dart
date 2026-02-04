// import 'package:lklk/core/constants/assets.dart';
//

// class Assets {
//   Assets._();

//   static List<GiftEntity> generateGifts() {
//     return List<GiftEntity>.generate(filesAssets.length, (index) {
//       final path = filesAssets[index];
//       final elementName = path.split('/').last.split('.').first;
//       return GiftEntity(
//         id: index + 1000, // Example: sequential id starting from 1000
//         price: (index + 1) * 100, // Example: sequential pricing
//         linkPath: path,
//         elementName: elementName,
//         img: AssetsData.gift,
//         type: 'popular',
//       );
//     });
//   }
// }
