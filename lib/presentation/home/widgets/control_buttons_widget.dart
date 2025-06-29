// lib/presentation/home/widgets/control_buttons_widget.dart

import 'package:flutter/material.dart';

/// A widget containing the Start/Pause button for drone detection.
class ControlButtonsWidget extends StatefulWidget {
  final bool isDetecting;
  final bool isLoading;
  final VoidCallback onToggleDetection;

  const ControlButtonsWidget({
    super.key,
    required this.isDetecting,
    required this.onToggleDetection,
    this.isLoading = false,
  });

  @override
  State<ControlButtonsWidget> createState() => _ControlButtonsWidgetState();
}

class _ControlButtonsWidgetState extends State<ControlButtonsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: widget.isLoading ? null : widget.onToggleDetection,
                icon:
                    widget.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(
                          widget.isDetecting
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 30,
                        ),
                label: Text(
                  widget.isLoading
                      ? 'Please wait...'
                      : widget.isDetecting
                      ? 'Pause Detection'
                      : 'Start Detection',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text and icon color
                  backgroundColor:
                      widget.isLoading
                          ? Colors.grey.shade600
                          : widget.isDetecting
                          ? Colors.orange.shade700
                          : Colors.green.shade700, // Button background color
                  disabledBackgroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // More rounded corners
                  ),
                  elevation: widget.isLoading ? 4 : 8, // Shadow
                  shadowColor:
                      widget.isLoading
                          ? Colors.grey.shade800
                          : widget.isDetecting
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                  animationDuration: const Duration(
                    milliseconds: 200,
                  ), // Smooth transition
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
