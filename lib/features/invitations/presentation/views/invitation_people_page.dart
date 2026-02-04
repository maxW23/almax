import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/invitations/data/datasources/invitations_api_service.dart';
import 'package:lklk/features/invitations/data/models/invite_person.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/generated/l10n.dart';

class InvitationPeoplePage extends StatefulWidget {
  const InvitationPeoplePage({super.key});

  @override
  State<InvitationPeoplePage> createState() => _InvitationPeoplePageState();
}

class _InvitationPeoplePageState extends State<InvitationPeoplePage> {
  late final InvitationsApiService _api;
  List<InvitePerson> _people = const [];
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
      final list = await _api.getInvitePeople();
      setState(() {
        _people = list;
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
    final isArabic = context.read<LanguageCubit>().state.languageCode == 'ar';
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
          title: Text(t.detailedRecords),
          flexibleSpace: Image.asset(
            'assets/invitation_page/appbar_bg_inivitaion.png',
            fit: BoxFit.fill,
          ),
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 48),
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: const Color(0xFFFF0000))),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: _fetch, child: Text(t.tryAgain)),
                          const Spacer(),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetch,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _people.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.transparent),
                        itemBuilder: (context, index) {
                          final p = _people[index];
                          final name = (p.name == null || p.name!.isEmpty)
                              ? 'unknown'
                              : p.name!;
                          final uid = p.userId ?? '-';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  uid,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
