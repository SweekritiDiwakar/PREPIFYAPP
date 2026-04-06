import 'package:flutter/material.dart';
import 'package:prepify/services/nepali_calendar_service.dart';

class NepaliFestivalWidget extends StatelessWidget {
  const NepaliFestivalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final upcomingFestivals = NepaliCalendarService.getUpcomingFestivals();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Row(
          children: [
            const Text(
              "🎉 Nepali Festivals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Serif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (upcomingFestivals.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'No upcoming festivals in the next 60 days.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: upcomingFestivals.length,
            itemBuilder: (context, index) {
              final festival = upcomingFestivals[index];
              final name = festival['name'] as String;
              final date = festival['date'] as String;
              final daysUntil = festival['daysUntil'] as int;
              final suggestions =
                  NepaliCalendarService.getFestivalSuggestionsByName()[name] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$date (BS) • ${daysUntil == 0 ? 'Today!' : '$daysUntil days away'}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${suggestions.length} items',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.take(5).map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                          ),
                          child: Text(item, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        );
                      }).toList(),
                    ),
                    if (suggestions.length > 5) ...[
                      const SizedBox(height: 8),
                      Text(
                        '+${suggestions.length - 5} more items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
