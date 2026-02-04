// lklk_game_add
class GameBean {
  int? id;
  String? icon;
  String? name;
  String? url;

  GameBean({this.id, this.icon, this.name, this.url});

  factory GameBean.fromJson(Map<String, dynamic> source) {
    return GameBean(
      id: source['id'] as int,
      name: source['name'] as String,
      icon: source['icon'] as String,
      url: source['url'] as String,
    );
  }
}
