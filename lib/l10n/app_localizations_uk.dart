// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Детектор Дронів';

  @override
  String get supportBanner => 'Підтримати Drone Sentinel';

  @override
  String get droneSentinelTitle => 'Drone Sentinel';

  @override
  String get droneSentinelSubtitle => 'Розширене виявлення дронів на базі ШІ';

  @override
  String get startListening => 'Почати прослуховування';

  @override
  String get stopListening => 'Зупинити прослуховування';

  @override
  String get loading => 'Завантаження...';

  @override
  String get aboutTitle => 'Про Drone Sentinel';

  @override
  String get aboutDescription =>
      'Drone Sentinel використовує передові технології штучного інтелекту для виявлення звуків дронів у реальному часі. Наша модель машинного навчання аналізує звукові патерни для виявлення потенційної активності дронів з високою точністю.';

  @override
  String get detectionDashboard => 'Панель виявлення';

  @override
  String get detectionThreshold => 'Поріг виявлення';

  @override
  String get droneDetected => 'ДРОН ВИЯВЛЕНО!';

  @override
  String get noDroneDetected => 'Дрон не виявлено';

  @override
  String get confidence => 'Впевненість';

  @override
  String get audioWaveform => 'Звукова хвиля';

  @override
  String get frequencyAnalysis => 'Частотний аналіз';

  @override
  String get predictionScores => 'Оцінки прогнозування';

  @override
  String get errorTitle => 'Помилка';

  @override
  String get initializationError => 'Помилка ініціалізації';

  @override
  String get permissionDenied => 'Дозвіл відхилено';

  @override
  String get microphonePermissionRequired =>
      'Для використання цього додатку потрібен дозвіл на мікрофон.';

  @override
  String get modelLoadError =>
      'Не вдалося завантажити модель TensorFlow Lite. Будь ласка, перевірте шлях до моделі та файл.';

  @override
  String get ok => 'ОК';

  @override
  String get soundDetectionMeter => 'Лічильник виявлення звуку';

  @override
  String get listeningForSounds => 'Прослуховування звуків...';

  @override
  String get listening => 'Прослуховування...';

  @override
  String get systemStatus => 'Стан системи';

  @override
  String get monitoringFor => 'Моніторинг';

  @override
  String get backgroundNoiseFpvDrone => 'Фоновий шум, FPV дрон';

  @override
  String get microphone => 'Мікрофон';

  @override
  String get connected => 'Підключено';

  @override
  String get model => 'Модель';

  @override
  String get loaded => 'Завантажено';

  @override
  String get detectionStatus => 'Стан виявлення';

  @override
  String get waitingForSounds => 'Очікування звуків...';

  @override
  String get loadingSoundDetectionModel =>
      'Завантаження моделі виявлення звуку...';

  @override
  String get moreDetections => 'Більше виявлень';

  @override
  String get higherAccuracy => 'Вища точність';

  @override
  String get backgroundNoise => 'Фоновий шум';

  @override
  String get fpvDrone => 'FPV дрон';
}
