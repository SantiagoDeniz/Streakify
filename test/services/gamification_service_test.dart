import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streakify/services/gamification_service.dart';
import 'package:streakify/models/gamification.dart';

void main() {
  group('GamificationService Tests', () {
    late GamificationService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = GamificationService();
    });

    test('should start with 0 points', () async {
      final points = await service.getTotalPoints();
      expect(points, 0);
    });

    test('should award medal and points', () async {
      await service.awardMedal('test_achievement', MedalTier.bronze);

      final medals = await service.getMedals();
      expect(medals.length, 1);
      expect(medals.first.achievementId, 'test_achievement');
      expect(medals.first.tier, MedalTier.bronze);

      final points = await service.getTotalPoints();
      expect(points, MedalTier.bronze.points);
    });

    test('should not award duplicate medal', () async {
      await service.awardMedal('test_achievement', MedalTier.bronze);
      await service.awardMedal('test_achievement', MedalTier.bronze);

      final medals = await service.getMedals();
      expect(medals.length, 1);

      final points = await service.getTotalPoints();
      expect(points, MedalTier.bronze.points); // Points only added once
    });

    test('getMedalTierForValue returns correct tier', () {
      // Bronze: >= 2x (e.g. 20 / 10)
      expect(service.getMedalTierForValue(20, 10), MedalTier.silver); 
      // Wait, logic in code: ratio >= 2 is Silver? 
      // Code says:
      // if (ratio >= 10) return MedalTier.platinum;
      // if (ratio >= 5) return MedalTier.gold;
      // if (ratio >= 2) return MedalTier.silver;
      // return MedalTier.bronze;
      
      expect(service.getMedalTierForValue(10, 10), MedalTier.bronze); // Ratio 1
      expect(service.getMedalTierForValue(20, 10), MedalTier.silver); // Ratio 2
      expect(service.getMedalTierForValue(50, 10), MedalTier.gold); // Ratio 5
      expect(service.getMedalTierForValue(100, 10), MedalTier.platinum); // Ratio 10
    });
    
    test('awardStreakMedal awards correct medal based on streak', () async {
      await service.awardStreakMedal(7, 'streak_7');
      var medals = await service.getMedals();
      expect(medals.last.tier, MedalTier.bronze);
      
      await service.awardStreakMedal(30, 'streak_30');
      medals = await service.getMedals();
      expect(medals.last.tier, MedalTier.silver);
    });
  });
}
