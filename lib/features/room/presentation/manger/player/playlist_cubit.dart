import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'playlist_state.dart';

/// Cubit لإدارة قائمة الأغاني، مع دعم التحديد المتعدد والإضافة والحذف
class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit({this.onSongRemoved, this.onPlaylistCleared})
      : super(const PlaylistState()) {
    _restore();
  }

  /// Callback لإخطار PlaybackCubit عند حذف أغنية
  final Future<void> Function(int removedIndex, int newLength)? onSongRemoved;

  /// Callback لإخطار PlaybackCubit عند مسح القائمة
  final Future<void> Function()? onPlaylistCleared;

  static const _prefsKey = 'user_playlist';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_prefsKey) ?? const [];
    emit(state.copyWith(paths: paths, selected: {}));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.paths);
  }

  void toggleSelection(int index) {
    final sel = Set<int>.from(state.selected);
    if (sel.contains(index)) {
      sel.remove(index);
    } else {
      sel.add(index);
    }
    emit(state.copyWith(selected: sel));
  }

  void clearSelection() => emit(state.copyWith(selected: {}));

  void selectAll() => emit(state.copyWith(selected: {
        for (int i = 0; i < state.paths.length; i++) i,
      }));

  Future<void> addPaths(List<String> paths) async {
    if (paths.isEmpty) return;
    final updated = List<String>.from(state.paths)..addAll(paths);
    emit(state.copyWith(paths: updated));
    await _persist();
  }

  Future<void> removeAt(int index, {bool deleteFile = true}) async {
    if (index < 0 || index >= state.paths.length) return;
    final pathToRemove = state.paths[index];
    final updated = List<String>.from(state.paths)..removeAt(index);
    emit(state.copyWith(paths: updated));
    await _persist();

    // إخطار PlaybackCubit بالحذف
    if (onSongRemoved != null) {
      await onSongRemoved!(index, updated.length);
    }

    if (deleteFile) {
      final file = File(pathToRemove);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> removeSelected({bool deleteFiles = true}) async {
    if (state.selected.isEmpty) return;
    final indices = state.selected.toList()..sort((a, b) => b.compareTo(a));
    for (final i in indices) {
      await removeAt(i, deleteFile: deleteFiles);
    }
    clearSelection();
  }

  Future<void> clearAll({bool deleteFiles = false}) async {
    if (deleteFiles) {
      for (final p in state.paths) {
        final f = File(p);
        if (await f.exists()) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    }
    emit(state.copyWith(paths: [], selected: {}));
    await _persist();

    // إخطار PlaybackCubit بمسح القائمة
    if (onPlaylistCleared != null) {
      await onPlaylistCleared!();
    }
  }

  /// نسخ ملف إلى Documents للتخزين الدائم وإرجاع المسار الجديد
  Future<String> copyToAppDir(String sourcePath, {String? fileName}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final name = fileName ?? sourcePath.split('/').last;
    final target = File('${appDir.path}/$name');
    final src = File(sourcePath);

    if (!await target.exists() ||
        (await target.length()) != (await src.length())) {
      await src.copy(target.path);
    }
    return target.path;
  }
}
