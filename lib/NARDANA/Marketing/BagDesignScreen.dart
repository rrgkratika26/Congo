import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:IMS/NARDANA/Marketing/ModelFIBCBag/BagModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../Color/Colorclass.dart';
import 'BagPainter.dart';

class BagComponentInfo {
  final String name;
  final String gsm;
  final String material;

  const BagComponentInfo({
    required this.name,
    required this.gsm,
    required this.material,
  });

  bool get isApplicable => gsm.trim() != '0' && gsm.trim().isNotEmpty;

  bool get isCoated {
    final m = material.toLowerCase();
    return m.contains('coat') && !m.contains('uncoat');
  }
}

class FibcBagSpecification {
  final String inquiryId;
  final num length;
  final num width;
  final num height;
  final num loopFreeHeight;
  final num longLegHeight;
  final num shortLegHeight;
  final num fillingSpoutDiameter;
  final num fillingSpoutHeight;
  final num dischargeSpoutDiameter;
  final num dischargeSpoutHeight;
  final String construction;
  final String bagType;
  final num safeWorkingLoad;
  final num total;
  final String safetyFactor;
  final String loopColor;
  final List<BagComponentInfo> components;

  const FibcBagSpecification({
    required this.inquiryId,
    required this.length,
    required this.width,
    required this.height,
    this.loopFreeHeight = 0,
    this.longLegHeight = 0,
    this.shortLegHeight = 0,
    this.fillingSpoutDiameter = 0,
    this.fillingSpoutHeight = 0,
    this.dischargeSpoutDiameter = 0,
    this.dischargeSpoutHeight = 0,
    this.construction = 'Rectangular Standard',
    this.bagType = '4-Panel',
    this.safeWorkingLoad = 0,
    this.total = 0,
    this.safetyFactor = '',
    this.loopColor = '',
    this.components = const [],
  });

  /// Old shape: flat map with exact-case keys (SIZE_L, Inquiry_ID, ...).
  /// Kept for backward compatibility with any existing callers.
  factory FibcBagSpecification.fromApiJson(Map<String, dynamic> data) {
    return FibcBagSpecification.fromApiResponse(
      {'bagDetails': data, 'components': const []},
    );
  }

  /// Real API shape:
  /// { "bagDetails": { "sizE_L": "90", "looP_LL": "77", "typee": "U+2", ... },
  ///   "components": [ { "roW_LIST": "BODY", "gsm": "155", "material": "uncoated" }, ... ] }
  ///
  /// The backend mixes casing between fields (sizE_L vs SIZE_L), so every
  /// lookup here is case-insensitive.
  factory FibcBagSpecification.fromApiResponse(
      Map<String, dynamic> json, {
        String? inquiryId,
      }) {
    final rawDetails = json['bagDetails'];
    final details = (rawDetails is Map)
        ? rawDetails.cast<String, dynamic>()
        : json;
    final rawComponents = json['components'];
    final componentsJson = (rawComponents is List) ? rawComponents : const [];

    final normalized = <String, dynamic>{
      for (final entry in details.entries) entry.key.toUpperCase(): entry.value,
    };
    dynamic field(String key) => normalized[key.toUpperCase()];

    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.tryParse(value.toString()) ?? 0;
    }

    String parseString(dynamic value) => value?.toString().trim() ?? '';

    final construction = parseString(field('TYPEE'));
    final bagType = parseString(field('BAG_TYPE'));

    return FibcBagSpecification(
      inquiryId: inquiryId ?? parseString(field('INQUIRY_ID')),
      length: parseNum(field('SIZE_L')),
      width: parseNum(field('SIZE_W')),
      height: parseNum(field('SIZE_H')),
      loopFreeHeight: parseNum(field('LOOP_FREE_HEIGHT')),
      longLegHeight: parseNum(field('LOOP_LL')),
      shortLegHeight: parseNum(field('LOOP_SL')),
      fillingSpoutDiameter: parseNum(field('F_S_SIZE_D')),
      fillingSpoutHeight: parseNum(field('F_S_SIZE_H')),
      dischargeSpoutDiameter: parseNum(field('D_S_SIZE_D')),
      dischargeSpoutHeight: parseNum(field('D_S_SIZE_H')),
      construction: construction.isEmpty ? 'Rectangular Standard' : construction,
      bagType: bagType.isEmpty ? '4-Panel' : bagType,
      safeWorkingLoad: parseNum(field('SWL')),
      total: parseNum(field('TOTAL')),
      safetyFactor: parseString(field('SF')),
      loopColor: parseString(field('LOOP_COLOR')),
      components: componentsJson.map((c) {
        final cm = (c as Map).cast<String, dynamic>();
        final cNorm = <String, dynamic>{
          for (final e in cm.entries) e.key.toUpperCase(): e.value,
        };
        return BagComponentInfo(
          name: parseString(cNorm['ROW_LIST']),
          gsm: parseString(cNorm['GSM']),
          material: parseString(cNorm['MATERIAL']),
        );
      }).toList(),
    );
  }
}

class StaticFibcBagCard extends StatefulWidget {
  final FibcBagSpecification specification;
  final double maxHeight;

  const StaticFibcBagCard({
    super.key,
    required this.specification,
    this.maxHeight = 600,
  });

  @override
  State<StaticFibcBagCard> createState() => _StaticFibcBagCardState();
}

class _StaticFibcBagCardState extends State<StaticFibcBagCard> {
  final TransformationController _transformationController =
  TransformationController();
  final GlobalKey _boundaryKey = GlobalKey();

  double _zoom = 1.0;
  bool _showMoreSpecs = false;

  // Pen / annotate state.
  bool _drawMode = false;
  Color _penColor = const Color(0xFFDC2626);
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;
  static const List<Color> _penColors = [
    Color(0xFFDC2626), // red
    Color(0xFF111827), // near-black
    Color(0xFF2563EB), // blue
    Color(0xFF16A34A), // green
  ];

  bool _isExporting = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _zoom = 1.0);
  }

  Size _viewportSize = Size.zero; // set this in build() where you know maxCardWidth/viewerHeight
  void _applyZoom(double nextScale) {
    final clamped = nextScale.clamp(0.5, 4.0);
    final current = _transformationController.value;
    final currentScale = current.getMaxScaleOnAxis();
    if (currentScale == 0) return;
    final factor = clamped / currentScale;

    final center = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    final scenePoint = MatrixUtils.transformPoint(Matrix4.inverted(current), center);

    final updated = current.clone()
      ..translate(scenePoint.dx, scenePoint.dy)
      ..scale(factor)
      ..translate(-scenePoint.dx, -scenePoint.dy);

    _transformationController.value = updated;
    setState(() => _zoom = clamped);
  }

  void _zoomIn() => _applyZoom(_zoom + 0.25);

  void _zoomOut() => _applyZoom(_zoom - 0.25);

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    setState(() => _zoom = scale.clamp(0.5, 4.0));
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.specification;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = math.min(constraints.maxWidth, 720.0);
        final isCompact = maxCardWidth < 420;

        final viewerHeight = math
            .min(widget.maxHeight, maxCardWidth * (isCompact ? 1.05 : 0.72))
            .clamp(320.0, widget.maxHeight);
        _viewportSize = Size(maxCardWidth, viewerHeight);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E5EC)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(spec, isCompact),
                  _buildToolbar(),
                  SizedBox(
                    height: viewerHeight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(color: const Color(0xFFF7F8FB)),
                          ),
                          Positioned.fill(
                            child: InteractiveViewer(
                              transformationController:
                              _transformationController,
                              minScale: 0.5,
                              maxScale: 4.0,
                              // Panning/zoom is disabled while the pen is
                              // active so a finger drag draws instead of
                              // moving the canvas.
                              panEnabled: !_drawMode,
                              scaleEnabled: !_drawMode,
                              boundaryMargin: const EdgeInsets.all(250),
                              constrained: false,
                              onInteractionUpdate: _onInteractionUpdate,
                              child: RepaintBoundary(
                                key: _boundaryKey,
                                child: SizedBox(
                                  width: maxCardWidth,
                                  height: viewerHeight,
                                  child: Stack(
                                    children: [
                                      CustomPaint(
                                        painter: FibcConstructionPainter(
                                          specification: spec,
                                          loopColor: _parseColor(spec.loopColor) ??
                                              const Color(0xFF1976D2),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          // Only the pen intercepts touches;
                                          // otherwise let InteractiveViewer
                                          // handle pan/zoom underneath.
                                          ignoring: !_drawMode,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onPanStart: (details) {
                                              setState(() {
                                                _currentStroke = _Stroke(
                                                  points: [details.localPosition],
                                                  color: _penColor,
                                                  width: 3,
                                                );
                                              });
                                            },
                                            onPanUpdate: (details) {
                                              setState(() {
                                                _currentStroke?.points
                                                    .add(details.localPosition);
                                              });
                                            },
                                            onPanEnd: (_) {
                                              setState(() {
                                                if (_currentStroke != null) {
                                                  _strokes.add(_currentStroke!);
                                                }
                                                _currentStroke = null;
                                              });
                                            },
                                            child: CustomPaint(
                                              painter: _AnnotationPainter(
                                                strokes: _strokes,
                                                current: _currentStroke,
                                              ),
                                              size: Size.infinite,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildKeyDimensionsBar(spec),
                  _buildMoreSpecsToggle(spec),
                  if (spec.components.isNotEmpty)
                    _buildComponentsTable(spec.components),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(FibcBagSpecification spec, bool isCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 20,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FIBC BAG DESIGN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: C.success,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (spec.inquiryId.isNotEmpty) spec.inquiryId,
                    if (spec.construction.isNotEmpty) spec.construction,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A808C),
                  ),
                ),
              ],
            ),
          ),
          _zoomControls(),
        ],
      ),
    );
  }

  Widget _zoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton(Icons.remove, _zoomOut, tooltip: 'Zoom out'),
        const SizedBox(width: 2),
        Text(
          '${(_zoom * 100).round()}%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 2),
        _iconButton(Icons.add, _zoomIn, tooltip: 'Zoom in'),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      color: Colors.white,
      child: Row(
        children: [

          if (_isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            _toolIconButton(
              icon: Icons.picture_as_pdf_outlined,
              tooltip: 'Download as PDF',
              onTap: _exportPdf,
            ),
            _toolIconButton(
              icon: Icons.print_outlined,
              tooltip: 'Print',
              onTap: _printImage,
            ),
          ],
        ],
      ),
    );
  }

  Widget _toolIconButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    bool active = false,
  }) {
    final disabled = onTap == null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: disabled
                ? const Color(0xFFC7CBD4)
                : (active ? const Color(0xFF2563EB) : const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    final selected = color.value == _penColor.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _penColor = color),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? const Color(0xFF252A34) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> _captureDrawingAsPng() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _buildPdfBytes(Uint8List pngBytes, PdfPageFormat format) async {
    final image = pw.MemoryImage(pngBytes);
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
      ),
    );
    return doc.save();
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final pngBytes = await _captureDrawingAsPng();
      if (pngBytes == null) {
        _showSnack('Could not capture the bag drawing.');
        return;
      }
      final pdfBytes = await _buildPdfBytes(pngBytes, PdfPageFormat.a4);
      final inquiryId = widget.specification.inquiryId;
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${inquiryId.isEmpty ? 'fibc-bag' : inquiryId}.pdf',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _printImage() async {
    setState(() => _isExporting = true);
    try {
      final pngBytes = await _captureDrawingAsPng();
      if (pngBytes == null) {
        _showSnack('Could not capture the bag drawing.');
        return;
      }
      await Printing.layoutPdf(
        onLayout: (format) => _buildPdfBytes(pngBytes, format),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The handful of numbers someone actually needs at a glance:
  /// overall size, safe working load, and the loop height that matches
  /// the drawing. Everything else lives behind "More specs".
  Widget _buildKeyDimensionsBar(FibcBagSpecification spec) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _keyStat('SIZE (L×W×H)',
                '${_fmt(spec.length)} × ${_fmt(spec.width)} × ${_fmt(spec.height)} cm'),
          ),
          if (spec.safeWorkingLoad > 0)
            Expanded(
              child: _keyStat('SWL', '${_fmt(spec.safeWorkingLoad)} kg'),
            ),
          if (spec.safetyFactor.isNotEmpty)
            Expanded(child: _keyStat('SF', spec.safetyFactor)),
        ],
      ),
    );
  }

  Widget _keyStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
            color: Color(0xFF9AA0AA),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF252A34),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreSpecsToggle(FibcBagSpecification spec) {
    final secondary = <MapEntry<String, String>>[
      MapEntry('LOOP HEIGHT', '${_fmt(spec.loopFreeHeight)} cm'),
      MapEntry('LONG LEG', '${_fmt(spec.longLegHeight)} cm'),
      MapEntry('SHORT LEG', '${_fmt(spec.shortLegHeight)} cm'),
      if (spec.fillingSpoutDiameter > 0)
        MapEntry('FILL SPOUT', '${_fmt(spec.fillingSpoutDiameter)} × ${_fmt(spec.fillingSpoutHeight)} cm'),
      if (spec.dischargeSpoutDiameter > 0)
        MapEntry('DISCHARGE SPOUT', '${_fmt(spec.dischargeSpoutDiameter)} × ${_fmt(spec.dischargeSpoutHeight)} cm'),
      MapEntry('BAG TYPE', spec.bagType),
      if (spec.total > 0) MapEntry('QUANTITY', _fmt(spec.total)),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _showMoreSpecs = !_showMoreSpecs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showMoreSpecs ? 'Hide specs' : 'More specs',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                Icon(
                  _showMoreSpecs
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
          if (_showMoreSpecs) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secondary
                  .where((e) => e.value.trim().isNotEmpty)
                  .map((e) => _infoChip(e.key, e.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComponentsTable(List<BagComponentInfo> components) {
    final rows = components.where((c) => c.isApplicable).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              'FABRIC COMPOSITION',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
                color: Color(0xFF7A808C),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE4E7EC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _componentHeaderRow(),
                for (int i = 0; i < rows.length; i++)
                  _componentRow(rows[i], isLast: i == rows.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _componentHeaderRow() {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: Color(0xFF9AA0AA),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('COMPONENT', style: style)),
          Expanded(flex: 2, child: Text('GSM', style: style)),
          Expanded(flex: 2, child: Text('MATERIAL', style: style)),
        ],
      ),
    );
  }

  Widget _componentRow(BagComponentInfo c, {required bool isLast}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF0F1F4))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              c.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF252A34),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              c.gsm,
              style: const TextStyle(fontSize: 12, color: Color(0xFF444B57)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.isCoated
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  c.material.isEmpty ? '-' : c.material,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: c.isCoated
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF737985),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF252A34),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(num value) {
    final d = value.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
  }

  Color? _parseColor(String value) {
    final t = value.trim();
    if (t.isEmpty) return null;

    if (t.startsWith('#')) {
      var hex = t.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(parsed);
    }

    switch (t.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFF2B90C);
      case 'white':
        return const Color(0xFFE5E7EB);
      case 'green':
        return const Color(0xFF34D399);
      case 'blue':
        return const Color(0xFF2563EB);
      case 'black':
        return const Color(0xFF374151);
      case 'red':
        return const Color(0xFFDC2626);
      case 'orange':
        return const Color(0xFFF97316);
      default:
        return null;
    }
  }
}

class RectangularStandardBagPainter extends CustomPainter {
  final double length;
  final double width;
  final double bagHeight;

  final double loopHeight;
  final double longLeg;
  final double shortLeg;

  final double fillSpoutDia;
  final double fillSpoutHeight;

  final double dischargeSpoutDia;
  final double dischargeSpoutHeight;
  final FibcBagType constructionType; // ← add this field
  final Color loopColor;

  RectangularStandardBagPainter({
    required this.length,
    required this.width,
    required this.bagHeight,
    required this.loopHeight,
    required this.longLeg,
    required this.shortLeg,
    required this.fillSpoutDia,
    required this.fillSpoutHeight,
    required this.dischargeSpoutDia,
    required this.dischargeSpoutHeight,
    required this.loopColor,
    required this.constructionType,
  });

  static const double _angle = 26;
  static const Color _stroke = Color(0xFF30343B);
  static const Color _dimLine = Color(0xFF2563EB);
  static const Color _extLine = Color(0xFFB8BCC6);

  Offset _project(double x, double y, double z, double scale, Offset origin) {
    final rad = _angle * math.pi / 180;
    final px = origin.dx + (x - y) * math.cos(rad) * scale;
    final py = origin.dy - z * scale + (x + y) * math.sin(rad) * scale;
    return Offset(px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double L = length <= 0 ? 90 : length;
    final double W = width <= 0 ? 90 : width;
    final double H = bagHeight <= 0 ? 120 : bagHeight;
    final double LH = loopHeight <= 0 ? 25 : loopHeight;
    final double LL = longLeg > 0 ? longLeg : LH;
    final double SL = shortLeg > 0 ? shortLeg : LH * .4;

    final availableWidth = size.width - 200;
    final availableHeight = size.height - 160;

    final scale = math
        .min(
      availableWidth / math.max(L + W, 1),
      availableHeight / math.max(H + LL, 1),
    )
        .clamp(0.6, 5.0);

    // --- Pass 1: project key points around a dummy origin to measure
    // the shape's actual bounding box (including loops sticking up). ---
    Offset rawP(double x, double y, double z) =>
        _project(x, y, z, scale, Offset.zero);

    final keyPoints = <Offset>[
      rawP(L, W, 0),
      rawP(L, 0, 0),
      rawP(0, W, 0),
      rawP(L, W, H),
      rawP(L, 0, H),
      rawP(0, W, H),
      rawP(0, 0, H),
      rawP(L, 0, H) - Offset(0, LH * scale),
      rawP(0, W, H) - Offset(0, LH * scale),
      rawP(L, W, H) - Offset(0, LH * scale),
    ];

    final minX = keyPoints.map((o) => o.dx).reduce(math.min);
    final maxX = keyPoints.map((o) => o.dx).reduce(math.max);
    final minY = keyPoints.map((o) => o.dy).reduce(math.min);
    final maxY = keyPoints.map((o) => o.dy).reduce(math.max);
    final shapeCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);

    // --- Pass 2: real origin — shifts everything so the shape's
    // bounding-box center lands exactly on the canvas center. ---
    final origin = Offset(size.width / 2, size.height / 2) - shapeCenter;

    Offset p(double x, double y, double z) => _project(x, y, z, scale, origin);

    final frontBottom = p(L, W, 0);
    final leftBottom = p(L, 0, 0);
    final rightBottom = p(0, W, 0);

    final frontTop = p(L, W, H);
    final leftTop = p(L, 0, H);
    final rightTop = p(0, W, H);
    final backTop = p(0, 0, H);

    _drawShadow(canvas, frontBottom, leftBottom, rightBottom);
    _drawTypeOverlay(
      canvas, leftTop, frontTop, rightTop, backTop,
      leftBottom, frontBottom, rightBottom, scale,
    );

    _drawLoop(canvas, backTop, LH, scale, LL, SL, isLeft: true, opacity: .3);

    // Right body panel (0,W,*) side
    _fillPanel(
      canvas,
      [rightTop, frontTop, frontBottom, rightBottom],
      const Color(0xFFE8EBF0),
      const Color(0xFFD5D9E0),
    );

    // Left body panel (L,0,*) side
    _fillPanel(
      canvas,
      [leftTop, frontTop, frontBottom, leftBottom],
      Colors.white,
      const Color(0xFFF0F2F5),
    );

    // Diamond top face
    _fillPanel(
      canvas,
      [backTop, leftTop, frontTop, rightTop],
      const Color(0xFFFFE6C7),
      const Color(0xFFF8D39B),
    );

    _drawFabricTexture(canvas, leftTop, frontTop, frontBottom, leftBottom);
    _drawSeam(canvas, frontBottom, frontTop);
    _drawSeam(canvas, leftBottom, leftTop);
    _drawSeam(canvas, rightBottom, rightTop);

    if (dischargeSpoutDia > 0 && dischargeSpoutHeight > 0) {
      _drawSpout(
        canvas,
        p(L / 2, W / 2, 0),
        p(L / 2, W / 2, -dischargeSpoutHeight),
        dischargeSpoutDia,
        scale,
        const Color(0xFFE9EBEF),
      );
    }
    if (fillSpoutDia > 0 && fillSpoutHeight > 0) {
      _drawSpout(
        canvas,
        p(L / 2, W / 2, H),
        p(L / 2, W / 2, H + fillSpoutHeight),
        fillSpoutDia,
        scale,
        Colors.white,
      );
    }


    _drawLoop(canvas, leftTop, LH, scale, LL, SL, isLeft: true, opacity: 1);
    _drawLoop(canvas, rightTop, LH, scale, SL, LL, isLeft: false, opacity: 1);

    _drawLoop(canvas, frontTop, LH, scale, LL, SL, isLeft: true, opacity: 1);
    _drawEdgeDimension(
      canvas,
      from: leftBottom,
      to: leftTop,
      label: 'H  ${_fmt(H)} cm',
      side: _Side.left,
      offset: 44,
    );

    _drawEdgeDimension(
      canvas,
      from: frontBottom,
      to: leftBottom,
      label: 'L  ${_fmt(L)} cm',
      side: _Side.bottomRight,
      offset: 40,
    );

    _drawEdgeDimension(
      canvas,
      from: frontBottom,
      to: rightBottom,
      label: 'W  ${_fmt(W)} cm',
      side: _Side.bottomLeft,
      offset: 40,
    );

    _drawLoopDimension(
      canvas,
      base: leftTop,
      loopH: LH,
      scale: scale,
      label: 'LOOP  ${_fmt(LH)} cm',
      dx: -32,
    );
  }

  void _drawShadow(Canvas canvas, Offset front, Offset left, Offset right) {
    final center = Offset((left.dx + right.dx) / 2, front.dy + 10);
    final w = (right.dx - left.dx).abs() * .8;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w, height: 16),
      Paint()
        ..color = Colors.black.withOpacity(.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
  }

  void _fillPanel(Canvas canvas, List<Offset> pts, Color from, Color to) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [from, to],
    ).createShader(path.getBounds());

    canvas.drawPath(path, Paint()..shader = shader);
    canvas.drawPath(
      path,
      Paint()
        ..color = _stroke.withOpacity(.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _drawFabricTexture(
      Canvas canvas,
      Offset tl,
      Offset tr,
      Offset br,
      Offset bl,
      ) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(.025)
      ..strokeWidth = 1;
    const count = 14;
    for (int i = 1; i < count; i++) {
      final t = i / count;
      canvas.drawLine(Offset.lerp(tl, bl, t)!, Offset.lerp(tr, br, t)!, paint);
    }
  }

  void _drawSeam(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(.16)
      ..strokeWidth = 1;
    _dashedLine(canvas, a, b, paint, const [5, 3]);
  }

  void _dashedLine(
      Canvas canvas,
      Offset a,
      Offset b,
      Paint paint,
      List<double> dash,
      ) {
    final vector = b - a;
    final total = vector.distance;
    if (total <= 0) return;
    final direction = vector / total;
    double distance = 0;
    bool draw = true;
    int index = 0;
    while (distance < total) {
      final segment = math.min(dash[index % dash.length], total - distance);
      if (draw) {
        canvas.drawLine(
          a + direction * distance,
          a + direction * (distance + segment),
          paint,
        );
      }
      distance += segment;
      draw = !draw;
      index++;
    }
  }

  void _drawLoop(
      Canvas canvas,
      Offset base,
      double loopH,
      double scale,
      double longLegCm,
      double shortLegCm, {
        required bool isLeft,
        required double opacity,
      }) {
    final heightPx = loopH * scale;
    final longPx = longLegCm * scale;
    final shortPx = shortLegCm * scale;
    final leftLeg = isLeft ? longPx : shortPx;
    final rightLeg = isLeft ? shortPx : longPx;
    final inset = scale * 2.0;
    final leftX = base.dx - inset;
    final rightX = base.dx + inset;
    final peakY = base.dy - heightPx;
    final archWidth = scale * 10;

    final path = Path()
      ..moveTo(leftX, base.dy)
      ..lineTo(leftX, base.dy + leftLeg)
      ..cubicTo(
        leftX - archWidth * .3,
        base.dy - heightPx * .25,
        leftX - archWidth * .65,
        peakY,
        base.dx,
        peakY,
      )
      ..cubicTo(
        rightX + archWidth * .65,
        peakY,
        rightX + archWidth * .3,
        base.dy - heightPx * .25,
        rightX,
        base.dy + rightLeg,
      )
      ..lineTo(rightX, base.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = loopColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(scale * 3.4, 3)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(.35 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(scale * 1, 1)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLoopDimension(
      Canvas canvas, {
        required Offset base,
        required double loopH,
        required double scale,
        required String label,
        required double dx,
      }) {
    final top = Offset(base.dx, base.dy - loopH * scale);
    final lineX = base.dx + dx;

    final extPaint = Paint()
      ..color = _extLine
      ..strokeWidth = 1;
    canvas.drawLine(base, Offset(lineX, base.dy), extPaint);
    canvas.drawLine(top, Offset(lineX, top.dy), extPaint);

    final dimPaint = Paint()
      ..color = _dimLine
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(lineX, base.dy), Offset(lineX, top.dy), dimPaint);
    _arrowHead(canvas, Offset(lineX, base.dy), const Offset(0, 1), dimPaint);
    _arrowHead(canvas, Offset(lineX, top.dy), const Offset(0, -1), dimPaint);

    _labelChip(
      canvas,
      Offset(lineX - 6, (base.dy + top.dy) / 2),
      label,
      alignRight: true,
    );
  }

  void _drawSpout(
      Canvas canvas,
      Offset base,
      Offset tip,
      double diameter,
      double scale,
      Color color,
      ) {
    if (diameter <= 0) return;
    final radius = diameter * scale / 2;
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = _stroke.withOpacity(.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final body = Path()
      ..moveTo(base.dx - radius, base.dy)
      ..lineTo(tip.dx - radius, tip.dy)
      ..lineTo(tip.dx + radius, tip.dy)
      ..lineTo(base.dx + radius, base.dy)
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    final topOval = Rect.fromCenter(
      center: tip,
      width: radius * 2,
      height: radius,
    );
    canvas.drawOval(topOval, fill);
    canvas.drawOval(topOval, stroke);

    final middle = Offset(tip.dx, base.dy + (tip.dy - base.dy) * .55);
    canvas.drawLine(
      Offset(middle.dx - radius * .75, middle.dy),
      Offset(middle.dx + radius * .75, middle.dy),
      Paint()
        ..color = const Color(0xFF1D70B8)
        ..strokeWidth = math.max(scale * 1.5, 1.5)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawEdgeDimension(
      Canvas canvas, {
        required Offset from,
        required Offset to,
        required String label,
        required _Side side,
        required double offset,
      }) {
    late Offset dimFrom;
    late Offset dimTo;

    switch (side) {
      case _Side.left:
        dimFrom = Offset(math.min(from.dx, to.dx) - offset, from.dy);
        dimTo = Offset(dimFrom.dx, to.dy);
        break;
      case _Side.bottomLeft:
        dimFrom = from + Offset(-offset, offset);
        dimTo = to + Offset(-offset, offset);
        break;
      case _Side.bottomRight:
        dimFrom = from + Offset(offset, offset);
        dimTo = to + Offset(offset, offset);
        break;
    }

    final extPaint = Paint()
      ..color = _extLine
      ..strokeWidth = 1;
    _dashedLine(canvas, from, dimFrom, extPaint, const [3, 3]);
    _dashedLine(canvas, to, dimTo, extPaint, const [3, 3]);

    final dimPaint = Paint()
      ..color = _dimLine
      ..strokeWidth = 1.4;
    canvas.drawLine(dimFrom, dimTo, dimPaint);

    final dir = (dimTo - dimFrom);
    final len = dir.distance;
    final unit = len == 0 ? const Offset(0, 1) : dir / len;
    _arrowHead(canvas, dimFrom, -unit, dimPaint);
    _arrowHead(canvas, dimTo, unit, dimPaint);

    final mid = Offset.lerp(dimFrom, dimTo, .5)!;
    _labelChip(
      canvas,
      mid,
      label,
      alignRight: side == _Side.left,
      rotate: side == _Side.left,
    );
  }

  void _arrowHead(Canvas canvas, Offset tip, Offset direction, Paint paint) {
    const size = 6.0;
    final angle = math.atan2(direction.dy, direction.dx);
    final p1 =
        tip - Offset(math.cos(angle - .45), math.sin(angle - .45)) * size;
    final p2 =
        tip - Offset(math.cos(angle + .45), math.sin(angle + .45)) * size;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = paint.color);
  }

  void _labelChip(
      Canvas canvas,
      Offset center,
      String label, {
        bool alignRight = false,
        bool rotate = false,
      }) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E3A8A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final padding = 5.0;
    final rect = Rect.fromCenter(
      center: rotate ? Offset(center.dx, center.dy) : center,
      width: tp.width + padding * 2,
      height: tp.height + padding * 1.4,
    );

    canvas.save();
    if (rotate) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 2);
      canvas.translate(-center.dx, -center.dy);
    }

    final chipRect = alignRight && !rotate
        ? rect.translate(-rect.width - 6, 0)
        : rect;

    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(5)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(5)),
      Paint()
        ..color = const Color(0xFFCBD5F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(
      canvas,
      Offset(chipRect.left + padding, chipRect.top + padding * .7),
    );
    canvas.restore();
  }

  String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(covariant RectangularStandardBagPainter oldDelegate) {
    return oldDelegate.length != length ||
        oldDelegate.width != width ||
        oldDelegate.bagHeight != bagHeight ||
        oldDelegate.loopHeight != loopHeight ||
        oldDelegate.longLeg != longLeg ||
        oldDelegate.shortLeg != shortLeg ||
        oldDelegate.fillSpoutDia != fillSpoutDia ||
        oldDelegate.fillSpoutHeight != fillSpoutHeight ||
        oldDelegate.dischargeSpoutDia != dischargeSpoutDia ||
        oldDelegate.dischargeSpoutHeight != dischargeSpoutHeight ||
        oldDelegate.loopColor != loopColor;
  }





  void _drawTypeOverlay(
  Canvas canvas,
  Offset leftTop, Offset frontTop, Offset rightTop, Offset backTop,
  Offset leftBottom, Offset frontBottom, Offset rightBottom,
  double scale,
  ) {
  final foldPaint = Paint()
  ..color = _stroke.withOpacity(.35)
  ..strokeWidth = 1;

  switch (constructionType) {
  case FibcBagType.uPanelBaffle:
  case FibcBagType.baffled:
  _dashedLine(canvas,
  Offset.lerp(leftTop, frontTop, .5)!,
  Offset.lerp(leftBottom, frontBottom, .5)!,
  foldPaint, const [2, 4]);
  _dashedLine(canvas,
  Offset.lerp(rightTop, frontTop, .5)!,
  Offset.lerp(rightBottom, frontBottom, .5)!,
  foldPaint, const [2, 4]);
  break;
  case FibcBagType.crossCorner:
  canvas.drawLine(backTop, frontTop,
  Paint()..color = _stroke.withOpacity(.5)..strokeWidth = 1);
  canvas.drawLine(leftTop, rightTop, foldPaint);
  break;
  case FibcBagType.tunnelLift:
  final stripTop = Offset.lerp(leftTop, rightTop, .5)!;
  final stripBottom = Offset.lerp(leftBottom, rightBottom, .5)!;
  canvas.drawLine(stripTop, stripBottom,
  Paint()..color = loopColor..strokeWidth = math.max(scale * 3, 3));
  break;
  default:
  break;
  }
  }

}

enum _Side { left, bottomLeft, bottomRight }

/// One freehand pen stroke drawn on top of the bag image.
class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _Stroke({required this.points, required this.color, required this.width});
}

/// Paints the user's pen strokes over the bag drawing. Kept as a separate
/// CustomPaint layer (rather than mutating the bag painter) so annotations
/// don't get wiped when the spec changes and the bag redraws.
class _AnnotationPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? current;

  _AnnotationPainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, if (current != null) current!]) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) => true;
}