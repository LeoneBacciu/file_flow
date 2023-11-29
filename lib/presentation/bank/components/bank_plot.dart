import 'package:collection/collection.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';

import '../../../core/date_misc.dart';
import '../../../models/document.dart';

class BankPlot extends StatelessWidget {
  final DocumentList documents;

  const BankPlot({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: charts.TimeSeriesChart(
          makeSeries(documents),
          animate: true,
          domainAxis: charts.DateTimeAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onSurface,
                ),
              ),
              lineStyle: charts.LineStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.onSurface,
                ),
                dashPattern: const [5, 5],
              ),
            ),
          ),
          defaultRenderer: charts.BarRendererConfig<DateTime>(
            groupingType: charts.BarGroupingType.stacked,
          ),
          behaviors: [
            charts.SeriesLegend(
              outsideJustification: charts.OutsideJustification.middleDrawArea,
            ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<DocumentPlotElement, DateTime>> makeSeries(
      DocumentList documents) {
    final initialDate = DateTime.now().subtract(const Duration(days: 365));
    final groups = groupBy(
      documents
          .where(
            (d) => d.content!.date.isAfter(initialDate),
          )
          .expand(
            (d) => d.tags.map(
              (t) => DocumentPlotElement(
                  d.content!.date, d.content!.amount / d.tags.length, t),
            ),
          ),
      (de) => de.tag,
    );
    return groups.entries
        .map(
          (e) => charts.Series<DocumentPlotElement, DateTime>(
            id: e.key,
            domainFn: (d, _) => d.date.copyWith(day: 1),
            measureFn: (d, _) => d.amount,
            data: e.value + [DocumentPlotElement(initialDate, 0, '')],
          ),
        )
        .toList();
  }
}

class DocumentPlotElement {
  final DateTime date;
  final double amount;
  final String tag;

  DocumentPlotElement(this.date, this.amount, this.tag);

  @override
  String toString() {
    return DateMisc.format(date);
  }
}
