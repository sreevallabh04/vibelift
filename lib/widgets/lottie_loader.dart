import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoader extends StatelessWidget {
  final String assetPath;
  final double size;
  final String? message;

  const LottieLoader({
    super.key,
    required this.assetPath,
    this.size = 200,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Predefined Lottie animations
class LottieAnimations {
  static const String success = 'assets/lottie/success.json';
  static const String loading = 'assets/lottie/loading.json';
  static const String empty = 'assets/lottie/empty.json';
  static const String confetti = 'assets/lottie/confetti.json';
}

// Show success animation dialog
void showSuccessAnimation(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        child: LottieLoader(
          assetPath: LottieAnimations.success,
          size: 150,
          message: message,
        ),
      );
    },
  );
}

// Show confetti animation overlay
void showConfettiAnimation(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          LottieAnimations.confetti,
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () {
              entry.remove();
            });
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
}
