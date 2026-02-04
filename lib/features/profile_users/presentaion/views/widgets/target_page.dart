import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class TargetPage extends StatefulWidget {
  const TargetPage({super.key});

  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
  final user = sl<UserCubit>().state.user;
  late final WebViewController _controller;
  var isLoading = true;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (error) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const AutoSizeText('حدث خطأ'),
                content: AutoSizeText('فشل تحميل الصفحة: ${error.description}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const AutoSizeText('حسناً'),
                  ),
                ],
              ),
            );
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            "http://lklklive.com/admin/login3?email=${user?.email}&idd=${user?.idd}"),
      )
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(S.of(context).target),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              } else {
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(
              controller: _controller,
            ),
            if (isLoading)
              LinearProgressIndicator(
                value: loadingPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 3,
              ),
          ],
        ),
      ),
    );
  }
}
