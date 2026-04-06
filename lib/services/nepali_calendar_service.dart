import 'package:nepali_utils/nepali_utils.dart';

class NepaliCalendarService {
  NepaliCalendarService._();

  // Nepali (BS) festivals: month is BS month (1=Baisakh ... 12=Chaitra)
  static final List<Map<String, Object>> _festivals = [
    {
      'name': 'Dashain',
      'bsMonth': 6, // Ashwin
      'bsDay': 1,
      'suggestions': ['Mutton', 'Sel roti', 'Aalu tama', 'Yak cheese'],
    },
    {
      'name': 'Tihar',
      'bsMonth': 7, // Kartik
      'bsDay': 10,
      'suggestions': ['Sweets', 'Ghee', 'Dahi', 'Kheer'],
    },
    {
      'name': 'Maghe Sankranti',
      'bsMonth': 9, // Poush
      'bsDay': 1,
      'suggestions': ['Tilko laddu', 'Ghee', 'Sweet rice'],
    },
    {
      'name': 'Chhath',
      'bsMonth': 7, // Kartik
      'bsDay': 16,
      'suggestions': ['Bananas', 'Sugarcane', 'Seasonal fruits'],
    },
    {
      'name': 'Holi',
      'bsMonth': 11, // Falgun
      'bsDay': 15,
      'suggestions': ['Sweets', 'Thandai', 'Gujiya'],
    },
  ];

  /// Returns today's date in Nepali (BS) calendar as a formatted string.
  static String getTodayNepaliDate() {
    final today = NepaliDateTime.now();
    return NepaliDateFormat('MMMM d, y').format(today);
  }

  /// Converts a Gregorian [DateTime] to a BS date string.
  static String toNepaliDate(DateTime gregorian) {
    final bs = gregorian.toNepaliDateTime();
    return NepaliDateFormat('MMMM d, y').format(bs);
  }

  /// Returns upcoming festivals within [lookAheadDays] days (using BS calendar).
  static List<Map<String, Object>> getUpcomingFestivals({int lookAheadDays = 60}) {
    final today = NepaliDateTime.now();
    final upcoming = <Map<String, Object>>[];

    for (final festival in _festivals) {
      final bsMonth = festival['bsMonth'] as int;
      final bsDay = festival['bsDay'] as int;

      // Try current BS year first, then next year
      for (final yearOffset in [0, 1]) {
        try {
          final candidate = NepaliDateTime(today.year + yearOffset, bsMonth, bsDay);
          final candidateGregorian = candidate.toDateTime();
          final todayGregorian = today.toDateTime();
          final diff = candidateGregorian.difference(
            DateTime(todayGregorian.year, todayGregorian.month, todayGregorian.day),
          ).inDays;

          if (diff >= 0 && diff <= lookAheadDays) {
            upcoming.add({
              'name': festival['name'] as String,
              'date': NepaliDateFormat('MMMM d').format(candidate),
              'daysUntil': diff,
            });
            break;
          } else if (diff > lookAheadDays) {
            break;
          }
        } catch (_) {
          // Skip invalid BS dates
        }
      }
    }

    upcoming.sort((a, b) => (a['daysUntil'] as int).compareTo(b['daysUntil'] as int));
    return upcoming;
  }

  static List<String> fetchFestivalGrocerySuggestions() {
    final upcoming = getUpcomingFestivals();
    final Set<String> suggestions = {};
    for (final festival in upcoming) {
      final name = festival['name'] as String;
      final items = getFestivalSuggestionsByName()[name] ?? [];
      suggestions.addAll(items);
    }
    return suggestions.toList()..sort();
  }

  static Map<String, List<String>> getFestivalSuggestionsByName() {
    return Map.fromEntries(_festivals.map((festival) {
      return MapEntry(
        festival['name'] as String,
        (festival['suggestions'] as List<Object?>).cast<String>(),
      );
    }));
  }
}
