import 'package:jiffy/jiffy.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';

class PaymentPlan {
  String name;
  Interest interest;
  double pvTax;
  Jiffy start;
  Jiffy end;
  List<PaymentSeries> series;
  String docId;
  double additionDiscount;
  String additionDiscountType;
  double additionDiscountCurrency;

  PaymentPlan clone(PaymentPlan paymentPlan) {
    return PaymentPlan()
      ..name = paymentPlan.name
      ..interest = paymentPlan.interest
      ..pvTax = paymentPlan.pvTax
      ..start = paymentPlan.start
      ..end = paymentPlan.end
      ..series = paymentPlan.series
          .map((series) => PaymentSeries().clone(series))
          .toList()
      ..docId = paymentPlan.docId
      ..additionDiscount = paymentPlan.additionDiscount
      ..additionDiscountType = paymentPlan.additionDiscountType
      ..additionDiscountCurrency = paymentPlan.additionDiscountCurrency;
  }
}

class PaymentSeries {
  int id;
  SeriesTypes type;
  String text;
  double percent;
  int numberOfPayments;
  SeriesDueDate dueDate;
  SeriesInterestDate interestDate;
  PaymentSeriesPrices prices;
  SeriesSettings settings;
  int fixedDay;
  double fixedValue;
  bool isNew;
  bool isModified;
  int serieTypeId;

  PaymentSeries clone(PaymentSeries series) {
    return PaymentSeries()
      ..id = series.id
      ..dueDate = (SeriesDueDate()
        ..date = series.dueDate.date
        ..type = series.dueDate.type
        ..value = series.dueDate.value)
      ..fixedDay = series.fixedDay
      ..fixedValue = series.fixedValue
      ..interestDate = (SeriesInterestDate()
        ..date = series.interestDate?.date
        ..type = series.interestDate?.type
        ..value = series.interestDate?.value)
      ..numberOfPayments = series.numberOfPayments
      ..percent = series.percent
      ..prices = (PaymentSeriesPrices()
        ..nominal = (SeriesPrices()
          ..seriesValue = series.prices?.nominal?.seriesValue ?? 0
          ..seriesTotal = series.prices?.nominal?.seriesTotal ?? 0)
        ..future = (SeriesPrices()
          ..seriesValue = series.prices?.future?.seriesValue ?? 0
          ..seriesTotal = series.prices?.future?.seriesTotal ?? 0))
      ..settings = (SeriesSettings()
        ..adjustments = series.settings.adjustments
        ..changeValueFixed = series.settings.changeValueFixed
        ..fixedDay = series.settings.fixedDay
        ..interval = series.settings.interval
        ..minPrice = series.settings.minPrice
        ..numberOfPayments = series.settings.numberOfPayments
        ..percentage = series.settings.percentage
        ..postDeliveryType = series.settings.postDeliveryType
        ..residue = series.settings.residue
        ..startDate = series.settings.startDate
        ..typeValueSerie = series.settings.typeValueSerie)
      ..serieTypeId = series.serieTypeId
      ..text = series.text
      ..type = series.type
      ..isNew = series.isNew
      ..isModified = series.isModified;
  }
}

class PaymentPlanWithDateTime {
  String name;
  Interest interest;
  double pvTax;
  DateTime start;
  DateTime end;
  List<PaymentSeriesWithDateTime> series;
  String docId;
  double additionDiscount;
  String additionDiscountType;
  double additionDiscountCurrency;

  PaymentPlanWithDateTime clone(PaymentPlan paymentPlan) {
    return PaymentPlanWithDateTime()
      ..name = paymentPlan.name
      ..interest = paymentPlan.interest
      ..pvTax = paymentPlan.pvTax
      ..start = paymentPlan.start.dateTime
      ..end = paymentPlan.end.dateTime
      ..series = paymentPlan.series
          .map((series) => PaymentSeriesWithDateTime().clone(series))
          .toList()
      ..docId = paymentPlan.docId
      ..additionDiscount = paymentPlan.additionDiscount
      ..additionDiscountType = paymentPlan.additionDiscountType
      ..additionDiscountCurrency = paymentPlan.additionDiscountCurrency;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'interest': this.interest.toMap(),
      'pvTax': this.pvTax,
      'start': this.start,
      'end': this.end,
      'series': this
          .series
          .map((series) => PaymentSeriesWithDateTime().toMap(series))
          .toList(),
      'docId': this.docId,
      'additionDiscount': this.additionDiscount,
      'additionDiscountType': this.additionDiscountType,
      'additionDiscountCurrency': this.additionDiscountCurrency
    };
  }
}

class PaymentSeriesWithDateTime {
  int id;
  SeriesTypes type;
  String text;
  double percent;
  int numberOfPayments;
  SeriesDueDateWithDateTime dueDate;
  SeriesInterestDateWithDateTime interestDate;
  PaymentSeriesPrices prices;
  SeriesSettings settings;
  int fixedDay;
  double fixedValue;
  bool isNew;
  bool isModified;
  int serieTypeId;

  PaymentSeriesWithDateTime clone(PaymentSeries series) {
    return PaymentSeriesWithDateTime()
      ..id = series.id
      ..type = series.type
      ..text = series.text
      ..percent = series.percent
      ..numberOfPayments = series.numberOfPayments
      ..dueDate = (SeriesDueDateWithDateTime()
        ..date = series.dueDate.date.dateTime
        ..type = series.dueDate.type
        ..value = series.dueDate.value)
      ..interestDate = (SeriesInterestDateWithDateTime()
        ..date = series.interestDate?.date?.dateTime
        ..type = series.interestDate?.type
        ..value = series.interestDate?.value)
      ..prices = (PaymentSeriesPrices()
        ..nominal = (SeriesPrices()
          ..seriesValue = series.prices?.nominal?.seriesValue ?? 0
          ..seriesTotal = series.prices?.nominal?.seriesTotal ?? 0)
        ..future = (SeriesPrices()
          ..seriesValue = series.prices?.future?.seriesValue ?? 0
          ..seriesTotal = series.prices?.future?.seriesTotal ?? 0))
      ..settings = (SeriesSettings()
        ..adjustments = series.settings.adjustments
        ..interval = series.settings.interval
        ..minPrice = series.settings.minPrice
        ..numberOfPayments = series.settings.numberOfPayments
        ..percentage = series.settings.percentage
        ..residue = series.settings.residue
        ..startDate = series.settings.startDate
        ..postDeliveryType = series.settings.postDeliveryType
        ..typeValueSerie = series.settings.typeValueSerie
        ..changeValueFixed = series.settings.changeValueFixed
        ..fixedDay = series.settings.fixedDay)
      ..fixedValue = series.fixedValue
      ..isNew = series.isNew
      ..isModified = series.isModified
      ..serieTypeId = series.serieTypeId;
  }

  Map<String, dynamic> toMap(PaymentSeriesWithDateTime series) {
    return {
      'id': series.id,
      'type': PaymentBloc().convertSeriesTypeToString(series.type),
      'text': series.text,
      'percent': series.percent,
      'numberOfPayments': series.numberOfPayments,
      'dueDate': series.dueDate.toMap(),
      'interestDate': series.interestDate.toMap(),
      'prices': series.prices.toMap(),
      'settings': series.settings.toMap(),
      'fixedValue': series.fixedValue,
      'serieTypeId': series.serieTypeId,
    };
  }
}

class Interest {
  InterestTypes type;
  double value;

  Map<String, dynamic> toMap() {
    return {
      'type': PaymentBloc().convertInterestTypesToString(this.type),
      'value': this.value,
    };
  }
}

class SeriesSettings {
  bool adjustments;
  bool interval;
  double minPrice;
  bool numberOfPayments;
  bool percentage;
  bool residue;
  bool startDate;
  PostDeliveryTypes postDeliveryType;
  TypeValueSerie typeValueSerie;
  bool changeValueFixed;
  bool fixedDay;

  Map<String, dynamic> toMap() {
    return {
      'adjustments': this.adjustments,
      'interval': this.interval,
      'minPrice': this.minPrice,
      'numberOfPayments': this.numberOfPayments,
      'percentage': this.percentage,
      'residue': this.residue,
      'startDate': this.startDate,
      'postDeliverTypes':
          PaymentBloc().convertPostDeliveryTypesToString(this.postDeliveryType),
      'typeValueSerie':
          PaymentBloc().convertTypeValueSerieToString(this.typeValueSerie),
      'changeValueFixed': this.changeValueFixed,
      'fixedDay': this.fixedDay,
    };
  }
}

class PaymentSeriesPrices {
  SeriesPrices nominal;
  SeriesPrices future;

  Map<String, dynamic> toMap() {
    return {
      'nominal': this.nominal.toMap(),
      'future': this.future.toMap(),
    };
  }
}

class SeriesPrices {
  double seriesValue;
  double seriesTotal;

  Map<String, dynamic> toMap() {
    return {
      'seriesValue': this.seriesValue,
      'seriesTotal': this.seriesTotal,
    };
  }
}

class SeriesDueDate {
  Jiffy date;
  DueTypes type;
  int value;
}

class SeriesInterestDate {
  Jiffy date;
  InterestDueTypes type;
  int value;
}

class SeriesDueDateWithDateTime {
  DateTime date;
  DueTypes type;
  int value;

  Map<String, dynamic> toMap() {
    return {
      'date': this.date,
      'type': PaymentBloc().convertDueTypesToString(this.type),
      'value': this.value,
    };
  }
}

class SeriesInterestDateWithDateTime {
  DateTime date;
  InterestDueTypes type;
  int value;

  Map<String, dynamic> toMap() {
    return {
      'date': this.date,
      'type': PaymentBloc().convertInterestDueTypesToString(this.type),
      'value': this.value,
    };
  }
}

enum InterestTypes { tp, sac, sacoc }

enum SeriesTypes {
  upfront,
  act,
  monthly,
  bimonthly,
  trimester,
  quarterly,
  fiveMonthly,
  semester,
  sevenMonthly,
  eightMonthly,
  nineMonthly,
  tenMonthly,
  elevenMonthly,
  yearly,
  periodically,
  unic,
  financing,
  fgts,
  subsidy,
  delivery,
  without
}

enum PostDeliveryTypes {
  overcome,
  adjustPrice,
  delivery,
  financing,
  deliveryOrFinancing
}

enum TypeValueSerie {
  fixed,
  percentage,
}

enum DueTypes {
  daysToStart,
  startWithUpfront,
  startAfterUpfront,
  monthsAfterConstruction,
  monthsAfterProposal
}

enum InterestDueTypes {
  daysToStart,
  startWithUpfront,
  startAfterUpfront,
  monthsAfterConstruction,
  monthsAfterProposal,
  monthsAfterStartSeries,
  without
}

enum AccessMode {
  create,
  edit,
  view,
}

enum FuturePriceCalcType {
  nominal,
  future,
}

enum PriceDifferenceType {
  save,
  remove,
}
