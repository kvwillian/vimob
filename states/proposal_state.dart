import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:rxdart/subjects.dart';
import 'package:jiffy/jiffy.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/models/proposal/history.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/company_state.dart';

class ProposalState with ChangeNotifier {
  factory ProposalState() => instance;
  ProposalState._internal();
  static var instance = ProposalState._internal();

  var currentProposals = BehaviorSubject<List<Proposal>>();

  var proposalLogs = BehaviorSubject<List<History>>();

  var proposalAttachments = BehaviorSubject<List<Attachment>>();

  var _proposals = List<Proposal>();

  var _deviceLocale;

  String get deveiceLocale => _deviceLocale;

  set deveiceLocale(String deveiceLocale) {
    _deviceLocale = deveiceLocale;
  }

  StreamSubscription _listener;
  StreamSubscription _listenerProposalLogs;
  StreamSubscription _listenerAttachments;
  StreamSubscription _listenerAttachmentUpload;
  storage.TaskState attachmentUploadTask;

  var filterStatus = Map<String, StatusFilter>();

  Jiffy proposalDate;
  Development selectedDevelopment = Development();
  Block selectedBlock = Block();
  Unit selectedUnit = Unit();
  PaymentPlan selectedPaymentPlan = PaymentPlan();
  Proposal selectedProposal = Proposal();

  fetchPropsalsList({String companyId, String uid}) async {
    if (_listener != null) {
      currentProposals.add([]);
      await _listener.cancel();
    }
    _listener = ProposalBloc()
        .fetchProposals(companyId: companyId, uid: uid)
        .listen((proposalsStream) {
      currentProposals.add(proposalsStream);

      _proposals = currentProposals.value;

      initFilterStatus();

      filterProposals(filterStatus: filterStatus);

      notifyListeners();
    });
  }

  fetchProposalLogs({String proposalId}) async {
    if (_listenerProposalLogs != null) {
      proposalLogs.add([]);
      await _listenerProposalLogs.cancel();
    }

    _listenerProposalLogs = ProposalBloc()
        .fetchProposalLogs(proposalId: proposalId)
        .listen((historyList) {
      proposalLogs.add(historyList);
      notifyListeners();
    });
  }

  initFilterStatus() {
    var avaialableStatusList = ProposalBloc().initAvailableStatusList(
        CompanyState().companyStatuses.proposals, deveiceLocale);

    filterStatus = ProposalBloc().initProposalFilters(
        proposals: currentProposals.value,
        statusAvailable: avaialableStatusList);
  }

  filterProposals({Map<String, StatusFilter> filterStatus}) {
    var filteredList = ProposalBloc()
        .filterProposals(filterStatus: filterStatus, proposals: _proposals);

    currentProposals.add(filteredList);
    notifyListeners();
  }

  updateFilterStatus({String key, bool selected}) {
    filterStatus[key].selected = selected;
    notifyListeners();
  }

  cleanFilter() {
    var avaialableStatusList = ProposalBloc().initAvailableStatusList(
        CompanyState().companyStatuses.proposals, deveiceLocale);

    filterStatus = ProposalBloc().initProposalFilters(
        proposals: _proposals, statusAvailable: avaialableStatusList);

    currentProposals.add(_proposals);
    notifyListeners();
  }

  fetchAttachment({String proposalId, double deviceWidth}) async {
    if (_listenerAttachments != null) {
      proposalAttachments.add([]);
      await _listenerAttachments.cancel();
    }

    _listenerAttachments = ProposalBloc()
        .fecthAttachments(proposalId: proposalId, deviceWidth: deviceWidth)
        .listen((attachmentList) {
      proposalAttachments.add(attachmentList);
      notifyListeners();
    });
  }

  Future<void> uploadAttachment(
      {String proposalId, File doc, bool abbreviate}) async {
    if (_listenerAttachmentUpload != null) {
      await _listenerAttachmentUpload.cancel();
    }

    _listenerAttachmentUpload = ProposalBloc()
        .uploadAttachment(proposalId: proposalId, doc: doc)
        .snapshotEvents
        .listen((task) async {
      print(task.state);
      attachmentUploadTask = task.state;
      notifyListeners();
      if (task.state == storage.TaskState.success) {
        var attachment = ProposalBloc().mountAttachment(
            doc: doc,
            src: await task.ref.getDownloadURL(),
            type: task.metadata.contentType,
            abbreviate: abbreviate);

        ProposalBloc().addAttachmentToProposal(
            proposalId: proposalId, attachment: attachment);

        print("Success");
        notifyListeners();
      }
    });
  }

  Future<void> removeAttachment(
      {String proposalId, Attachment attachment}) async {
    await ProposalBloc()
        .removeAttachment(attachment: attachment, proposalId: proposalId);
    notifyListeners();
  }

  Future<void> linkBuyer({Proposal proposal, Buyer buyer}) async {
    await ProposalBloc().linkBuyer(proposal: proposal, buyer: buyer);
    notifyListeners();
  }

  Future<void> unLinkBuyer({Proposal proposal}) async {
    await ProposalBloc().unLinkBuyer(proposal: proposal);
    notifyListeners();
  }

  removeProposal({String proposalId}) async {
    await ProposalBloc().removeProposal(proposalId: proposalId);
  }

  Future<void> sendProposal({Proposal proposal, User user}) async {
    await ProposalBloc().sendProposal(proposal: proposal, user: user);
    notifyListeners();
  }

  @override
  Future dispose() async {
    await _listener.cancel();
    await _listenerProposalLogs.cancel();
    await _listenerAttachments.cancel();
    await _receivePortDownload.cancel();

    super.dispose();
  }

  //======================================Download======================================

  addTaskId(Attachment attachment, String taskId) {
    var list = List<Attachment>();

    proposalAttachments.value.map((item) {
      if (attachment.id == item.id) {
        item.downloadInfo = TaskInfo()..id = taskId;
      }

      list.add(item);

      return list;
    }).toList();

    proposalAttachments.add(list);
    notifyListeners();
  }

  _updateDownloadTaskInfo(TaskInfo taskInfo) {
    var list = List<Attachment>();

    proposalAttachments.value.map((attachment) {
      if (attachment.downloadInfo?.id == taskInfo.id) {
        attachment.downloadInfo = taskInfo;
      }

      list.add(attachment);

      return list;
    }).toList();

    proposalAttachments.add(list);
    notifyListeners();
  }

  ReceivePort _port = ReceivePort();
  StreamSubscription<dynamic> _receivePortDownload;

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    if (_receivePortDownload == null) {
      _receivePortDownload = _port.listen((dynamic data) async {
        String id = data()[0];
        DownloadTaskStatus status = data()[1];
        int progress = data()[2];

        _updateDownloadTaskInfo(TaskInfo()
          ..downloadStatus = status
          ..id = id
          ..progress = progress);
      });
    }
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}
