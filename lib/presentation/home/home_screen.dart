// lib/presentation/home/home_screen.dart

import 'package:drone_detector/presentation/home/widgets/enhanced_audio_waveform_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_viewmodel.dart';
import 'widgets/control_buttons_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Access the ViewModel instance
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Get the ViewModel from the Provider
    _viewModel = Provider.of<HomeViewModel>(context, listen: false);
    _viewModel.initialize(); // Initialize ViewModel resources
  }

  @override
  void dispose() {
    _viewModel.dispose(); // Dispose ViewModel resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drone Detector'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display detection status
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  Color textColor =
                      viewModel.isDroneDetected
                          ? Colors.red.shade700
                          : Colors.green.shade700;
                  return Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          viewModel.detectionMessage,
                          key: ValueKey(viewModel.detectionMessage),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (viewModel.isDetecting)
                        AnimatedOpacity(
                          opacity: viewModel.isDetecting ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            'Confidence: ${viewModel.detectionConfidence.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child:
                            viewModel.isLoading
                                ? const SizedBox(
                                  key: ValueKey('loading'),
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                                : const SizedBox(
                                  key: ValueKey('not-loading'),
                                  height: 24,
                                ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // Audio Frequency Bar Visualization
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return SizedBox(
                    height: 150,
                    width: double.infinity,
                    // child: AudioFrequencyBarWidget(
                    //   frequencies: viewModel.audioFrequencies,
                    //   isDetecting: viewModel.isDetecting,
                    // ),
                    child: EnhancedAudioWaveformWidget(
                      samples: viewModel.samples,
                      isDetecting: viewModel.isDetecting,
                      isDroneDetected: viewModel.isDroneDetected,
                      confidence: viewModel.detectionConfidence,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Control Buttons (Start/Pause)
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return ControlButtonsWidget(
                    isDetecting: viewModel.isDetecting,
                    isLoading: viewModel.isLoading,
                    onToggleDetection: viewModel.toggleDetection,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
