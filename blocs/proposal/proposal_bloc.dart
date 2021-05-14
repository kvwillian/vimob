import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/blocs/utils/file_manager_bloc.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/filter/filter.dart';
import 'package:vimob/models/proposal/attachment.dart';
import 'package:vimob/models/proposal/history.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';

class ProposalBloc {
  ProposalBloc();

  Stream<List<Proposal>> fetchProposals({String uid, String companyId}) {
    var proposalsStream = BehaviorSubject<List<Proposal>>();

    FirebaseFirestore.instance
        .collection("proposals")
        .where("users.$uid", isEqualTo: true)
        .where("company.id", isEqualTo: companyId)
        .snapshots()
        .listen((snapshot) {
      var proposals = List<Proposal>();
      if (snapshot.docs.isNotEmpty) {
        print("FIRESTORE: fetchProposals(snapshot)");
        snapshot.docs.forEach((doc) {
          var proposal = Proposal()
            ..id = doc.id
            ..status =
                doc.data()['status'] != null ? doc.data()['status'] : null
            ..date = doc.data()['date'] != null
                ? Jiffy(doc.data()['date'].toDate())
                : null
            ..idProposalMega = doc.data()['idProposalMega'] != null
                ? doc.data()['idProposalMega']
                : null
            ..development = doc.data()['development'] != null
                ? (DevelopmentReference()
                  ..id = doc.data()['development']['id']
                  ..name = doc.data()['development']['name']
                  ..type = doc.data()['development']['type'])
                : null
            ..agent = doc.data()['agent'] != null
                ? (Reference()
                  ..id = doc.data()['agent']['id']
                  ..name = doc.data()['agent']['name'])
                : null
            ..buyer = doc.data()['buyer'] != null
                ? (Reference()
                  ..id = doc.data()['buyer']['id']
                  ..name = doc.data()['buyer']['name'])
                : null
            ..block = doc.data()['block'] != null
                ? (Reference()
                  ..id = doc.data()['block']['id']
                  ..name = doc.data()['block']['name'])
                : null
            ..company = doc.data()['company'] != null
                ? (Reference()
                  ..id = doc.data()['company']['id']
                  ..name = doc.data()['company']['name'])
                : null
            ..approver = doc.data()['approver'] != null
                ? (Reference()
                  ..id = doc.data()['approver']['id']
                  ..name = doc.data()['approver']['name'])
                : null
            ..isSynchronized = doc.data()['synchronized']
            ..modifiedPaymentPlan = PaymentBloc()
                .createPaymentPlan(doc.data()['modifiedPaymentPlan'], true)
            ..paymentPlan =
                PaymentBloc().createPaymentPlan(doc.data()['paymentPlan'], true)
            ..unit = _createProposalUnit(doc.data()['unit']);

          proposals.add(proposal);
          proposals = sortProposals(proposals);
          proposalsStream.add(proposals);
        });
      } else {
        proposalsStream.add(proposals);
      }
    });

    return proposalsStream;
  }

  List<Proposal> sortProposals(List<Proposal> proposals) {
    List<Proposal> inAttendance = List<Proposal>();
    List<Proposal> avaliation = List<Proposal>();
    List<Proposal> generic = List<Proposal>();

    proposals.forEach((proposal) {
      switch (proposal.status) {
        case "inAttendance":
          inAttendance.add(proposal);
          inAttendance.sort((a, b) => b.date != null
              ? b.date.isSameOrAfter(a.date)
                  ? 1
                  : 0
              : 0);
          break;
        case "avaliation":
          avaliation.add(proposal);
          avaliation.sort((a, b) => b.date != null
              ? b.date.isSameOrAfter(a.date)
                  ? 1
                  : 0
              : 0);
          break;
        default:
          generic.add(proposal);
          generic.sort((a, b) => b.date != null
              ? b.date.isSameOrAfter(a.date)
                  ? 1
                  : 0
              : 0);
      }
    });

    return <Proposal>[...inAttendance, ...avaliation, ...generic].toList();
  }

  ProposalUnit _createProposalUnit(Map<dynamic, dynamic> docData) {
    try {
      return (ProposalUnit()
        ..id = docData['id']
        ..name = docData['name']
        ..developmentUnit = (Unit()
          ..area = (UnitArea()
            ..commonSquareMeters = double.parse(
                docData['data']['area']['commonSquareMeters'].toString())
            ..privateSquareMeters = double.parse(
                docData['data']['area']['privateSquareMeters'].toString()))
          ..floor = docData['data']['floor'].toInt()
          ..id = docData['data']['id']
          ..name = docData['data']['name']
          ..price = docData['data']['price'].toDouble()
          ..room = docData['data']['room'].toInt()
          ..companyStatus = (CompanyStatus()
            ..available = docData['data']['status']['available']
            ..color = docData['data']['status']['color']
            ..data = docData['data']['status']['date'] != null
                ? Jiffy(docData['data']['status']['date'].toDate())
                : null
            ..status = docData['data']['status']['status']
            ..text = docData['data']['status']['text'])
          ..typology = docData['data']['typology']
          ..block = (Reference()
            ..name = docData['data']['block']['name']
            ..id = docData['data']['block']['id'])));
    } catch (e) {
      print("unit Id: " + docData['id']);
      return null;
    }
  }

// =======================================Filter=========================================================
  Map<String, StatusFilter> initProposalFilters(
      {List<Proposal> proposals, Map<String, String> statusAvailable}) {
    Map<String, StatusFilter> filterStatus = Map<String, StatusFilter>();

    // fill with all available values
    statusAvailable.forEach((status, statusTranslated) {
      if (!filterStatus.containsKey(status)) {
        filterStatus[status.toLowerCase()] = StatusFilter()
          ..amount = 0
          ..selected = false
          ..status = statusTranslated;
      }
    });

    //count how much each proposal status has
    proposals.forEach((proposal) {
      var statusLowerCase = proposal.status.toLowerCase();
      if (filterStatus.containsKey(statusLowerCase)) {
        filterStatus[statusLowerCase].amount++;
        filterStatus[statusLowerCase].selected = true;
      } else {
        filterStatus[statusLowerCase] = StatusFilter()
          ..amount = 1
          ..selected = true;
      }
    });

    return filterStatus;
  }

  Map<String, String> initAvailableStatusList(
      Map<String, CompanyStatusConfig> proposals, String deviceLocale) {
    var avaialableStatusList = Map<String, String>();

    proposals.forEach((status, statusTranslated) {
      if (deviceLocale == "pt_BR") {
        avaialableStatusList[status] = statusTranslated.ptBR;
      } else {
        avaialableStatusList[status] = statusTranslated.enUS;
      }
    });

    return avaialableStatusList;
  }

  List<Proposal> filterProposals(
      {Map<String, StatusFilter> filterStatus, List<Proposal> proposals}) {
    return proposals
        .where(
            (proposal) => filterStatus[proposal.status.toLowerCase()].selected)
        .toList();
  }

// =======================================Filter=========================================================

  double totalCalculate(List<PaymentSeries> series) {
    return series.fold(
        0, (prev, next) => prev + (next.prices.nominal.seriesTotal));
  }

// =======================================Logs=========================================================

  Stream<List<History>> fetchProposalLogs({String proposalId}) {
    var historyListStream = BehaviorSubject<List<History>>();
    FirebaseFirestore.instance
        .collection("proposals-logs")
        .doc(proposalId)
        .collection("proposalsLogsList")
        .orderBy("date", descending: true)
        .snapshots()
        .listen((docs) {
      var historyList = List<History>();

      if (docs.docs.isNotEmpty) {
        print("FIRESTORE: fetchProposalLogs(snapshot)");

        docs.docs.forEach((doc) {
          var history = History()
            ..color = Color(int.parse(doc
                .data()['status']['color']
                .toString()
                .replaceAll("#", "0xFF")))
            ..date = Jiffy(doc.data()['date'].toDate())
            ..status = doc.data()['status']['type']
            ..title = doc.data()['analyst']
            ..descriptionPtBr = doc.data()['description']['pt_BR']
            ..descriptionEnUs = doc.data()['description']['en_US'];

          historyList.add(history);
        });
        historyListStream.add(historyList);
      }
    });
    return historyListStream;
  }

  Stream<List<Attachment>> fecthAttachments(
      {String proposalId, double deviceWidth}) {
    var attachmentListStream = BehaviorSubject<List<Attachment>>();

    FirebaseFirestore.instance
        .collection('attachments')
        .doc(proposalId)
        .collection("attachmentsList")
        .snapshots()
        .listen((docs) async {
      var list = List<Attachment>();

      if (docs.docs.isNotEmpty) {
        print("FIRESTORE: fecthAttachments(snapshot) ");

        //=====================Check current downloads=====================
        List<DownloadTask> currentDownloadStatus =
            await FlutterDownloader.loadTasks();

        docs.docs.forEach((doc) {
          TaskInfo taskInfo;
          currentDownloadStatus.forEach((downloadTask) {
            if (downloadTask.url == doc.data()['src'] &&
                downloadTask.status == DownloadTaskStatus.running) {
              taskInfo = TaskInfo()
                ..downloadStatus = downloadTask.status
                ..id = downloadTask.taskId
                ..progress = downloadTask.progress;
            }
          });

          var attachment = Attachment()
            ..date = Jiffy(doc.data()['date'].toDate())
            ..id = doc.id
            ..name = doc.data()['name']
            ..fullName = doc.data()['fullName']
            ..src = doc.data()['src']
            ..totalBytes = doc.data()['totalBytes']
            ..type = doc.data()['type']
            ..downloadInfo = taskInfo;

          list.add(attachment);

          list.sort((a, b) => b.date.isSameOrAfter(a.date) ? 1 : 0);
          attachmentListStream.add(list);
        });
      } else {
        attachmentListStream.add(null);
      }
    });

    return attachmentListStream;
  }

  storage.UploadTask uploadAttachment({String proposalId, File doc}) {
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child('proposalsAttachments/$proposalId/${basename(doc.path)}');

    storage.UploadTask uploadTask = ref.putFile(doc);

    return uploadTask;
  }

  Attachment mountAttachment(
      {File doc, String src, String type, bool abbreviate}) {
    String fileName = basename(doc.path);

    return Attachment()
      ..date = Jiffy()
      ..name = abbreviate
          ? fileName.substring((fileName.length - 15), fileName.length)
          : fileName
      ..fullName = fileName
      ..src = src
      ..totalBytes = doc.lengthSync().toDouble()
      ..type = type;
  }

  addAttachmentToProposal({String proposalId, Attachment attachment}) async {
    await FirebaseFirestore.instance
        .collection("attachments")
        .doc(proposalId)
        .collection("attachmentsList")
        .doc()
        .set({
      "date": attachment.date.dateTime,
      "name": attachment.name,
      "fullName": attachment.fullName,
      "src": attachment.src,
      "totalBytes": attachment.totalBytes,
      "type": attachment.type,
    });
    print("FIRESTORE: addAttachmentToProposal");
  }

  removeAttachment({String proposalId, Attachment attachment}) async {
    try {
      await FirebaseFirestore.instance
          .collection("attachments")
          .doc(proposalId)
          .collection("attachmentsList")
          .doc(attachment.id)
          .delete();

      print("FIRESTORE: removeAttachment");

      await storage.FirebaseStorage.instance
          .ref()
          .child('proposalsAttachments/$proposalId/${attachment.fullName}')
          .delete();
      print("STORAGE: removeAttachment");

      String fullName768x1280 =
          attachment.fullName.replaceAll(".", "_768x1280.");

      await storage.FirebaseStorage.instance
          .ref()
          .child('proposalsAttachments/$proposalId/$fullName768x1280')
          .delete();
      print("STORAGE: removeAttachment _768x1280.");

      String fullName1440x2560 =
          attachment.fullName.replaceAll(".", "_1440x2560.");

      await storage.FirebaseStorage.instance
          .ref()
          .child('proposalsAttachments/$proposalId/$fullName1440x2560')
          .delete();
      print("STORAGE: removeAttachment _1440x2560.");

      String fullName320x480 = attachment.fullName.replaceAll(".", "_320x480.");

      await storage.FirebaseStorage.instance
          .ref()
          .child('proposalsAttachments/$proposalId/$fullName320x480')
          .delete();
      print("STORAGE: removeAttachment _320x480.");
    } catch (e) {
      print(e);
    }
  }

// =======================================buyer of proposal=========================================================

  Future<void> linkBuyer({Proposal proposal, Buyer buyer}) async {
    try {
      await FirebaseFirestore.instance
          .collection("proposals")
          .doc(proposal.id)
          .update({
        "buyer": {"id": buyer.id, "name": buyer.name}
      });
      print("FIRESTORE: linkBuyer");
    } catch (e) {
      print(e);
    }
  }

  Future<void> unLinkBuyer({Proposal proposal}) async {
    try {
      await FirebaseFirestore.instance
          .collection("proposals")
          .doc(proposal.id)
          .update({"buyer": null});
      print("FIRESTORE: unLinkBuyer");
    } catch (e) {
      print(e);
    }
  }

  removeProposal({String proposalId}) async {
    try {
      await FirebaseFirestore.instance
          .collection("proposals")
          .doc(proposalId)
          .delete();
      print("FIRESTORE: removeProposal");
    } catch (e) {
      print(e);
    }
  }

  sendProposal({Proposal proposal, User user}) async {
    await _updateProposalStatus(proposalId: proposal.id);
    await updateUnit(proposal.unit.id, "avaliation", null);
    await updateUnitDevelopmentUnits(
        proposal.company.id,
        proposal.development.id,
        proposal.unit.developmentUnit,
        "avaliation",
        DevelopmentState().currentDevelopmentUnit.value.blocks,
        reservedBy: null);

    _addHistory(
        proposalId: proposal.id,
        history: History()
          ..title = user.name
          ..date = new Jiffy()
          ..descriptionEnUs = "Propose sent"
          ..descriptionPtBr = "Proposta enviada"
          ..color = Color(0xFF00D87A)
          ..status = "sent");
  }

  Future<void> _updateProposalStatus({String proposalId}) async {
    try {
      await FirebaseFirestore.instance
          .collection("proposals")
          .doc(proposalId)
          .update(
              {"status": "avaliation", "synchronized": false, "fromApp": true});
      print("FIRESTORE: _updateProposalStatus");
    } catch (e) {
      print(e);
    }
  }

  updateUnit(String unitId, String status, String reservedBy) async {
    try {
      await FirebaseFirestore.instance
          .collection("units")
          .doc(unitId)
          .update({'status': status, 'reservedBy': reservedBy});

      print("FIRESTORE: _updateUnitStatus");
    } catch (e) {
      print(e);
    }
  }

  updateUnitDevelopmentUnits(String companyId, String developmentId, Unit unit,
      String status, List<Block> blocks,
      {String reservedBy}) async {
    try {
      var developmentUnitDocs = await FirebaseFirestore.instance
          .collection("development-units")
          .where("company.id", isEqualTo: companyId)
          .where("development.id", isEqualTo: developmentId)
          .get();

      if (developmentUnitDocs.docs.isNotEmpty) {
        print("FIRESTORE: _updateDevelopmentUnitStatus");

        Block block = blocks.firstWhere((b) => b.id == unit.block.id);

        var unitList = await block.units;

        block.units = Future<Iterable<Unit>>(() {
          return unitList.map((u) {
            if (u.id == unit.id) {
              u.status = status;
              if (reservedBy != null) {
                u.reservedBy = reservedBy;
              }
            }
            return u;
          });
        });

        blocks[blocks.indexWhere((b) => b.id == block.id)] = block;

        var blocksJsonFuture =
            blocks.map((b) async => await b.toMap(b)).toList();

        var blocksJson = await Future.wait(blocksJsonFuture);

        await FirebaseFirestore.instance
            .collection("development-units")
            .doc(developmentUnitDocs.docs.first.id)
            .update({'blocks': blocksJson});

        print(
            "FIRESTORE: _updateDevelopmentUnitStatus(updateData development-units)");
      }
    } catch (e) {
      print(e);
    }
  }

  void _addHistory({String proposalId, History history}) {
    try {
      var docRef = FirebaseFirestore.instance
          .collection("proposals-logs")
          .doc(proposalId)
          .collection("proposalsLogsList")
          .doc();
      print("FIRESTORE: _addHistory");

      docRef.set(history.toJson(history));
    } catch (e) {
      print(e);
    }
  }

  Future<File> getOptmizedAttachmentImageSize(
      {Attachment attachment, double deviceWidth, String proposalId}) async {
    String fullName = attachment.fullName;
    String resizedImage;
    // StorageMetadata metaData;
    if (fullName != null) {
      if (deviceWidth <= 320) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'proposalsAttachments/$proposalId/${fullName.replaceAll(".", "_320x480.")}') ??
            null;

        resizedImage = await ref.getDownloadURL() ?? null;

        // metaData = await ref.getMetadata() ?? null;
      } else if (deviceWidth > 320 && deviceWidth <= 600) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'proposalsAttachments/$proposalId/${fullName.replaceAll(".", "_768x1280.")}') ??
            null;

        resizedImage = await ref.getDownloadURL() ?? null;

        // metaData = await ref.getMetadata() ?? null;
      } else if (deviceWidth > 600) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'proposalsAttachments/$proposalId/${fullName.replaceAll(".", "_1440x2560.")}') ??
            null;

        resizedImage = await ref?.getDownloadURL() ?? null;

        // metaData = await ref?.getMetadata() ?? null;
      }
    }
    File file = await FileManagerBloc()
        .createFile(src: resizedImage, fileName: fullName);

    return file;
  }

  Future addNewProposal() async {
    DevelopmentReference development = DevelopmentReference()
      ..id = ProposalState().selectedDevelopment.id
      ..name = ProposalState().selectedDevelopment.name
      ..type = ProposalState().selectedDevelopment.type;

    ProposalUnit unit = ProposalUnit()
      ..id = ProposalState().selectedUnit.id
      ..name = ProposalState().selectedUnit.name
      ..developmentUnit = ProposalState().selectedUnit;

    Reference block = Reference()
      ..id = ProposalState().selectedBlock.id
      ..name = ProposalState().selectedBlock.name;

    Reference agent = Reference()
      ..id = AuthenticationState().user.uid
      ..name = AuthenticationState().user.name;

    Reference company = Reference()
      ..id = AuthenticationState().user.company
      ..name = AuthenticationState().user.companyName;

    const String status = 'inAttendance';

    ProposalUser user = ProposalUser()..id = AuthenticationState().user.uid;

    Map<String, bool> users = {user.id: true};

    PaymentPlanWithDateTime paymentPlanDateTime =
        PaymentPlanWithDateTime().clone(ProposalState().selectedPaymentPlan);

    PaymentPlanWithDateTime modifiedPaymentPlanDateTime =
        PaymentPlanWithDateTime().clone(ProposalState().selectedPaymentPlan);

    modifiedPaymentPlanDateTime.series = PaymentState()
        .modifiedPaymentSeries
        .map((series) => PaymentSeriesWithDateTime().clone(series))
        .toList();

    DocumentReference docRef;
    if (ProposalState().selectedProposal.id != null) {
      ProposalWithDateTime newProposal = ProposalWithDateTime()
        ..id = ProposalState().selectedProposal.id
        ..company = company
        ..development = development
        ..block = block
        ..unit = unit
        ..buyer = ProposalState().selectedProposal.buyer ?? null
        ..agent = agent
        ..approver = ProposalState().selectedProposal.approver ?? null
        ..idProposalMega = null
        ..users = users
        ..date = ProposalState().proposalDate.dateTime
        ..status = status
        ..idProposalMega =
            ProposalState().selectedProposal.idProposalMega ?? null
        ..isSynchronized =
            ProposalState().selectedProposal.isSynchronized ?? false
        ..paymentPlan = paymentPlanDateTime
        ..modifiedPaymentPlan = modifiedPaymentPlanDateTime;
      // docRef =
      await FirebaseFirestore.instance
          .collection("proposals")
          .doc(ProposalState().selectedProposal.id)
          .update(newProposal.toMap());
      print("FIRESTORE: addNewProposal");
    } else {
      ProposalWithDateTime newProposal = ProposalWithDateTime()
        ..id = null
        ..company = company
        ..development = development
        ..block = block
        ..unit = unit
        ..buyer = null
        ..agent = agent
        ..approver = null
        ..idProposalMega = null
        ..users = users
        ..date = ProposalState().proposalDate.dateTime
        ..status = status
        ..idProposalMega = null
        ..isSynchronized = false
        ..paymentPlan = paymentPlanDateTime
        ..modifiedPaymentPlan = modifiedPaymentPlanDateTime;

      docRef = await FirebaseFirestore.instance
          .collection("proposals")
          .add(newProposal.toMap());
      print("FIRESTORE: addNewProposal");
    }

    PaymentPlan paymentPlan =
        PaymentPlan().clone(ProposalState().selectedPaymentPlan);

    PaymentPlan modifiedPaymentPlan =
        PaymentPlan().clone(ProposalState().selectedPaymentPlan);

    modifiedPaymentPlan.series = PaymentState()
        .modifiedPaymentSeries
        .map((series) => PaymentSeries().clone(series))
        .toList();

    ProposalState().selectedProposal = Proposal()
      ..id = docRef?.id ?? ProposalState().selectedProposal.id
      ..company = company
      ..development = development
      ..block = block
      ..unit = unit
      ..buyer = null
      ..agent = agent
      ..approver = null
      ..idProposalMega = null
      ..users = users
      ..date = Jiffy(ProposalState().proposalDate)
      ..status = status
      ..idProposalMega = null
      ..isSynchronized = false
      ..paymentPlan = paymentPlan
      ..modifiedPaymentPlan = modifiedPaymentPlan;

    if (docRef?.id != null) {
      _addHistory(
          proposalId: docRef.id,
          history: History()
            ..title = AuthenticationState().user.name
            ..date = new Jiffy()
            ..descriptionEnUs = "Propose created"
            ..descriptionPtBr = "Proposta criada"
            ..color = Color(0xFF00D87A)
            ..status = "created");
    }
  }
}
