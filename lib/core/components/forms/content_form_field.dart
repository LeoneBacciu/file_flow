import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../models/document.dart';
import '../../date_misc.dart';
import '../../functions.dart';
import '../separator.dart';

typedef DocumentContentState = FormFieldState<DocumentContent>;

class ContentFormField extends StatefulWidget {
  final DocumentContent? initialValue;
  final void Function(DocumentContent)? onChange;
  final File source;

  const ContentFormField({
    super.key,
    this.initialValue,
    this.onChange,
    required this.source,
  });

  @override
  State<ContentFormField> createState() => _ContentFormFieldState();
}

class _ContentFormFieldState extends State<ContentFormField> {
  late final dateInput = TextEditingController()
    ..text = widget.initialValue?.date.apply(DateMisc.format) ?? '';
  late final amountInput = TextEditingController()
    ..text = widget.initialValue?.amount.toStringAsFixed(2) ?? '';
  bool dateError = false, amountError = false;

  late DocumentContent documentContent = widget.initialValue ??
      DocumentContent(date: DateTime.now(), amount: 0, qrs: const []);

  @override
  void initState() {
    super.initState();
    widget.onChange?.call(documentContent);
    if (widget.initialValue == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => extractData(widget.source),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          child: Builder(builder: (context) {
            return TextField(
              controller: dateInput,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Conferma la data',
                errorText: dateError ? 'Data mancante' : null,
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dateInput.text.isNotEmpty
                      ? DateMisc.parse(dateInput.text)
                      : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  updateState(date: DateMisc.format(pickedDate));
                }
              },
            );
          }),
        ),
        const Separator.height(30),
        SizedBox(
          width: 300,
          child: TextFormField(
            controller: amountInput,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Conferma il costo',
              errorText: amountError ? 'Invalid amount' : null,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: (a) => updateState(),
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
        r'(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d');

    final amountRegex = RegExp(r'(\d+[.|,]\d\d)');

    // print(text);
    // print(
    //     'dates: ${dateRegex.allMatches(text).map((e) => text.substring(e.start, e.end))}');
    // print(
    //     'amounts: ${amountRegex.allMatches(text).map((e) => text.substring(e.start, e.end))}');

    final dateMatch = dateRegex.firstMatch(text);
    final amountMatch = amountRegex.firstMatch(text);
    DateTime? date;
    double? amount;
    List<String> qrs = [];

    if (dateMatch != null) {
      try {
        final formatted = text
            .substring(dateMatch.start, dateMatch.end)
            .replaceAll(RegExp(r'[- .]'), '/');
        date = DateMisc.parse(formatted);
      } catch (e) {
        dev.log('Wrong date format');
      }
    }

    if (amountMatch != null) {
      try {
        final formatted = text
            .substring(amountMatch.start, amountMatch.end)
            .replaceAll(RegExp(r','), '.');
        amount = double.parse(formatted);
      } catch (e) {
        dev.log('Wrong double format');
      }
    }

    textRecognizer.close();

    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

    final barcodes = await barcodeScanner.processImage(img);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;

      if (type == BarcodeType.url) {
        final barcodeUrl = barcode.value as BarcodeUrl;
        if (barcodeUrl.url != null) qrs.add(barcodeUrl.url!);
      }
      if (type == BarcodeType.text) {
        if (barcode.rawValue != null) qrs.add(barcode.rawValue!);
      }
    }

    barcodeScanner.close();

    updateState(
      date: date.apply(DateMisc.format),
      amount: amount?.toStringAsFixed(2),
      qrs: qrs,
    );
  }

  void updateState({String? date, String? amount, List<String>? qrs}) {
    if (date != null) dateInput.text = date;
    if (amount != null) amountInput.text = amount;
    DateTime? parsedDate;
    double? parsedAmount;
    try {
      parsedDate = DateMisc.parse(dateInput.text);
      setState(() => dateError = false);
    } catch (e) {
      dev.log(e.toString());
      setState(() => dateError = true);
    }
    try {
      parsedAmount = double.parse(amountInput.text);
      setState(() => amountError = false);
    } catch (e) {
      setState(() => amountError = true);
    }

    if (parsedDate != null && parsedAmount != null) {
      setState(
        () => documentContent = documentContent.copyWith(
          date: parsedDate,
          amount: parsedAmount,
          qrs: qrs,
        ),
      );
      widget.onChange?.call(documentContent);
    }
  }
}
