import 'package:flutter/material.dart';

import '../../date_misc.dart';
import '../separator.dart';
import 'search_context.dart';

class SearchDateRange extends StatefulWidget {
  const SearchDateRange({super.key});

  @override
  State<SearchDateRange> createState() => _SearchDateRangeState();
}

class _SearchDateRangeState extends State<SearchDateRange> {
  final startController = TextEditingController();
  final endController = TextEditingController();

  void onUpdate(DateTimeRange dateTimeRange) {
    startController.text = DateMisc.format(dateTimeRange.start);
    endController.text = DateMisc.format(dateTimeRange.end);
    SearchContext.of(context).dateTimeRange = dateTimeRange;
  }

  @override
  Widget build(BuildContext context) {
    final initialTime = DateTime.now().subtract(const Duration(days: 30));
    final dateTimeRange = SearchContext.of(context).dateTimeRange;
    if (dateTimeRange != null) {
      startController.text = DateMisc.format(dateTimeRange.start);
      endController.text = DateMisc.format(dateTimeRange.end);
    } else {
      startController.text = '';
      endController.text = '';
    }
    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: startController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Data Inizio',
            ),
            readOnly: true,
            onTap: () async {
              final pickedRange = await showDateRangePicker(
                context: context,
                initialDateRange: DateTimeRange(
                  start: dateTimeRange?.start ?? initialTime,
                  end: dateTimeRange?.end ?? DateTime.now(),
                ),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now(),
              );

              if (pickedRange != null) onUpdate(pickedRange);
            },
          ),
        ),
        const Separator.width(12),
        Flexible(
          child: TextField(
            controller: endController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Data Fine'),
            readOnly: true,
            onTap: () async {
              final pickedRange = await showDateRangePicker(
                context: context,
                initialDateRange: DateTimeRange(
                  start: dateTimeRange?.start ?? initialTime,
                  end: dateTimeRange?.end ?? DateTime.now(),
                ),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now(),
              );

              if (pickedRange != null) onUpdate(pickedRange);
            },
          ),
        ),
        IconButton(
          onPressed: () => SearchContext.of(context).dateTimeRange = null,
          icon: const Icon(Icons.cancel_outlined),
        ),
      ],
    );
  }
}
