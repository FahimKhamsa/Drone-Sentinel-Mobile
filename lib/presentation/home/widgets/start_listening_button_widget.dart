// lib/presentation/home/widgets/start_listening_button_widget.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class StartListeningButtonWidget extends StatelessWidget {
  final bool isListening;
  final bool isLoading;
  final VoidCallback onPressed;

  const StartListeningButtonWidget({
    super.key,
    required this.isListening,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceColor,
            border: Border.all(
              color:
                  isListening ? AppColors.successColor : AppColors.borderColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child:
                isLoading
                    ? CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 3,
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isListening ? Icons.stop : Icons.play_arrow,
                          color: AppColors.primaryColor,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isListening
                              ? AppLocalizations.of(context)!.stopListening
                              : AppLocalizations.of(context)!.startListening,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
