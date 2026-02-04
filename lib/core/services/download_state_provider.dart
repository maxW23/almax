class DownloadStateProvider {
  bool isPaused = false;

  void togglePause() {
    isPaused = !isPaused;
  }
}
