import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:intl/intl.dart';

class BirthdaySelectionDialog extends StatefulWidget {
  const BirthdaySelectionDialog({super.key});

  @override
  State<BirthdaySelectionDialog> createState() => _BirthdaySelectionDialogState();
}

class _BirthdaySelectionDialogState extends State<BirthdaySelectionDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        S.of(context).selectBirthday,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 320,
            height: 220,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              maximumYear: DateTime.now().year,
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  _selectedDate = newDateTime;
                });
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            S.of(context).cancel,
            style: const TextStyle(
                color: AppColors.secondColorDark, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: () {
            final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
            Navigator.of(context).pop(formattedDate);
          },
          child: Text(
            S.of(context).save,
            style: const TextStyle(
                color: AppColors.secondColorDark, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
