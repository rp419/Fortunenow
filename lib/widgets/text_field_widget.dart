import 'package:flutter/material.dart';

import '../res/app_colors.dart';
import '../res/app_constants.dart';

class TextFielldWidget extends StatefulWidget {
  const TextFielldWidget({
    Key? key,
    required this.controller,
    required this.label,
    required this.obsText,
    this.validator,
    required this.isPhone,
    required this.hint,
    this.autovalidateMode,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final bool obsText;
  final String? Function(String?)? validator;
  final bool isPhone;
  final String hint;
  final AutovalidateMode? autovalidateMode;
  @override
  State<TextFielldWidget> createState() => _TextFielldWidgetState();
}

class _TextFielldWidgetState extends State<TextFielldWidget> {
  @override
  void initState() {
    obsText = widget.obsText;
    super.initState();
  }

  late bool obsText;
  bool visiblePass = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppConstants.textStyle14,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.containerBgColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
                suffixIcon: obsText == true
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            visiblePass = !visiblePass;
                          });
                        },
                        icon: visiblePass ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                      )
                    : null,
              ),
              keyboardType: widget.isPhone ? TextInputType.phone : null,
              obscureText: obsText == true ? !visiblePass : false,
            ),
          ),
        ),
      ],
    );
  }
}
