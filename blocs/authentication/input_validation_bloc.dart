import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/widgets.dart';
import 'package:search_cep/search_cep.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';

class InputValidationBloc with ChangeNotifier {
  bool validatePassword({@required String passwordValue}) {
    return (passwordValue != null &&
        passwordValue.isNotEmpty &&
        passwordValue.length >= 6);
  }

  bool comparePassword({String password = "", String repeat = ""}) {
    return (password.isNotEmpty && repeat.isNotEmpty && password == repeat);
  }

  bool validateCpfCnpj({@required String value}) {
    return (value != null &&
        value.isNotEmpty &&
        (CPFValidator.isValid(value) || CNPJValidator.isValid(value)));
  }

  bool validateEmptyField({@required String value}) {
    return (value != null && value.isNotEmpty);
  }

  String updatePhoneMask({@required String value}) {
    String mask = "(00) 0000-0000";
    if (value.length >= 14) {
      mask = "(00) 00000-0000";
    }
    return mask;
  }

  bool validateEmail({String email}) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (email.isNotEmpty && regex.hasMatch(email));
  }

  Future<String> verifyCpfUsed(String cpf) async {
    try {
      var cpfUsedDocs = await FirebaseFirestore.instance
          .collection("users")
          .where("cpf", isEqualTo: cpf)
          .get();
      print("FIRESTORE: verifyCpfUsed");

      if (cpfUsedDocs.docs.isNotEmpty) {
        return "CPF_ALREADY_IN_USE";
      } else {
        return null;
      }
    } catch (e) {
      return "CPF_ALREADY_IN_USE";
    }
  }

  Future<bool> verifyBuyerExist(String cpfCnpj, String companyId) async {
    try {
      var cpfCnpjUsedDocs = await FirebaseFirestore.instance
          .collection("buyers")
          .where("company.id", isEqualTo: companyId)
          .where("cpf", isEqualTo: cpfCnpj)
          .get();
      print("FIRESTORE: verifyBuyerExist");

      return cpfCnpjUsedDocs.docs.isEmpty;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> verifyEmailUsed(String email) async {
    try {
      var emailUsedDocs = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();
      print("FIRESTORE: verifyEmailUsed");

      if (emailUsedDocs.docs.isNotEmpty) {
        return "EMAIL_ALREADY_IN_USE";
      } else {
        return null;
      }
    } catch (e) {
      return "EMAIL_ALREADY_IN_USE";
    }
  }

  String applyMask({String newValue}) {
    String mask = "";
    String newValueFormated =
        newValue.replaceAll(".", "").replaceAll("/", "").replaceAll("-", "");

    if (newValueFormated.length > 11) {
      mask = '00.000.000/0000-00';
    } else {
      mask = '000.000.000-000';
    }
    return mask;
  }

  Future<Address> fetchCep({String zipCode}) async {
    var viaCep = new ViaCepSearchCep();

    final result =
        await viaCep.searchInfoByCep(cep: zipCode.replaceAll("-", ""));
    final cep = result.fold((_) => null, (data) => data);

    if (cep != null) {
      return Address()
        ..city = cep.localidade
        ..streetAddress = cep.logradouro
        ..neighborhood = cep.bairro
        ..complement = cep.complemento
        ..state = cep.uf;
    } else {
      return null;
    }
  }

  FieldStatus validateFirstDueDate(
    BuildContext context,
    FieldStatus firstDueDateController,
    Jiffy newDate,
  ) {
    firstDueDateController.isValid = true;
    firstDueDateController.errorText = null;

    if (newDate.isBefore(
        Jiffy(ProposalState().selectedProposal.date), Units.DAY)) {
      firstDueDateController.isValid = false;
      firstDueDateController.errorText =
          '${I18n.of(context).firstDueDateBeforeError} '
          '${ProposalState().selectedProposal.date.format('dd/MM/yyyy')}';
    } else {
      if ((PaymentState().selectedSeries.fixedDay != null &&
              PaymentState().selectedSeries.fixedDay != 0) &&
          (PaymentState().selectedSeries.settings.fixedDay == null ||
              PaymentState().selectedSeries.settings.fixedDay == false)) {
        int dueDateFixedDay = newDate.date;
        int endOfMonth =
            Jiffy(ProposalState().selectedProposal.date).endOf(Units.MONTH).day;

        if (dueDateFixedDay != PaymentState().selectedSeries.fixedDay) {
          // Checks if fixedDay is any of 31, 30, 29, but the month has less total days
          if (PaymentState().selectedSeries.fixedDay >= endOfMonth) {
            if (dueDateFixedDay != endOfMonth) {
              firstDueDateController.isValid = false;
              firstDueDateController.errorText =
                  '${I18n.of(context).firstDueDateFixedDayError} $endOfMonth';
            }
          } else {
            firstDueDateController.isValid = false;
            firstDueDateController.errorText =
                '${I18n.of(context).firstDueDateFixedDayError} '
                '${PaymentState().selectedSeries.fixedDay}';
          }
        }
      }
    }

    if (PaymentState().selectedSeries.settings.startDate == null ||
        PaymentState().selectedSeries.settings.startDate == false) {
      switch (PaymentState().selectedSeries.dueDate.type) {
        case DueTypes.daysToStart:
          if (newDate.isAfter(
              PaymentState().selectedSeries.dueDate.date, Units.DAY)) {
            firstDueDateController.isValid = false;
            firstDueDateController.errorText =
                '${I18n.of(context).firstDueDateAfterError}';
          }
          break;
        case DueTypes.startWithUpfront:
        case DueTypes.startAfterUpfront:
        case DueTypes.monthsAfterProposal:
        case DueTypes.monthsAfterConstruction:
          if (newDate.isAfter(
              PaymentState().selectedSeries.dueDate.date, Units.MONTH)) {
            firstDueDateController.isValid = false;
            firstDueDateController.errorText =
                '${I18n.of(context).firstDueDateAfterError}';
          }
          break;
      }
    }

    return firstDueDateController;
  }

  FieldStatus validateNumberOfPayments(
    BuildContext context,
    FieldStatus numberOfPaymentsController,
  ) {
    numberOfPaymentsController.errorText = null;
    numberOfPaymentsController.isValid = true;

    num numberOfPayments =
        num.tryParse(numberOfPaymentsController.controller.text)?.toInt() ?? 0;

    if (numberOfPayments > 0) {
      if (!PaymentState().selectedSeries.settings.numberOfPayments) {
        // Enforce the numberOfPayments even if a series is split
        int overallNumberOfPayments = PaymentState().modifiedPaymentSeries.fold(
              0,
              (acc, series) => series.type == PaymentState().selectedSeries.type
                  ? acc + series.numberOfPayments
                  : acc,
            );

        if (numberOfPayments > PaymentState().selectedSeries.numberOfPayments ||
            overallNumberOfPayments >
                PaymentState().selectedSeries.numberOfPayments) {
          numberOfPaymentsController.errorText =
              '${I18n.of(context).numberOfPaymentsExceededError} '
              '${PaymentState().selectedSeries.numberOfPayments}';
          numberOfPaymentsController.isValid = false;
        }
      }
    } else {
      numberOfPaymentsController.errorText =
          I18n.of(context).numberOfPaymentsZeroError;
      numberOfPaymentsController.isValid = false;
    }

    return numberOfPaymentsController;
  }
}
