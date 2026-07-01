import 'package:for_u/presentation/res/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:nice_text_form/country_code_button/country_picker_bottom_sheet.dart';

import 'package:nice_text_form/nice_text_form.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';
import 'package:for_u/presentation/res/translations_manager.dart';

class FastCountryCodeButton extends StatefulWidget {
  final void Function(CountryCode) onSelectionChange;
  final CountryCodePickerController controller;

  const FastCountryCodeButton({
    super.key,
    required this.onSelectionChange,
    required this.controller,
  });

  @override
  State<FastCountryCodeButton> createState() => _FastCountryCodeButtonState();
}

class _FastCountryCodeButtonState extends State<FastCountryCodeButton> {
  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      controller: widget.controller,
      buttonWidth: 26.w,
      buttonHeight: 21.w,
      buttonBorderRadius: 4.r,
      bottomSheetSettings: CountryPickerBottomSheetSettings(
        isDarkMode: context.isDark,
        darkModePrimaryColor: ColorM.primary,
        enableScrollSpacingAnimation: false,
        sheetSearchBarSettings: SheetSearchBarSettings(
          hintText: Translation.search_country.tr,
        ),
      ),
      onSelectionChange: widget.onSelectionChange,
    );
  }
}
