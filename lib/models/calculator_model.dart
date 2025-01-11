class CalculatorModel {
  double? capital; // 本金
  double? riskPercentage; // 風險百分比
  double? riskRewardRatio; // 盈虧比
  double? entryPrice; // 進場價格
  double? stopLossPrice; // 止損價格

  // 計算止損百分比
  double? calculateStopLossPercentage() {
    if (entryPrice == null || stopLossPrice == null) return null;
    return (entryPrice! - stopLossPrice!).abs() / entryPrice! * 100;
  }

  // 計算倉位價值
  double? calculatePositionValue() {
    if (capital == null || riskRewardRatio == null) return null;
    double? stopLossPercentage = calculateStopLossPercentage();
    if (stopLossPercentage == null) return null;
    return capital! * riskPercentage! / (stopLossPercentage);
  }

  // 計算出場價格
  double? calculateExitPrice() {
    if (entryPrice == null || stopLossPrice == null || riskRewardRatio == null) {
      return null;
    }
    double priceDifference = (entryPrice! - stopLossPrice!).abs();
    if (entryPrice! > stopLossPrice!) {
      return entryPrice! + (priceDifference * riskRewardRatio!);
    } else {
      return entryPrice! - (priceDifference * riskRewardRatio!);
    }
  }
}
