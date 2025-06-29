// lib/presentation/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../../core/services/language_service.dart';
import 'home_viewmodel.dart';
import 'widgets/support_banner_widget.dart';
import 'widgets/language_toggle_widget.dart';
import 'widgets/drone_sentinel_header_widget.dart';
import 'widgets/start_listening_button_widget.dart';
import 'widgets/about_drone_sentinel_widget.dart';
import 'widgets/sound_detection_dashboard_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
  double _detectionThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<HomeViewModel>(context, listen: false);
    _viewModel.initialize();
    // Set initial threshold
    _viewModel.updateDetectionThreshold(_detectionThreshold / 100.0);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Support Banner
              SupportBannerWidget(),

              const SizedBox(height: 20),

              // Language Toggle
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return LanguageToggleWidget(
                    isEnglish: languageService.isEnglish,
                    onToggle: (value) {
                      languageService.changeLanguage(value);
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              // Drone Sentinel Header
              const DroneSentinelHeaderWidget(),

              const SizedBox(height: 40),

              // Start Listening Button
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return StartListeningButtonWidget(
                    isListening: viewModel.isDetecting,
                    isLoading: viewModel.isLoading,
                    onPressed: viewModel.toggleDetection,
                  );
                },
              ),

              const SizedBox(height: 40),

              // About Drone Sentinel
              const AboutDroneSentinelWidget(),

              const SizedBox(height: 20),

              // Sound Detection Dashboard
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  return SoundDetectionDashboardWidget(
                    isDetecting: viewModel.isDetecting,
                    isDroneDetected: viewModel.isDroneDetected,
                    detectionConfidence: viewModel.detectionConfidence,
                    detectionThreshold: _detectionThreshold,
                    onThresholdChanged: (value) {
                      setState(() {
                        _detectionThreshold = value;
                      });
                      // Update the viewmodel with the new threshold
                      viewModel.updateDetectionThreshold(value / 100.0);
                    },
                    samples: viewModel.samples,
                    audioFrequencies: viewModel.audioFrequencies,
                    predictionScores: viewModel.predictionScores,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
