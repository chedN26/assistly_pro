/// One point on the Forecast tab's Net Profit chart — either an
/// actual historical value ([isForecast] = false, drawn solid) or a
/// predicted value from the linear regression ([isForecast] = true,
/// drawn dashed).
class ForecastPoint {
  const ForecastPoint({
    required this.month,
    required this.netProfit,
    required this.isForecast,
  });

  final DateTime month;
  final double netProfit;
  final bool isForecast;
}
