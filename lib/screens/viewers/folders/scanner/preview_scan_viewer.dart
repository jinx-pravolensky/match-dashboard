import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/data/data_ranting.dart';

class ShotHole {
  Offset position;
  double score;
  bool isSelected;
  bool isModified;

  ShotHole({
    required this.position,
    required this.score,
    this.isSelected = false,
    this.isModified = false,
  });
}

class ViewerPreviewScanScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> trainingData;
  final Map<String, dynamic> sesiData;
  final int selectedShots;
  final Map<String, dynamic> aiResult;

  const ViewerPreviewScanScreen({
    super.key,
    required this.imagePath,
    required this.trainingData,
    required this.sesiData,
    required this.selectedShots,
    required this.aiResult,
  });

  @override
  State<ViewerPreviewScanScreen> createState() =>
      _ViewerPreviewScanScreenState();
}

class _ViewerPreviewScanScreenState extends State<ViewerPreviewScanScreen> {
  final List<ShotHole> _holes = [];
  bool _isSaving = false;
  late bool _isDecimal;
  late double _bullsEyeDiameter;

  // 🔥 INI DIA YANG KETINGGALAN KEMARIN WKWK
  ShotHole? _draggingHole;

  double? _pixelPerMm;
  Offset? _targetCenter;

  String windage = "0,0 mm";
  String elevation = "0,0 mm";
  String meanRadius = "0,0 mm";
  String maxSpread = "0,0 mm";

  @override
  void initState() {
    super.initState();
    _isDecimal = widget.trainingData['skorDesimal'] ?? false;

    if (widget.aiResult['pixel_per_mm'] != null) {
      _pixelPerMm = (widget.aiResult['pixel_per_mm']).toDouble();
    }
    if (widget.aiResult['target_center'] != null) {
      _targetCenter = Offset(
        (widget.aiResult['target_center']['x']).toDouble(),
        (widget.aiResult['target_center']['y']).toDouble(),
      );
    }

    _calculateBullsEyeDiameter();
    _parseAiHoles();
    _calculateBallistics();
  }

  void _calculateBullsEyeDiameter() {
    String subKat = widget.trainingData['subKategori'] ?? '';
    String katUtama = widget.trainingData['kategoriUtama'] ?? '';

    final kamusData = daftarKamusRanting.firstWhere(
      (k) => k['sub_kategori'] == subKat && k['kategori_utama'] == katUtama,
      orElse: () => daftarKamusRanting[0],
    );

    String bullsEyeStr = kamusData['bulls_eye'] ?? "0";
    String cleanStr = bullsEyeStr.replaceAll(' mm', '').replaceAll(',', '.');
    _bullsEyeDiameter = double.tryParse(cleanStr) ?? 0.0;
  }

  void _parseAiHoles() {
    if (widget.aiResult['holes'] != null) {
      List<dynamic> rawHoles = List.from(widget.aiResult['holes']);

      // Sortir skor dari yang terbesar (Fitur Smart Limit)
      rawHoles.sort((a, b) {
        double scoreA = (a['score'] ?? 0).toDouble();
        double scoreB = (b['score'] ?? 0).toDouble();
        return scoreB.compareTo(scoreA);
      });

      int limit = widget.selectedShots;
      int count = 0;

      for (var h in rawHoles) {
        if (count >= limit) break;

        _holes.add(
          ShotHole(
            position: Offset(
              (h['x'] ?? 0).toDouble(),
              (h['y'] ?? 0).toDouble(),
            ),
            score: (h['score'] ?? 0).toDouble(),
          ),
        );
        count++;
      }
    }
  }

  void _updateScoreBerdasarkanPosisi(ShotHole hole) {
    if (_targetCenter != null && _pixelPerMm != null) {
      String subKategori = widget.trainingData['subKategori'] ?? '';
      double dx = hole.position.dx - _targetCenter!.dx;
      double dy = hole.position.dy - _targetCenter!.dy;
      double distancePixel = sqrt(dx * dx + dy * dy);
      double distanceMm = distancePixel / _pixelPerMm!;
      double calculatedScore = 0.0;

      if (subKategori.toLowerCase().contains('rifle')) {
        calculatedScore = 11.0 - (distanceMm / 2.5);
      } else {
        calculatedScore = 11.0 - (distanceMm / 8.0);
      }

      calculatedScore = calculatedScore.clamp(0.0, 10.9);
      if (_isDecimal) {
        calculatedScore = double.parse(calculatedScore.toStringAsFixed(1));
      } else {
        calculatedScore = calculatedScore.floorToDouble().clamp(0.0, 10.0);
      }
      hole.score = calculatedScore;
    } else {
      hole.score = 0.0;
    }
  }

  void _calculateBallistics() {
    if (_holes.isEmpty || _pixelPerMm == null || _targetCenter == null) {
      setState(() {
        windage = "0,0 mm";
        elevation = "0,0 mm";
        meanRadius = "0,0 mm";
        maxSpread = "0,0 mm";
      });
      return;
    }

    double sumX = 0;
    double sumY = 0;
    for (var h in _holes) {
      sumX += (h.position.dx - _targetCenter!.dx);
      sumY += (_targetCenter!.dy - h.position.dy);
    }

    double avgX = sumX / _holes.length;
    double avgY = sumY / _holes.length;

    double windageMm = avgX / _pixelPerMm!;
    double elevationMm = avgY / _pixelPerMm!;

    double sumDist = 0;
    for (var h in _holes) {
      double dx = (h.position.dx - _targetCenter!.dx) - avgX;
      double dy = (_targetCenter!.dy - h.position.dy) - avgY;
      sumDist += sqrt(dx * dx + dy * dy);
    }
    double meanRadiusMm = (sumDist / _holes.length) / _pixelPerMm!;

    double maxDist = 0;
    for (int i = 0; i < _holes.length; i++) {
      for (int j = i + 1; j < _holes.length; j++) {
        double dx = _holes[i].position.dx - _holes[j].position.dx;
        double dy = _holes[i].position.dy - _holes[j].position.dy;
        double dist = sqrt(dx * dx + dy * dy);
        if (dist > maxDist) maxDist = dist;
      }
    }
    double maxSpreadMm = maxDist / _pixelPerMm!;

    setState(() {
      windage =
          "${windageMm > 0
              ? 'R'
              : windageMm < 0
              ? 'L'
              : ''} ${windageMm.abs().toStringAsFixed(1)} mm";
      elevation =
          "${elevationMm > 0
              ? 'U'
              : elevationMm < 0
              ? 'D'
              : ''} ${elevationMm.abs().toStringAsFixed(1)} mm";
      meanRadius = "${meanRadiusMm.toStringAsFixed(1)} mm";
      maxSpread = "${maxSpreadMm.toStringAsFixed(1)} mm";
    });
  }

  void _addManualHole(Offset localPosition) {
    if (_holes.length >= widget.selectedShots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Batas maksimum lubang tembakan tercapai!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      ShotHole newHole = ShotHole(
        position: localPosition,
        score: 0.0,
        isModified: true,
      );
      _updateScoreBerdasarkanPosisi(newHole);
      _holes.add(newHole);
      _calculateBallistics();
    });
  }

  void _onHoleTap(Offset tapPosition) {
    for (int i = 0; i < _holes.length; i++) {
      double dist = (tapPosition - _holes[i].position).distance;
      if (dist < 20) {
        setState(() {
          for (var h in _holes) h.isSelected = false;
          _holes[i].isSelected = true;
        });
        return;
      }
    }
    setState(() {
      for (var h in _holes) h.isSelected = false;
    });
  }

  void _removeSelectedHole() {
    setState(() {
      _holes.removeWhere((h) => h.isSelected);
      _calculateBallistics();
    });
  }

  String _getTotalScoreText() {
    double total = 0;
    for (var h in _holes) {
      total += _isDecimal ? h.score : h.score.floorToDouble();
    }
    return _isDecimal ? total.toStringAsFixed(1) : total.toInt().toString();
  }

  Future<void> _simpanHasilScan(bool isScanNext) async {
    setState(() => _isSaving = true);
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/training/${widget.trainingData['_id']}/sesi/${widget.sesiData['_id']}/update-score',
      );

      List<num> skorDetailArray = _holes
          .map((h) => _isDecimal ? h.score : h.score.floor())
          .toList();

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "score": _getTotalScoreText(),
          "jumlahLubang": _holes.length,
          "windage": windage,
          "elevation": elevation,
          "meanRadius": meanRadius,
          "maxSpread": maxSpread,
          "skorDetailArray": skorDetailArray,
        }),
      );

      setState(() => _isSaving = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, isScanNext ? 'NEXT' : true);
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'Gagal Menyimpan',
          desc: 'Terjadi kesalahan saat menyimpan skor.',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Koneksi Error',
        desc: e.toString(),
        btnOkOnPress: () {},
      ).show();
    }
  }

  double _getKaliberSizeInMm() {
    String kaliberStr = (widget.trainingData['amunisi'] ?? '4,5')
        .toString()
        .toLowerCase();
    if (kaliberStr.contains('6,3') || kaliberStr.contains('.25')) return 10.3;
    if (kaliberStr.contains('4,5') || kaliberStr.contains('.177')) return 4.5;
    if (kaliberStr.contains('5,6') || kaliberStr.contains('.22')) return 5.6;
    if (kaliberStr.contains('6mm') || kaliberStr.contains('br norma'))
      return 6.0;
    if (kaliberStr.contains('6.5') ||
        kaliberStr.contains('6,5') ||
        kaliberStr.contains('.260') ||
        kaliberStr.contains('.264'))
      return 6.5;
    if (kaliberStr.contains('7mm') ||
        kaliberStr.contains('7,62') ||
        kaliberStr.contains('.30'))
      return 7.62;
    if (kaliberStr.contains('8x57') || kaliberStr.contains('.32')) return 7.94;
    if (kaliberStr.contains('9mm') ||
        kaliberStr.contains('.38') ||
        kaliberStr.contains('.357'))
      return 9.1;
    if (kaliberStr.contains('.40')) return 10.17;
    if (kaliberStr.contains('.44') || kaliberStr.contains('.45')) return 11.43;
    return 4.5;
  }

  @override
  Widget build(BuildContext context) {
    bool hasSelectedHole = _holes.any((h) => h.isSelected);
    String base64Image = widget.aiResult['processed_image'] ?? '';

    // Hitung ukuran area sentuh (hitbox) peluru
    double pixelPerMm = _pixelPerMm ?? 15.0;
    double caliberMm = _getKaliberSizeInMm();
    double circleSize = (caliberMm * pixelPerMm) * 1.1;
    double halfSize = circleSize / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Preview Hasil Scan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: base64Image.isNotEmpty
                  ? InteractiveViewer(
                      maxScale: 5.0,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                for (var h in _holes) h.isSelected = false;
                                _draggingHole = null;
                              });
                            },
                            onTapUp: (details) =>
                                _onHoleTap(details.localPosition),
                            onDoubleTapDown: (details) =>
                                _addManualHole(details.localPosition),
                            child: SizedBox(
                              width: 700,
                              height: 700,
                              child: Stack(
                                children: [
                                  Image.memory(
                                    base64Decode(base64Image),
                                    width: 700,
                                    height: 700,
                                    fit: BoxFit.cover,
                                    color: Colors.black.withOpacity(0.4),
                                    colorBlendMode: BlendMode.darken,
                                  ),
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: HolePainter(
                                        holes: _holes,
                                        targetCenter: _targetCenter,
                                        pixelPerMm: _pixelPerMm,
                                        isDecimal: _isDecimal,
                                        bullsEyeDiameter: _bullsEyeDiameter,
                                      ),
                                    ),
                                  ),
                                  ..._holes.map((hole) {
                                    return Positioned(
                                      left: hole.position.dx - halfSize,
                                      top: hole.position.dy - halfSize,
                                      child: GestureDetector(
                                        onTapDown: (_) {
                                          setState(() {
                                            for (var h in _holes)
                                              h.isSelected = false;
                                            hole.isSelected = true;
                                            _draggingHole = hole;
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          if (hole.isSelected) {
                                            setState(() {
                                              hole.position += details.delta;
                                              hole.isModified = true;
                                              _draggingHole = hole;
                                              _updateScoreBerdasarkanPosisi(
                                                hole,
                                              );
                                              _calculateBallistics();
                                            });
                                          }
                                        },
                                        onPanEnd: (_) {
                                          setState(() {
                                            _draggingHole = null;
                                          });
                                        },
                                        child: Container(
                                          width: circleSize,
                                          height: circleSize,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  if (_draggingHole != null)
                                    Positioned(
                                      left: _draggingHole!.position.dx - 65,
                                      top: _draggingHole!.position.dy - 165,
                                      child: RawMagnifier(
                                        decoration: const MagnifierDecoration(
                                          shape: CircleBorder(
                                            side: BorderSide(
                                              color: Colors.blueAccent,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        size: const Size(130, 130),
                                        magnificationScale: 2.0,
                                        focalPointOffset: const Offset(0, 100),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Gambar tidak tersedia",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  if (hasSelectedHole) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: _removeSelectedHole,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          "Hapus Lubang",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Result: ${_holes.length} / ${widget.selectedShots}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Total Skor: ${_getTotalScoreText()}",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoText("Windage:", windage),
                      _buildInfoText("Mean Radius:", meanRadius),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoText("Elevation:", elevation),
                      _buildInfoText("Max Spread:", maxSpread),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isSaving
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "RETAKE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _simpanHasilScan(true),
                              child: const Text(
                                "SCAN NEXT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _simpanHasilScan(false),
                              child: const Text(
                                "DONE",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  final List<ShotHole> holes;
  final Offset? targetCenter;
  final double? pixelPerMm;
  final bool isDecimal;
  final double bullsEyeDiameter;

  HolePainter({
    required this.holes,
    this.targetCenter,
    this.pixelPerMm,
    required this.isDecimal,
    required this.bullsEyeDiameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final defaultPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final modifiedPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final selectedPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final purplePaint = Paint()
      ..color = const Color.fromARGB(221, 186, 3, 247)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (targetCenter != null) {
      canvas.drawLine(
        Offset(targetCenter!.dx - 15, targetCenter!.dy),
        Offset(targetCenter!.dx + 15, targetCenter!.dy),
        purplePaint,
      );
      canvas.drawLine(
        Offset(targetCenter!.dx, targetCenter!.dy - 15),
        Offset(targetCenter!.dx, targetCenter!.dy + 15),
        purplePaint,
      );

      if (bullsEyeDiameter > 0 && pixelPerMm != null) {
        double radiusInMm = bullsEyeDiameter / 2.0;
        double radiusInPixel = radiusInMm * pixelPerMm!;
        canvas.drawCircle(targetCenter!, radiusInPixel, purplePaint);
      }
    }

    double holeRadius = (pixelPerMm != null) ? (pixelPerMm! * 2.25) : 10.0;

    for (var h in holes) {
      Paint currentPaint = h.isSelected
          ? selectedPaint
          : (h.isModified ? modifiedPaint : defaultPaint);

      canvas.drawCircle(h.position, holeRadius, currentPaint);

      String displayScore = isDecimal
          ? h.score.toStringAsFixed(1)
          : h.score.floor().toString();

      final textSpan = TextSpan(
        text: displayScore,
        style: TextStyle(
          color: h.isSelected ? Colors.yellow : Colors.redAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black54,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(h.position.dx + holeRadius, h.position.dy - holeRadius),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
