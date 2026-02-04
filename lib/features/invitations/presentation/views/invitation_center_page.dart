import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/invitations/data/datasources/invitations_api_service.dart';
import 'package:lklk/features/invitations/data/models/invite_profit_response.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/invitations/presentation/views/invitation_people_page.dart';
import 'package:lklk/core/animations/shimmer_widget.dart';

class InvitationCenterPage extends StatefulWidget {
  const InvitationCenterPage({super.key});

  @override
  State<InvitationCenterPage> createState() => _InvitationCenterPageState();
}

class _InvitationSkeleton extends StatelessWidget {
  const _InvitationSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double h = 16, double w = double.infinity, BorderRadius? r}) =>
        Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: r ?? BorderRadius.circular(8),
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card skeleton
          ShimmerWidget(
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(w: 120),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: bar(h: 24, r: BorderRadius.circular(12))),
                      const SizedBox(width: 12),
                      Expanded(child: bar(h: 24, r: BorderRadius.circular(12))),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          bar(w: 100),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, __) => ShimmerWidget(
                child: Row(
                  children: [
                    Expanded(child: bar(h: 14)),
                    const SizedBox(width: 12),
                    bar(h: 14, w: 48, r: BorderRadius.circular(6)),
                  ],
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemCount: 10,
            ),
          ),
          const SizedBox(height: 16),
          ShimmerWidget(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _InviteLinkSheet on _InvitationCenterPageState {
  Future<void> _showInviteLinkDialog() async {
    final t = S.of(context);
    final user = await AuthService.getUserFromSharedPreferences();
    final userId = (user?.id?.trim().isNotEmpty ?? false)
        ? user!.id!.trim()
        : (user?.iduser.trim().isNotEmpty ?? false)
            ? user!.iduser.trim()
            : null;
    final link = userId != null
        ? 'https://lklklive.com/app/redirect/$userId'
        : 'https://lklklive.com/app/redirect';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final height = mq.size.height * 0.75;
        return SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height,
                margin: const EdgeInsets.only(left: 16, right: 16, top: 0),
                child: _RibbonCard(
                  ribbonText: t.invitationLinkTitle,
                  ribbonTextTop: 160,
                  topPadding: 120,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 120),
                        Text(
                          t.registerViaYourLink,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _RoundedPanel(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E5E5),
                                        width: 1),
                                  ),
                                  child: Text(
                                    link,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 40,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/invitation_page/btn_inivitaiton.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                ClipboardData(text: link));
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(t.linkCopied)),
                                              );
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.link,
                                                  size: 18,
                                                  color: Colors.white),
                                              const SizedBox(width: 8),
                                              Text(t.copyLink),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          t.shareWith,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Color(0xffFABF67),
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ShareCircle(
                              label: 'WhatsApp',
                              svgAsset: 'assets/socail_media_svg/whatsApp.svg',
                              onTap: () => _shareToWhatsApp(link),
                            ),
                            _ShareCircle(
                              label: 'Facebook',
                              svgAsset: 'assets/socail_media_svg/facebook.svg',
                              onTap: () => _shareToFacebook(link),
                            ),
                            _ShareCircle(
                              label: 'Snapchat',
                              svgAsset: 'assets/socail_media_svg/snapcaht.svg',
                              onTap: _openSnapchat,
                            ),
                            _ShareCircle(
                              label: 'Messenger',
                              svgAsset: 'assets/socail_media_svg/messenger.svg',
                              onTap: () => _shareToMessenger(link),
                            ),
                          ],
                        ),
                        Text(
                          t.copyFirstThenShare,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/invitation_page/btn_inivitaiton.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showInviteTasksDialog();
                                  },
                                  icon: const Icon(Icons.info_outline,
                                      color: Colors.white),
                                  label: Text(t.invitationTasksTitle),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.inviteNowFooter,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InvitationCenterPageState extends State<InvitationCenterPage> {
  late final InvitationsApiService _api;
  InviteProfitResponse? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = InvitationsApiService(ApiService());
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ln = context.read<LanguageCubit>().state.languageCode;
      final d = await _api.getInviteProfit(languageCode: ln);
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    // Reactive language read so UI updates when language changes
    final ln =
        context.select<LanguageCubit, String>((c) => c.state.languageCode);
    final isArabic = ln.toLowerCase().startsWith('ar');
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Text(t.invitationCentre),
          flexibleSpace: Image.asset(
            'assets/invitation_page/appbar_bg_inivitaion.png',
            fit: BoxFit.fill,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showInviteTasksDialog,
              tooltip: t.invitationCentre,
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/invitation_page/bg_invitation.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _loading
                ? const _InvitationSkeleton()
                : (_error != null
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 48),
                            // Friendly error visual
                            const Icon(Icons.cloud_off,
                                size: 56, color: Colors.white70),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: const Color(0xFFFF0000),
                              ),)
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: _fetch,
                                child: Text(t.tryAgain),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailedRecordsCard(
                              header: t.detailedRecords,
                              onTapHeader: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const InvitationPeoplePage(),
                                  ),
                                );
                              },
                              titleLeft: t.totalProfits,
                              valueLeft: (_data?.profit ?? 0).toString(),
                              titleRight: t.totalInvitees,
                              valueRight: (_data?.people ?? 0).toString(),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t.records,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange),
                            ),
                            const SizedBox(height: 12),
                            // سجلات تتمدد لملء المساحة المتبقية وتبقى قابلة للتمرير داخلياً
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _fetch,
                                child: const _RecordsList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // زر ثابت أسفل الشاشة
                            _BottomCtaButton(
                              label: t.earnMoreProfits,
                              onPressed: () => _showInviteLinkDialog(),
                            ),
                          ],
                        ),
                      )),
          ),
        ),
      ),
    );
  }

  Future<bool> _launchExternal(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  void _showLaunchError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Unable to open app. Try copying the link.')),
    );
  }

  Future<void> _shareToWhatsApp(String link) async {
    final encoded = Uri.encodeComponent(link);
    final uri = Uri.parse('whatsapp://send?text=$encoded');
    final fallback = Uri.parse('https://wa.me/?text=$encoded');
    final ok = await _launchExternal(uri) || await _launchExternal(fallback);
    if (!ok) _showLaunchError();
  }

  Future<void> _shareToFacebook(String link) async {
    final encoded = Uri.encodeComponent(link);
    // محاولة فتح التطبيق أولاً
    final app = Uri.parse(
        'fb://facewebmodal/f?href=https://www.facebook.com/sharer/sharer.php?u=$encoded');
    final web =
        Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encoded');
    final ok = await _launchExternal(app) || await _launchExternal(web);
    if (!ok) _showLaunchError();
  }

  Future<void> _shareToMessenger(String link) async {
    final encoded = Uri.encodeComponent(link);
    final app = Uri.parse('fb-messenger://share?link=$encoded');
    final web =
        Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encoded');
    final ok = await _launchExternal(app) || await _launchExternal(web);
    if (!ok) _showLaunchError();
  }

  Future<void> _openSnapchat() async {
    final app = Uri.parse('snapchat://');
    final web = Uri.parse('https://www.snapchat.com/');
    final ok = await _launchExternal(app) || await _launchExternal(web);
    if (!ok) _showLaunchError();
  }
}

class _DetailedRecordsCard extends StatelessWidget {
  final String header;
  final VoidCallback onTapHeader;
  final String titleLeft;
  final String valueLeft;
  final String titleRight;
  final String valueRight;
  const _DetailedRecordsCard({
    required this.header,
    required this.onTapHeader,
    required this.titleLeft,
    required this.valueLeft,
    required this.titleRight,
    required this.valueRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/invitation_page/small_bg-invivation.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTapHeader,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      header,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _Metric(title: titleLeft, value: valueLeft)),
                // Container(width: 1, height: 56, color: Colors.orange.shade200),
                Expanded(child: _Metric(title: titleRight, value: valueRight)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  const _Metric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final end = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 14,
              color: const Color(0xFFFF8E76),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          key: ValueKey(value),
          tween: Tween<double>(begin: 0, end: end.toDouble()),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (context, v, _) {
            final shown = v.round().toString();
            return Text(
              shown,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  color: const Color(0xFFFF8E76),
                  fontWeight: FontWeight.bold),
            );
          },
        ),
      ],
    );
  }
}

class _RecordsList extends StatefulWidget {
  const _RecordsList();

  @override
  State<_RecordsList> createState() => _RecordsListState();
}

class _RecordsListState extends State<_RecordsList> {
  final ScrollController _controller = ScrollController();
  final Random _rand = Random();
  late List<Map<String, String>> _items;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final isArabic = context.read<LanguageCubit>().state.languageCode == 'ar';
    _items = _generateMockItems(count: 200, isArabic: isArabic);
    // ابدأ السحب التلقائي للأسفل
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> _generateMockItems(
      {int count = 200, bool isArabic = false}) {
    // عناوين منطقية متنوعة حسب اللغة
    final titles = isArabic
        ? const <String>[
            'ربح 1200 عملة عبر الدعوة',
            'مكافأة التسجيل عبر الدعوة: 2000 عملة',
            'أول شحن عبر الدعوة: 8000 عملة',
            'الصديق أكمل مهمة: 1500 عملة',
            'انضم صديق مدعو: 3000 عملة',
            'سلسلة دعوات ناجحة: 4500 عملة',
          ]
        : const <String>[
            'Earn 1200 coins through referral',
            'Referral signup bonus: 2000 coins',
            'First recharge referral: 8000 coins',
            'Friend completed task: 1500 coins',
            'Invited user joined: 3000 coins',
            'Referral streak bonus: 4500 coins',
          ];
    String maskedUser() => '${50 + _rand.nextInt(50)}***';

    return List.generate(count, (_) {
      final title = titles[_rand.nextInt(titles.length)];
      return {'title': title, 'user': maskedUser()};
    });
  }

  void _startAutoScroll() {
    const step = 0.8; // بكسل لكل نبضة
    const interval = Duration(milliseconds: 16); // ~60fps
    _timer = Timer.periodic(interval, (t) {
      if (!_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      final cur = _controller.offset;
      if (cur >= max - 2) {
        // أعد إلى البداية لعمل حلقة مستمرة
        _controller.jumpTo(0);
      } else {
        _controller.jumpTo(cur + step);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // خلفية شفافة كما طلبت
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [], // لا ظل مع الشفافية
      ),
      child: ListView.separated(
        controller: _controller,
        itemCount: _items.length,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item['title']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                ),
                Text(
                  item['user']!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _BottomCtaButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/invitation_page/btn_inivitaiton.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _InvitationCenterPageState {
  void _showInviteTasksDialog() {
    final t = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final height = mq.size.height * 0.75;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height,
                margin: const EdgeInsets.only(left: 22, right: 22, top: 0),
                child: _RibbonCard(
                  ribbonText: t.invitationTasksTitle,
                  topPadding: 120,
                  ribbonTextTop: 145,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 120),
                        Text(
                          t.invitationSystem,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 50),
                        _RoundedPanel(
                          child: Text(
                            t.invitationSystemDesc,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          t.yourRewards,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffFABF67),
                                  fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            t.invitationRewardsDesc,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/invitation_page/btn_inivitaiton.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      size: 16, color: Colors.white),
                                  label: Text(t.back),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.inviteNowFooter,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RibbonCard extends StatelessWidget {
  final String ribbonText;
  final Widget child;
  final double topPadding;
  final double ribbonTextTop;
  const _RibbonCard({
    required this.ribbonText,
    required this.child,
    this.topPadding = 180,
    this.ribbonTextTop = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image:
                  AssetImage('assets/invitation_page/dialog_invitatrion.png'),
              fit: BoxFit.cover,
            ),
          ),
          // مساحة النص داخل الصورة (أعلى مساحة لشريط الشريط، وأسفل زر)
          padding: EdgeInsets.fromLTRB(20, topPadding, 20, 24),
          child: child,
        ),
        Positioned(
          top: ribbonTextTop,
          left: 0,
          right: 0,
          child: Text(
            ribbonText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _RoundedPanel extends StatelessWidget {
  final Widget child;
  const _RoundedPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      color: Colors.transparent,
      child: child,
    );
  }
}

class _ShareCircle extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback? onTap;
  const _ShareCircle(
      {required this.label, this.icon, this.svgAsset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  )
                : Icon(icon ?? Icons.share, color: Colors.orange.shade800),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      ),
    );
  }
}
