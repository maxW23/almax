import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';

Future<int?> showAmountDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(S.of(context).entrePrice),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: S.of(context).priceHint,
            labelText: S.of(context).price,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.secondColorDark, // استخدام لون ثابت
                  width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).pleaseEnterAmount;
            }
            if (int.tryParse(value) == null) {
              return S.of(context).valueMustBeNumber;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            S.of(context).cancel,
            style: const TextStyle(
                color: const Color(0xFFFF0000,),
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop(int.parse(controller.text));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                S.of(context).ok,
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
