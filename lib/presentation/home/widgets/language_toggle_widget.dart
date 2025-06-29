// lib/presentation/home/widgets/language_toggle_widget.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LanguageToggleWidget extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onToggle;

  const LanguageToggleWidget({
    super.key,
    required this.isEnglish,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EN',
            style: TextStyle(
              color:
                  isEnglish
                      ? AppColors.textColor
                      : AppColors.textSecondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () => onToggle(!isEnglish),
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.surfaceColor,
                border: Border.all(color: AppColors.borderColor, width: 2),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: isEnglish ? 2 : 28,
                    top: 2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: AppColors.primaryColor,
                          ),
                          child: Stack(
                            children: List.generate(
                              3,
                              (index) => Positioned(
                                top: 2 + (index * 2.0),
                                left: 2,
                                right: 2,
                                child: Container(
                                  height: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            'UK',
            style: TextStyle(
              color:
                  !isEnglish
                      ? AppColors.textColor
                      : AppColors.textSecondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
