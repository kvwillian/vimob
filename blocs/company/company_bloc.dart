import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/company_state.dart';
import 'package:http/http.dart' as http;

class CompanyBloc {
  Future<CompanyStatuses> fetchCompanyStatuses({String companyId}) async {
    var docs = await FirebaseFirestore.instance
        .collection("company-statuses")
        .where('company.id', isEqualTo: companyId)
        .get();

    var companyStatuses = CompanyStatuses()
      ..proposals = Map<String, CompanyStatusConfig>()
      ..units = Map<String, CompanyStatusConfig>();

    if (docs.docs[0].exists) {
      print("FIRESTORE: company-statuses");
      var doc = docs.docs[0].data;

      (doc()['proposals'] as Map<dynamic, dynamic>).forEach((key, value) {
        companyStatuses.proposals[key] = CompanyStatusConfig()
          ..color = _pickColor(color: value['color'])
          ..enUS = value['text']['en-US']
          ..ptBR = value['text']['pt-BR'];
      });

      (doc()['units'] as Map<dynamic, dynamic>).forEach((key, value) {
        companyStatuses.units[key] = CompanyStatusConfig()
          ..color = _pickColor(color: value['color'])
          ..enUS = value['text']['en-US']
          ..ptBR = value['text']['pt-BR'];
      });
    }
    return companyStatuses;
  }

  Color _pickColor({String color}) {
    return color != null
        ? Color(int.parse(color.replaceAll("#", "0xFF")))
        : Color(0xFF800000);
  }

  CompanyStatus getUnitStatus(String status) {
    return CompanyStatus()
      ..status = status
      ..color = CompanyState()
          .companyStatuses
          .units[status]
          .color
          .toString()
          .replaceAll('0xff', '#')
      ..text = I18n.translateUnitStatus(
        CompanyState().companyStatuses.units[status].ptBR,
      )
      ..available = _isUnitAvailable(status)
      ..data = null;
  }

  bool _isUnitAvailable(String status) {
    return status == 'available' || status == 'avaliation';
  }

  Future<String> fetchUrlMap(String companyId) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId)
          .get();

      String url;

      if (doc.exists) {
        print("FIRESTORE: company url");

        url = doc.data()['url'] ?? null;
      }
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> checkUrlMap({String userId, String devId, String urlMap}) async {
    if (userId != null && devId != null && urlMap != null && userId != '0') {
      var url =
          '$urlMap/vendas/espelhomapaapp.aspx?userId=$userId&devId=$devId&get=true';

      Response response;
      try {
        response = await http.get(url).timeout(Duration(milliseconds: 3500));
      } catch (e) {
        return false;
      }

      if (response != null && response?.statusCode == 200) {
        print(response.body);
        try {
          var jsonResponse = json.decode(response.body);
          return jsonResponse['temMapa'] ?? false;
        } catch (e) {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
