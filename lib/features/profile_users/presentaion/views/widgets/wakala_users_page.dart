import 'package:lklk/core/utils/logger.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/post_center_section/mini_dash_wakala/mini_dashboard_wakala_cubit.dart';

class WakalaUsersPage extends StatelessWidget {
  const WakalaUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MiniDashboardWakalaCubit()..loadUsers(),
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('إدارة المستخدمين',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade100,
                  Colors.white,
                ],
              ),
            ),
            child: BlocConsumer<MiniDashboardWakalaCubit, MiniDashboardState>(
              listener: (context, state) {},
              // listener: (context, state) {
              //   if (state.status.isError) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: AutoSizeText(state.message ?? ''),
              //         backgroundColor: const Color(0xFFFF0000),
              //       ),
              //     );
              //   }
              //   if (state.status.isAcceptUserError) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: AutoSizeText(state.message ?? ''),
              //         backgroundColor: Colors.orange,
              //       ),
              //     );
              //   }
              //   if (state.status.isDeleteUserError) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: AutoSizeText(state.message ?? ''),
              //         backgroundColor: const Color(0xFFFF0000),
              //       ),
              //     );
              //   }
              //   if (state.status.isAcceptUserSuccess) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: AutoSizeText(state.message ?? ''),
              //         backgroundColor: Colors.green,
              //       ),
              //     );
              //   }
              //   if (state.status.isDeleteUserSuccess) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: AutoSizeText(state.message ?? ''),
              //         backgroundColor: Colors.green,
              //       ),
              //     );
              //   }
              //   if (state.status.isLoaded) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: AutoSizeText(state.message ?? ''),
              //         backgroundColor: Colors.green,
              //       ),
              //     );
              //   }
              // },
              builder: (context, state) {
                log("MiniDashboardWakalaCubit length :${state.users.length}");
                if (state.users.isNotEmpty) {
                  return _buildUsersTable(state.users, context);
                } else if (state.status.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.purpleColor));
                }
                if (state.users.isEmpty) {
                  return const Center(child: Text('لا يوجد مستخدمين'));
                }
                return const Center(child: Text('قم بتحميل البيانات'));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTable(List<UserEntity> users, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DataTable2(
        minWidth: 800,
        columnSpacing: 20,
        horizontalMargin: 20,

        headingRowHeight: 60,
        //  dataTextStyle: _textRowStyle(),
        // headingTextStyle: _headerStyle,
        fixedTopRows: 1, // لتعليق عناوين الأعمدة
        // isScrollable: true, // ممكن إضافة حتى scrollbar
        isVerticalScrollBarVisible: true,
        isHorizontalScrollBarVisible: true,
        headingRowColor: WidgetStateProperty.resolveWith<Color>(
          (states) => Colors.deepPurple.withValues(alpha: 0.1),
        ),
        columns: [
          _buildDataColumn('ID', minWidth: 80),
          _buildDataColumn('ID2', minWidth: 100),
          _buildDataColumn('الاسم', minWidth: 150),
          _buildDataColumn('هدايا مرسلة', minWidth: 120),
          _buildDataColumn('هدايا مستلمة', minWidth: 120),
          _buildDataColumn('الحالة', minWidth: 120),
          _buildDataColumn('الإجراءات', minWidth: 150),
        ],
        rows: users.map((user) => _buildUserRow(user, context)).toList(),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, {double? minWidth}) {
    return DataColumn(
      label: Container(
          width: minWidth,
          alignment: Alignment.center,
          child: Text(
            label,
            style: _headerStyle,
            maxLines: 2,
            textAlign: TextAlign.center,
          )),
    );
  }

  DataRow _buildUserRow(UserEntity user, BuildContext context) {
    return DataRow(
      key: ValueKey(user.id),
      cells: [
        _buildCenteredCell(user.id.toString()),
        _buildCenteredCell(user.totalSocre ?? '-'),
        _buildCenteredCell(user.name ?? 'غير معروف'),
        _buildCenteredCell(user.giftSend ?? '0'),
        _buildCenteredCell(user.giftRecive ?? '0'),
        DataCell(
          Align(
            alignment: Alignment.center,
            child: _buildStatusBadge(user.type1),
          ),
        ),
        // DataCell(
        //   Container(
        //     width: 150,
        //     alignment: Alignment.center,
        //     child: _buildActionButtons(user, context),
        //   ),
        // ),
        DataCell(
          BlocConsumer<MiniDashboardWakalaCubit, MiniDashboardState>(
            listener: (context, state) {},
            buildWhen: (prev, curr) =>
                (curr.status.isAcceptUserLoading && curr.userId == user.id) ||
                (curr.status.isDeleteUserLoading && curr.userId == user.id) ||
                (curr.status.isAcceptUserError && curr.userId == user.id) ||
                (curr.status.isDeleteUserError && curr.userId == user.id) ||
                (curr.status.isAcceptUserSuccess && curr.userId == user.id) ||
                (curr.status.isDeleteUserSuccess && curr.userId == user.id),
            builder: (context, state) {
              if (state.status.isAcceptUserLoading && state.userId == user.id) {
                return Center(
                    child: const CircularProgressIndicator(
                        color: AppColors.purpleColor));
              }

              if (state.status.isDeleteUserLoading && state.userId == user.id) {
                return Center(
                    child: const CircularProgressIndicator(
                        color: AppColors.purpleColor));
              }
              if (state.status.isDeleteUserError && state.userId == user.id) {
                return SizedBox(width: 80, child: Text("تم"));
              }
              if (state.status.isAcceptUserError && state.userId == user.id) {
                return SizedBox(width: 80, child: Text("تم"));
              }
              return _buildActionButtons(user, context);
            },
          ),
        ),
      ],
    );
  }

  DataCell _buildCenteredCell(String text) {
    return DataCell(
      Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: _textRowStyle(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  TextStyle _textRowStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = 'مقبول';
        break;
      case 'delete':
        color = const Color(0xFFFF0000);
        text = 'محذوف';
        break;
      default:
        color = Colors.grey;
        text = status ?? '';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserEntity user, BuildContext context) {
    final cubit = context.read<MiniDashboardWakalaCubit>();

    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      child: _getActionContent(user, cubit),
    );
  }

  Widget _getActionContent(UserEntity user, MiniDashboardWakalaCubit cubit) {
    if (user.type1 == 'wait') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              await cubit.acceptUser(user.id.toString());
              await cubit.loadUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: const Color(0xFFFF0000)),
            onPressed: () async {
              await cubit.deleteUser(user.id.toString());
              await cubit.loadUsers();
            },
          ),
        ],
      );
    }

    if (user.type1 == 'accepted') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_rounded,
                color: const Color(0xFFFF0000)),
            onPressed: () async {
              await cubit.deleteUser(user.id.toString());
              await cubit.loadUsers();
            },
          ),
        ],
      );
    }
    if (user.type1 == 'delete') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: const Color(0xFFFF0000)),
            onPressed: () async {
              await cubit.deleteUser(user.id.toString());
              await cubit.loadUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () async {
              await cubit.acceptUser(user.id.toString());
              await cubit.loadUsers();
            },
          ),
        ],
      );
    }
    return const Text(
      'تم',
      style: TextStyle(color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }

  static const _headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
    fontSize: 14,
    height: 1.2,
  );
}
