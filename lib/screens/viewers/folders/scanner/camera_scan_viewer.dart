import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ns3_project/components/colors.dart';
import 'package:ns3_project/service/api_config.dart';
import 'package:ns3_project/screens/viewers/folders/scanner/preview_scan_viewer.dart';

class ViewerCameraScanScreen extends StatefulWidget {
  final Map<String, dynamic> trainingData;
  final Map<String, dynamic> sesiData;
  final int defaultShots;

  const ViewerCameraScanScreen({
    super.key,
    required this.trainingData,
    required this.sesiData,
    required this.defaultShots,
  });

  @override
  State<ViewerCameraScanScreen> createState() => _ViewerCameraScanScreenState();
}

class _ViewerCameraScanScreenState extends State<ViewerCameraScanScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  int _selectedShots = 5;
  int _maxShots = 10;
  bool _hasScannedAtLeastOnce = false;

  String _instructionText =
      "Harap posisikan kertas target penuh di dalam bingkai hijau";

  @override
  void initState() {
    super.initState();
    _maxShots = widget.trainingData['shotsPerSeries'] ?? 10;
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

      String subKategori = widget.trainingData['subKategori'] ?? '';
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
          _instructionText =
              "Harap posisikan kertas target penuh di dalam bingkai hijau";
        });
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewerPreviewScanScreen(
              imagePath: image.path,
              trainingData: widget.trainingData,
              sesiData: widget.sesiData,
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
        print("Berhasil Scan! Data JSON: $responseData");
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
                  "Scan Target Latihan",
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRect(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width:
                                        _controller!.value.previewSize!.height,
                                    height:
                                        _controller!.value.previewSize!.width,
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.greenAccent.withOpacity(0.8),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
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
