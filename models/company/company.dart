import 'package:flutter/material.dart';

class Company {
  int externalId;
  String id;
  String name;
  bool status;
  String urlMap;
  String permissionId;
}

class CompanyStatuses {
  Map<String, CompanyStatusConfig> proposals;
  Map<String, CompanyStatusConfig> units;
}

class CompanyStatusConfig {
  Color color;
  String enUS;
  String ptBR;
}
