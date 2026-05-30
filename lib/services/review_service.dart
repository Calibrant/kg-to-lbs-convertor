import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _kHasRequestedReview = 'has_requested_review';
  static const String _kConversionCount = 'conversion_count';
  static const int _conversionThreshold = 5;

  final InAppReview _inAppReview = InAppReview.instance;

  /// Increments the conversion counter and triggers a review if threshold is met.
  /// Called by "Quick Converter" users.
  Future<
    void
  >
  incrementConversionAndCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we already requested a review in the past
      if (prefs.getBool(
            _kHasRequestedReview,
          ) ??
          false)
        return;

      int count =
          (prefs.getInt(
                _kConversionCount,
              ) ??
              0) +
          1;
      await prefs.setInt(
        _kConversionCount,
        count,
      );

      if (count >=
          _conversionThreshold) {
        await _requestInAppReview(
          prefs,
        );
      }
    } catch (
      e
    ) {
      // Silent catch to prevent app crashes during non-critical review logic
    }
  }

  /// Triggers a review immediately after a goal is saved.
  /// Called by "Tracker" users.
  Future<
    void
  >
  requestReviewAfterGoalSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getBool(
            _kHasRequestedReview,
          ) ??
          false)
        return;

      await _requestInAppReview(
        prefs,
      );
    } catch (
      e
    ) {
      // Silent catch
    }
  }

  /// Private helper to execute the native in-app review dialog.
  Future<
    void
  >
  _requestInAppReview(
    SharedPreferences prefs,
  ) async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      // Persist that we've requested it to avoid spamming in the future
      await prefs.setBool(
        _kHasRequestedReview,
        true,
      );
    }
  }

  /// Manually opens the store listing for the "Rate App" button.
  /// Bypasses the 'hasRequestedReview' flag.
  Future<
    void
  >
  openStoreListing() async {
    try {
      // Note: appStoreId is required for iOS.
      // For Android, it uses the package name automatically.
      await _inAppReview.openStoreListing();
    } catch (
      e
    ) {
      // Silent catch
    }
  }
}
