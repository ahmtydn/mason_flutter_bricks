class AppAssets {
  const AppAssets._();

  static const String envDir = 'assets/env';
  static const String iconsDir = 'assets/icons';
  static const String imagesDir = 'assets/images';
  static const String lottieDir = 'assets/lottie';

  static String image(String name) => '$imagesDir/$name';
  static String icon(String name) => '$iconsDir/$name';
  static String lottie(String name) => '$lottieDir/$name';
}
