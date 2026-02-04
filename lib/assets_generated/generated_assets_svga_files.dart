import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

class AssetsFiles {
  AssetsFiles._();

  static const svgaFilesAssets = [
    'assets/files/bear.svga',
    'assets/files/Bouquet.svga',
    'assets/files/bride.svga',
    'assets/files/butterfly.svga',
    'assets/files/camel.svga',
    'assets/files/car.svga',
    'assets/files/castle_2.svga',
    'assets/files/clock.svga',
    'assets/files/coffee.svga',
    'assets/files/crown.svga',
    'assets/files/dragon.svga',
    'assets/files/falcon.svga',
    'assets/files/fruit juice.svga',
    'assets/files/helicopter.svga',
    'assets/files/kiss.svga',
    'assets/files/lamp.svga',
    'assets/files/mic.svga',
    'assets/files/piano wing.svga',
    'assets/files/plane000.svga',
    'assets/files/planet.svga',
    'assets/files/ring 4.svga',
    'assets/files/rocket.svga',
    'assets/files/rose box_000.svga',
    'assets/files/rose with love.svga',
    'assets/files/rose.svga',
    'assets/files/sheep (1).svga',
    'assets/files/sheep.svga',
    'assets/files/shisha.svga',
    'assets/files/slipper.svga',
    'assets/files/Soft drink with glass.svga',
    'assets/files/stage.svga',
    'assets/files/suprem gun.svga',
    'assets/files/tiger.svga',
    'assets/files/top live.svga',
    'assets/files/war plane.svga',
    'assets/files/wedding dress.svga',
    'assets/files/yacht.svga',
  ];
  static List<ElementEntity> generateGifts() {
    return List<ElementEntity>.generate(svgaFilesAssets.length, (index) {
      final path = svgaFilesAssets[index];
      final elementName = path.split('/').last.split('.').first;
      return ElementEntity(
        id: index + 1000, // Example: sequential id starting from 1000
        price: " (index + 1) * 100", // Example: sequential pricing
        linkPath: path,
        elementName: elementName,
        imgElement: AssetsData.gift,
        type: 'popular',
      );
    });
  }
}
