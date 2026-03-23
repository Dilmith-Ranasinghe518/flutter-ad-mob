/// Defines the environment mode for Google Mobile Ads.
enum AdEnvironment {
  /// Show only real / live ads using the provided Ad Unit IDs.
  enable,

  /// Completely disable ads. Ads will neither be loaded nor shown.
  disable,

  /// Hybrid mode: shows real ads in release/production builds,
  /// but uses Google's standard test Ad Unit IDs during development/testing.
  hybrid,
}
