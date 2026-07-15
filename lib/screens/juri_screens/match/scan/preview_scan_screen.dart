import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/api_config.dart';

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

class PreviewScanScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> sesiData;
  final Map<String, dynamic> rantingData;
  final Map<String, dynamic> pesertaData;
  final String matchId;
  final int selectedShots;
  final Map<String, dynamic> aiResult;

  const PreviewScanScreen({
    super.key,
    required this.imagePath,
    required this.sesiData,
    required this.rantingData,
    required this.pesertaData,
    required this.matchId,
    required this.selectedShots,
    required this.aiResult,
  });

  @override
  State<PreviewScanScreen> createState() => _PreviewScanScreenState();
}

class _PreviewScanScreenState extends State<PreviewScanScreen> {
  List<ShotHole> holes = [];
  double totalScore = 0.0;
  ShotHole? _draggingHole;
  bool _isDataExtracted = false;

  String windageStr = "0,0 mm";
  String elevationStr = "0,0 mm";
  String meanRadiusStr = "0,0 mm";
  String maxSpreadStr = "0,0 mm";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataExtracted) {
      _ekstrakDataAI();
      _isDataExtracted = true;
    }
  }

  void _ekstrakDataAI() {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 700.0;
    List<dynamic> rawHoles = List.from(widget.aiResult['holes'] ?? []);
    rawHoles.sort((a, b) {
      double scoreA = (a['score'] ?? 0).toDouble();
      double scoreB = (b['score'] ?? 0).toDouble();
      return scoreB.compareTo(scoreA);
    });
    int limit = widget.selectedShots;
    int count = 0;
    for (var hole in rawHoles) {
      if (count >= limit) break;
      ShotHole newHole = ShotHole(
        position: Offset(
          (hole['x'] as num).toDouble() * scale,
          (hole['y'] as num).toDouble() * scale,
        ),
        score: 0.0,
      );
      _updateScoreBerdasarkanPosisi(newHole);
      holes.add(newHole);
      count++;
    }
    _recalculateTotalScore();
  }

  void _recalculateTotalScore() {
    double tempTotal = 0.0;
    for (var hole in holes) {
      tempTotal += hole.score;
    }
    String tempWindage = "0,0 mm";
    String tempElevation = "0,0 mm";
    String tempMeanRadius = "0,0 mm";
    String tempMaxSpread = "0,0 mm";
    if (holes.isNotEmpty &&
        widget.aiResult['target_center'] != null &&
        widget.aiResult['pixel_per_mm'] != null) {
      double scale = MediaQuery.of(context).size.width / 700.0;
      double centerX =
          (widget.aiResult['target_center']['x'] as num).toDouble() * scale;
      double centerY =
          (widget.aiResult['target_center']['y'] as num).toDouble() * scale;
      double pixelPerMm =
          (widget.aiResult['pixel_per_mm'] as num).toDouble() * scale;
      double sumX = 0;
      double sumY = 0;
      for (var hole in holes) {
        sumX += hole.position.dx;
        sumY += hole.position.dy;
      }
      double groupCenterX = sumX / holes.length;
      double groupCenterY = sumY / holes.length;
      double dxPixel = groupCenterX - centerX;
      double windageMm = dxPixel / pixelPerMm;
      double dyPixel = centerY - groupCenterY;
      double elevationMm = dyPixel / pixelPerMm;
      double sumRadius = 0;
      for (var hole in holes) {
        double hx = hole.position.dx - groupCenterX;
        double hy = hole.position.dy - groupCenterY;
        sumRadius += sqrt(hx * hx + hy * hy);
      }
      double meanRadiusMm = (sumRadius / holes.length) / pixelPerMm;
      double maxSpreadPixel = 0;
      for (int i = 0; i < holes.length; i++) {
        for (int j = i + 1; j < holes.length; j++) {
          double dist = (holes[i].position - holes[j].position).distance;
          if (dist > maxSpreadPixel) maxSpreadPixel = dist;
        }
      }
      double maxSpreadMm = maxSpreadPixel / pixelPerMm;
      String windDir = windageMm > 0
          ? "(Kanan)"
          : windageMm < 0
          ? "(Kiri)"
          : "";
      String elevDir = elevationMm > 0
          ? "(Atas)"
          : elevationMm < 0
          ? "(Bawah)"
          : "";
      tempWindage =
          "${windageMm.abs().toStringAsFixed(1).replaceAll('.', ',')} mm $windDir";
      tempElevation =
          "${elevationMm.abs().toStringAsFixed(1).replaceAll('.', ',')} mm $elevDir";
      tempMeanRadius =
          "${meanRadiusMm.toStringAsFixed(1).replaceAll('.', ',')} mm";
      tempMaxSpread =
          "${maxSpreadMm.toStringAsFixed(1).replaceAll('.', ',')} mm";
    }
    setState(() {
      totalScore = double.parse(tempTotal.toStringAsFixed(1));
      windageStr = tempWindage;
      elevationStr = tempElevation;
      meanRadiusStr = tempMeanRadius;
      maxSpreadStr = tempMaxSpread;
    });
  }

  void _updateScoreBerdasarkanPosisi(ShotHole hole) {
    if (widget.aiResult['target_center'] != null &&
        widget.aiResult['pixel_per_mm'] != null) {
      double scale = MediaQuery.of(context).size.width / 700.0;
      double centerX =
          (widget.aiResult['target_center']['x'] as num).toDouble() * scale;
      double centerY =
          (widget.aiResult['target_center']['y'] as num).toDouble() * scale;
      double pixelPerMm =
          (widget.aiResult['pixel_per_mm'] as num).toDouble() * scale;
      String disiplin = widget.aiResult['disiplin'] ?? 'rifle';
      bool isDecimal = widget.rantingData['skorDesimal'] ?? false;
      double dx = hole.position.dx - centerX;
      double dy = hole.position.dy - centerY;
      double distancePixel = sqrt(dx * dx + dy * dy);
      double distanceMm = distancePixel / pixelPerMm;
      double calculatedScore = 0.0;
      if (disiplin == 'rifle') {
        calculatedScore = 11.0 - (distanceMm / 2.5);
      } else {
        calculatedScore = 11.0 - (distanceMm / 8.0);
      }
      calculatedScore = calculatedScore.clamp(0.0, 10.9);
      if (isDecimal) {
        calculatedScore = double.parse(calculatedScore.toStringAsFixed(1));
      } else {
        calculatedScore = calculatedScore.floorToDouble().clamp(0.0, 10.0);
      }
      hole.score = calculatedScore;
    } else {
      hole.score = 0.0;
    }
  }

  Future<void> _simpanHasilScan(bool isNext) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
    );
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/match/${widget.matchId}/ranting/${widget.rantingData['_id']}/peserta/${widget.pesertaData['_id']}/sesi/${widget.sesiData['_id']}/update-score',
      );
      List<double> finalScores = holes.map((h) => h.score).toList();
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "score": totalScore.toStringAsFixed(1),
          "jumlahLubang": holes.length,
          "windage": windageStr,
          "elevation": elevationStr,
          "meanRadius": meanRadiusStr,
          "maxSpread": maxSpreadStr,
          "skorDetailArray": finalScores,
        }),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        if (isNext) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.infoReverse,
            animType: AnimType.scale,
            title: 'LANJUT TERUS!',
            desc: 'Target berhasil disimpan!',
            btnOkColor: primaryColor,
            btnOkText: 'OK',
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            btnOkOnPress: () => Navigator.pop(context, 'NEXT'),
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'BERHASIL',
            desc: 'Nilai Sesi Berhasil Disimpan!',
            btnOkColor: primaryColor,
            btnOkText: 'OKE!',
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
            btnOkOnPress: () {
              Navigator.of(context)
                ..pop()
                ..pop(true);
            },
          ).show();
        }
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  String formatScore(double score) {
    return score == score.toInt() ? score.toInt().toString() : score.toString();
  }

  double _getKaliberSizeInMm() {
    String kaliberStr =
        (widget.rantingData['amunisi'] ??
                widget.rantingData['kaliberAmunisi'] ??
                widget.rantingData['kaliber_amunisi'] ??
                widget.sesiData['kaliberAmunisi'] ??
                widget.sesiData['kaliber_amunisi'] ??
                widget.pesertaData['kaliberAmunisi'] ??
                widget.pesertaData['kaliber_amunisi'] ??
                '4,5')
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
    bool hasSelectedHole = holes.any((h) => h.isSelected);
    String? base64ProcessedImage = widget.aiResult['processed_image'];
    double scale = MediaQuery.of(context).size.width / 700.0;
    double pixelPerMmFromPython =
        (widget.aiResult['pixel_per_mm'] as num?)?.toDouble() ?? 15.0;
    double screenPixelPerMm = pixelPerMmFromPython * scale;
    double caliberMm = _getKaliberSizeInMm();
    double visualFix = 1.1;
    double circleSize = (caliberMm * screenPixelPerMm) * visualFix;
    double halfSize = circleSize / 2;
    String disiplin = widget.aiResult['disiplin'] ?? 'rifle';
    double aimingMarkDiameterMm = disiplin == 'rifle' ? 30.5 : 59.5;
    double aimingMarkScreenSize = aimingMarkDiameterMm * screenPixelPerMm;
    double aimingMarkHalfSize = aimingMarkScreenSize / 2;
    double? centerX;
    double? centerY;
    if (widget.aiResult['target_center'] != null) {
      centerX =
          (widget.aiResult['target_center']['x'] as num).toDouble() * scale;
      centerY =
          (widget.aiResult['target_center']['y'] as num).toDouble() * scale;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Preview",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    for (var h in holes) {
                      h.isSelected = false;
                    }
                    _draggingHole = null;
                  });
                },
                onDoubleTapDown: (TapDownDetails details) {
                  setState(() {
                    for (var h in holes) {
                      h.isSelected = false;
                    }
                    _draggingHole = null;

                    ShotHole newHole = ShotHole(
                      position: details.localPosition,
                      score: 0.0,
                      isModified: true,
                    );
                    _updateScoreBerdasarkanPosisi(newHole);
                    holes.add(newHole);
                    _recalculateTotalScore();
                  });
                },
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRect(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: base64ProcessedImage != null
                                ? Image.memory(
                                    base64Decode(base64ProcessedImage),
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (centerX != null && centerY != null)
                            Positioned(
                              left: centerX - aimingMarkHalfSize,
                              top: centerY - aimingMarkHalfSize,
                              child: Container(
                                width: aimingMarkScreenSize,
                                height: aimingMarkScreenSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.4),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      221,
                                      186,
                                      3,
                                      247,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          if (centerX != null && centerY != null)
                            Positioned(
                              left: centerX - 7.5,
                              top: centerY - 7.5,
                              child: const Icon(
                                Icons.add,
                                color: Color.fromARGB(221, 186, 3, 247),
                                size: 15,
                              ),
                            ),
                          ...holes.map((hole) {
                            Color dotColor = Colors.redAccent;
                            if (hole.isSelected) {
                              dotColor = Colors.blueAccent;
                            } else if (hole.isModified) {
                              dotColor = Colors.green;
                            }
                            return Positioned(
                              left: hole.position.dx - halfSize,
                              top: hole.position.dy - halfSize,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    for (var h in holes) {
                                      h.isSelected = false;
                                    }
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

                                      _updateScoreBerdasarkanPosisi(hole);
                                      _recalculateTotalScore();
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: dotColor,
                                      width: 2.0,
                                    ),
                                    color: Colors.transparent,
                                  ),
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
                          if (hasSelectedHole)
                            Positioned(
                              top: 20,
                              right: 20,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    holes.removeWhere((h) => h.isSelected);
                                    _draggingHole = null;
                                    _recalculateTotalScore();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 28,
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
            ),
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Score: ${formatScore(totalScore)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    holes.map((h) => formatScore(h.score)).join("  "),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Windage: $windageStr  |  Elevation: $elevationStr",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Mean Radius: $meanRadiusStr  |  Max Spread: $maxSpreadStr",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
