import 'dart:io';

import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

import '../../../core/components/separator.dart';

class ContentForm extends StatefulWidget {
  final File source;
  final DocumentContent initialValue;
  final void Function(DocumentContent) onChange;

  const ContentForm({
    super.key,
    required this.source,
    required this.onChange,
    required this.initialValue,
  });

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  late TextEditingController dateInput = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.initialValue.date));
  late TextEditingController amountInput =
      TextEditingController(text: widget.initialValue.amount.toString());
  late DateTime date = widget.initialValue.date;

  void updateListener() {
    if (amountInput.text.isNotEmpty) {
      widget.onChange(
        DocumentContent(
          date: date,
          amount: double.parse(amountInput.text),
          urls: const [],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    dateInput.addListener(updateListener);
    amountInput.addListener(updateListener);
    readFile(widget.source);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          child: TextFormField(
            controller: dateInput,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              icon: Icon(
                Icons.calendar_today,
              ),
              labelText: "Conferma la data",
            ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));

              setState(() {
                if (pickedDate != null) {
                  date = pickedDate;
                  dateInput.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                }
              });
            },
          ),
        ),
        const Separator.height(30),
        SizedBox(
          width: 300,
          child: TextFormField(
            controller: amountInput,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              icon: Icon(
                Icons.euro,
              ),
              labelText: "Conferma il costo",
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            ],
          ),
        )
      ],
    );
  }

  Future<void> readFile(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final img = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(img);

    String text = recognizedText.text.toLowerCase();

    final dateRegex = RegExp(
        r"(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d");

    final amountRegex = RegExp(r"(\d+\.?\d*)");

    print(
        'dates: ${dateRegex.allMatches(text).map((e) => text.substring(e.start, e.end))}');
    print(
        'amounts: ${amountRegex.allMatches(text).map((e) => text.substring(e.start, e.end))}');

    // for (TextBlock block in recognizedText.blocks) {
    //   final rect = block.boundingBox;
    //   final cornerPoints = block.cornerPoints;
    //   final text = block.text;
    //   final languages = block.recognizedLanguages;
    //
    //   var dateRegex = RegExp(
    //       r"(0[1-9]|1[012])[- /.] (0[1-9]|[12][0-9]|3[01])[- /.] (19|20)\d\d",
    //       caseSensitive: false);
    //   List<String> results = [];
    //
    //   for (final line in block.lines) {
    //     for (final word in line.elements) {
    //       results.add(word.text.trim().toLowerCase());
    //     }
    //   }

    // print(results);
    //
    // print(results.where((e) => dateRegex.hasMatch(e)));
    // }

    textRecognizer.close();
  }

  @override
  void dispose() {
    dateInput.dispose();
    amountInput.dispose();
    super.dispose();
  }
}
