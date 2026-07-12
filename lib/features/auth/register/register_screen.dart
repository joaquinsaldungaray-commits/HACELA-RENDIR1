import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/features/auth/widgets/auth_header.dart';
import 'package:hacela_rendir/features/auth/widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                      title: 'Creá tu cuenta',
                      subtitle:
                          'Empezá a construir una visión completa de tus inversiones.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthTextField(
                      controller: nameController,
                      label: 'Nombre completo',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Ingresá tu nombre completo.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: emailController,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
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
                        if (value == null || value.length < 6) {
                          return 'Debe tener al menos 6 caracteres.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextField(
                      controller: confirmPasswordController,
                      label: 'Confirmar contraseña',
                      icon: Icons.lock_reset_outlined,
                      obscureText: true,
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Las contraseñas no coinciden.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Crear cuenta',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: submit,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Ya tengo una cuenta',
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        context.go(AppRoutes.login);
                      },
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