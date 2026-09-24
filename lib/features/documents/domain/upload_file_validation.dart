/// Mirrors the current server contract: PDF/JPEG/PNG only, maximum 20 MB.
const int kMaxUploadSizeBytes = 20 * 1024 * 1024;

const List<String> kAllowedUploadExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

enum UploadValidationError { unsupportedType, tooLarge }

/// Returns `null` when [filePath]/[sizeBytes] pass, otherwise which check
/// failed. Extension is checked before size — an unsupported type is a
/// clearer signal to show the user than a size limit that may not even
/// apply to that kind of file.
UploadValidationError? validateUploadFile(String filePath, int sizeBytes) {
  final dotIndex = filePath.lastIndexOf('.');
  final extension = dotIndex == -1
      ? ''
      : filePath.substring(dotIndex + 1).toLowerCase();
  if (!kAllowedUploadExtensions.contains(extension)) {
    return UploadValidationError.unsupportedType;
  }
  if (sizeBytes > kMaxUploadSizeBytes) {
    return UploadValidationError.tooLarge;
  }
  return null;
}
