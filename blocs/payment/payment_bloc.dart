import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/widgets.dart';
import 'package:jiffy/jiffy.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/blocs/payment/series_calc_bloc.dart';
import 'package:vimob/models/development/block.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';

class PaymentBloc {
  int id = 0;

  PaymentBloc();

  PaymentPlan createPaymentPlan(
      Map<dynamic, dynamic> docData, bool isProposalPaymentPlan) {
    return (PaymentPlan()
      ..additionDiscount = docData['additionDiscount'] != null
          ? docData['additionDiscount'].toDouble()
          : null
      ..additionDiscountType = docData['additionDiscountType']
      ..additionDiscountCurrency = docData['additionDiscountCurrency'] != null
          ? docData['additionDiscountCurrency'].toDouble()
          : null
      ..docId = docData['docId']
      ..interest = (Interest()
        ..type = convertInterestTypes(docData['interest']['type'])
        ..value = docData['interest']['value'] != null
            ? docData['interest']['value'].toDouble()
            : null)
      ..name = docData['name']
      ..pvTax = docData['pvTax'] != null ? docData['pvTax'].toDouble() : null
      ..series = createPaymentSeries(docData['series'], isProposalPaymentPlan)
      ..start =
          docData['start'] != null ? Jiffy(docData['start'].toDate()) : null
      ..end = docData['end'] != null ? Jiffy(docData['end'].toDate()) : null);
  }

  List<PaymentSeries> createPaymentSeries(
      List<dynamic> series, bool isProposalPaymentPlan) {
    int id = 0;
    return (series)
        .map((i) => PaymentSeries()
          ..id = ++id
          ..dueDate = (SeriesDueDate()
            ..date = Jiffy(i['dueDate']['date'] != null
                ? i['dueDate']['date']?.toDate()
                : null)
            ..type = convertDueTypes(i['dueDate']['type'])
            ..value = i['dueDate']['value'] != null
                ? i['dueDate']['value'].toInt()
                : null)
          ..fixedDay = i['fixedDay'] != null ? i['fixedDay']?.toInt() : null
          ..fixedValue =
              i['fixedValue'] != null ? i['fixedValue']?.toDouble() : null
          ..interestDate = i['interestDate'] != null
              ? (SeriesInterestDate()
                ..date = Jiffy(i['interestDate']['date'] != null
                    ? i['interestDate']['date']?.toDate()
                    : null)
                ..type = convertInterestDueTypes(i['interestDate']['type'])
                ..value = i['interestDate']['value'] != null
                    ? i['interestDate']['value'].toInt()
                    : null)
              : null
          ..numberOfPayments = i['numberOfPayments'] != null
              ? i['numberOfPayments'].toInt()
              : null
          ..percent = i['percent'] != null ? i['percent'].toDouble() : null
          ..prices = (PaymentSeriesPrices()
            ..future = (SeriesPrices()
              ..seriesValue = i['prices'] != null
                  ? i['prices']['future']['seriesValue']?.toDouble()
                  : 0
              ..seriesTotal = i['prices'] != null
                  ? i['prices']['future']['seriesTotal']?.toDouble()
                  : 0)
            ..nominal = (SeriesPrices()
              ..seriesValue = i['prices'] != null
                  ? i['prices']['nominal']['seriesValue']?.toDouble()
                  : 0
              ..seriesTotal = i['prices'] != null
                  ? i['prices']['nominal']['seriesTotal']?.toDouble()
                  : 0))
          ..serieTypeId =
              i['serieTypeId'] != null ? i['serieTypeId'].toInt() : null
          ..settings = (SeriesSettings()
            ..adjustments = i['settings']['adjustments']
            ..changeValueFixed = i['settings']['changeValueFixed']
            ..fixedDay = i['settings']['fixedDay']
            ..interval = i['settings']['interval']
            ..minPrice = i['settings']['minPrice'] != null
                ? i['settings']['minPrice']?.toDouble()
                : null
            ..numberOfPayments = i['settings']['numberOfPayments']
            ..percentage = i['settings']['percentage']
            ..postDeliveryType =
                convertPostDeliveryTypes(i['settings']['postDeliveryType'])
            ..residue = i['settings']['residue']
            ..startDate = i['settings']['startDate']
            ..typeValueSerie =
                convertTypeValueSerie(i['settings']['typeValueSerie']))
          ..text = isProposalPaymentPlan
              ? i['text']
              : I18n.translatePaymentSeriesName(i['type']['text'])
          ..type = convertSeriesType(
              isProposalPaymentPlan ? i['type'] : i['type']['name']))
        .toList();
  }

  /// gets the payment plan bound to the product
  bool _findByProduct(
      Map<String, dynamic> developments,
      String developmentId,
      Map<String, dynamic> blocks,
      String blockId,
      Map<String, dynamic> units,
      String unitId,
      String id) {
    bool eqBlock = false;
    blocks.keys.forEach((b) {
      if (b == blockId) {
        eqBlock = true;
      }
    });
    bool eqUnit = false;
    units.keys.forEach((u) {
      if (u == unitId) {
        eqUnit = true;
      }
    });

    return (developments[developmentId] ?? false || eqBlock || eqUnit);
  }

  /// gets the payment plan according to its type: either global or product
  bool _filterByPaymentPlanType(
    DocumentSnapshot doc,
    String companyId,
    String developlementId,
    String blockId,
    String unitId,
  ) {
    var data = doc.data;

    if (data()['type'] != null) {
      if (data()['type'] == 'global') {
        return true;
      } else {
        if (data()['type'] == 'product') {
          return _findByProduct(data()['developments'], developlementId,
              data()['blocks'], blockId, data()['units'], unitId, doc.id);
        } else {
          return false;
        }
      }
    } else {
      // backwards compatibility
      if (data()['developments'].entries.length == 0 &&
          data()['blocks'].entries.length == 0 &&
          data()['units'].entries.length == 0) {
        // global
        return true;
      } else {
        // product
        return _findByProduct(data()['developments'], developlementId,
            data()['blocks'], blockId, data()['units'], unitId, doc.id);
      }
    }
  }

  Future<List<PaymentPlan>> fetchPaymentPlans() async {
    Development development = ProposalState().selectedDevelopment;
    Block block = ProposalState().selectedBlock;
    Unit unit = ProposalState().selectedUnit;
    QuerySnapshot query;

    query = await FirebaseFirestore.instance
        .collection('payment-plans')
        .where('company.id', isEqualTo: development.company.id)
        .where('typeSegment', isEqualTo: development.type)
        .where('active', isEqualTo: true)
        .orderBy('name.pt-BR')
        .get();

    print("FIRESTORE: fetchPaymentPlans");

    var paymentPlans = List<PaymentPlan>();

    ProposalState().proposalDate = Jiffy();

    var blockDocument = await FirebaseFirestore.instance
        .collection('blocks')
        .doc(block.id)
        .get();

    print("FIRESTORE: fetchPaymentPlans( fetch blocks)");

    ProposalState().selectedBlock.deliveryDate =
        blockDocument.data()['deliveryDate'] == null
            ? Jiffy(ProposalState().proposalDate)
            : Jiffy.unix(
                blockDocument.data()['deliveryDate'].millisecondsSinceEpoch);

    if (query.docs.isNotEmpty) {
      query.docs.where((doc) {
        bool a = _filterByPaymentPlanType(
          doc,
          development.company.id,
          development.id,
          block.id,
          unit.id,
        );
        // if (doc.id == "j5bJjYCVHWHFCqGTqzxy") {
        //   print("aaaa");
        // }

        return a;
      }).forEach((doc) {
        if (doc.id == "j5bJjYCVHWHFCqGTqzxy") {
          print("aaaa");
        }

        Jiffy today = Jiffy(DateTime.now());
        Jiffy start = Jiffy(doc.data()['validityDate']['start'].toDate());
        Jiffy end = Jiffy(doc.data()['validityDate']['end'].toDate());

        // ignoring not yet valid or already expired payment plans
        if (today.isBefore(start) || today.isAfter(end)) {
          return null;
        }

        List<PaymentSeries> paymentSeries =
            createPaymentSeries(doc.data()['series'], false);

        PaymentPlan paymentPlan = PaymentPlan()
          ..additionDiscount = doc.data()['additionDiscount'].toDouble()
          ..additionDiscountType = doc.data()['additionDiscountType']
          ..additionDiscountCurrency =
              doc.data()['additionDiscountCurrency'] != null
                  ? doc.data()['additionDiscountCurrency'].toDouble()
                  : null
          ..docId = doc.id
          ..interest = (Interest()
            ..type = convertInterestTypes(doc.data()['interest']['type'])
            ..value = doc.data()['interest']['value']?.toDouble() ?? 0)
          ..name = doc.data()['name']['pt-BR']
          ..pvTax = doc.data()['pvTax'].toDouble()
          ..series = paymentSeries
          ..start = start
          ..end = end;

        paymentPlan.series = calculateSeriesDatePrice(
          paymentSeries,
          paymentPlan,
          ProposalState().selectedUnit,
          accessMode: "create",
        );

        paymentPlans.add(paymentPlan);
      });

      SeriesCalcBloc().resetSeries();

      return paymentPlans;
    } else {
      return null;
    }
  }

  /// Calculates the dueDate, interestDate, nominal and future prices
  calculateSeriesDatePrice(
    List<PaymentSeries> paymentSeries,
    PaymentPlan paymentPlan,
    Unit unit, {
    String accessMode,
    PaymentSeries editingSeries,
  }) {
    List<PaymentSeries> upfrontSeries = paymentSeries
        .where((series) => PaymentBloc().isUpfrontType(series.type))
        .toList();

    List<PaymentSeries> afterUpfrontSeries = paymentSeries
        .where((series) => !PaymentBloc().isUpfrontType(series.type))
        .toList();

    upfrontSeries = upfrontSeries
        .map((series) => _seriesDueDate(series, upfrontSeries.length))
        .toList();

    SeriesCalcBloc().calculateOverallMinMaxUpfrontDueDate(upfrontSeries);

    afterUpfrontSeries = afterUpfrontSeries
        .map((series) => _seriesDueDate(series, upfrontSeries.length))
        .toList();

    double totalFixedValue =
        SeriesCalcBloc().calculateSeriesTotalFixedValue(paymentSeries);

    List<PaymentSeries> series = [...upfrontSeries, ...afterUpfrontSeries]
        .map((series) => _seriesPrice(
              paymentPlan,
              series,
              unit.price,
              totalFixedValue,
              upfrontSeries.length,
              paymentPlan.interest,
            ))
        .toList();

    if (accessMode == "create") {
      series = _seriesDeliveryDateSplit(
        paymentPlan,
        series,
        upfrontSeries.length,
        unit.price,
        totalFixedValue,
        paymentPlan.interest,
      );

      series = series
          .map((series) => _seriesPrice(
                paymentPlan,
                series,
                unit.price,
                totalFixedValue,
                upfrontSeries.length,
                paymentPlan.interest,
              ))
          .toList();
    }

    return _sortPaymentSeries(series);
  }

  /// sort ascending by date, text
  List<PaymentSeries> sortPaymentSeries(List<PaymentSeries> paymentSeries) {
    paymentSeries.sort((a, b) {
      if (b.dueDate.date.isAfter(a.dueDate.date, Units.DAY)) {
        return 0;
      } else {
        if (b.dueDate.date.isSame(a.dueDate.date, Units.DAY)) {
          if (a.text.compareTo(b.text) < 0) {
            return 0;
          }
        }
      }

      return 1;
    });

    return paymentSeries;
  }

  /// Calculates the due date for the series
  PaymentSeries _seriesDueDate(
    PaymentSeries series,
    int upfrontSeriesCount,
  ) {
    if (!_isSeriesModified(series)) {
      SeriesDueDate dueDate = SeriesDueDate()
        ..type = series.dueDate.type
        ..value = series.dueDate.value;

      SeriesDueDate seriesDueDate = SeriesCalcBloc().calculateSeriesDueDate(
        series,
        upfrontSeriesCount,
      );

      dueDate.date = seriesDueDate.date;

      series.dueDate = dueDate;
    }

    return series;
  }

  /// Calculates the interest for the series
  PaymentSeries _seriesPrice(
    PaymentPlan paymentPlan,
    PaymentSeries series,
    double unitPrice,
    double totalFixedValue,
    int upfrontSeriesCount,
    Interest interest,
  ) {
    SeriesPrices nominalPrice =
        _hasNominalPrice(series.prices.nominal.seriesValue)
            ? series.prices.nominal
            : SeriesCalcBloc().calculateSeriesNominalPrice(
                paymentPlan,
                series,
                unitPrice,
                totalFixedValue,
              );

    if (!_hasNoInterest(series.interestDate, interest)) {
      series.interestDate = SeriesCalcBloc().calculateSeriesInterestDate(
        series,
        upfrontSeriesCount,
      );
    }

    SeriesPrices futurePrice = SeriesPrices()
      ..seriesTotal = nominalPrice.seriesTotal
      ..seriesValue = calculateSeriesPrice(
        nominalPrice.seriesValue,
        FuturePriceCalcType.future,
        series,
        interest,
      );

    series.prices = PaymentSeriesPrices()
      ..nominal = nominalPrice
      ..future = futurePrice;

    return series;
  }

  bool _hasNominalPrice(double price) {
    return price != 0;
  }

  /// A series will be split in case its interest starts after the delivery date and its payments exceed this date
  /// The first of the split series won't have interest and it'll end on the delivery date
  /// The second series will start right after the delivery date and it will contain interest
  List<PaymentSeries> _seriesDeliveryDateSplit(
    PaymentPlan paymentPlan,
    List<PaymentSeries> paymentSeries,
    int upfrontSeriesCount,
    double unitPrice,
    double totalFixedValue,
    Interest interest,
  ) {
    List<PaymentSeries> newSeriesList = [];
    Jiffy blockDeliveryDate = Jiffy(ProposalState().selectedBlock.deliveryDate);

    for (PaymentSeries series in paymentSeries) {
      if (series.interestDate.type ==
          InterestDueTypes.monthsAfterConstruction) {
        if (blockDeliveryDate.isSameOrAfter(series.dueDate.date, Units.MONTH)) {
          if (series.interestDate.date
              .isSameOrAfter(blockDeliveryDate, Units.MONTH)) {
            int monthPeriod =
                SeriesCalcBloc().getMonthBySpecialType(series.type);

            Jiffy seriesLastPayment = Jiffy(Jiffy(series.dueDate.date)
                .add(months: series.numberOfPayments * monthPeriod));

            if (seriesLastPayment.isSameOrAfter(series.interestDate.date)) {
              int originalNumberOfPayments = series.numberOfPayments;

              PaymentSeries newSeries = PaymentSeries().clone(series);
              newSeries.id = _getNewSeriesId();

              series.numberOfPayments = _getFirstSeriesNumberOfPayments(
                series.dueDate.date,
                monthPeriod,
              );

              series.interestDate.type = InterestDueTypes.without;
              series.interestDate.value = 0;
              series.prices.nominal = SeriesCalcBloc().calculateNominalPrice(
                series.numberOfPayments,
                series.prices.nominal.seriesValue,
              );

              series.prices.future.seriesValue = 0;
              series.prices.future.seriesTotal = 0;

              newSeries.numberOfPayments = _getSecondSeriesNumberOfPayments(
                originalNumberOfPayments,
                series.numberOfPayments,
              );

              newSeries.dueDate.type = DueTypes.monthsAfterConstruction;
              newSeries.dueDate.value = 1;

              newSeries.prices.nominal = SeriesCalcBloc().calculateNominalPrice(
                newSeries.numberOfPayments,
                newSeries.prices.nominal.seriesValue,
              );

              newSeries.prices.future.seriesValue = 0;
              newSeries.prices.future.seriesTotal = 0;
              newSeries = _seriesDueDate(newSeries, upfrontSeriesCount);

              newSeries = _seriesPrice(
                paymentPlan,
                newSeries,
                unitPrice,
                totalFixedValue,
                upfrontSeriesCount,
                interest,
              );

              newSeriesList.add(newSeries);
            }
          }
        }
      }
    }

    paymentSeries
        .addAll(newSeriesList.map((series) => PaymentSeries().clone(series)));

    return paymentSeries;
  }

  int _getFirstSeriesNumberOfPayments(
    Jiffy dueDate,
    int monthPeriod,
  ) {
    Jiffy blockDeliveryDate = ProposalState().selectedBlock.deliveryDate;

    int seriesNumberOfPayments = 1 +
        blockDeliveryDate
            .diff(
              dueDate,
              Units.MONTH,
              true,
            )
            .ceil();

    return SeriesCalcBloc().getMonthByPeriodicity(
      seriesNumberOfPayments,
      monthPeriod,
    );
  }

  int _getSecondSeriesNumberOfPayments(
    int originalNumberOfPayments,
    int numberOfPayments,
  ) {
    return originalNumberOfPayments - numberOfPayments;
  }

  /// sort ascending by date, text
  List<PaymentSeries> _sortPaymentSeries(List<PaymentSeries> paymentSeries) {
    paymentSeries.sort((a, b) {
      if (b.dueDate.date.isAfter(a.dueDate.date, Units.DAY)) {
        return 0;
      } else {
        if (b.dueDate.date.isSame(a.dueDate.date, Units.DAY)) {
          if (a.text.compareTo(b.text) < 0) {
            return 0;
          }
        }
      }

      return 1;
    });

    return paymentSeries;
  }

  applyPostDeliveryDistribute() {
    PaymentState().paymentPlans.forEach(
          (stream) => stream.forEach(
            (plan) => plan.series.forEach(
              (series) =>
                  SeriesCalcBloc().distributePostDeliverySeries(plan, series),
            ),
          ),
        );
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
      if (_cannotChangeFixedDay()) {
        int endOfMonth =
            Jiffy(ProposalState().selectedProposal.date).endOf(Units.MONTH).day;

        if (newDate.date != PaymentState().selectedSeries.fixedDay) {
          // verifies if fixedDay is any of 31, 30 or 29, but the month has less total days
          if (PaymentState().selectedSeries.fixedDay >= endOfMonth) {
            if (newDate.date != endOfMonth) {
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

  bool _cannotChangeFixedDay() {
    return (PaymentState().selectedSeries.fixedDay != null &&
            PaymentState().selectedSeries.fixedDay != 0) &&
        (PaymentState().selectedSeries.settings.fixedDay == null ||
            PaymentState().selectedSeries.settings.fixedDay == false);
  }

  FieldStatus validateNumberOfPayments(
    BuildContext context,
    FieldStatus numberOfPaymentsController,
    bool isEditing,
  ) {
    numberOfPaymentsController.errorText = null;
    numberOfPaymentsController.isValid = true;

    int numberOfPayments =
        int.tryParse(numberOfPaymentsController.controller.text)?.toInt() ?? 0;

    if (numberOfPayments > 0) {
      if (!PaymentState().selectedSeries.settings.numberOfPayments) {
        // Enforce the numberOfPayments even if the series has been split
        int maxNumberOfPayments = ProposalState()
            .selectedPaymentPlan
            .series
            .where(
                (series) => series.type == PaymentState().selectedSeries.type)
            .fold(
              0,
              (acc, series) => acc + series.numberOfPayments,
            );

        maxNumberOfPayments = maxNumberOfPayments == 0
            ? PaymentState().selectedSeries.numberOfPayments
            : maxNumberOfPayments;

        int currentNumberOfPaymentsOfType =
            PaymentState().modifiedPaymentSeries.fold(
                  0,
                  (acc, series) =>
                      series.type == PaymentState().selectedSeries.type
                          ? acc + series.numberOfPayments
                          : acc,
                );
        if (isEditing) {
          currentNumberOfPaymentsOfType = (numberOfPayments -
                  PaymentState().selectedSeries.numberOfPayments) +
              currentNumberOfPaymentsOfType;
        } else {
          currentNumberOfPaymentsOfType += numberOfPayments;
        }

        if (numberOfPayments > maxNumberOfPayments ||
            PaymentState().selectedSeries.numberOfPayments >
                maxNumberOfPayments ||
            currentNumberOfPaymentsOfType > maxNumberOfPayments) {
          numberOfPaymentsController.errorText =
              '${I18n.of(context).numberOfPaymentsExceededError} '
              '$maxNumberOfPayments';
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

  validateSeriesNominalPrice(
    BuildContext context,
    FieldStatusMoneyMasked nominalPriceController,
  ) {
    nominalPriceController = validateSeriesPrice(
      context,
      nominalPriceController,
    );

    if (nominalPriceController.isValid) {
      if (nominalPriceController.controller.numberValue <
          PaymentState().modifiedSelectedSeries.settings.minPrice) {
        MoneyMaskedTextController invalidNominalPrice =
            MoneyMaskedTextController(
          leftSymbol: 'R\$ ',
          initialValue: PaymentState().modifiedSelectedSeries.settings.minPrice,
          thousandSeparator: '.',
          decimalSeparator: ',',
        );

        nominalPriceController.errorText = I18n.of(context).interpolateText(
          I18n.of(context).minPrice,
          {
            '[value]': invalidNominalPrice.text,
          },
        );
        nominalPriceController.isValid = false;
      }
    }

    return nominalPriceController;
  }

  validateSeriesPrice(
    BuildContext context,
    FieldStatusMoneyMasked priceController,
  ) {
    if (priceController.controller.numberValue == 0) {
      priceController.errorText = I18n.of(context).valueCannotBeZero;
      priceController.isValid = false;
    } else {
      priceController.errorText = null;
      priceController.isValid = true;
    }

    return priceController;
  }

  updateModifiedSelectedSeriesPrices(
    double nominalPrice,
    double futurePrice,
    double totalPrice,
  ) {
    PaymentState().modifiedSelectedSeries.prices.nominal.seriesValue =
        nominalPrice;

    PaymentState().modifiedSelectedSeries.prices.future.seriesValue =
        futurePrice;

    PaymentState().modifiedSelectedSeries.prices.nominal.seriesTotal =
        totalPrice;
  }

  /// calculates the series price according to the nominal price
  SeriesPrices calculateSeriesPriceFromNominal(double nominalPrice) {
    double futurePrice = calculateSeriesPrice(
      nominalPrice,
      FuturePriceCalcType.future,
      PaymentState().modifiedSelectedSeries,
      ProposalState().selectedPaymentPlan.interest,
    );

    double totalPrice = SeriesCalcBloc().calculateSeriesTotalPrice(
      PaymentState().modifiedSelectedSeries.numberOfPayments,
      nominalPrice,
    );

    updateModifiedSelectedSeriesPrices(
      nominalPrice,
      futurePrice,
      totalPrice,
    );

    return SeriesPrices()
      ..seriesValue = futurePrice
      ..seriesTotal = totalPrice;
  }

  /// calculates the series price according to the future price
  SeriesPrices calculateSeriesPriceFromFuture(double futurePrice) {
    double nominalPrice = calculateSeriesPrice(
      futurePrice,
      FuturePriceCalcType.nominal,
      PaymentState().modifiedSelectedSeries,
      ProposalState().selectedPaymentPlan.interest,
    );

    double totalPrice = SeriesCalcBloc().calculateSeriesTotalPrice(
      PaymentState().modifiedSelectedSeries.numberOfPayments,
      nominalPrice,
    );

    updateModifiedSelectedSeriesPrices(
      nominalPrice,
      futurePrice,
      totalPrice,
    );

    return SeriesPrices()
      ..seriesValue = nominalPrice
      ..seriesTotal = totalPrice;
  }

  /// calculates the series price according to the total price
  SeriesPrices calculateSeriesPriceFromTotal(double totalPrice) {
    SeriesPrices newPrice = SeriesCalcBloc().calculateSeriesTotalPriceToNominal(
      PaymentState().modifiedSelectedSeries.numberOfPayments,
      totalPrice,
    );

    PaymentState().modifiedSelectedSeries.prices.nominal.seriesValue =
        newPrice.seriesValue;

    PaymentState().modifiedSelectedSeries.prices.nominal.seriesTotal =
        totalPrice;

    return SeriesPrices()
      ..seriesValue = newPrice.seriesValue
      ..seriesTotal = totalPrice;
  }

  /// calculates series prices considering whether there's insterest or not
  double calculateSeriesPrice(
    double currentPrice,
    FuturePriceCalcType futurePriceCalcType,
    PaymentSeries paymentSeries,
    Interest interest,
  ) {
    double price;

    if (_hasNoInterest(paymentSeries.interestDate, interest)) {
      price = currentPrice;
    } else {
      price = SeriesCalcBloc()
          .calculateSeriesFuturePrice(
            interest.value,
            paymentSeries.numberOfPayments,
            currentPrice,
            paymentSeries.dueDate,
            paymentSeries.interestDate,
            futurePriceCalcType,
            paymentSeries.type,
          )
          .seriesValue;
    }

    return price;
  }

  bool _hasNoInterest(SeriesInterestDate interestDate, Interest interest) {
    return interestDate == null ||
        interestDate?.type == InterestDueTypes.without ||
        interest.type == InterestTypes.sacoc;
  }

  PaymentSeries newSeries(PaymentSeries series) {
    PaymentSeries newSeries = PaymentSeries().clone(series);

    newSeries.id = _getNewSeriesId();
    newSeries.dueDate.date = Jiffy(ProposalState().proposalDate);
    newSeries.numberOfPayments = 1;
    newSeries.prices.nominal.seriesValue = 1;
    newSeries.prices.nominal.seriesTotal = 1;
    newSeries.prices.future.seriesValue = 1;
    newSeries.isNew = true;

    return newSeries;
  }

  int _getNewSeriesId() {
    return PaymentState()
            .modifiedPaymentSeries
            .fold(0, (p, n) => n.id > p ? n.id : p) +
        1;
  }

  saveSeries(AccessMode accessMode) {
    switch (accessMode) {
      case AccessMode.create:
        PaymentState()
            .modifiedPaymentSeries
            .add(PaymentState().modifiedSelectedSeries);
        break;
      case AccessMode.edit:
        int index = PaymentState().modifiedPaymentSeries.indexWhere(
            (series) => series.id == PaymentState().modifiedSelectedSeries.id);

        PaymentState().modifiedPaymentSeries[index] =
            PaymentState().modifiedSelectedSeries;
        break;
      default:
        assert(accessMode is AccessMode);
    }

    PaymentState().modifiedPaymentSeries = calculateSeriesDatePrice(
      PaymentState().modifiedPaymentSeries,
      ProposalState().selectedPaymentPlan,
      ProposalState().selectedUnit,
      editingSeries: PaymentState().modifiedSelectedSeries,
    );

    PaymentState().saveSeries();
  }

  removeSeries() {
    PaymentState().modifiedPaymentSeries.removeWhere(
        (series) => series.id == PaymentState().modifiedSelectedSeries.id);

    PaymentState().modifiedPaymentSeries = calculateSeriesDatePrice(
      PaymentState().modifiedPaymentSeries,
      ProposalState().selectedPaymentPlan,
      ProposalState().selectedUnit,
    );

    PaymentState().removeSeries();
  }

  /// determines the series available for price dilution
  setAvailableSeriesToDilute() {
    PaymentState().availableSeriesToDilute = PaymentState()
        .modifiedPaymentSeries
        .where((series) => series.id != PaymentState().selectedSeries.id)
        .toList();
  }

  /// set the series to be diluted
  setSelectedSeriesToDilute(bool selected, PaymentSeries selectedSeries) {
    List<PaymentSeries> alreadySelected = PaymentState()
        .selectedSeriesToDilute
        .where((series) => series.id == selectedSeries.id)
        .toList();

    if (alreadySelected.isEmpty && selected) {
      PaymentState().selectedSeriesToDilute.add(selectedSeries);
    } else {
      if (alreadySelected.isNotEmpty && !selected) {
        PaymentState().selectedSeriesToDilute.remove(selectedSeries);
      }
    }
  }

  resetSelectedSeriesToDilute() {
    PaymentState().selectedSeriesToDilute = [];
  }

  /// returns the price difference for dilution
  double seriesPriceDifference(PriceDifferenceType type) {
    return SeriesCalcBloc().calculateSeriesPriceDifference(
      PaymentState().selectedSeries?.prices?.nominal?.seriesTotal ?? 0,
      PaymentState().modifiedSelectedSeries?.prices?.nominal?.seriesTotal ?? 0,
      type,
      PaymentState().modifiedSelectedSeries.isNew ?? false,
    );
  }

  /// Whether or not there's a price difference to dilute
  bool isPossibleToDilute() {
    return PaymentBloc().seriesPriceDifference(PriceDifferenceType.save) != 0 &&
        PaymentState().availableSeriesToDilute.length > 0;
  }

  /// If the user has selected any series to dilute over,
  /// it will attempt to perform the distribution of the
  /// price difference over the selected series
  bool diluteSeries(PriceDifferenceType type) {
    bool couldDiluteSeries = true;

    if (PaymentState().selectedSeriesToDilute.length > 0) {
      couldDiluteSeries = SeriesCalcBloc().diluteSeries(type);
    }

    return couldDiluteSeries;
  }

  bool isUpfrontType(SeriesTypes type) {
    return type == SeriesTypes.act || type == SeriesTypes.upfront;
  }

  List<String> validatePaymentPlan(BuildContext context) {
    PaymentPlan paymentPlan = ProposalState().selectedPaymentPlan;
    List<String> errorMessages = [];

    errorMessages.addAll(_validatePaymentPlanFixedValue(context, paymentPlan));
    errorMessages.addAll(_validatePaymentPlanPercentage(context, paymentPlan));

    return errorMessages;
  }

  List<String> _validatePaymentPlanFixedValue(
    BuildContext context,
    PaymentPlan paymentPlan,
  ) {
    List<String> errorMessages = [];
    List<SeriesTypes> seriesType = [];

    PaymentState()
        .modifiedPaymentSeries
        .where((series) => _cannotChangeFixedValue(series))
        .forEach((series) {
      if (seriesType.indexWhere((type) => type == series.type) == -1) {
        seriesType.add(series.type);
      }
    });

    seriesType.forEach((type) {
      List<PaymentSeries> series = PaymentState()
          .modifiedPaymentSeries
          .where((series) => series.type == type)
          .toList();

      String typeText;
      double totalValue = 0;
      double fixedValue = 0;

      for (PaymentSeries s in series) {
        typeText = s.text;
        fixedValue = s.fixedValue;
        totalValue += s.prices.nominal.seriesTotal;
      }

      MoneyMaskedTextController value = MoneyMaskedTextController(
        leftSymbol: 'R\$ ',
        initialValue: fixedValue,
        thousandSeparator: '.',
        decimalSeparator: ',',
      );

      if (totalValue != fixedValue) {
        Map<String, String> text = {
          '[type]': typeText,
          '[value]': value.text,
        };

        String message = I18n.of(context).interpolateText(
          I18n.of(context).fixedValueValidationError,
          text,
        );

        errorMessages.add(message);
      }
    });

    return errorMessages;
  }

  bool _cannotChangeFixedValue(PaymentSeries series) {
    return series.settings.typeValueSerie == TypeValueSerie.fixed &&
        !series.settings.changeValueFixed;
  }

  List<String> _validatePaymentPlanPercentage(
    BuildContext context,
    PaymentPlan paymentPlan,
  ) {
    List<String> errorMessages = [];

    List<PaymentSeries> percentageSeries = PaymentState()
        .modifiedPaymentSeries
        .where((series) => _isPercentageSeries(series))
        .toList();

    double totalPercentValue =
        percentageSeries.fold(0, (p, n) => p + n.prices.nominal.seriesTotal);

    List<PaymentSeries> seriesToValidate = [];

    for (SeriesTypes type in SeriesTypes.values) {
      List<PaymentSeries> seriesByType =
          percentageSeries.where((series) => series.type == type).toList();

      if (seriesByType.length > 0) {
        seriesByType[0].prices.nominal.seriesTotal = seriesByType.fold(
          0,
          (p, n) => p + n.prices.nominal.seriesTotal,
        );

        seriesToValidate.add(seriesByType[0]);
      }
    }

    List<PaymentSeries> percentageSeriesByType =
        _getSeriesTotalByType(percentageSeries);

    percentageSeriesByType.forEach((series) {
      if (_cannotChangePercentage(series)) {
        double currentPercentage = double.parse(
            ((series.prices.nominal.seriesTotal / totalPercentValue) * 100)
                .toStringAsFixed(2));

        if (currentPercentage < series.percent) {
          double minPrice = totalPercentValue * (series.percent / 100);

          MoneyMaskedTextController value = MoneyMaskedTextController(
            leftSymbol: 'R\$ ',
            initialValue: minPrice,
            thousandSeparator: '.',
            decimalSeparator: ',',
          );

          Map<String, String> text = {
            '[type]': series.text,
            '[percent]': series.percent.toString(),
            '[value]': value.text,
          };

          String message = I18n.of(context).interpolateText(
            I18n.of(context).percentageValidationError,
            text,
          );

          errorMessages.add(message);
        }
      }
    });

    return errorMessages;
  }

  bool _isPercentageSeries(PaymentSeries series) {
    // null check for backwards compatibility
    return series.settings.typeValueSerie == null ||
        series.settings.typeValueSerie == TypeValueSerie.percentage;
  }

  bool _cannotChangePercentage(PaymentSeries series) {
    return !series.settings.percentage;
  }

  bool _isSeriesModified(PaymentSeries series) {
    return series?.isModified ?? false;
  }

  List<PaymentSeries> _getSeriesTotalByType(
      List<PaymentSeries> percentageSeries) {
    List<PaymentSeries> percentageSeriesByType = [];

    percentageSeries.forEach((series) {
      if (percentageSeriesByType.indexWhere((s) => s.type == series.type) < 0) {
        percentageSeriesByType.add(series.clone(series));
      }
    });

    percentageSeriesByType.forEach((series) {
      List<PaymentSeries> seriesListByType =
          percentageSeries.where((s) => s.type == series.type).toList();

      double total =
          seriesListByType.fold(0, (p, n) => p + n.prices.nominal.seriesTotal);
      series.prices.nominal.seriesTotal = total;
    });

    return percentageSeriesByType;
  }

  SeriesTypes convertSeriesType(String type) {
    switch (type) {
      case "act":
        return SeriesTypes.act;
      case "bimonthly":
        return SeriesTypes.bimonthly;
      case "delivery":
        return SeriesTypes.delivery;
      case "eight-monthly":
        return SeriesTypes.eightMonthly;
      case "eleven-monthly":
        return SeriesTypes.elevenMonthly;
      case "FGTS":
        return SeriesTypes.fgts;
      case "financing":
        return SeriesTypes.financing;
      case "five-monthly":
        return SeriesTypes.fiveMonthly;
      case "monthly":
        return SeriesTypes.monthly;
      case "nine-monthly":
        return SeriesTypes.nineMonthly;
      case "periodically":
        return SeriesTypes.periodically;
      case "quarterly":
        return SeriesTypes.quarterly;
      case "semester":
        return SeriesTypes.semester;
      case "seven-monthly":
        return SeriesTypes.sevenMonthly;
      case "subsidy":
        return SeriesTypes.subsidy;
      case "ten-monthly":
        return SeriesTypes.tenMonthly;
      case "trimester":
        return SeriesTypes.trimester;
      case "unic":
        return SeriesTypes.unic;
      case "upfront":
        return SeriesTypes.upfront;
      case "without":
        return SeriesTypes.without;
      case "yearly":
        return SeriesTypes.yearly;
      default:
        return null;
    }
  }

  String convertSeriesTypeToString(SeriesTypes type) {
    switch (type) {
      case SeriesTypes.act:
        return "act";
      case SeriesTypes.bimonthly:
        return "bimonthly";
      case SeriesTypes.delivery:
        return "delivery";
      case SeriesTypes.eightMonthly:
        return "eight-monthly";
      case SeriesTypes.elevenMonthly:
        return "eleven-monthly";
      case SeriesTypes.fgts:
        return "FGTS";
      case SeriesTypes.financing:
        return "financing";
      case SeriesTypes.fiveMonthly:
        return "five-monthly";
      case SeriesTypes.monthly:
        return "monthly";
      case SeriesTypes.nineMonthly:
        return "nine-monthly";
      case SeriesTypes.periodically:
        return "periodically";
      case SeriesTypes.quarterly:
        return "quarterly";
      case SeriesTypes.semester:
        return "semester";
      case SeriesTypes.sevenMonthly:
        return "seven-monthly";
      case SeriesTypes.subsidy:
        return "subsidy";
      case SeriesTypes.tenMonthly:
        return "ten-monthly";
      case SeriesTypes.trimester:
        return "trimester";
      case SeriesTypes.unic:
        return "unic";
      case SeriesTypes.upfront:
        return "upfront";
      case SeriesTypes.without:
        return "without";
      case SeriesTypes.yearly:
        return "yearly";
      default:
        return null;
    }
  }

  DueTypes convertDueTypes(String type) {
    switch (type) {
      case "daysToStart":
        return DueTypes.daysToStart;
      case "startWithUpfront":
        return DueTypes.startWithUpfront;
      case "startAfterUpfront":
        return DueTypes.startAfterUpfront;
      case "monthsAfterConstruction":
        return DueTypes.monthsAfterConstruction;
      case "monthsAfterProposal":
        return DueTypes.monthsAfterProposal;
      default:
        return null;
    }
  }

  String convertDueTypesToString(DueTypes type) {
    switch (type) {
      case DueTypes.daysToStart:
        return "daysToStart";
      case DueTypes.startWithUpfront:
        return "startWithUpfront";
      case DueTypes.startAfterUpfront:
        return "startAfterUpfront";
      case DueTypes.monthsAfterConstruction:
        return "monthsAfterConstruction";
      case DueTypes.monthsAfterProposal:
        return "monthsAfterProposal";
      default:
        return null;
    }
  }

  InterestDueTypes convertInterestDueTypes(String type) {
    switch (type) {
      case "daysToStart":
        return InterestDueTypes.daysToStart;
      case "startWithUpfront":
        return InterestDueTypes.startWithUpfront;
      case "startAfterUpfront":
        return InterestDueTypes.startAfterUpfront;
      case "monthsAfterConstruction":
        return InterestDueTypes.monthsAfterConstruction;
      case "monthsAfterProposal":
        return InterestDueTypes.monthsAfterProposal;
      case "monthsAfterStartSeries":
        return InterestDueTypes.monthsAfterStartSeries;
      case "without":
        return InterestDueTypes.without;
      default:
        return null;
    }
  }

  String convertInterestDueTypesToString(InterestDueTypes type) {
    switch (type) {
      case InterestDueTypes.daysToStart:
        return "daysToStart";
      case InterestDueTypes.startWithUpfront:
        return "startWithUpfront";
      case InterestDueTypes.startAfterUpfront:
        return "startAfterUpfront";
      case InterestDueTypes.monthsAfterConstruction:
        return "monthsAfterConstruction";
      case InterestDueTypes.monthsAfterProposal:
        return "monthsAfterProposal";
      case InterestDueTypes.monthsAfterStartSeries:
        return "monthsAfterStartSeries";
      case InterestDueTypes.without:
        return "without";
      default:
        return null;
    }
  }

  PostDeliveryTypes convertPostDeliveryTypes(String type) {
    switch (type) {
      case "adjustPrice":
        return PostDeliveryTypes.adjustPrice;
      case "delivery":
        return PostDeliveryTypes.delivery;
      case "deliveryOrFinancing":
        return PostDeliveryTypes.deliveryOrFinancing;
      case "financing":
        return PostDeliveryTypes.financing;
      case "overcome":
        return PostDeliveryTypes.overcome;
      default:
        return null;
    }
  }

  String convertPostDeliveryTypesToString(PostDeliveryTypes type) {
    switch (type) {
      case PostDeliveryTypes.adjustPrice:
        return "adjustPrice";
      case PostDeliveryTypes.delivery:
        return "delivery";
      case PostDeliveryTypes.deliveryOrFinancing:
        return "deliveryOrFinancing";
      case PostDeliveryTypes.financing:
        return "financing";
      case PostDeliveryTypes.overcome:
        return "overcome";
      default:
        return null;
    }
  }

  TypeValueSerie convertTypeValueSerie(String type) {
    switch (type) {
      case "fixed":
        return TypeValueSerie.fixed;
        break;
      case "percentage":
        return TypeValueSerie.percentage;
        break;
      default:
        return null;
    }
  }

  String convertTypeValueSerieToString(TypeValueSerie type) {
    switch (type) {
      case TypeValueSerie.fixed:
        return "fixed";
        break;
      case TypeValueSerie.percentage:
        return "percentage";
        break;
      default:
        return null;
    }
  }

  InterestTypes convertInterestTypes(String type) {
    switch (type) {
      case "TP":
        return InterestTypes.tp;
      case "SAC":
        return InterestTypes.sac;
      case "SACOC":
        return InterestTypes.sacoc;
      default:
        return null;
    }
  }

  String convertInterestTypesToString(InterestTypes type) {
    switch (type) {
      case InterestTypes.tp:
        return "TP";
      case InterestTypes.sac:
        return "SAC";
      case InterestTypes.sacoc:
        return "SACOC";
      default:
        return null;
    }
  }
}
