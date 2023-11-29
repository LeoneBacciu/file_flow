import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/components/common.dart';
import '../../../models/document.dart';
import '../../preview/preview_page.dart';

class BankCard extends StatelessWidget {
  final Document document;

  const BankCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              heroRoute: NavigationRoute.bank,
              document: document,
            ),
          ),
        ),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Hero(
                  tag: '${NavigationRoute.bank}-${document.preview.path}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(document.preview, fit: BoxFit.cover),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: const TextStyle(fontSize: 30),
                      ),
                      Wrap(
                        spacing: 16,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM/yyyy')
                                .format(document.content!.date)),
                          ),
                          Chip(
                            avatar: const Icon(Icons.euro),
                            label: Text(
                                document.content!.amount.toStringAsFixed(2)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
