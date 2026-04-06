import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  const PdfViewerScreen({super.key, required this.url});
  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  bool _loading = true;
  int _total = 0;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final dir = await getTemporaryDirectory();
    final name = Uri.parse(widget.url).pathSegments.last;
    final path = '${dir.path}/$name';
    final file = File(path);

    final bool needsDownload = !file.existsSync() ||
        (file.existsSync() &&
            DateTime.now().difference(file.lastModifiedSync()).inHours >= 24);

    if (needsDownload) {
      await Dio().download(widget.url, path);
    }

    if (mounted) {
      setState(() {
        _localPath = path;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF — Page $_current of $_total'),
        actions: [IconButton(icon: const Icon(Icons.download), onPressed: () {})],
      ),
      body: _loading
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: AppColors.saffron),
            SizedBox(height: 16),
            Text('PDF लोड हो रहा है...'),
          ]))
        : PDFView(
            filePath: _localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            onPageChanged: (page, total) => setState(() { _current = (page ?? 0) + 1; _total = total ?? 0; }),
          ),
    );
  }
}
