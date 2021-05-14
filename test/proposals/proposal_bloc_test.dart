import 'package:flutter_test/flutter_test.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/models/proposal/proposal.dart';

void main() {
  group("Propoasl bloc |", () {
    List<Proposal> proposals = [
      Proposal()..status = 'avaliation',
      Proposal()..status = 'avaliation',
      Proposal()..status = 'locked',
      Proposal()..status = 'inattendance',
      Proposal()..status = 'inattendance',
      Proposal()..status = 'inattendance',
      Proposal()..status = 'approved',
      Proposal()..status = 'approved',
      Proposal()..status = 'approved',
      Proposal()..status = 'disapproved',
    ];
    List<Proposal> proposalsUnsorted = [
      Proposal()..status = 'avaliation',
      Proposal()..status = 'avaliation',
      Proposal()..status = 'locked',
      Proposal()..status = 'inAttendance',
      Proposal()..status = 'inAttendance',
      Proposal()..status = 'inAttendance',
      Proposal()..status = 'approved',
      Proposal()..status = 'approved',
      Proposal()..status = 'approved',
      Proposal()..status = 'disapproved',
    ];
    Map<String, String> statusAvailable = {
      'avaliation': "Avaliation",
      'locked': "Locked",
      'inAttendance': "InAttendance",
      'approved': "Approved",
      'disapproved': "Disapproved",
      'expired': "Expired",
    };

    test("Should initialize filter", () {
      Map<String, StatusFilter> statusFilter = ProposalBloc()
          .initProposalFilters(
              proposals: proposals, statusAvailable: statusAvailable);

      expect(statusFilter["avaliation"].amount, 2);
      expect(statusFilter["avaliation"].selected, true);
      expect(statusFilter["avaliation"].status, "Avaliation");
      expect(statusFilter["locked"].amount, 1);
      expect(statusFilter["locked"].selected, true);
      expect(statusFilter["locked"].status, "Locked");
      expect(statusFilter["inattendance"].amount, 3);
      expect(statusFilter["inattendance"].selected, true);
      expect(statusFilter["inattendance"].status, "InAttendance");
      expect(statusFilter["approved"].amount, 3);
      expect(statusFilter["approved"].selected, true);
      expect(statusFilter["approved"].status, "Approved");
      expect(statusFilter["disapproved"].amount, 1);
      expect(statusFilter["disapproved"].selected, true);
      expect(statusFilter["disapproved"].status, "Disapproved");
      expect(statusFilter["expired"].amount, 0);
      expect(statusFilter["expired"].selected, false);
      expect(statusFilter["expired"].status, "Expired");
    });

    test("Should sort proposals", () {
      List<Proposal> sortedList =
          ProposalBloc().sortProposals(proposalsUnsorted);

      List<Proposal> expectedList = [
        Proposal()..status = 'inAttendance',
        Proposal()..status = 'inAttendance',
        Proposal()..status = 'inAttendance',
        Proposal()..status = 'avaliation',
        Proposal()..status = 'avaliation',
        Proposal()..status = 'locked',
        Proposal()..status = 'approved',
        Proposal()..status = 'approved',
        Proposal()..status = 'approved',
        Proposal()..status = 'disapproved',
      ];

      expect(sortedList[0].status, expectedList[0].status);
      expect(sortedList[3].status, expectedList[3].status);
    });

    test("Should filter by avaliation", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = true,
        'locked': StatusFilter()..selected = false,
        'inattendance': StatusFilter()..selected = false,
        'approved': StatusFilter()..selected = false,
        'disapproved': StatusFilter()..selected = false,
        'expired': StatusFilter()..selected = false,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 2);
    });

    test("Should filter by locked", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = false,
        'locked': StatusFilter()..selected = true,
        'inattendance': StatusFilter()..selected = false,
        'approved': StatusFilter()..selected = false,
        'disapproved': StatusFilter()..selected = false,
        'expired': StatusFilter()..selected = false,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 1);
    });

    test("Should filter by inattendance", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = false,
        'locked': StatusFilter()..selected = false,
        'inattendance': StatusFilter()..selected = true,
        'approved': StatusFilter()..selected = false,
        'disapproved': StatusFilter()..selected = false,
        'expired': StatusFilter()..selected = false,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 3);
    });

    test("Should filter by approved", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = false,
        'locked': StatusFilter()..selected = false,
        'inattendance': StatusFilter()..selected = false,
        'approved': StatusFilter()..selected = true,
        'disapproved': StatusFilter()..selected = false,
        'expired': StatusFilter()..selected = false,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 3);
    });

    test("Should filter by disapproved", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = false,
        'locked': StatusFilter()..selected = false,
        'inattendance': StatusFilter()..selected = false,
        'approved': StatusFilter()..selected = false,
        'disapproved': StatusFilter()..selected = true,
        'expired': StatusFilter()..selected = false,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 1);
    });

    test("Should filter by expired", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = false,
        'locked': StatusFilter()..selected = false,
        'inattendance': StatusFilter()..selected = false,
        'approved': StatusFilter()..selected = false,
        'disapproved': StatusFilter()..selected = false,
        'expired': StatusFilter()..selected = true,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 0);
    });
    test("Should filter by disapproved and approved", () {
      Map<String, StatusFilter> filterStatus = {
        'avaliation': StatusFilter()..selected = false,
        'locked': StatusFilter()..selected = false,
        'inattendance': StatusFilter()..selected = false,
        'approved': StatusFilter()..selected = true,
        'disapproved': StatusFilter()..selected = true,
        'expired': StatusFilter()..selected = false,
      };

      var filteredList = ProposalBloc()
          .filterProposals(filterStatus: filterStatus, proposals: proposals);

      expect(filteredList.length, 4);
    });
  });
}
