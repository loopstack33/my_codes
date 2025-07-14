import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AutoCameraScreen extends StatefulWidget {
  const AutoCameraScreen({super.key});

  @override
  State<AutoCameraScreen> createState() => _AutoCameraScreenState();
}

class _AutoCameraScreenState extends State<AutoCameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  Timer? _timer;
  int _secondsLeft = 10;
  bool isCapturing = false;
  List<String> capturedImagePaths = [];
  int _imageCount = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();
    cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller?.initialize();
    if (mounted) setState(() {});
  }

  void _startTimerAndCapture() {
    _secondsLeft = 10;
    capturedImagePaths.clear();
    _imageCount = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsLeft == 0) {
        _stopCapture();
        return;
      }

      setState(() {
        _secondsLeft--;
      });

      // Try to capture 1 image every second
      if (_controller!.value.isInitialized && !_controller!.value.isTakingPicture) {
        _captureImage();
      }
    });

    setState(() {
      isCapturing = true;
    });
  }

  void _stopCapture() {
    _timer?.cancel();
    setState(() {
      isCapturing = false;
    });
    // TODO: Process images or show to user
  }

  Future<void> _captureImage() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await _controller!.takePicture();
      await file.saveTo(filePath);
      capturedImagePaths.add(filePath);
      _imageCount++;

      // Optional: Analyze image for distance estimation
      _analyzeImageForDistance(filePath);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void _analyzeImageForDistance(String imagePath) {
    // Fake estimation using image brightness or size
    // In real-world, use image ML analysis or focus depth sensor (native Android)
    File image = File(imagePath);

    // Placeholder logic
    if (_imageCount % 3 == 0) {
      _showDistanceFeedback("Move closer");
    } else if (_imageCount % 4 == 0) {
      _showDistanceFeedback("Move farther");
    } else {
      _showDistanceFeedback("Hold still (focused)");
    }
  }

  void _showDistanceFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 500),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(_controller?.value.isInitialized ?? false)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Auto Camera Timer")),
      body: Column(
        children: [
          // Camera Preview
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
          if (isCapturing)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                'Time left: $_secondsLeft',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          // Captured Images Preview
          if (capturedImagePaths.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: capturedImagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Image.file(
                    File(capturedImagePaths[index]),
                    width: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

          const Spacer(),

          // Start Button
          ElevatedButton(
            onPressed: isCapturing ? null : _startTimerAndCapture,
            child: const Text("Start 10s Capture"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
