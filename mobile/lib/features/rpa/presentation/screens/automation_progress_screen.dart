import 'package:flutter/material.dart';
import 'package:mobile/features/rpa/presentation/widgets/hacking_mode_overlay.dart';

class AutomationProgressScreen extends StatefulWidget {
  const AutomationProgressScreen({super.key});

  @override
  State<AutomationProgressScreen> createState() =>
      _AutomationProgressScreenState();
}

class _AutomationProgressScreenState extends State<AutomationProgressScreen> {
  final List<String> _logs = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() async {
    // Mock simulation of steps
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _logs.add('Initializing Browser Environment...');
      _progress = 0.1;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _logs.add('Injecting User Data...');
      _progress = 0.5;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _logs.add('Form Submitted Successfully.');
      _progress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const HackingModeOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'AUTO-FILLING DS-160',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.greenAccent,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '> ${_logs[index]}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontFamily: 'Courier',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
