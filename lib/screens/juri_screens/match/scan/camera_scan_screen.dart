import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/screens/juri_screens/match/scan/preview_scan_screen.dart';
import 'package:ns3_project/service/api_config.dart';

class CameraScanScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> rantingData;
  final Map<String, dynamic> pesertaData;
  final Map<String, dynamic> sesiData;
  final int defaultShots;

  const CameraScanScreen({
    super.key,
    required this.matchId,
    required this.rantingData,
    required this.pesertaData,
    required this.sesiData,
    required this.defaultShots,
  });

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  int _selectedShots = 5;
  int _maxShots = 10;
  bool _hasScannedAtLeastOnce = false;

  String _instructionText = "Please take a photo of the card with white holes";

  @override
  void initState() {
    super.initState();
    _maxShots = widget.rantingData['shotsPerSeries'] ?? 10;
    _selectedShots = widget.defaultShots > 0 ? widget.defaultShots : _maxShots;

    if (_selectedShots > _maxShots) {
      _selectedShots = _maxShots;
    }

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (!mounted) return;
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      print("Gagal Inisialisasi Kamera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takeAndUploadPhoto() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 15),
              Text(
                "AI Sedang Meratakan Target...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/scan/analyze'),
      );
      request.fields['shots'] = _selectedShots.toString();

      String subKategori = widget.rantingData['sub_kategori'] ?? '';
      String disiplin = subKategori.toLowerCase().contains('rifle')
          ? 'rifle'
          : 'pistol';
      request.fields['discipline'] = disiplin;
      request.files.add(
        await http.MultipartFile.fromPath('targetImage', image.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          _instructionText = "Please take a photo of the card with white holes";
        });

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScanScreen(
              imagePath: image.path,
              matchId: widget.matchId,
              sesiData: widget.sesiData,
              rantingData: widget.rantingData,
              pesertaData: widget.pesertaData,
              selectedShots: _selectedShots,
              aiResult: responseData,
            ),
          ),
        );
        if (result == 'NEXT') {
          setState(() {
            _hasScannedAtLeastOnce = true;
            widget.sesiData['jumlahLubang'] =
                (widget.sesiData['jumlahLubang'] ?? 0) + _selectedShots;
            widget.sesiData['targetScanned'] =
                (widget.sesiData['targetScanned'] ?? 0) + 1;
          });
        }
      } else if (response.statusCode == 400) {
        var errorData = jsonDecode(response.body);
        setState(() {
          if (errorData['error'] == 'TOO_FAR') {
            _instructionText =
                "❌ Jarak Terlalu Jauh! Silakan dekatkan kamera ke kertas target.";
          } else {
            _instructionText = "❌ ${errorData['error']}";
          }
        });
      } else {
        print("Gagal Koneksi Server: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context);
      print("Koneksi Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    int targetScanned = widget.sesiData['targetScanned'] ?? 0;
    int targetKe = targetScanned + 1;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasScannedAtLeastOnce);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Scan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _isCameraInitialized
                    ? Center(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRect(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.previewSize!.height,
                                height: _controller!.value.previewSize!.width,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Target: $targetKe",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "Shots:   ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            DropdownButton<int>(
                              value: _selectedShots,
                              dropdownColor: Colors.grey.shade800,
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              items: List.generate(_maxShots, (i) => i + 1)
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text("$e per target"),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedShots = val!),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _instructionText,
                          key: ValueKey<String>(_instructionText),
                          style: TextStyle(
                            color: _instructionText.contains('❌')
                                ? Colors.redAccent
                                : Colors.white70,
                            fontSize: 14,
                            fontWeight: _instructionText.contains('❌')
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, _hasScannedAtLeastOnce),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _takeAndUploadPhoto,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent.shade200,
                                width: 4,
                              ),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
