import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/clients/client_list_tab.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/fab_menu.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';

enum BuyerAppBarMode { view, edit, create, createAndLink }

class BuyerPage extends StatefulWidget {
  BuyerPage({
    Key key,
    @required this.buyer,
    @required this.mode,
    this.proposal,
  }) : super(key: key);

  final Buyer buyer;
  final BuyerAppBarMode mode;
  final Proposal proposal;

  @override
  _BuyerPageState createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  FieldStatus _nameController = FieldStatus();
  FieldStatusMasked _cpfCnpjController = FieldStatusMasked();
  FieldStatus _emailController = FieldStatus();
  FieldStatusMasked _phoneController = FieldStatusMasked();
  FieldStatusMasked _zipCodeController = FieldStatusMasked();
  FieldStatus _streetController = FieldStatus();
  FieldStatus _numberController = FieldStatus();
  FieldStatus _complementController = FieldStatus();
  FieldStatus _neighborhoodController = FieldStatus();
  FieldStatus _cityController = FieldStatus();
  FieldStatus _stateController = FieldStatus();
  FieldStatus _noteController = FieldStatus();

  @override
  void initState() {
    super.initState();
    initializeFields();
  }

  @override
  void didChangeDependencies() {
    if (widget.mode == BuyerAppBarMode.view) {
      initializeFields();
    }
    super.didChangeDependencies();
  }

  void initializeFields() {
    Buyer buyer;
    if (widget.buyer != null) {
      buyer = BuyerState()
          .buyersList
          .value
          .firstWhere((element) => element.id == widget.buyer.id);
    } else {
      buyer = widget.buyer;
    }
    _nameController.controller = TextEditingController(text: buyer?.name ?? "");
    _cpfCnpjController.controller = MaskedTextController(
        mask: InputValidationBloc().applyMask(newValue: buyer?.cpf ?? ""),
        text: buyer?.cpf ?? "");
    _phoneController.controller = MaskedTextController(
        mask: InputValidationBloc().updatePhoneMask(value: buyer?.phone ?? ""),
        text: buyer?.phone ?? "");
    _emailController.controller =
        TextEditingController(text: buyer?.email ?? "");
    _zipCodeController.controller = MaskedTextController(
        mask: "00000-000", text: buyer?.address?.zipCode ?? "");
    _streetController.controller =
        TextEditingController(text: buyer?.address?.streetAddress ?? "");
    _numberController.controller =
        TextEditingController(text: buyer?.address?.number ?? "");
    _complementController.controller =
        TextEditingController(text: buyer?.address?.complement ?? "");
    _neighborhoodController.controller =
        TextEditingController(text: buyer?.address?.neighborhood ?? "");
    _cityController.controller =
        TextEditingController(text: buyer?.address?.city ?? "");
    _stateController.controller =
        TextEditingController(text: buyer?.address?.state ?? "");
    _noteController.controller = TextEditingController(text: buyer?.note ?? "");

    // _nameController.isValid = InputValidationBloc()
    //     .validateEmptyField(value: _nameController.controller.text);

    // _phoneController.isValid = InputValidationBloc()
    //     .validateEmptyField(value: _phoneController.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    var buyerState = Provider.of<BuyerState>(context);
    var proposalState = Provider.of<ProposalState>(context);
    var authenticationState = Provider.of<AuthenticationState>(context);

    return WillPopScope(
      onWillPop: () async {
        buyerState.isEditing = false;

        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: (widget.mode == BuyerAppBarMode.view &&
                widget.proposal?.status == 'inAttendance')
            ? _buildFabMenu()
            : null,
        appBar: _buildAppBar(
            buyerState: buyerState,
            authenticationState: authenticationState,
            proposalState: proposalState),
        body: Container(
          child: ListView(
            key: Key("buyer_page_list_view"),
            padding: EdgeInsets.all(Style.horizontal(4)),
            children: <Widget>[
              Text(
                I18n.of(context).personalData,
                style: Style.mainTheme.textTheme.headline6.copyWith(
                    color: Style.mainTheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              Divider(),
              //=========================================Name============================================
              TextFieldCustom(
                componentKey: Key("buyer_name_text_field"),
                controller: _nameController.controller,
                isEnabled: buyerState.isEditing,
                label: I18n.of(context).name,
                textCapitalization: TextCapitalization.words,
                errorText: _nameController.errorText,
                fieldIsValid: _nameController.isValid,
                onChanged: (String newValue) {
                  _nameController.controller.value =
                      _nameController.controller.value.copyWith(text: newValue);

                  setState(() {
                    _nameController.isValid = InputValidationBloc()
                        .validateEmptyField(value: newValue);
                  });
                },
              ),
              //=========================================cpf/cpnj============================================

              TextFieldCustom(
                componentKey: Key("buyer_cpf_cnpj_text_field"),
                controller: _cpfCnpjController.controller,
                isEnabled: buyerState.isEditing,
                label: "CPF/CNPJ",
                textInputType: TextInputType.number,
                errorText: _cpfCnpjController.errorText,
                fieldIsValid: _cpfCnpjController.isValid,
                helperText: _cpfCnpjController.infoText,
                onChanged: (String newValue) async {
                  await _validateCpfCnpj(newValue);
                },
              ),
              //=========================================Phone============================================
              TextFieldCustom(
                componentKey: Key("buyer_phone_text_field"),
                controller: _phoneController.controller,
                isEnabled: buyerState.isEditing,
                label: I18n.of(context).phone,
                errorText: _phoneController.errorText,
                textInputType: TextInputType.phone,
                fieldIsValid: _phoneController.isValid,
                onChanged: (String newValue) {
                  _phoneController.controller.mask =
                      InputValidationBloc().updatePhoneMask(value: newValue);
                  // _phoneController.controller.updateText(newValue);

                  // _phoneController.controller.updateMask(
                  //     InputValidationBloc().updatePhoneMask(value: newValue));
                  setState(() {
                    _phoneController.controller.value = _phoneController
                        .controller.value
                        .copyWith(text: newValue);

                    _phoneController.isValid = InputValidationBloc()
                        .validateEmptyField(value: newValue);
                  });
                },
              ),
              //=========================================email============================================
              TextFieldCustom(
                componentKey: Key("buyer_email_text_field"),
                controller: _emailController.controller,
                isEnabled: buyerState.isEditing,
                label: I18n.of(context).email,
                textInputType: TextInputType.emailAddress,
                errorText: _emailController.errorText,
                fieldIsValid: _emailController.isValid,
                onChanged: (String newValue) {
                  _emailController.controller.value = _emailController
                      .controller.value
                      .copyWith(text: newValue);

                  setState(() {
                    _emailController.isValid =
                        InputValidationBloc().validateEmail(email: newValue);
                  });
                },
              ),
              Text(
                I18n.of(context).address,
                style: Style.mainTheme.textTheme.headline6.copyWith(
                    color: Style.mainTheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              Divider(),
              //=========================================ZipCode============================================
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: Style.horizontal(4)),
                      child: TextFieldCustom(
                        componentKey: Key("buyer_zip_code_text_field"),
                        controller: _zipCodeController.controller,
                        isEnabled: buyerState.isEditing,
                        label: I18n.of(context).zipCode,
                        textInputType: TextInputType.number,
                        errorText: _zipCodeController.errorText,
                        helperText: _zipCodeController.infoText,
                        fieldIsValid: _zipCodeController.isValid,
                        onChanged: (String newValue) async {
                          _zipCodeController.controller.value =
                              _zipCodeController.controller.value
                                  .copyWith(text: newValue);

                          await _autoCompleteAddress(newValue);
                        },
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
              //=========================================Street============================================
              TextFieldCustom(
                componentKey: Key("buyer_street_text_field"),
                controller: _streetController.controller,
                isEnabled: buyerState.isEditing,
                label: I18n.of(context).street,
                textCapitalization: TextCapitalization.words,
                errorText: _streetController.errorText,
                fieldIsValid: _streetController.isValid,
                onChanged: (String newValue) {
                  _streetController.controller.value = _streetController
                      .controller.value
                      .copyWith(text: newValue);
                },
              ),
              Row(
                children: <Widget>[
                  //=========================================number============================================
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: Style.horizontal(4)),
                      child: TextFieldCustom(
                        componentKey: Key("buyer_number_text_field"),
                        controller: _numberController.controller,
                        isEnabled: buyerState.isEditing,
                        label: I18n.of(context).number,
                        textCapitalization: TextCapitalization.words,
                        textInputType: TextInputType.number,
                        errorText: _numberController.errorText,
                        fieldIsValid: _numberController.isValid,
                        onChanged: (String newValue) {
                          _numberController.controller.value = _numberController
                              .controller.value
                              .copyWith(text: newValue);
                        },
                      ),
                    ),
                  ),
                  //=========================================complement============================================
                  Expanded(
                    child: TextFieldCustom(
                      componentKey: Key("buyer_complement_text_field"),
                      controller: _complementController.controller,
                      isEnabled: buyerState.isEditing,
                      label: I18n.of(context).complement,
                      textCapitalization: TextCapitalization.words,
                      errorText: _complementController.errorText,
                      fieldIsValid: _complementController.isValid,
                      onChanged: (String newValue) {
                        _complementController.controller.value =
                            _complementController.controller.value
                                .copyWith(text: newValue);
                      },
                    ),
                  ),
                ],
              ),
              //=========================================neighborhood============================================
              TextFieldCustom(
                componentKey: Key("buyer_neighborhood_text_field"),
                controller: _neighborhoodController.controller,
                isEnabled: buyerState.isEditing,
                label: I18n.of(context).neighborhood,
                textCapitalization: TextCapitalization.words,
                errorText: _neighborhoodController.errorText,
                fieldIsValid: _neighborhoodController.isValid,
                onChanged: (String newValue) {
                  _neighborhoodController.controller.value =
                      _neighborhoodController.controller.value
                          .copyWith(text: newValue);
                },
              ),
              Row(
                children: <Widget>[
                  //=========================================city============================================
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: Style.horizontal(4)),
                      child: TextFieldCustom(
                        componentKey: Key("buyer_city_text_field"),
                        controller: _cityController.controller,
                        isEnabled: buyerState.isEditing,
                        label: I18n.of(context).city,
                        textCapitalization: TextCapitalization.words,
                        errorText: _cityController.errorText,
                        fieldIsValid: _cityController.isValid,
                        onChanged: (String newValue) {
                          _cityController.controller.value = _cityController
                              .controller.value
                              .copyWith(text: newValue);
                        },
                      ),
                    ),
                  ),
                  //=========================================state============================================
                  Expanded(
                    child: TextFieldCustom(
                      componentKey: Key("buyer_state_text_field"),
                      controller: _stateController.controller,
                      isEnabled: buyerState.isEditing,
                      label: I18n.of(context).state,
                      textCapitalization: TextCapitalization.words,
                      errorText: _stateController.errorText,
                      fieldIsValid: _stateController.isValid,
                      maxLength: 2,
                      maxLengthEnforced: true,
                      onChanged: (String newValue) {
                        _stateController.controller.value = _stateController
                            .controller.value
                            .copyWith(text: newValue.toUpperCase());
                      },
                    ),
                  ),
                ],
              ),
              //=========================================note============================================
              TextFieldCustom(
                componentKey: Key("buyer_note_text_field"),
                controller: _noteController.controller,
                isEnabled: buyerState.isEditing,
                label: I18n.of(context).note,
                textCapitalization: TextCapitalization.sentences,
                textInputType: TextInputType.multiline,
                errorText: _neighborhoodController.errorText,
                fieldIsValid: _neighborhoodController.isValid,
                maxLines: 5,
                verticalSize: 15,
                onChanged: (String newValue) {
                  _noteController.controller.value =
                      _noteController.controller.value.copyWith(text: newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==================================FAB Menu===================================

  FABMenu _buildFabMenu() {
    return FABMenu(
      componentKey: Key("fab_menu"),
      options: <FABMenuOptionProperties>[
        FABMenuOptionProperties(
          onTapKey: Key("fab_menu_change_client"),
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ClientListTab(
                          isListLinkBuyer: true,
                          proposal: widget.proposal,
                        )));
          },
          icon: Icon(
            Icons.repeat,
            color: Colors.black,
          ),
          text: Text(
            I18n.of(context).changeClient,
            style: Style.mainTheme.textTheme.bodyText2,
          ),
        ),
        FABMenuOptionProperties(
          onTapKey: Key("fab_menu_unlink_client"),
          onTap: () {
            ProposalState().unLinkBuyer(proposal: widget.proposal);
          },
          icon: Icon(
            Icons.link_off,
            color: Colors.black,
          ),
          text: Text(
            I18n.of(context).unLinkClient,
            style: Style.mainTheme.textTheme.bodyText2,
          ),
        ),
      ],
    );
  }

  //==================================Address auto-complete===================================

  Future _autoCompleteAddress(String newValue) async {
    if (newValue.length == 9) {
      setState(() {
        _zipCodeController.infoText = I18n.of(context).searchingAddress;
      });
      Address address = await InputValidationBloc().fetchCep(zipCode: newValue);
      if (address != null) {
        setState(() {
          _streetController.controller.value = _streetController
              .controller.value
              .copyWith(text: address.streetAddress);
          _numberController.controller.value =
              _numberController.controller.value.copyWith(text: address.number);
          _complementController.controller.value = _complementController
              .controller.value
              .copyWith(text: address.complement);
          _neighborhoodController.controller.value = _neighborhoodController
              .controller.value
              .copyWith(text: address.neighborhood);
          _cityController.controller.value =
              _cityController.controller.value.copyWith(text: address.city);
          _stateController.controller.value =
              _stateController.controller.value.copyWith(text: address.state);
          _zipCodeController.infoText = null;
        });
      }
    }
  }

  //==================================Validation===================================

  Future<void> _validateCpfCnpj(String newValue) async {
    _cpfCnpjController.controller.value =
        _cpfCnpjController.controller.value.copyWith(text: newValue);

    setState(() {
      _cpfCnpjController.isValid =
          InputValidationBloc().validateCpfCnpj(value: newValue);
      _cpfCnpjController.controller.mask =
          InputValidationBloc().applyMask(newValue: newValue);
      _cpfCnpjController.errorText = null;
    });

    if (newValue.length >= 14 &&
        _cpfCnpjController.isValid &&
        newValue != widget.buyer?.cpf) {
      setState(() {
        _cpfCnpjController.infoText = I18n.of(context).checkingAvailability;
      });
      bool _isValid = await InputValidationBloc().verifyBuyerExist(
          newValue,
          Provider.of<AuthenticationState>(context, listen: false)
              .user
              .company);
      setState(() {
        _cpfCnpjController.infoText = null;
        _cpfCnpjController.isValid = _isValid;

        if (!_isValid) {
          _cpfCnpjController.errorText = I18n.of(context).cpfCnpjAlreadyInUse;
        }
      });
    }
  }

  //==================================Edit===================================

  Future<void> _editBuyer(BuyerState buyerState, BuildContext context) async {
    setState(() {
      _nameController.isValid = InputValidationBloc()
          .validateEmptyField(value: _nameController.controller.text);
      _phoneController.controller.mask = InputValidationBloc()
          .updatePhoneMask(value: _phoneController.controller.text);
      _phoneController.isValid = InputValidationBloc()
          .validateEmptyField(value: _phoneController.controller.text);
    });
    await _validateCpfCnpj(_cpfCnpjController.controller.text);
    if (_nameController.isValid &&
        _cpfCnpjController.isValid &&
        _phoneController.isValid) {
      try {
        buyerState.updateBuyer(Buyer()
          ..address = (Address()
            ..city = _cityController.controller.text
            ..complement = _complementController.controller.text
            ..neighborhood = _neighborhoodController.controller.text
            ..number = _numberController.controller.text
            ..state = _stateController.controller.text
            ..streetAddress = _streetController.controller.text
            ..zipCode = _zipCodeController.controller.text)
          ..company = widget.buyer.company
          ..cpf = _cpfCnpjController.controller.text
          ..email = _emailController.controller.text
          ..externalId = widget.buyer.externalId
          ..id = widget.buyer.id
          ..isSynchronized = widget.buyer.isSynchronized
          ..name = _nameController.controller.text
          ..note = _noteController.controller.text
          ..phone = _phoneController.controller.text
          ..typePerson = widget.buyer.typePerson
          ..user = widget.buyer.user
          ..userExternalId = widget.buyer.userExternalId);
        ShowSnackbar().showSnackbarSuccess(context, I18n.of(context).success);
      } catch (e) {
        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).genericError);
      }
    } else {
      ShowSnackbar()
          .showSnackbarError(context, I18n.of(context).fieldsRequired);
    }
  }

  //==================================Create===================================

  Future<Buyer> _createBuyer(
      BuyerState buyerState, AuthenticationState authenticationState) async {
    if (_nameController.isValid &&
        _cpfCnpjController.isValid &&
        _phoneController.isValid) {
      try {
        var buyer = await buyerState.createBuyer(
          buyer: Buyer()
            ..address = (Address()
              ..city = _cityController.controller.text
              ..complement = _complementController.controller.text
              ..neighborhood = _neighborhoodController.controller.text
              ..number = _numberController.controller.text
              ..state = _stateController.controller.text
              ..streetAddress = _streetController.controller.text
              ..zipCode = _zipCodeController.controller.text)
            ..company = (Reference()
              ..id = authenticationState.user.company
              ..name = authenticationState.user.companyName)
            ..cpf = _cpfCnpjController.controller.text
            ..email = _emailController.controller.text
            ..externalId = null
            ..isSynchronized = false
            ..name = _nameController.controller.text
            ..note = _noteController.controller.text
            ..phone = _phoneController.controller.text
            ..typePerson =
                _cpfCnpjController.controller.text.length > 14 ? "J" : "F"
            ..user = authenticationState.user.uid
            ..userExternalId = authenticationState
                .user.companies[authenticationState.user.company].externalId,
          user: authenticationState.user,
        );
        buyerState.isEditing = false;
        Navigator.pop(context);
        ShowSnackbar().showSnackbarError(context, I18n.of(context).success);
        return buyer;
      } catch (e) {
        ShowSnackbar()
            .showSnackbarError(context, I18n.of(context).genericError);
        print(e);
      }
    } else {
      ShowSnackbar()
          .showSnackbarError(context, I18n.of(context).fieldsRequired);
    }
    return null;
  }

  //==================================AppBar===================================

  Widget _buildAppBar(
      {BuyerState buyerState,
      AuthenticationState authenticationState,
      ProposalState proposalState}) {
    switch (widget.mode) {
      case BuyerAppBarMode.edit:
        return AppBarResponsive().show(
            context: context,
            title: I18n.of(context).client,
            onBack: () {
              initializeFields();
              buyerState.isEditing = false;
              Navigator.pop(context);
            },
            actions: <Widget>[
              buyerState.isEditing
                  ? _buildActionsEditMode(buyerState, context)
                  : InkWell(
                      key: Key("open_edit_mode"),
                      onTap: () {
                        buyerState.isEditing = true;
                      },
                      child: Icon(
                        Icons.edit,
                        color: Style.mainTheme.appBarTheme.iconTheme.color,
                        size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
                      ),
                    ),
            ]);
        break;
      case BuyerAppBarMode.create:
        return AppBarResponsive().show(
            context: context,
            title: I18n.of(context).newClient,
            onBack: () {
              buyerState.isEditing = false;
              Navigator.pop(context);
            },
            actions: <Widget>[
              InkWell(
                key: Key("buyer_page_create"),
                onTap: () async {
                  //create buyer

                  setState(() {
                    _nameController.isValid = InputValidationBloc()
                        .validateEmptyField(
                            value: _nameController.controller.text);
                    _phoneController.controller.mask = InputValidationBloc()
                        .updatePhoneMask(
                            value: _phoneController.controller.text);
                    _phoneController.isValid = InputValidationBloc()
                        .validateEmptyField(
                            value: _phoneController.controller.text);
                  });
                  await _validateCpfCnpj(_cpfCnpjController.controller.text);

                  await _createBuyer(buyerState, authenticationState);
                },
                child: Icon(
                  Icons.check,
                  color: Style.mainTheme.appBarTheme.iconTheme.color,
                  size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
                ),
              ),
            ]);

        break;
      case BuyerAppBarMode.createAndLink:
        return AppBarResponsive().show(
            context: context,
            title: I18n.of(context).createAndLinkClient,
            onBack: () {
              buyerState.isEditing = false;
              Navigator.pop(context);
            },
            actions: <Widget>[
              InkWell(
                key: Key("buyer_page_create_and_link"),
                onTap: () async {
                  //create buyer

                  setState(() {
                    _nameController.isValid = InputValidationBloc()
                        .validateEmptyField(
                            value: _nameController.controller.text);
                    _phoneController.controller.mask = InputValidationBloc()
                        .updatePhoneMask(
                            value: _phoneController.controller.text);
                    _phoneController.isValid = InputValidationBloc()
                        .validateEmptyField(
                            value: _phoneController.controller.text);
                  });
                  await _validateCpfCnpj(_cpfCnpjController.controller.text);

                  var buyer =
                      await _createBuyer(buyerState, authenticationState);

                  await proposalState.linkBuyer(
                      proposal: widget.proposal, buyer: buyer);
                },
                child: Icon(
                  Icons.check,
                  color: Style.mainTheme.appBarTheme.iconTheme.color,
                  size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
                ),
              ),
            ]);

        break;
      default:
        return null;
    }
  }

  Row _buildActionsEditMode(BuyerState buyerState, BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: Style.horizontal(2)),
          child: InkWell(
            key: Key("editing_cancel"),
            onTap: () {
              initializeFields();
              buyerState.isEditing = false;
            },
            child: Icon(
              Icons.close,
              color: Style.mainTheme.appBarTheme.iconTheme.color,
              size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
            ),
          ),
        ),
        InkWell(
          key: Key("edit_buyer_button"),
          onTap: () {
            // setState(() {
            //   await _validateCpfCnpj(_cpfCnpjController.controller.text);
            //   _nameController.isValid = InputValidationBloc()
            //       .validateEmptyField(value: _nameController.controller.text);
            //   await _validateCpfCnpj(_cpfCnpjController.controller.text);
            //   _phoneController.controller.mask = InputValidationBloc()
            //       .updatePhoneMask(value: _phoneController.controller.text);
            //   _phoneController.isValid = InputValidationBloc()
            //       .validateEmptyField(value: _phoneController.controller.text);
            // });

            _editBuyer(buyerState, context);
          },
          child: Icon(
            Icons.check,
            color: Style.mainTheme.appBarTheme.iconTheme.color,
            size: Style.mainTheme.appBarTheme.actionsIconTheme.size,
          ),
        ),
      ],
    );
  }
}
