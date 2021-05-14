import 'package:flutter/material.dart';
import 'package:vimob/blocs/company/company_bloc.dart';
import 'package:vimob/models/company/company.dart';

class CompanyState with ChangeNotifier {
  factory CompanyState() => instance;
  static var instance = CompanyState._internal();
  CompanyState._internal();

  CompanyStatuses companyStatuses = CompanyStatuses();
  String urlMap;

  fetchCompanyStatuses({String companyId}) async {
    companyStatuses =
        await CompanyBloc().fetchCompanyStatuses(companyId: companyId);

    notifyListeners();
  }

  fetchCompanyUrlMap({String companyId}) async {
    urlMap = await CompanyBloc().fetchUrlMap(companyId);

    notifyListeners();
  }
}
