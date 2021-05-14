import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/profile_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/invite/image_profile.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _nameController =
      TextEditingController(text: AuthenticationState().user.name ?? "");
  var _lastNameController =
      TextEditingController(text: AuthenticationState().user.lastName ?? "");
  var _emailController =
      TextEditingController(text: AuthenticationState().user.email ?? "");
  var _phoneController = MaskedTextController(
      text: AuthenticationState().user.phone ?? "",
      mask: InputValidationBloc()
          .updatePhoneMask(value: AuthenticationState().user.phone ?? ""));

  bool _isEditing = false;

  @override
  void initState() {
    ProfileState().profileForm.name = _nameController.text;
    ProfileState().profileForm.lastName = _lastNameController.text;
    ProfileState().profileForm.email = _emailController.text;
    ProfileState().profileForm.phoneValue = _phoneController.text;

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var profileState = Provider.of<ProfileState>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarResponsive().show(
          context: context,
          title: I18n.of(context).profile,
          actions: <Widget>[
            _isEditing
                ? _buildSendUpdateButton(profileState.profileForm)
                : _buildEditModeButton(),
          ]),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: Style.vertical(88),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        ImageProfile(
                          size: Style.horizontal(30),
                        ),
                        Positioned(
                          bottom: Style.horizontal(1),
                          right: Style.horizontal(1),
                          child: _buildIconCameraButton(context),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Style.horizontal(4.0)),
                    child: Column(
                      children: <Widget>[
                        //=========================== Name ===========================

                        TextFieldCustom(
                          componentKey: Key("name_textfield"),
                          icon: Icon(
                            Icons.person,
                            size: Style.mainTheme.iconTheme.size,
                          ),
                          isEnabled: _isEditing,
                          controller: _nameController,
                          label: I18n.of(context).name,
                          helperText: "",
                          fieldIsValid: profileState.profileForm.nameIsValid,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (String newValue) {
                            _nameController.value =
                                _nameController.value.copyWith(text: newValue);

                            profileState.handleNameValue(newValue: newValue);
                          },
                        ),
                        //===========================Last Name ===========================

                        TextFieldCustom(
                          componentKey: Key("last_name_textfield"),
                          icon: Icon(
                            Icons.person,
                            size: Style.mainTheme.iconTheme.size,
                          ),
                          isEnabled: _isEditing,
                          controller: _lastNameController,
                          label: I18n.of(context).lastName,
                          helperText: "",
                          fieldIsValid:
                              profileState.profileForm.lastNameIsValid,
                          textInputType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (String newValue) {
                            _lastNameController.value = _lastNameController
                                .value
                                .copyWith(text: newValue);
                            profileState.handleLastNameValue(
                                newValue: newValue);
                          },
                        ),
                        //=========================== Phone ===========================

                        TextFieldCustom(
                          componentKey: Key("phone_textfield"),
                          icon: Icon(
                            Icons.phone,
                            size: Style.mainTheme.iconTheme.size,
                          ),
                          isEnabled: _isEditing,
                          controller: _phoneController,
                          label: I18n.of(context).phone,
                          errorText: null,
                          helperText: "",
                          fieldIsValid: profileState.profileForm.phoneIsValid,
                          textInputType: TextInputType.number,
                          onChanged: (String newValue) {
                            _phoneController.value =
                                _phoneController.value.copyWith(text: newValue);

                            setState(() {
                              _phoneController.mask = InputValidationBloc()
                                  .updatePhoneMask(value: newValue);
                            });

                            profileState.handlePhoneValue(newValue: newValue);
                          },
                        ),
                        //=========================== Email ===========================

                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: Style.horizontal(80),
                              child: TextFieldCustom(
                                componentKey: Key("email_textfield"),
                                icon: Icon(
                                  Icons.email,
                                  size: Style.mainTheme.iconTheme.size,
                                ),
                                isEnabled: false,
                                controller: _emailController,
                                label: I18n.of(context).email,
                                errorText:
                                    profileState.profileForm.emailErrorText,
                                helperText: "",
                                fieldIsValid:
                                    profileState.profileForm.emailIsValid,
                                textInputType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                onChanged: (String newValue) {
                                  _emailController.value = _emailController
                                      .value
                                      .copyWith(text: newValue);
                                },
                              ),
                            ),
                            //=========================== Password ===========================

                            _isEditing
                                ? InkWell(
                                    key: Key("profile_edit_email_button"),
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (_) =>
                                              _buildDialog(context));
                                    },
                                    child: Text(I18n.of(context).edit),
                                  )
                                : Container(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: Style.horizontal(4.0)),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.lock),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: Style.horizontal(5)),
                                child: InkWell(
                                  key: Key("change_password_button"),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed("changePassword"),
                                  child: Text(
                                    I18n.of(context).changePassword,
                                    style: Style.textHighlightBold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Dialog _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: Style.horizontal(40),
        width: Style.horizontal(80),
        padding: EdgeInsets.only(top: Style.horizontal(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              I18n.of(context).attention,
              style: Style.titleSecondaryText,
            ),
            Center(
              child: Text(
                I18n.of(context).changeEmailWarning,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                        key: Key("change_email_dialog_back_button"),
                        onPressed: () => Navigator.pop(context),
                        child: Text(I18n.of(context).back)),
                  ),
                  Expanded(
                    child: FlatButton(
                        key: Key("change_email_dialog_button"),
                        onPressed: () =>
                            Navigator.pushNamed(context, 'changeEmail'),
                        child: Text("OK")),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildEditModeButton() {
    return Padding(
      padding: EdgeInsets.only(right: Style.horizontal(4)),
      child: InkWell(
        key: Key("profile_edit_mode_button"),
        onTap: () {
          setState(() {
            _isEditing = !_isEditing;
          });
        },
        child: Icon(
          Icons.edit,
          color: Style.mainTheme.appBarTheme.iconTheme.color,
        ),
      ),
    );
  }

  Padding _buildSendUpdateButton(FormStatus form) {
    return Padding(
      padding: EdgeInsets.only(right: Style.horizontal(4)),
      child: InkWell(
        key: Key("profile_send_update_button"),
        onTap: () async {
          //Check if have some connection
          if (ConnectivityState().hasInternet) {
            try {
              await ProfileState()
                  .updateUserInformation(user: AuthenticationState().user);

              setState(() {
                _isEditing = !_isEditing;
              });

              ShowSnackbar()
                  .showSnackbarSuccess(context, I18n.of(context).success);
            } catch (e) {
              ShowSnackbar().showSnackbarError(
                  context,
                  TranslateErrorMessages()
                      .translateError(context: context, error: e.toString()));
            }
          } else {
            //Reset form with old information
            _resetForm();
            ShowSnackbar()
                .showSnackbarError(context, I18n.of(context).checkConnection);
          }
        },
        child: Icon(
          Icons.check,
          color: Style.mainTheme.appBarTheme.iconTheme.color,
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _nameController.text = AuthenticationState().user.name ?? "";
      _lastNameController.text = AuthenticationState().user.lastName ?? "";
      _emailController.text = AuthenticationState().user.email ?? "";
      _phoneController.text = AuthenticationState().user.phone ?? "";
    });
  }

  InkWell _buildIconCameraButton(BuildContext context) {
    return InkWell(
      onTap: () async => _buildImageOptions(context),
      child: Icon(
        Icons.camera_alt,
        size: Style.mainTheme.iconTheme.size,
      ),
    );
  }

  Future _buildImageOptions(BuildContext context) async {
    {
      await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          height: Style.horizontal(30),
          child: Column(
            children: <Widget>[
              _buildImagePickerOption(
                text: I18n.of(context).camera,
                iconData: Icons.camera_alt,
                imageSource: ImageSource.camera,
              ),
              Divider(
                color: Colors.black,
              ),
              _buildImagePickerOption(
                text: I18n.of(context).gallery,
                iconData: Icons.photo_library,
                imageSource: ImageSource.gallery,
              )
            ],
          ),
        ),
      );
    }
  }

  Expanded _buildImagePickerOption(
      {String text, ImageSource imageSource, IconData iconData}) {
    return Expanded(
      child: Center(
        child: InkWell(
            onTap: () async {
              try {
                PickedFile pickedFile =
                    await ImagePicker().getImage(source: imageSource);
                File image = File(pickedFile.path);
                if (image != null) {
                  AuthenticationState().updateImageProfile(image: image);
                  ShowSnackbar()
                      .showSnackbarSuccess(context, I18n.of(context).success);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              } catch (e) {
                ShowSnackbar().showSnackbarError(
                    context,
                    TranslateErrorMessages()
                        .translateError(context: context, error: e));
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Padding(
                  padding: EdgeInsets.only(left: Style.horizontal(4.0)),
                  child: Text(text),
                ),
              ],
            )),
      ),
    );
  }
}
