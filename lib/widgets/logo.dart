import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Logo oficial TesClinic (imagem da marca).
///
/// Usa o asset `assets/images/tesclinic_logo_mark.png`:
/// texto branco, traço vermelho no T e glow vermelho inferior.
class TesClinicLogo extends StatelessWidget {
  /// Altura visual aproximada (escala a imagem).
  final double fontSize;
  final bool showUnderline;
  final String? suffix;
  final bool center;

  const TesClinicLogo({
    super.key,
    this.fontSize = 32,
    this.showUnderline = true,
    this.suffix,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    // Proporção do asset cropado ~572x160
    final height = fontSize * 1.15;
    final width = height * (572 / 160);

    final logo = Image.asset(
      'assets/images/tesclinic_logo_mark.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => _FallbackTextLogo(fontSize: fontSize, suffix: suffix),
    );

    Widget content;
    if (suffix != null && suffix!.isNotEmpty) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logo,
          const SizedBox(width: 8),
          Text(
            suffix!,
            style: GoogleFonts.inter(
              fontSize: fontSize * 0.72,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      );
    } else {
      content = logo;
    }

    if (center) {
      return Center(child: content);
    }
    return content;
  }
}

/// Fallback se o asset não carregar (nunca deve aparecer em build correto).
class _FallbackTextLogo extends StatelessWidget {
  final double fontSize;
  final String? suffix;
  const _FallbackTextLogo({required this.fontSize, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'T',
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: suffix != null ? 'esClinic $suffix' : 'esClinic',
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: fontSize * 3.2,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.9),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.55),
                blurRadius: 8,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Logo compacto para AppBar (altura fixa menor).
class TesClinicLogoCompact extends StatelessWidget {
  final double height;
  const TesClinicLogoCompact({super.key, this.height = 28});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/tesclinic_logo_mark.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
