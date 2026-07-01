import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/ui_kit/shapes/gradient_border_side.dart' as s;
import 'package:for_u/app/extensions/theme_extensions.dart';

class OtpField extends StatefulWidget {
  final int length;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final MainAxisSize mainAxisSize;
  final double fieldWidth;
  final double fieldHeight;
  final Decoration unselectedFieldDecoration;
  final Decoration selectedFieldDecoration;
  final Function(String)? onComplete;
  final Function(String)? onChanged;
  final bool autofocus;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final hintText;
  final Color? cursorColor;
  const OtpField({
    super.key,
    this.length = 5,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 10,
    this.mainAxisSize = MainAxisSize.max,
    this.fieldWidth = 40,
    this.fieldHeight = 40,
    this.unselectedFieldDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.black,
    ),
    this.selectedFieldDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.blue,
    ),
    this.onComplete,
    this.onChanged,
    this.autofocus = true,
    this.textStyle = const TextStyle(fontSize: 16, color: Colors.black),
    this.hintStyle = const TextStyle(fontSize: 16, color: Colors.black),
    this.hintText = '_',
    this.cursorColor,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  // A zero-width space keeps every field non-empty, so the soft keyboard always
  // reports a backspace through onChanged — even on an already-empty box. iOS
  // swallows the backspace key on a truly-empty native field, which is why
  // deleting never stepped back to the previous box before.
  static const String _sentinel = '​';

  int selectedIndex = 0;
  late List<String?> otp;
  late List<FocusNode> focusNodes;
  late List<TextEditingController> textEditingControllers;

  @override
  void initState() {
    super.initState();
    otp = List.generate(widget.length, (index) => null);
    focusNodes = List.generate(widget.length, (index) => FocusNode());
    textEditingControllers = List.generate(
      widget.length,
      (index) => TextEditingController(text: _sentinel),
    );

    // Track the focused box for the selected decoration, and keep the caret
    // parked after the (possibly hidden) content. Registered once here so
    // rebuilds don't stack duplicate listeners.
    for (int i = 0; i < widget.length; i++) {
      final index = i;
      focusNodes[index].addListener(() {
        if (!mounted) return;
        if (focusNodes[index].hasFocus) {
          setState(() => selectedIndex = index);
          final text = textEditingControllers[index].text;
          textEditingControllers[index].selection =
              TextSelection.collapsed(offset: text.length);
        } else if (index == selectedIndex) {
          setState(() => selectedIndex = -1);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    for (var textEditingController in textEditingControllers) {
      textEditingController.dispose();
    }
    super.dispose();
  }

  String _currentOtp() => otp.where((element) => element != null).join('');

  // Writes a box's digit (or clears it) while re-seeding the sentinel and
  // parking the caret at the end — the single place that mutates field text.
  void _setField(int index, String? digit) {
    otp[index] = digit;
    final text = '$_sentinel${digit ?? ''}';
    textEditingControllers[index].value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Single handler for every keystroke. Typing a digit fills the box and steps
  /// forward; backspace clears the latest digit and steps back to the previous
  /// box — the mirror of typing — so editing feels symmetric both ways.
  void _onFieldChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      // Backspace. If this box was already empty, the deletion belongs to the
      // previous box (and focus follows it back); otherwise clear in place.
      final wasEmpty = otp[index] == null;
      _setField(index, null);
      if (wasEmpty && index > 0) {
        _setField(index - 1, null);
        focusNodes[index - 1].requestFocus();
      }
      setState(() {});
      widget.onChanged?.call(_currentOtp());
      return;
    }

    // Several digits arriving in one change — SMS autofill or a fast paste that
    // dumped the whole code into a single box — get spread across the boxes from
    // here forward. Replacing one filled box still arrives as two characters
    // (old + new), so keep that case in place instead of spilling into the next.
    if (digits.length > 1 && !(otp[index] != null && digits.length == 2)) {
      _fillFrom(index, digits);
      return;
    }

    // Keep the last digit typed so re-typing over a filled box replaces it.
    _setField(index, digits.characters.last);

    final otpString = _currentOtp();
    if (otpString.length == widget.length && int.tryParse(otpString) != null) {
      focusNodes[index].unfocus();
      widget.onComplete?.call(otpString);
    } else if (index + 1 < widget.length) {
      focusNodes[index + 1].requestFocus();
    }
    setState(() {});
    widget.onChanged?.call(otpString);
  }

  // Spreads a run of digits across the boxes starting at [start], then either
  // fires onComplete for a full code or parks focus on the next empty box.
  void _fillFrom(int start, String digits) {
    int box = start;
    for (int d = 0; d < digits.length && box < widget.length; d++, box++) {
      _setField(box, digits[d]);
    }

    final otpString = _currentOtp();
    if (otpString.length == widget.length && int.tryParse(otpString) != null) {
      focusNodes[widget.length - 1].unfocus();
      widget.onComplete?.call(otpString);
    } else {
      focusNodes[box < widget.length ? box : widget.length - 1].requestFocus();
    }
    setState(() {});
    widget.onChanged?.call(otpString);
  }

  Future<void> _handlePaste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;

    // Extract only digits and limit to the available fields.
    final String digits = data!.text!.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final String pasteText = digits.substring(
      0,
      math.min(digits.length, widget.length),
    );

    for (int i = 0; i < pasteText.length; i++) {
      _setField(i, pasteText[i]);
    }

    // Move focus to the next empty field or the last field.
    int nextIndex = pasteText.length;
    if (nextIndex >= widget.length) {
      nextIndex = widget.length - 1;
    }
    focusNodes[nextIndex].requestFocus();
    setState(() => selectedIndex = nextIndex);

    final String otpString = _currentOtp();
    if (otpString.length == widget.length && int.tryParse(otpString) != null) {
      widget.onComplete?.call(otpString);
    } else {
      widget.onChanged?.call(otpString);
    }
  }

  void _showPasteMenu(Offset globalPosition, BuildContext context) async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    showMenu(
      context: context,
      color: context.colorScheme.secondary,
      menuPadding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      position: RelativeRect.fromRect(
        globalPosition & const Size(0, 0),
        Offset.zero & overlay.size,
      ),
      shape: s.SmoothRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(11.r)),
        smoothness: 1,
      ),
      items: [
        PopupMenuItem(
          value: 'paste',
          child: Text(
            context.locale.languageCode == 'ar' ? 'لصق' : 'Paste',
            style: context.labelMedium,
          ),
        ),
      ],
    ).then((value) {
      if (value == 'paste') {
        _handlePaste();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: widget.spacing,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: [
        for (int i = 0; i < widget.length; i++)
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                curve: Curves.fastEaseInToSlowEaseOut,
                width: widget.fieldWidth,
                height: widget.fieldHeight,
                decoration: selectedIndex == i
                    ? widget.selectedFieldDecoration
                    : widget.unselectedFieldDecoration,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The sentinel is invisible, so render the placeholder
                    // ourselves while the box holds no digit.
                    if (otp[i] == null)
                      IgnorePointer(
                        child: Text(widget.hintText, style: widget.hintStyle),
                      ),
                    SizedBox(
                      width: widget.fieldWidth,
                      child: TextFormField(
                        controller: textEditingControllers[i],
                        cursorColor: widget.cursorColor,
                        enableInteractiveSelection: false,
                        contextMenuBuilder: null,
                        keyboardType: TextInputType.number,
                        key: Key(i.toString()),
                        autofocus: widget.autofocus && i == 0,
                        textAlign: TextAlign.center,
                        focusNode: focusNodes[i],
                        onChanged: (value) => _onFieldChanged(i, value),
                        style: widget.textStyle,
                        decoration: const InputDecoration.collapsed(
                          hintText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    focusNodes[i].requestFocus();
                  },
                  onLongPressStart: (details) {
                    _showPasteMenu(details.globalPosition, context);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
