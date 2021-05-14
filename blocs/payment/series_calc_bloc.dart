import 'dart:math';

import 'package:jiffy/jiffy.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';

class SeriesCalcBloc {
  SeriesPrices calculateSeriesNominalPrice(
    PaymentPlan paymentPlan,
    PaymentSeries series,
    double unitPrice,
    double totalFixedValue,
  ) {
    double discountPrice = getUnitPrice(unitPrice, paymentPlan);

    double seriesDiscountedPrice = discountPrice - totalFixedValue;

    if (seriesDiscountedPrice < 0)
      print("totalFixedValue greater than discounted price");

    double unitSerieValue =
        series.settings.typeValueSerie == TypeValueSerie.fixed
            ? series.fixedValue
            : seriesDiscountedPrice * (series.percent / 100);
/*
    unitSerieValue = double.parse(
      unitSerieValue.toStringAsFixed(2),
    );
*/
    double seriesValue = unitSerieValue / series.numberOfPayments;
    double seriesTotal = series.numberOfPayments * seriesValue;

    return SeriesPrices()
      ..seriesValue = seriesValue
      ..seriesTotal = seriesTotal;
  }

  SeriesPrices calculateNominalPrice(
    int numberOfPayments,
    double currentPrice,
  ) {
    return SeriesPrices()
      ..seriesValue = double.parse(
        currentPrice.toStringAsFixed(2),
      )
      ..seriesTotal = double.parse(
        calculateSeriesTotalPrice(
          numberOfPayments,
          currentPrice,
        ).toStringAsFixed(2),
      );
  }

  double calculateSeriesTotalPrice(int numberOfPayments, double currentPrice) {
    var result = (currentPrice ?? 0) * numberOfPayments;

    return double.parse(result.toStringAsFixed(2));
  }

  SeriesPrices calculateSeriesTotalPriceToNominal(
    int numberOfPayments,
    double totalPrice,
  ) {
    totalPrice ??= 0;

    var result = totalPrice / numberOfPayments;

    return SeriesPrices()
      ..seriesValue = double.parse(result.toStringAsFixed(2))
      ..seriesTotal = double.parse(totalPrice.toStringAsFixed(2));
  }

  double calculateSeriesTotalFixedValue(List<PaymentSeries> series) {
    return series.fold(
      0,
      (p, n) => n.settings.typeValueSerie == TypeValueSerie.fixed
          ? p + n.fixedValue
          : p,
    );
  }

  /// Returns the sum of every series' total price in a given paymentPlan
  double getPaymentPlanTotalPrice(List<PaymentSeries> paymentSeries) {
    return paymentSeries.fold(0, (p, n) => p + n.prices.nominal.seriesTotal);
  }

  /// Returns the unit price with the addition(+) or discount(-) percentage applied
  double getUnitPrice(double price, PaymentPlan paymentPlan) {
    return paymentPlan.additionDiscountType == "V"
        ? price + (paymentPlan.additionDiscountCurrency ?? 0)
        : price + (price * (paymentPlan.additionDiscount ?? 0)) / 100;
  }

  /// Calculates the series interest
  SeriesPrices calculateSeriesFuturePrice(
    double interest,
    int numberOfPayments,
    double currentPrice,
    SeriesDueDate seriesDueDate,
    SeriesInterestDate seriesInterestDate,
    FuturePriceCalcType type,
    SeriesTypes seriesType,
  ) {
    Jiffy dueDate = Jiffy(seriesDueDate.date);
    Jiffy interestDate = Jiffy(seriesInterestDate.date);

    int interval = getMonthBySpecialType(seriesType);

    int numberOfPaymentsToRemove = _calculateNumberOfPaymentsToRemove(
      dueDate,
      interestDate,
      interval,
      numberOfPayments,
    );

    SeriesPrices result;

    if (numberOfPaymentsToRemove >= numberOfPayments) {
      result = SeriesPrices()
        ..seriesValue = currentPrice
        ..seriesTotal = currentPrice;
    } else {
      numberOfPayments -= numberOfPaymentsToRemove;
      dueDate.add(months: numberOfPaymentsToRemove * interval);

      double interestTaxPeriod = _calculateInterestTaxPeriod(
        dueDate,
        interestDate,
        interval,
        numberOfPayments,
        interest,
      );

      switch (type) {
        case FuturePriceCalcType.nominal:
          result = _calculateNominalPriceFromInterest(
            currentPrice,
            interestTaxPeriod,
            numberOfPayments,
          );
          break;
        case FuturePriceCalcType.future:
          result = _calculateFuturePriceFromInterest(
            currentPrice,
            interestTaxPeriod,
            numberOfPayments,
          );
          break;
        default:
          assert(type is FuturePriceCalcType);
      }
    }

    return result;
  }

  // If the interest date is after the due date,
  // this difference will be removed from the number of payments and
  // it'll later be added to the due date
  int _calculateNumberOfPaymentsToRemove(
    Jiffy dueDate,
    Jiffy interestDate,
    int interval,
    int numberOfPayments,
  ) {
    int numberOfPaymentsToRemove = 0;

    if (interestDate.isAfter(dueDate, Units.DAY)) {
      // ceil() will consider a whole month if it's less than a month's period of difference
      num diffMonths = interestDate.diff(dueDate, Units.MONTH, true).ceil();
      numberOfPaymentsToRemove = (diffMonths / interval).ceil();
    }

    return numberOfPaymentsToRemove;
  }

  double _calculateInterestTaxPeriod(
    Jiffy dueDate,
    Jiffy interestDate,
    int interval,
    int numberOfPayments,
    double interest,
  ) {
    const int decimalPrecision = 7;

    num firstInterval = (dueDate.month -
            interestDate.month +
            (dueDate.year - interestDate.year) * 12) /
        interval;
    num interestTax = interest / 100;
    num interestTaxPeriod = pow((1 + interestTax), interval) - 1;

    num part1 = pow((1 + interestTaxPeriod), (1 - firstInterval));
    num part2 = (1 - pow((1 + interestTaxPeriod), -numberOfPayments)) /
        interestTaxPeriod;

    num round = pow(10, decimalPrecision);

    return (part1 * part2 * round) / round;
  }

  _calculateNominalPriceFromInterest(
    double currentPrice,
    double interestTaxPeriod,
    int numberOfPayments,
  ) {
    double value = (currentPrice * interestTaxPeriod) / numberOfPayments;
    double total = value * numberOfPayments;

    return SeriesPrices()
      ..seriesValue = double.parse(value.toStringAsFixed(2))
      ..seriesTotal = double.parse(total.toStringAsFixed(2));
  }

  _calculateFuturePriceFromInterest(
    double currentPrice,
    double interestTaxPeriod,
    int numberOfPayments,
  ) {
    double value = (currentPrice / interestTaxPeriod) * numberOfPayments;

    return SeriesPrices()
      ..seriesValue = double.parse(value.toStringAsFixed(2))
      ..seriesTotal = double.parse(value.toStringAsFixed(2));
  }

  double calculateSeriesPriceDifference(
    double originalTotal,
    double selectedTotal,
    PriceDifferenceType type,
    bool isNew,
  ) {
    double priceDifference = 0;

    switch (type) {
      case PriceDifferenceType.save:
        if (isNew) {
          priceDifference = selectedTotal;
        } else {
          priceDifference = selectedTotal - originalTotal;
        }
        break;
      case PriceDifferenceType.remove:
        priceDifference = originalTotal * -1;
        break;
      default:
        assert(type is PriceDifferenceType);
    }

    return priceDifference;
  }

  /// calculates the series due date
  SeriesDueDate calculateSeriesDueDate(
    PaymentSeries series,
    int upfrontSeriesCount,
  ) {
    Jiffy time = Jiffy(ProposalState().proposalDate);
    Jiffy proposalDate = Jiffy(ProposalState().proposalDate);
    series.fixedDay ??= 0;

    switch (series.dueDate.type) {
      case DueTypes.daysToStart:
        time.add(days: series.dueDate.value);
        break;
      case DueTypes.startWithUpfront:
        if (upfrontSeriesCount != 0) {
          time = Jiffy(PaymentState().upfrontFirstDate);
        }
        break;
      case DueTypes.startAfterUpfront:
        if (upfrontSeriesCount != 0) {
          time = Jiffy(PaymentState().upfrontLastDate);
        }

        time = series.fixedDay > 0
            ? _getFixedDayDate(time, series.fixedDay)
            : time;
        break;
      case DueTypes.monthsAfterConstruction:
        Jiffy newBlockDeliveryDate = Jiffy(
          ProposalState().selectedBlock.deliveryDate,
        );
        newBlockDeliveryDate.add(months: series.dueDate.value);

        if (ProposalState().selectedBlock.deliveryDate != null) {
          if (proposalDate.isAfter(newBlockDeliveryDate, Units.DAY)) {
            newBlockDeliveryDate = proposalDate;
          }
        } else {
          newBlockDeliveryDate = proposalDate;
        }

        time = series.fixedDay > 0
            ? _getFixedDayDate(newBlockDeliveryDate, series.fixedDay)
            : Jiffy(newBlockDeliveryDate);
        break;
      case DueTypes.monthsAfterProposal:
        time.add(months: series.dueDate.value);
        time = series.fixedDay > 0
            ? _getFixedDayDate(time, series.fixedDay)
            : time;
        break;
      default:
        throw "invalid dueDate.type: ${series.dueDate.type}";
    }

    return new SeriesDueDate()
      ..type = series.dueDate.type
      ..value = series.dueDate.value
      ..date = time;
  }

  Jiffy _getFixedDayDate(Jiffy date, int fixedDay) {
    Jiffy fixedDayDate = Jiffy(date);
    int auxFixedDay = date.endOf(Units.MONTH).day;
    Jiffy proposalDate = Jiffy(ProposalState().proposalDate);

    auxFixedDay = auxFixedDay < fixedDay ? auxFixedDay : fixedDay;

    fixedDayDate =
        Jiffy({"year": date.year, "month": date.month, "day": auxFixedDay});

    if (proposalDate.isSameOrAfter(fixedDayDate, Units.MONTH)) {
      fixedDayDate.add(months: 1);
    }

    return fixedDayDate;
  }

  ///Calculates the interest date
  SeriesInterestDate calculateSeriesInterestDate(
    PaymentSeries series,
    int upfrontSeriesCount,
  ) {
    Jiffy time = Jiffy(ProposalState().proposalDate);
    Jiffy proposalDate = Jiffy(ProposalState().proposalDate);

    switch (series.interestDate.type) {
      case InterestDueTypes.daysToStart:
        time.add(days: series.interestDate.value);
        break;
      case InterestDueTypes.startWithUpfront:
        if (upfrontSeriesCount == 0) {
          time = _getNoUpfrontInterestDate();
        } else {
          time = Jiffy(PaymentState().upfrontFirstDate);
        }
        break;
      case InterestDueTypes.startAfterUpfront:
        if (upfrontSeriesCount == 0) {
          time = _getNoUpfrontInterestDate();
        } else {
          time = Jiffy(PaymentState().upfrontLastDate);
        }
        break;
      case InterestDueTypes.monthsAfterConstruction:
        Jiffy newBlockDeliveryDate =
            ProposalState().selectedBlock.deliveryDate == null
                ? proposalDate
                : Jiffy(ProposalState().selectedBlock.deliveryDate);
        newBlockDeliveryDate.add(months: series.interestDate.value);
        time = newBlockDeliveryDate;
        break;
      case InterestDueTypes.monthsAfterProposal:
        time.add(months: series.interestDate.value);
        break;
      case InterestDueTypes.monthsAfterStartSeries:
        time = Jiffy(series.dueDate.date);
        time.add(months: series.interestDate.value);
        break;
      case InterestDueTypes.without:
        break;
      default:
        throw "invalid interestDate.type: ${series.interestDate.type}";
    }

    return new SeriesInterestDate()
      ..type = series.interestDate.type
      ..value = series.interestDate.value
      ..date = time;
  }

  /// Get Interest Date when there's no upfront
  Jiffy _getNoUpfrontInterestDate() {
    Jiffy proposalDate = ProposalState().proposalDate;

    if (ProposalState().selectedBlock.deliveryDate != null) {
      if (proposalDate.isAfter(
          ProposalState().selectedBlock.deliveryDate, Units.DAY)) {
        return proposalDate;
      } else {
        return Jiffy(ProposalState().selectedBlock.deliveryDate);
      }
    } else {
      return proposalDate;
    }
  }

  /// This method will distribute the prices over the selected series
  /// in case the total value is insufficient for diluition, it'll return false
  bool diluteSeries(PriceDifferenceType type) {
    // The sum of the total nominal prices to dilute
    double seriesToDiluteTotalPrice = PaymentState()
        .selectedSeriesToDilute
        .fold(0, (prev, next) => prev + next.prices.nominal.seriesTotal);

    double priceDifference = PaymentBloc().seriesPriceDifference(type);

    for (var series in PaymentState().selectedSeriesToDilute) {
      double currentTotal = series.prices.nominal.seriesTotal;
      double percentage = currentTotal / seriesToDiluteTotalPrice;
      double valueToDilute = priceDifference * percentage;

      SeriesPrices future;
      SeriesPrices nominal;

      // check type then if its the remaining value
      double dilutedPrice = type == PriceDifferenceType.save
          ? currentTotal - valueToDilute
          : PaymentState().selectedSeriesToDilute.length == 1
              ? valueToDilute
              : currentTotal + valueToDilute;

      if (dilutedPrice < 0) {
        return false;
      }

      nominal = calculateSeriesTotalPriceToNominal(
        series.numberOfPayments,
        dilutedPrice,
      );

      if (series.interestDate == null ||
          series.interestDate.type == InterestDueTypes.without ||
          ProposalState().selectedPaymentPlan.interest.type ==
              InterestTypes.sacoc) {
        future = nominal;
      } else {
        if (type == PriceDifferenceType.remove) {
          if (PaymentBloc()
              .isUpfrontType(PaymentState().modifiedSelectedSeries.type)) {
            //TODO: REMOVE THE SERIES BEFORE DILUTING
            calculateOverallMinMaxUpfrontDueDate(
              PaymentState().modifiedPaymentSeries,
            );
          } else {
            if (PaymentState().selectedSeriesToDilute.length == 1) {
              series.interestDate.date = Jiffy(ProposalState().proposalDate);
            }
          }
        }

        future = calculateSeriesFuturePrice(
          ProposalState().selectedPaymentPlan.interest.value,
          series.numberOfPayments,
          nominal.seriesValue,
          series.dueDate,
          series.interestDate,
          FuturePriceCalcType.future,
          null,
        );
      }

      series.prices = PaymentSeriesPrices()
        ..nominal = nominal
        ..future = future;
    }

    return true;
  }

  /// It will distribute the selected series for post delivery
  distributePostDeliverySeries(PaymentPlan paymentPlan, PaymentSeries series) {
    if (series.settings.postDeliveryType == null ||
        series.settings.postDeliveryType == PostDeliveryTypes.overcome) {
      return;
    }
    // Difference between delivery month and series due date
    int numberOfPayments = _calculatePostDeliveryDiff(
      Jiffy(series.dueDate.date),
    );

    double postDeliverySeriesTotal = 0.0;

    // in case the blockDeliveryDate is before the proposalDate
    if (numberOfPayments <= 0) {
      numberOfPayments = 1;
      postDeliverySeriesTotal = series.prices.nominal.seriesTotal;
    } else {
      postDeliverySeriesTotal = this.calculateSeriesTotalPrice(
        numberOfPayments,
        series.prices.nominal.seriesValue,
      );
    }

    double differencePrice =
        series.prices.nominal.seriesTotal - postDeliverySeriesTotal;

    // Switch helpers
    PaymentSeries seriesFound;
    double seriesTotal;
    SeriesPrices seriesNominal;
    SeriesPrices seriesFuture;

    switch (series.settings.postDeliveryType) {

      /// It will adjust the price and the number of payments
      case PostDeliveryTypes.adjustPrice:
        seriesNominal = calculateSeriesTotalPriceToNominal(
          numberOfPayments,
          series.prices.nominal.seriesTotal,
        );

        if (seriesNominal == null) {
          throw ("Could not calculate series nominal price");
        }

        if (series.interestDate == null ||
            paymentPlan.interest.type == InterestTypes.sacoc) {
          seriesFuture = seriesNominal;
        } else {
          seriesFuture = calculateSeriesFuturePrice(
            paymentPlan.interest.value,
            numberOfPayments,
            seriesNominal.seriesValue,
            series.dueDate,
            series.interestDate,
            FuturePriceCalcType.future,
            series.type,
          );
        }

        if (seriesFuture == null) {
          throw ("Could not calculate series future price");
        }

        series.numberOfPayments = numberOfPayments;
        series.prices.nominal = seriesNominal;
        series.prices.future = seriesFuture;

        break;

      /// It will keep the number of payments and will distribute
      /// over financing or delivery
      case PostDeliveryTypes.delivery:
      case PostDeliveryTypes.financing:
        seriesFound = _findSeriesByType(
          paymentPlan,
          convertSeriesTypeToPostDeliveryType(
            series.settings.postDeliveryType,
          ),
        );

        if (seriesFound == null) {
          return;
        }

        seriesTotal = seriesFound.prices.nominal.seriesTotal;

        seriesNominal = calculateSeriesTotalPriceToNominal(
          seriesFound.numberOfPayments,
          seriesTotal + differencePrice,
        );

        if (seriesNominal == null) {
          throw ("Could not calculate series nominal price");
        }

        if (seriesFound.interestDate == null ||
            paymentPlan.interest.type == InterestTypes.sacoc) {
          seriesFuture = seriesNominal;
        } else {
          seriesFuture = calculateSeriesFuturePrice(
            paymentPlan.interest.value,
            seriesFound.numberOfPayments,
            seriesNominal.seriesValue,
            seriesFound.dueDate,
            seriesFound.interestDate,
            FuturePriceCalcType.future,
            seriesFound.type,
          );
        }

        if (seriesFuture == null) {
          throw ("Could not calculate series future price");
        }

        seriesFound.prices.nominal = seriesNominal;
        seriesFound.prices.future = seriesFuture;

        seriesNominal = this.calculateSeriesTotalPriceToNominal(
          numberOfPayments,
          series.prices.nominal.seriesTotal - differencePrice,
        );

        if (seriesNominal == null) {
          throw "Could not calculate series nominal price";
        }

        if (series.interestDate == null ||
            paymentPlan.interest.type == InterestTypes.sacoc) {
          seriesFuture = seriesNominal;
        } else {
          seriesFuture = this.calculateSeriesFuturePrice(
            paymentPlan.interest.value,
            numberOfPayments,
            seriesNominal.seriesValue,
            series.dueDate,
            series.interestDate,
            FuturePriceCalcType.future,
            series.type,
          );
        }

        if (seriesFuture == null) {
          throw "Could not calculate series future price";
        }

        series.numberOfPayments = numberOfPayments;
        series.prices.nominal = seriesNominal;
        series.prices.future = seriesFuture;
        break;

      /// It will keep the number of payments and the adjusted price will be distributed over conclusion
      /// and financing, proportionally
      case PostDeliveryTypes.deliveryOrFinancing:
        PaymentSeries delivery = _findSeriesByType(
          paymentPlan,
          SeriesTypes.delivery,
        );

        PaymentSeries financing = _findSeriesByType(
          paymentPlan,
          SeriesTypes.financing,
        );

        if (delivery == null && financing == null) {
          return;
        }

        double deliveryTotal =
            delivery == null ? 0.0 : delivery.prices.nominal.seriesTotal;
        double financingTotal =
            financing == null ? 0.0 : financing.prices.nominal.seriesTotal;
        double percentTotal = deliveryTotal + financingTotal;

        double deliveryPercent = deliveryTotal / percentTotal;
        double financingPercent = financingTotal / percentTotal;

        if (delivery != null) {
          double seriesTotal = delivery.prices.nominal.seriesTotal;
          double deliveryProportionalValue = differencePrice * deliveryPercent;

          var seriesNominal = this.calculateSeriesTotalPriceToNominal(
            delivery.numberOfPayments,
            seriesTotal + deliveryProportionalValue,
          );

          if (seriesNominal == null) {
            throw "Could not calculate series nominal price";
          }

          SeriesPrices seriesFuture;

          if (delivery.interestDate == null ||
              paymentPlan.interest.type == InterestTypes.sacoc) {
            seriesFuture = seriesNominal;
          } else {
            seriesFuture = this.calculateSeriesFuturePrice(
              paymentPlan.interest.value,
              delivery.numberOfPayments,
              seriesNominal.seriesValue,
              delivery.dueDate,
              delivery.interestDate,
              FuturePriceCalcType.future,
              series.type,
            );
          }

          if (seriesFuture == null) {
            throw "Could not calculate series future price";
          }

          delivery.prices.nominal = seriesNominal;
          delivery.prices.future = seriesFuture;
        }

        if (financing != null) {
          seriesTotal = financing.prices.nominal.seriesTotal;
          double financingProportionalValue =
              differencePrice * financingPercent;

          var seriesNominal = this.calculateSeriesTotalPriceToNominal(
            financing.numberOfPayments,
            seriesTotal + financingProportionalValue,
          );

          if (seriesNominal == null) {
            throw "Could not calculate series nominal price";
          }

          SeriesPrices seriesFuture;

          if (financing.interestDate == null ||
              paymentPlan.interest.type == InterestTypes.sacoc) {
            seriesFuture = seriesNominal;
          } else {
            seriesFuture = this.calculateSeriesFuturePrice(
              paymentPlan.interest.value,
              financing.numberOfPayments,
              seriesNominal.seriesValue,
              financing.dueDate,
              financing.interestDate,
              FuturePriceCalcType.future,
              series.type,
            );
          }

          if (seriesFuture == null) {
            throw "Could not calculate series future price";
          }

          financing.prices.nominal = seriesNominal;
          financing.prices.future = seriesFuture;
        }

        seriesNominal = this.calculateSeriesTotalPriceToNominal(
          numberOfPayments,
          series.prices.nominal.seriesTotal - differencePrice,
        );

        if (seriesNominal == null) {
          throw "Could not calculate series nominal price";
        }

        if (series.interestDate == null ||
            paymentPlan.interest.type == InterestTypes.sacoc) {
          seriesFuture = seriesNominal;
        } else {
          seriesFuture = this.calculateSeriesFuturePrice(
            paymentPlan.interest.value,
            numberOfPayments,
            seriesNominal.seriesValue,
            series.dueDate,
            series.interestDate,
            FuturePriceCalcType.future,
            series.type,
          );
        }

        if (seriesFuture == null) {
          throw "Could not calculate series future price";
        }

        series.numberOfPayments = numberOfPayments;
        series.prices.nominal = seriesNominal;
        series.prices.future = seriesFuture;

        break;
      default:
    }

    /// Calculate selected series new prices and future prices

    SeriesPrices nominal;
    SeriesPrices future;

    nominal = calculateNominalPrice(
      numberOfPayments,
      series.prices.nominal.seriesValue,
    );

    if (nominal == null) {
      throw ("Could not calculate series nominal");
    }

    if (series.interestDate == null ||
        series.interestDate.type == InterestDueTypes.without ||
        ProposalState().selectedPaymentPlan.interest.type ==
            InterestTypes.sacoc) {
      future = nominal;
    } else {
      future = calculateSeriesFuturePrice(
        paymentPlan.interest.value,
        numberOfPayments,
        nominal.seriesValue,
        series.dueDate,
        series.interestDate,
        FuturePriceCalcType.future,
        series.type,
      );
    }

    if (future == null) {
      throw ("Could not calculate series future");
    }

    // Save into the current instance
    series.numberOfPayments = numberOfPayments;
    series.prices.nominal = nominal;
    series.prices.future = future;

    return series;
  }

  /// It will calculate the difference between
  /// delivery date and series due date
  _calculatePostDeliveryDiff(Jiffy seriesDueDate) {
    Jiffy postDeliveryDate = Jiffy(ProposalState().selectedBlock.deliveryDate);
    postDeliveryDate.add(months: 1);

    return postDeliveryDate.diff(seriesDueDate, Units.MONTH);
  }

  /// Returns the first series of a given type
  PaymentSeries _findSeriesByType(PaymentPlan paymentPlan, SeriesTypes type) {
    return paymentPlan.series
        .firstWhere((series) => series.type == type, orElse: () => null);
  }

  /// Get the first(min) and last(max) upfront dueDate, considering numberOfPayments
  calculateOverallMinMaxUpfrontDueDate(List<PaymentSeries> paymentSeries) {
    Jiffy highDate = Jiffy(Jiffy().add(years: 1000));
    Jiffy lowDate = Jiffy(Jiffy().subtract(years: 1000));

    Jiffy minDueDate = Jiffy(highDate);
    Jiffy maxDueDate = Jiffy(lowDate);
    int maxNumberOfPayments = 0;

    _getMaxDueDate(Jiffy dueDate, int numberOfPayments) {
      return Jiffy(dueDate).add(months: numberOfPayments);
    }

    _setMaxDueDate(Jiffy dueDate, int numberOfPayments) {
      maxDueDate = dueDate;
      maxNumberOfPayments = numberOfPayments;
    }

    paymentSeries
        .where((series) => PaymentBloc().isUpfrontType(series.type))
        .forEach((series) {
      final current = Jiffy(series.dueDate.date);
      current.add(months: series.numberOfPayments);

      if (Jiffy(series.dueDate.date).isBefore(minDueDate, Units.DAY)) {
        minDueDate = Jiffy(series.dueDate.date);
      }

      if (current
          .isAfter(_getMaxDueDate(Jiffy(maxDueDate), maxNumberOfPayments))) {
        _setMaxDueDate(Jiffy(series.dueDate.date), series.numberOfPayments);
      }
    });

    PaymentState().upfrontFirstDate = minDueDate == highDate
        ? Jiffy(ProposalState().proposalDate)
        : Jiffy(minDueDate);
    PaymentState().upfrontLastDate = maxDueDate == lowDate
        ? Jiffy(ProposalState().proposalDate)
        : Jiffy(maxDueDate);
    PaymentState().upfrontLastDate.add(months: maxNumberOfPayments);
  }

  resetSeries() {
    PaymentState().upfrontFirstDate = null;
    PaymentState().upfrontLastDate = null;
  }

  SeriesTypes convertSeriesTypeToPostDeliveryType(
      PostDeliveryTypes postDeliveryType) {
    switch (postDeliveryType) {
      case PostDeliveryTypes.delivery:
        return SeriesTypes.delivery;
        break;
      case PostDeliveryTypes.financing:
        return SeriesTypes.financing;
        break;
      default:
        return postDeliveryType as SeriesTypes;
    }
  }

  int getMonthBySpecialType(SeriesTypes type) {
    switch (type) {
      case SeriesTypes.bimonthly:
        return 2;
      case SeriesTypes.trimester:
        return 3;
      case SeriesTypes.quarterly:
        return 4;
      case SeriesTypes.fiveMonthly:
        return 5;
      case SeriesTypes.semester:
        return 6;
      case SeriesTypes.sevenMonthly:
        return 7;
      case SeriesTypes.eightMonthly:
        return 8;
      case SeriesTypes.nineMonthly:
        return 9;
      case SeriesTypes.tenMonthly:
        return 10;
      case SeriesTypes.elevenMonthly:
        return 11;
      case SeriesTypes.yearly:
        return 12;
      default:
        return 1; // monthly
    }
  }

  int getMonthByPeriodicity(int numberOfPayments, int periodicity) {
    return (numberOfPayments / periodicity).floor();
  }
}
