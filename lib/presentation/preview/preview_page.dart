import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/edit/edit_page.dart';
import 'package:file_flow/presentation/preview/components/delete_dialog.dart';
import 'package:file_flow/presentation/preview/components/images_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../state/sync/sync_cubit.dart';

class PreviewPage extends StatefulWidget {
  final Document document;
  final NavigationRoute heroRoute;

  const PreviewPage(
      {super.key, required this.document, required this.heroRoute});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final _headerKey = GlobalKey();
  double? headerHeight;

  @override
  Widget build(BuildContext context) {
    if (headerHeight == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          final renderBox =
              _headerKey.currentContext!.findRenderObject() as RenderBox;
          headerHeight = renderBox.size.height;
          print(renderBox.size);
        }),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EditPage(
                  heroRoute: widget.heroRoute,
                  document: widget.document,
                ),
              ),
            ),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              showDialog<bool>(
                context: context,
                builder: (context) => const DeleteDialog(),
              ).then((d) {
                if (d == true) {
                  BlocProvider.of<SyncCubit>(context)
                      .deleteDocument(widget.document);
                  Navigator.of(context).pop();
                }
              });
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (widget.document.content != null)
              SliverAppBar(
                expandedHeight: headerHeight,
                collapsedHeight: headerHeight,
                floating: true,
                automaticallyImplyLeading: false,
                flexibleSpace:
                    headerHeight != null ? _buildHeader() : const SizedBox(),
              ),
            ImagesPreview(
              heroRoute: widget.heroRoute,
              images: widget.document.files,
            ),
            // Atrocious hack to compute the height beforehand
            SliverToBoxAdapter(
              child: Offstage(
                offstage: true,
                child: _buildHeader(_headerKey),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: widget.heroRoute,
        onPressed: () => Share.shareXFiles(
          widget.document.files.map((f) => XFile(f.path)).toList(),
          subject: widget.document.name,
          text: widget.document.name,
        ),
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget _buildHeader([Key? key]) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: widget.document.content!.qrs.map(
              (u) {
                if (u.startsWith('http')) {
                  final uri = Uri.parse(u);
                  return ActionChip(
                    avatar: const Icon(Icons.public),
                    label: Text(uri.host),
                    onPressed: () => Share.shareUri(uri),
                  );
                } else {
                  return ActionChip(
                    avatar: const Icon(Icons.text_fields),
                    label: Text(u),
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: u),
                    ),
                  );
                }
              },
            ).toList(),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: widget.document.tags
                .map(
                  (t) => Chip(
                    label: Text(t),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
