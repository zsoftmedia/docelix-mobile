class ExchangeRateModel {
  final String base;
  final String quote;
  final double rate;
  final String requestedDate;
  final String rateDate;
  final String source;

  const ExchangeRateModel({
    required this.base,
    required this.quote,
    required this.rate,
    required this.requestedDate,
    required this.rateDate,
    required this.source,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      base: json['base']?.toString() ?? '',
      quote: json['quote']?.toString() ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      requestedDate: json['requested_date']?.toString() ?? '',
      rateDate: json['rate_date']?.toString() ?? '',
      source: json['source']?.toString() ?? 'ECB',
    );
  }
}