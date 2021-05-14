import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/style.dart';

class CompanyListDropDown extends StatefulWidget {
  CompanyListDropDown({
    Key key,
    this.value,
    this.items,
    this.label,
    this.onChange,
  })  : assert(items != null),
        super(key: key);

  final String value;
  final List<DropdownMenuItem> items;
  final String label;
  final Function onChange;

  _CompanyListDropDownState createState() => _CompanyListDropDownState();
}

class _CompanyListDropDownState extends State<CompanyListDropDown> {
  String value;

  @override
  void initState() {
    super.initState();
    value = widget.value ??
        widget.items
            .firstWhere((i) => i.value == AuthenticationState().user.company)
            .value;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticationState>(context).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.label}",
        ),
        SizedBox(
          width: Style.horizontal(70),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              key: Key("dropdown_button_companies"),
              style: Style.companyOptionText,
              value: value,
              items: widget.items,
              onChanged: widget.onChange ??
                  (val) async {
                    setState(() => value = val);
                    await CompanyState().fetchCompanyStatuses(companyId: value);

                    await AuthenticationState()
                        .updateSelectedCompany(user.companies[val]);
                    await CompanyState().fetchCompanyUrlMap(companyId: value);
                    await AuthenticationState().getUserPermissions();
                  },
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
