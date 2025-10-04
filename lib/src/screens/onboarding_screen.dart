import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmate/src/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _geminiKeyController = TextEditingController();
  final TextEditingController _grokKeyController = TextEditingController();
  bool _biometrics = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _grokKeyController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Save API keys if provided
      if (_geminiKeyController.text.trim().isNotEmpty) {
        await ref.read(settingsProvider.notifier).setGeminiKey(_geminiKeyController.text.trim());
      }
      
      if (_grokKeyController.text.trim().isNotEmpty) {
        await ref.read(settingsProvider.notifier).setGrokKey(_grokKeyController.text.trim());
      }
      
      // Save biometric setting
      await ref.read(settingsProvider.notifier).setBiometric(_biometrics);
      
      // Complete onboarding
      widget.onFinished();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // App Logo/Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/app-logo.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.psychology,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Welcome Text
                        Text(
                          'Welcome to MindMate',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your personal AI-powered journaling companion for mental wellness',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        // Setup Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Setup (Optional)',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add AI API keys for enhanced features. The app works offline too!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              // Gemini API Key Field
                              TextField(
                                controller: _geminiKeyController,
                                decoration: const InputDecoration(
                                  labelText: 'Gemini API Key',
                                  hintText: 'Optional - for Google AI features',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.key),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              // Grok API Key Field
                              TextField(
                                controller: _grokKeyController,
                                decoration: const InputDecoration(
                                  labelText: 'Grok API Key',
                                  hintText: 'Optional - for X.AI features',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.key),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              // Biometric Toggle
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.fingerprint,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Biometric Lock',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            'Secure your journal with biometric authentication',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _biometrics,
                                      onChanged: (value) => setState(() => _biometrics = value),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _handleContinue,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You can always change these settings later',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
