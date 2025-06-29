// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_constants.dart';
import 'core/permissions.dart';
import 'data/repositories/tflite_model_repository.dart';
import 'data/services/audio_capture_service.dart';
import 'data/services/tflite_inference_service.dart';
import 'domain/usecases/detect_drone_usecase.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/home_viewmodel.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/shared_widgets/message_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the TFLite model repository
  final modelRepository = TfliteModelRepository();
  try {
    // Load the model. This method now returns Future<void>.
    await modelRepository.loadModel(AppConstants.tfliteModelPath);

    // Check if the model loaded successfully using the isLoaded getter.
    if (!modelRepository.isLoaded) {
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MessageBox(
                title: 'Error',
                message:
                    'Failed to load TensorFlow Lite model. Please check the model path and file.',
                buttonText: 'OK',
              ),
            ),
          ),
        ),
      );
      return; // Stop app execution if model can't be loaded
    }
  } catch (e) {
    // Catch any exceptions during model loading
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MessageBox(
              title: 'Initialization Error',
              message: 'An error occurred while loading the model: $e',
              buttonText: 'OK',
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Request microphone permission at app start
  final bool hasPermission = await AppPermissions.requestMicrophonePermission();
  if (!hasPermission) {
    // Show a message if permission is not granted
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: MessageBox(
              title: 'Permission Denied',
              message: 'Microphone permission is required to use this app.',
              buttonText: 'OK',
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Set up dependency injection using Provider
  runApp(
    MultiProvider(
      providers: [
        // Provide the single instance of TfliteModelRepository to the app
        Provider<TfliteModelRepository>.value(value: modelRepository),

        // Provide services
        Provider<AudioCaptureService>(create: (_) => AudioCaptureService()),
        Provider<TfliteInferenceService>(
          create:
              (context) => TfliteInferenceService(
                // TfliteInferenceService now depends on the repository
                Provider.of<TfliteModelRepository>(context, listen: false),
              ),
        ),

        // Provide use cases
        Provider<DetectDroneUsecase>(
          create:
              (context) => DetectDroneUsecase(
                Provider.of<AudioCaptureService>(context, listen: false),
                Provider.of<TfliteInferenceService>(context, listen: false),
              ),
        ),

        // Provide the ViewModel
        ChangeNotifierProvider<HomeViewModel>(
          create:
              (context) => HomeViewModel(
                Provider.of<DetectDroneUsecase>(context, listen: false),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Detector',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
