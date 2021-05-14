import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/style.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';

class CpfTextField extends StatefulWidget {
  CpfTextField(
      {Key key,
      this.onEditingComplete,
      this.formStatus,
      this.onChanged,
      this.helperText})
      : super(key: key);

  final VoidCallback onEditingComplete;
  final FormStatus formStatus;
  final String helperText;
  final ValueChanged<String> onChanged;

  @override
  _CpfTextFieldState createState() => _CpfTextFieldState();
}

class _CpfTextFieldState extends State<CpfTextField> {
  final userController = MaskedTextController(mask: '000.000.000-00');

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key("textfield_cpf"),
      style: Style.inputText,
      controller: userController,
      enabled: !widget.formStatus.inProgress,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        errorText: (widget.formStatus.cpfIsValid &&
                widget.formStatus.cpfErrorText == null)
            ? null
            : TranslateErrorMessages().translateCpfError(
                error: widget.formStatus.cpfErrorText, context: context),
        helperText: widget.helperText ?? "",
        counterText: "",
        labelText: "CPF",
        icon: SvgPicture.asset(
          "assets/login/cpf_card.svg",
          width: Style.inputIconSize,
        ),
      ),
      onEditingComplete: widget.onEditingComplete,
      maxLength: 14,
      onChanged: widget.onChanged,
    );
  }
}
