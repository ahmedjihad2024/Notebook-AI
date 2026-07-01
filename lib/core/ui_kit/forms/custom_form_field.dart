import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';

// `intl` (re-exported by easy_localization) ships its own TextDirection, which
// would shadow Flutter's; hide it so TextDirection means dart:ui's here.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:for_u/app/extensions/extensions.dart';
import 'package:nice_text_form/nice_text_form.dart';
import '../../utils/mixins/after_layout.dart';

class SecurityController {
  late Function() _refresher;
  bool isSecure = true;

  void _setRefresher(Function() refresher) {
    _refresher = refresher;
  }

  void hideText() {
    if (!isSecure) {
      isSecure = true;
      _refresher();
    }
  }

  void showText() {
    if (isSecure) {
      isSecure = false;
      _refresher();
    }
  }
}

class NiceTextForm extends StatefulWidget {
  final SecurityController? controller;
  final double? width;
  final double? height;
  final String? initialSelectionFlag;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? validatorStyle;
  final String hintText;
  final TextInputType? keyboardType;
  final TextEditingController? textEditingController;
  final void Function(CountryCode countryCode)? countryCode;
  final int? textLength;
  final bool isPhoneForm;
  final EdgeInsetsGeometry? padding;
  final Widget Function(bool isSecure)? sufixWidget;
  final Widget? prefixWidget;
  final FocusNode? focusNode;
  final String? Function(String)? validator;
  final bool? obscureText;
  final Future<Widget?> Function(String text, void Function() hide)?
  searchResultsBuilder;
  final bool showSearchResultsTop;
  final Offset searchResultsOffset;
  final Widget? label;
  final Decoration? boxDecoration;
  final Decoration? activeBoxDecoration;
  final int maxLines;
  final BoxConstraints? boxConstraints;
  final Function(String)? onTextChanged;
  final AlignmentDirectional alignment;
  final bool showCountryCode;
  final TextInputAction? textInputAction;
  final Color? cursorColor;
  final void Function(String)? onFieldSubmitted;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextDirection? textDirection;

  /// Runs [customValidators] on every change when true.
  final bool enableCustomValidation;

  /// Extra validators invoked on each text change (for side effects/feedback).
  final List<Function(String)?>? customValidators;

  const NiceTextForm({
    super.key,
    this.height,
    required this.hintText,
    this.width,
    this.initialSelectionFlag,
    this.textStyle,
    this.hintStyle,
    this.countryCode,
    this.textEditingController,
    this.keyboardType,
    this.textLength,
    this.isPhoneForm = false,
    this.padding,
    this.sufixWidget,
    this.focusNode,
    this.validator,
    this.validatorStyle,
    this.textInputAction,
    this.obscureText,
    this.label,
    this.boxDecoration,
    this.activeBoxDecoration,
    this.prefixWidget,
    this.boxConstraints,
    this.searchResultsBuilder,
    this.showSearchResultsTop = false,
    this.searchResultsOffset = const Offset(0, 0),
    this.maxLines = 1,
    this.onTextChanged,
    this.alignment = AlignmentDirectional.center,
    this.controller,
    this.showCountryCode = false,
    this.cursorColor,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.enableCustomValidation = false,
    this.customValidators,
  });

  @override
  State<NiceTextForm> createState() => _NiceTextFormState();
}

class _NiceTextFormState extends State<NiceTextForm> with AfterLayout {
  String? errorMessage;
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();
  Widget? _searchWidget;
  late LayerLink _layerLink;
  CancelableOperation<Widget?>? _cancelabelOperation;
  bool focused = false;
  late FocusNode focusNode;
  String? selectedCountryCode;

  @override
  void initState() {
    _layerLink = LayerLink();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(focusListener);

    super.initState();
  }

  @override
  void dispose() {
    if (_overlayPortalController.isShowing) _overlayPortalController.hide();
    focusNode.removeListener(focusListener);

    super.dispose();
  }

  void focusListener() {
    setState(() {
      if (focusNode.hasFocus) {
        focused = true;
      } else {
        focused = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.controller?._setRefresher(() {
      // keep focus on the field when text visibility toggles
      focusNode.requestFocus();
      focused = true;
      setState(() {});
    });

    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: _buildSearchOverlay,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLabel(),
            _buildField(context),
            if (errorMessage != null) _buildError(),
          ],
        ),
      ),
    );
  }

  /// The floating search-results panel anchored to the field.
  Widget _buildSearchOverlay(BuildContext context) {
    return Positioned(
      right: 0,
      child: CompositedTransformFollower(
        offset: Offset(
          widget.searchResultsOffset.dx,
          widget.searchResultsOffset.dy,
        ),
        targetAnchor: widget.showSearchResultsTop
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        followerAnchor: widget.showSearchResultsTop
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        link: _layerLink,
        child: _searchWidget ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.label != null) widget.label! else const SizedBox.shrink(),
      ],
    );
  }

  /// The bordered box: optional country code, prefix, input and suffix.
  Widget _buildField(BuildContext context) {
    return IntrinsicHeight(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        width: widget.width,
        padding: widget.padding,
        alignment: widget.alignment,
        constraints: widget.boxConstraints,
        decoration:
            (focused && widget.activeBoxDecoration != null && !widget.readOnly)
            ? widget.activeBoxDecoration
            : widget.boxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isPhoneForm) ..._buildCountryCodePrefix(context),
            if (widget.prefixWidget != null) ...[
              widget.prefixWidget!,
              kIsWeb || !Platform.isWindows
                  ? 6.horizontalSpace
                  : const SizedBox(width: 5),
            ],
            if (selectedCountryCode != null && widget.showCountryCode) ...[
              Text(
                selectedCountryCode!,
                style: widget.hintStyle?.copyWith(height: 1),
              ),
              kIsWeb || !Platform.isWindows
                  ? 7.horizontalSpace
                  : const SizedBox(width: 4),
            ],
            _buildInput(),
            if (widget.sufixWidget != null) ...[
              kIsWeb || !Platform.isWindows
                  ? const SizedBox(width: 5)
                  : 6.horizontalSpace,
              widget.sufixWidget!(
                widget.obscureText ?? widget.controller?.isSecure ?? false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Country flag picker + dropdown chevron, shown when [isPhoneForm].
  List<Widget> _buildCountryCodePrefix(BuildContext context) {
    return [
      CountryCodeButton(
        initialSelection: widget.initialSelectionFlag ?? "EG",
        localization: context.deviceLocale,
        padding: EdgeInsets.zero,
        width: 25.w,
        height: 25.w,
        dialogWidth: .9 * 1.sw,
        dialogHeight: .8 * 1.sh,
        borderRadius: BorderRadius.circular(7.r),
        onSelectionChange: (countryCode) {
          setState(() => selectedCountryCode = countryCode.dialCode);
          widget.countryCode?.call(countryCode);
        },
        searchFormBuilder: (textController) =>
            _buildCountrySearchField(context, textController),
      ),
      kIsWeb || !Platform.isWindows
          ? 3.horizontalSpace
          : const SizedBox(width: 3),
      Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 30.sp,
        color: Colors.black.withOpacity(.3),
      ),
    ];
  }

  /// The search field shown inside the country-picker dialog.
  Widget _buildCountrySearchField(
    BuildContext context,
    TextEditingController textController,
  ) {
    return Material(
      color: Colors.transparent,
      child: NiceTextForm(
        height: 50.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        boxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.black.withOpacity(.03),
        ),
        hintText: "search",
        textEditingController: textController,
        hintStyle: context.titleSmall.copyWith(
          color: Colors.black.withOpacity(.5),
          fontSize: 18.sp,
        ),
        textStyle: context.titleSmall.copyWith(
          color: Colors.black,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Expanded(
      child: TextFormField(
        readOnly: widget.readOnly,
        style: widget.textStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        focusNode: focusNode,
        cursorColor: widget.cursorColor,
        textInputAction: widget.textInputAction,
        controller: widget.textEditingController,
        onFieldSubmitted: widget.onFieldSubmitted,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText ?? widget.controller?.isSecure ?? false,
        maxLines: widget.maxLines,
        minLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.textLength),
          ...widget.inputFormatters ?? [],
        ],
        onTapOutside: (_) {
          if (widget.readOnly) return;
          hideSearchWidget();
        },
        onTap: () {
          if (widget.readOnly) return;
          setState(() => focused = true);
          if (!_overlayPortalController.isShowing && _searchWidget != null) {
            _overlayPortalController.show();
          }
        },
        decoration: InputDecoration.collapsed(
          border: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
        ),
        onChanged: _onChanged,
      ),
    );
  }

  Future<void> _onChanged(String value) async {
    widget.onTextChanged?.call(value);

    if (widget.enableCustomValidation && widget.customValidators != null) {
      for (var validator in widget.customValidators!) {
        validator?.call(value);
      }
    }

    _cancelabelOperation?.cancel();
    if (widget.searchResultsBuilder != null) {
      _cancelabelOperation = CancelableOperation.fromFuture(
        widget.searchResultsBuilder!(value, hideSearchWidget),
        onCancel: () => null,
      );
      _searchWidget = await _cancelabelOperation?.value;
      handleShowingSearchWidget();
    }

    final msg = widget.validator?.call(value);
    if (msg != null) {
      setState(() => errorMessage = msg);
    } else if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }

  Widget _buildError() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 6.w, start: 20.w),
      child: Row(
        spacing: 5.w,
        children: [Text(errorMessage!, style: widget.validatorStyle)],
      ),
    );
  }

  @override
  Future<void> afterLayout(BuildContext context) async {
    // _searchWidget = await widget.searchResultsBuilder?.call(_value);
    // handleShowingSearchWidget();
  }

  void handleShowingSearchWidget() {
    if (_searchWidget == null && _overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }
    if (_searchWidget != null) {
      _overlayPortalController.show();
    }
  }

  void hideSearchWidget() {
    if (_overlayPortalController.isShowing) {
      _overlayPortalController.hide();
    }
  }
}
