import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'webview_flutter_android',
    dartOut: 'lib/src/generated_android_webview.dart',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.webviewflutter',
    ),
    javaOut:
        'android/src/main/java/io/flutter/plugins/webviewflutter/GeneratedAndroidWebView.java',
  ),
)
@HostApi()
abstract class WebViewHostApi {
  void setPlatformNavigationDelegate(int instanceId);

  void setPlatformWebViewClient(int instanceId);

  void setPlatformWebChromeClient(int instanceId);

  void loadData(int instanceId, String data, String mimeType, String encoding);

  void loadDataWithBaseUrl(
    int instanceId,
    String baseUrl,
    String data,
    String mimeType,
    String encoding,
    String historyUrl,
  );

  void loadUrl(int instanceId, String url, Map<String?, String?> headers);

  String? getUrl(int instanceId);

  bool canGoBack(int instanceId);

  bool canGoForward(int instanceId);

  void goBack(int instanceId);

  void goForward(int instanceId);

  void reload(int instanceId);

  void clearCache(int instanceId, bool includeDiskFiles);

  void evaluateJavascript(int instanceId, String javascriptString);

  void addJavascriptChannels(
      int instanceId, List<String> javascriptChannelNames);

  void removeJavascriptChannels(
      int instanceId, List<String> javascriptChannelNames);

  void runJavascript(int instanceId, String javascriptString);

  String? runJavascriptReturningResult(int instanceId, String javascriptString);

  void setWebContentsDebuggingEnabled(bool enabled);

  void setBackgroundColor(int instanceId, int color);

  void setUserAgent(int instanceId, String? userAgent);

  void setZoomEnabled(int instanceId, bool enabled);
}
