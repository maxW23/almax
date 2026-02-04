import 'package:flutter/material.dart';
import 'package:lklk/features/room/domain/entities/game_config.dart';
import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/coins_balance_page.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// lklk_game_add
class GameWebViewPage extends StatefulWidget {
  const GameWebViewPage({
    super.key,
    required this.url,
    required this.config,
  });

  final String url;
  final GameConfig config;

  @override
  State<GameWebViewPage> createState() => _GameWebViewPageState();
}

class _GameWebViewPageState extends State<GameWebViewPage> {
  late final WebViewController controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    final navigator = Navigator.of(context);
    final userCubit = context.read<UserCubit>();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'baishunChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (_isDisposed) return;
          _handleGameMessage(message.message, navigator, userCubit);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleGameMessage(String message, NavigatorState navigator, UserCubit userCubit) {
    try {
      final obj = json.decode(message);
      String jsFunName = obj['jsCallback'];
      
      if (jsFunName.contains('getConfig')) {
        log("🎮 [GAME] 游戏调⁠用getConfig");
        String jsUrl = "$jsFunName(${jsonEncode(widget.config.toJson())})";
        log("🎮 [GAME] getConfig $jsUrl");

        controller.runJavaScript(jsUrl);
      } else if (jsFunName.contains('destroy')) {
        log("🎮 [GAME] 游戏调⁠用destroy - إغلاق اللعبة");
        _closeGameProperly(navigator);
      } else if (jsFunName.contains('gameRecharge')) {
        log("🎮 [GAME] 游戏调⁠用gameRecharge - فتح متجر الدفع");
        
        final user = userCubit.user;
        if (mounted && user != null) {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => CoinsBalancePage(
                  wallet: user.wallet ?? 0,
                  diamond: user.diamond ?? 0,
                  userCubit: userCubit,
              )));
        } else {
             log("Cannot open recharge: User not found or widget not mounted");
        }

      } else if (jsFunName.contains('gameLoaded')) {
        log("🎮 [GAME] 游戏调⁠用gameLoaded - تم تحميل اللعبة");
      }
    } catch (e) {
      log("Error handling game message: $e");
    }
  }

  /// إغلاق اللعبة بشكل صحيح مع تنظيف جميع الموارد
  Future<void> _closeGameProperly(NavigatorState navigator) async {
    log('🔇 [GAME] بدء إغلاق اللعبة وتنظيف الموارد');

    try {
      // إيقاف جميع أصوات اللعبة عبر JavaScript
      await controller.runJavaScript('''
        // إيقاف جميع عناصر الصوت والفيديو
        var audioElements = document.querySelectorAll('audio, video');
        audioElements.forEach(function(element) {
          element.pause();
          element.currentTime = 0;
          element.src = '';
        });
        
        // إيقاف Web Audio API
        if (window.AudioContext || window.webkitAudioContext) {
          try {
            if (window.audioContext) {
              window.audioContext.close();
            }
          } catch(e) { console.log('AudioContext cleanup error:', e); }
        }
        
        // إيقاف أي مؤقتات أو intervals
        var highestTimeoutId = setTimeout(function(){}, 0);
        for (var i = 0; i < highestTimeoutId; i++) {
          clearTimeout(i);
          clearInterval(i);
        }
      ''');

      // تنظيف الموارد
      await _cleanupResources();

      log('✅ [GAME] تم تنظيف موارد اللعبة بنجاح');

      // إغلاق الشاشة
      if (navigator.canPop()) {
        navigator.pop();
      }
    } catch (e) {
      log('❌ [GAME] خطأ أثناء إغلاق اللعبة: $e');
      // إغلاق قسري حتى لو حدث خطأ
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  /// تنظيف جميع الموارد
  Future<void> _cleanupResources() async {
    _isDisposed = true;

    // تنظيف WebView
    try {
      // إيقاف تحميل أي محتوى جديد
      await controller.loadRequest(Uri.parse('about:blank'));

      // تنظيف الذاكرة المؤقتة
      await controller.clearCache();
      await controller.clearLocalStorage();

      log('✅ [GAME] تم تنظيف WebView بنجاح');
    } catch (e) {
      log('⚠️ [GAME] تحذير أثناء تنظيف WebView: $e');
    }
  }

  @override
  void dispose() {
    log('🗑️ [GAME] تخلص من GameWebViewPage');

    // تنظيف الموارد عند التخلص من الويدجت
    _cleanupResources();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // التعامل مع زر الرجوع
        log('🔙 [GAME] المستخدم ضغط زر الرجوع');
        await _closeGameProperly(Navigator.of(context));
        return false; // منع الإغلاق التلقائي لأننا نتعامل معه يدوياً
      },
      child: SafeArea(
        top: false,
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
