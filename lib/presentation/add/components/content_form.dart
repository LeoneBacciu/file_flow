import 'dart:io';
import 'dart:developer' as dev;

import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../core/components/separator.dart';
import '../../../core/date_ui.dart';

class ContentForm extends StatefulWidget {
  final File source;
  final void Function(DocumentContent) onChange;

  const ContentForm({super.key, required this.source, required this.onChange});

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController amountInput = TextEditingController();

  final urls = <Uri>[];

  void updateListener() {
    if (dateInput.text.isNotEmpty && amountInput.text.isNotEmpty) {
      widget.onChange(
        DocumentContent(
          date: DateUi.parse(dateInput.text),
          amount: double.parse(amountInput.text),
          urls: urls,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    dateInput.addListener(updateListener);
    amountInput.addListener(updateListener);
    extractData(widget.source);
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
                  dateInput.text = DateUi.format(pickedDate);
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

  Future<void> extractData(File file) async {
    final img = InputImage.fromFile(file);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(img);

    String text = recognizedText.text.toLowerCase();

    final dateRegex = RegExp(
        r"(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d");

    final amountRegex = RegExp(r"(\d+[.|,]\d\d)");

    // print(text);
    // print(
    //     'dates: ${dateRegex.allMatches(text).map((e) => text.substring(e.start, e.end))}');
    // print(
    //     'amounts: ${amountRegex.allMatches(text).map((e) => text.substring(e.start, e.end))}');

    final dateMatch = dateRegex.firstMatch(text);
    final amountMatch = amountRegex.firstMatch(text);

    if (dateMatch != null) {
      try {
        final formatted = text
            .substring(dateMatch.start, dateMatch.end)
            .replaceAll(RegExp(r"[- .]"), '/');
        final validated = DateUi.format(DateUi.parse(formatted));
        dateInput.text = validated;
      } catch (e) {
        dev.log('Wrong date format');
      }
    }

    if (amountMatch != null) {
      try {
        final formatted = text
            .substring(amountMatch.start, amountMatch.end)
            .replaceAll(RegExp(r","), '.');
        final validated = double.parse(formatted).toStringAsFixed(2);
        amountInput.text = validated;
      } catch (e) {
        dev.log('Wrong double format');
      }
    }

    textRecognizer.close();

    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

    final barcodes = await barcodeScanner.processImage(img);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      print(barcode.rawValue);

      if (type == BarcodeType.url) {
        final barcodeUrl = barcode.value as BarcodeUrl;
        if (barcodeUrl.url != null) urls.add(Uri.parse(barcodeUrl.url!));
      }
    }

    barcodeScanner.close();
  }

  @override
  void dispose() {
    dateInput.dispose();
    amountInput.dispose();
    super.dispose();
  }
}
