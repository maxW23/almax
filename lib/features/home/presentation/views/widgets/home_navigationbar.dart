import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<HomeBottomNavigationBar> createState() =>
      _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final rt = NotificationRealtimeService.instance;
    return ValueListenableBuilder<int>(
      valueListenable: rt.chatUnread,
      builder: (context, chatUnread, _) {
        return ValueListenableBuilder<int>(
          valueListenable: rt.userTabUnread,
          builder: (context, userUnread, __) {
            return RepaintBoundary(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondColor, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                height: size.width * 0.155,
                child: ListView.builder(
                  itemCount: _HomeBottomNavigationBarState.svgIconPaths.length,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.024),
                  itemBuilder: (context, index) => buildNavItem(
                    index,
                    size,
                    key: ValueKey('nav_$index'),
                    chatUnread: chatUnread,
                    userUnread: userUnread,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildNavItem(int index, Size size,
      {Key? key, required int chatUnread, required int userUnread}) {
    final int count = index == 1 ? chatUnread : (index == 0 ? userUnread : 0);
    final bool showBadge = count > 0;

    return InkWell(
      key: key,
      onTap: () async {
        widget.onTap(index);

        if (index == 1) {
          await NotificationRealtimeService.instance.markChatRead();
        } else if (index == 0) {
          await NotificationRealtimeService.instance.markUserTabRead();
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: size.width * 0.014),
          Stack(
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: SvgPicture.asset(
                  _HomeBottomNavigationBarState.svgIconPaths[index],
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    index == widget.currentIndex ? Colors.black : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (showBadge && index != widget.currentIndex)
                Positioned(
                  right: 0,
                  top: -1.4,
                  child: _NumericBadge(count: count),
                ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.fastLinearToSlowEaseIn,
            margin: EdgeInsets.only(
              top: index == widget.currentIndex ? 0 : size.width * 0.029,
              right: size.width * 0.08,
              left: size.width * 0.08,
            ),
            width: size.width * 0.153,
            height: index == widget.currentIndex ? size.width * 0.014 : 0,
            decoration: BoxDecoration(
              color: index == widget.currentIndex ? Colors.black : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ترتيب الأيقونات: 0 المستخدم، 1 المحادثات (envelope)، 2 الرئيسية
  static const List<String> svgIconPaths = [
    'assets/icons/home_nav_bar_icon/user.svg',
    'assets/icons/home_nav_bar_icon/envelope.svg',
    'assets/icons/home_nav_bar_icon/home.svg',
  ];
}

class _NumericBadge extends StatelessWidget {
  const _NumericBadge({required this.count});
  final int count;

  String get _label => count > 99 ? '99+' : '$count';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
