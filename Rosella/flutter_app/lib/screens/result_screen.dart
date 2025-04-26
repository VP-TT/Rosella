import 'package:flutter/material.dart';
import 'ultrasound_screen.dart';
import 'nearby_hospitals_screen.dart';

class ResultScreen extends StatelessWidget {
  final String prediction;

  const ResultScreen({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final cleanedPrediction = prediction.toLowerCase().trim();
    final isLikely = cleanedPrediction == 'likely pcos';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Result'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLikely
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 100,
                color: isLikely ? Colors.redAccent : Colors.green,
              ),
              const SizedBox(height: 30),
              Text(
                prediction,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isLikely ? Colors.redAccent : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Side-by-side buttons if likely
              if (isLikely) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UltrasoundUploadScreen(),
                            ),
                          );
                        },
                        child: const Text('Upload Ultrasound'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NearbyHospitalsScreen(),
                            ),
                          );
                        },
                        child: const Text('Nearby Hospitals'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
