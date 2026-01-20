import 'package:flutter_test/flutter_test.dart';

import 'package:city_watch/Services/Recognition/recognition_service.dart';

void main() {
  test('computeBadges: first contribution badge is earned', () {
    final badges = RecognitionService()
        .computeBadges(impactPoints: 0, contributionsCount: 1);
    final first = badges.firstWhere((b) => b.id == 'first_contribution');
    expect(first.earned, true);
  });

  test('computeBadges: impact_1000 earned only at 1000+', () {
    final badgesLow = RecognitionService()
        .computeBadges(impactPoints: 999, contributionsCount: 100);
    final b1 = badgesLow.firstWhere((b) => b.id == 'impact_1000');
    expect(b1.earned, false);

    final badgesHigh = RecognitionService()
        .computeBadges(impactPoints: 1000, contributionsCount: 100);
    final b2 = badgesHigh.firstWhere((b) => b.id == 'impact_1000');
    expect(b2.earned, true);
  });
}
