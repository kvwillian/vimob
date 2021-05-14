import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';

class TranslateErrorMessages {
  String translateError({String error, BuildContext context}) {
    if (error == null) {
      return I18n.of(context).genericError;
    } else {
      error = error.replaceAll("Exception: ", "");

      switch (error) {
        case "ERROR_EMAIL_CONFIRMATION":
          return I18n.of(context).errorEmailConfimation;

          break;
        case "ERROR_WRONG_PASSWORD":
          return I18n.of(context).wrongPassword;

          break;
        case "ERROR_USER_DISABLED":
          return I18n.of(context).userDisabled;

          break;
        case "ERROR_USER_NOT_FOUND":
          return I18n.of(context).userNotFound;

          break;

        case "CODE_NOT_EXIST":
          return I18n.of(context).codeNotExist;

          break;
        case "INVALID_CODE":
          return I18n.of(context).invalidCode;

          break;
        case "CODE_ALREADY_USED":
          return I18n.of(context).codeAlreadyUsed;

          break;
        case "CODE_ALREADY_USED_SALES_COMPANY":
          return I18n.of(context).codeAlreadyUsedSalesCompany;

          break;
        case "FIELDS_REQUIRED":
          return I18n.of(context).fieldsRequired;

          break;
        case "ERROR_INVALID_EMAIL":
          return I18n.of(context).invalidEmail;

          break;

        case "ERROR_REQUIRES_RECENT_LOGIN":
          return I18n.of(context).genericError;

          break;
        case "ERROR_WEAK_PASSWORD":
          return I18n.of(context).weakPassword;

          break;
        case "ERROR_TOO_MANY_REQUESTS":
          return I18n.of(context).genericError;

          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          return I18n.of(context).genericError;

          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          return I18n.of(context).emailAlreadyInUse;

          break;

        default:
          return I18n.of(context).genericError;
          break;
      }
    }
  }

  String translateEmailError({String error, BuildContext context}) {
    if (error == null) {
      return null;
    } else {
      switch (error) {
        case "EMAIL_ALREADY_IN_USE":
          return I18n.of(context).emailAlreadyInUse;
          break;
        default:
          return "E-mail ${I18n.of(context).invalid.toLowerCase()}";
          break;
      }
    }
  }

  String translateCpfError({String error, BuildContext context}) {
    switch (error) {
      case "CPF_ALREADY_IN_USE":
        return I18n.of(context).cpfAlreadyInUse;
        break;
      case "CPF_INVALID":
        return "CPF ${I18n.of(context).invalid.toLowerCase()}";
        break;
      default:
        return "";
        break;
    }
  }
}
