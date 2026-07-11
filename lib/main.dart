import 'package:flutter/material.dart';

void main() {
  runApp(const HacelaRendirApp());
}

class HacelaRendirApp extends StatelessWidget {
  const HacelaRendirApp({super.key});

  static const Color backgroundColor = Color(0xFF071019);
  static const Color cardColor = Color(0xFF0D1824);
  static const Color primaryColor = Color(0xFF24D17E);
  static const Color mutedColor = Color(0xFF8E9AA8);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacela Rendir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color backgroundColor = Color(0xFF071019);
  static const Color cardColor = Color(0xFF0D1824);
  static const Color primaryColor = Color(0xFF24D17E);
  static const Color mutedColor = Color(0xFF8E9AA8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: primaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'HACELA RENDIR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tu cartera. Tu análisis. Tu ventaja.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const FeatureCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Seguimiento de cartera',
                    description:
                        'Consolidá todas tus inversiones en un mismo lugar.',
                  ),
                  const SizedBox(height: 12),
                  const FeatureCard(
                    icon: Icons.show_chart_rounded,
                    title: 'Rentabilidad y riesgo',
                    description:
                        'Analizá rendimiento, beta, drawdown y volatilidad.',
                  ),
                  const SizedBox(height: 12),
                  const FeatureCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Journal inteligente',
                    description:
                        'Registrá cada decisión y mejorá como inversor.',
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Próximamente: creación de cuenta.',
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Comenzar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Próximamente: inicio de sesión.',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF223140),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Ya tengo una cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Datos protegidos · Conexiones seguras',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1824),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF223140),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF24D17E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Color(0xFF24D17E),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8E9AA8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}