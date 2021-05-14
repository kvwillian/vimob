import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

///[TextInputType] default: [TextInputType.text].
///
///[Label] is required.
///
///[Icon] is required.
///
///[TextCapitalization] default: [TextCapitalization.none].
///
///[FieldIsValid] and [ErrorText] will show error or not ((fieldIsValid && errorText == null)).
///
///[ErrorText] default: "[Label] invalido".
class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({
    Key key,
    this.textInputType,
    @required this.label,
    this.icon,
    this.onChanged,
    this.onTap,
    this.fieldIsValid = true,
    this.componentKey,
    this.errorText,
    this.textCapitalization,
    this.helperText,
    this.controller,
    this.isEnabled,
    this.readOnly,
    this.inputFormatters,
    this.maxLines,
    this.verticalSize,
    this.maxLengthEnforced,
    this.maxLength,
  }) : super(key: key);

  final TextInputType textInputType;
  final String label;
  final String errorText;
  final String helperText;
  final Widget icon;
  final ValueChanged<String> onChanged;
  final Function onTap;
  final bool fieldIsValid;
  final bool isEnabled;
  final bool readOnly;
  final int maxLines;
  final Key componentKey;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final double verticalSize;
  final bool maxLengthEnforced;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Style.vertical(verticalSize ?? 8.3),
      child: TextField(
        key: componentKey,
        enabled: isEnabled ?? true,
        readOnly: readOnly ?? false,
        controller: controller ?? null,
        style: Style.inputText,
        maxLength: maxLength ?? null,
        maxLengthEnforced: maxLengthEnforced ?? true,
        maxLines: maxLines ?? 1,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        keyboardType: textInputType ?? TextInputType.text,
        decoration: InputDecoration(
            disabledBorder: InputBorder.none,
            errorText: (fieldIsValid && errorText == null)
                ? null
                : errorText ??
                    "$label ${I18n.of(context).invalid.toLowerCase()}",
            helperText: helperText ?? "",
            counterText: "",
            labelText: label,
            icon: icon ?? null),
        onChanged: onChanged,
        onTap: onTap,
        inputFormatters: inputFormatters ?? null,
      ),
    );
  }
}
