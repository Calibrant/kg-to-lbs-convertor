class WeightConverter {
  static const double _factor = 2.20462;

  static double kgToLbs(double kg) {
    return kg * _factor;
  }

  static double lbsToKg(double lbs) {
    return lbs / _factor;
  }

  static String format(double value) => value.toStringAsFixed(2);
}