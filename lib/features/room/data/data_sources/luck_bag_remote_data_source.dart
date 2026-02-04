// data/data_sources/luck_bag_remote_data_source.dart
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/room/data/models/luck_bag_model.dart';

abstract class LuckBagRemoteDataSource {
  Future<String> getBagResult(LuckBagModel luckBag);
  Future<String> purchaseBag(LuckBagModel luckBag);
  Future<String> sendUltraMessage(int roomID, String message);
}

// data/data_sources/luck_bag_remote_data_source_impl.dart
class LuckBagRemoteDataSourceImpl implements LuckBagRemoteDataSource {
  final ApiService apiService;

  LuckBagRemoteDataSourceImpl({required this.apiService});

  @override
  Future<String> getBagResult(LuckBagModel luckBag) async {
    final response = await apiService.post(
      '/result/bag/${luckBag.roomID}?who=${luckBag.who}&how=${luckBag.how}&user=${luckBag.user}&doc=${luckBag.id}',
    );
    return response.toString();
  }

  @override
  Future<String> purchaseBag(LuckBagModel luckBag) async {
    final response = await apiService.post(
      '/buy/bag/${luckBag.roomID}?who=${luckBag.who}&how=${luckBag.how}',
    );
    return response.toString();
  }

  @override
  Future<String> sendUltraMessage(int roomID, String message) async {
    final response = await apiService.post(
      '/ultramessage/$roomID?message=$message',
    );
    return response.toString();
  }
}
