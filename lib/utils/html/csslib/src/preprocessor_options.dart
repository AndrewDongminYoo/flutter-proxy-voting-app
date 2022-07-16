class PreprocessorOptions {
  final bool polyfill;
  final bool warningsAsErrors;
  final bool throwOnWarnings;
  final bool throwOnErrors;
  final bool verbose;
  final bool checked;
  final bool lessSupport;
  final bool useColors;
  final String? inputFile;
  const PreprocessorOptions(
      {this.verbose = false,
      this.checked = false,
      this.lessSupport = true,
      this.warningsAsErrors = false,
      this.throwOnErrors = false,
      this.throwOnWarnings = false,
      this.useColors = true,
      this.polyfill = false,
      this.inputFile});
}
