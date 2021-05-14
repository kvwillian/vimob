import 'package:flutter/material.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/style.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    Key key,
    this.passwordFocusNode,
    @required this.formStatus,
    @required this.onChanged,
    @required this.fieldIsValid,
    @required this.labelText,
    this.helperText,
    this.errorText,
    this.componentKey,
    this.controller,
  }) : super(key: key);

  final FocusNode passwordFocusNode;
  final FormStatus formStatus;
  final bool fieldIsValid;
  final String labelText;
  final String helperText;
  final String errorText;
  final Key componentKey;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  var passwordController = TextEditingController();
  bool isObscure = true;
  IconData passwordIcon;
  @override
  Widget build(BuildContext context) {
    if (isObscure) {
      passwordIcon = Icons.visibility;
    } else {
      passwordIcon = Icons.visibility_off;
    }

    return TextField(
      key: widget.componentKey,
      style: Style.inputText,
      controller: widget.controller ?? passwordController,
      enabled: !widget.formStatus.inProgress,
      keyboardType: TextInputType.text,
      autocorrect: false,
      focusNode: widget.passwordFocusNode,
      obscureText: isObscure,
      maxLines: 1,
      scrollPadding: EdgeInsets.zero,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText ?? null,
        errorText: widget.fieldIsValid ? null : widget.errorText ?? "",
        icon: Icon(Icons.lock,
            color: Style.inputIconColor, size: Style.inputIconSize),
        suffixIcon: GestureDetector(
          onTap: () {
            if (!widget.formStatus.inProgress) {
              setState(() {
                isObscure = !isObscure;
              });
            }
          },
          child: Icon(
            passwordIcon,
            key: Key("textfield_password_icon"),
            size: Theme.of(context).iconTheme.size,
          ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
