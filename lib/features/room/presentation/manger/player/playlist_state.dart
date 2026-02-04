part of 'playlist_cubit.dart';

class PlaylistState extends Equatable {
  final List<String> paths; // مسارات الملفات المخزنة
  final Set<int> selected; // فهارس العناصر المحددة

  const PlaylistState({this.paths = const [], this.selected = const {}});

  bool get isEmpty => paths.isEmpty;

  PlaylistState copyWith({List<String>? paths, Set<int>? selected}) {
    return PlaylistState(
      paths: paths ?? this.paths,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [paths, selected];
}
