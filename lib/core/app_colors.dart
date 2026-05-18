/// File: lib/core/app_colors.dart
/// Role: Defines the core color palette and semantic tokens (primary, secondary, surface, gradients)
/// used throughout the TuneIn application to maintain design system consistency.

import 'package:flutter/material.dart';

/// The primary brand color.
const Color kPrimary             = Color(0xFF9D3756);

/// The primary brand color container variant.
const Color kPrimaryContainer    = Color(0xFFFA7F9F);

/// Color for text/icons drawn on top of the primary color.
const Color kOnPrimary           = Color(0xFFFFEFF0);

/// A slightly darker version of the primary color.
const Color kPrimaryDim          = Color(0xFF8E2B4A);

/// The secondary brand color.
const Color kSecondary           = Color(0xFF944052);

/// The secondary color container variant.
const Color kSecondaryContainer  = Color(0xFFFFC2CB);

/// Color for text/icons drawn on top of the secondary color.
const Color kOnSecondary         = Color(0xFFFFEFF0);

/// The tertiary brand color.
const Color kTertiary            = Color(0xFF864A4B);

/// The tertiary color container variant.
const Color kTertiaryContainer   = Color(0xFFF7AAAA);

/// The default background surface color.
const Color kSurface             = Color(0xFFFFF4F6);

/// A dim variant of the surface color.
const Color kSurfaceDim          = Color(0xFFFFC4DE);

/// The default container surface color.
const Color kSurfaceContainer    = Color(0xFFFFE0EC);

/// A low-emphasis variant of the container surface color.
const Color kSurfaceContainerLow = Color(0xFFFFECF2);

/// A high-emphasis variant of the container surface color.
const Color kSurfaceContainerHigh   = Color(0xFFFFD8E8);

/// The highest-emphasis variant of the container surface color.
const Color kSurfaceContainerHighest = Color(0xFFFFD0E4);

/// Color for text/icons drawn on top of standard surfaces.
const Color kOnSurface           = Color(0xFF492136);

/// A variant of kOnSurface used for medium-emphasis text/icons.
const Color kOnSurfaceVariant    = Color(0xFF7C4D64);

/// Outline color for borders and dividers.
const Color kOutline             = Color(0xFF9B6880);

/// A lighter variant of kOutline.
const Color kOutlineVariant      = Color(0xFFD69DB7);

/// The general application background color.
const Color kBackground          = Color(0xFFFFF4F6);

/// Color for text/icons drawn on top of the background.
const Color kOnBackground        = Color(0xFF492136);

/// Inverse surface color used for snackbars and high contrast widgets.
const Color kInverseSurface      = Color(0xFF220215);

/// Color for text/icons drawn on top of the inverse surface.
const Color kInverseOnSurface    = Color(0xFFC48DA6);

/// Inverse primary color.
const Color kInversePrimary      = Color(0xFFFA7F9F);

/// Error indicator color.
const Color kError               = Color(0xFFB31B25);

/// The default brand gradient representing the visual soul of the app.
const LinearGradient kSoulGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimary, kPrimaryContainer],
);
