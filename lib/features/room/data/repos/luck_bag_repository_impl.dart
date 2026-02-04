// data/repositories/luck_bag_repository_impl.dart
import 'package:lklk/features/room/data/data_sources/luck_bag_remote_data_source.dart';
import 'package:lklk/features/room/data/models/luck_bag_model.dart';
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';
import 'package:lklk/features/room/domain/repos/luck_bag_repository.dart';

class LuckBagRepositoryImpl implements LuckBagRepository {
  final LuckBagRemoteDataSource remoteDataSource;

  LuckBagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> getBagResult(LuckBagEntity luckBag) async {
    final model = LuckBagModel.fromEntity(luckBag);
    return remoteDataSource.getBagResult(model);
  }

  @override
  Future<String> purchaseBag(LuckBagEntity luckBag) async {
    final model = LuckBagModel.fromEntity(luckBag);
    return remoteDataSource.purchaseBag(model);
  }

  @override
  Future<String> sendUltraMessage(int roomID, String message) async {
    return remoteDataSource.sendUltraMessage(roomID, message);
  }
}
