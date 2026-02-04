import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/join_to_wakala/join_to_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/out_of_wakala/out_from_wakala_cubit.dart';
import 'package:lklk/generated/l10n.dart';

class AgencyCenterPage extends StatelessWidget {
  const AgencyCenterPage({super.key, required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => JoinToWakalaCubit()),
        BlocProvider(create: (_) => OutFromWakalaCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).agency)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              title: S.of(context).joinToWakala,
              color: const Color(0xFFFFC107),
              onTap: (ctx) async {
                await ctx.read<JoinToWakalaCubit>().joinToWakala(user.iduser);
                final st = ctx.read<JoinToWakalaCubit>().state;
                final success = st is JoinToWakalaSuccess;
                final msg = success
                    ? (st as JoinToWakalaSuccess).message
                    : (st is JoinToWakalaError ? st.message : S.of(ctx).error);
                _showSnack(ctx, success: success, msg: msg);
              },
            ),
            const SizedBox(height: 12),
            _card(
              title: S.of(context).leaveWakala,
              color: const Color(0xFFE53935),
              onTap: (ctx) async {
                await ctx.read<OutFromWakalaCubit>().outFromWakala(user.iduser);
                final st = ctx.read<OutFromWakalaCubit>().state;
                final success = st is OutFromWakalaSuccess;
                final msg = success
                    ? (st as OutFromWakalaSuccess).message
                    : (st is OutFromWakalaError ? st.message : S.of(ctx).error);
                _showSnack(ctx, success: success, msg: msg);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required Color color,
    required Future<void> Function(BuildContext) onTap,
  }) {
    return Builder(
      builder: (ctx) {
        return InkWell(
          onTap: () async => onTap(ctx),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600))),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(BuildContext ctx, {required bool success, required String msg}) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            success ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
