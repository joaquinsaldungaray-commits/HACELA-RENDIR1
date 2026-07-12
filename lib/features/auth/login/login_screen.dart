import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/auth/widgets/auth_header.dart';
import 'package:hacela_rendir/features/auth/widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (formKey.currentState?.validate() ?? false) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const AuthHeader(
                      title: 'Bienvenido',
                      subtitle:
                          'Ingresá para consultar tu cartera y tus métricas.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: emailController,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá tu correo electrónico.';
                        }

                        if (!value.contains('@')) {
                          return 'Ingresá un correo válido.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresá tu contraseña.';
                        }

                        if (value.length < 6) {
                          return 'Debe tener al menos 6 caracteres.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Ingresar',
                      icon: Icons.login_rounded,
                      onPressed: submit,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Crear una cuenta',
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        context.go(AppRoutes.register);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}