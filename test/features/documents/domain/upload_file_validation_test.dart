import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/documents/domain/upload_file_validation.dart';

void main() {
  group('validateUploadFile', () {
    test('passes for an allowed extension under the size cap', () {
      expect(validateUploadFile('/tmp/contract.pdf', 1024), isNull);
    });

    test('is case-insensitive on extension', () {
      expect(validateUploadFile('/tmp/scan.PDF', 1024), isNull);
    });

    test('rejects an unsupported extension', () {
      expect(
        validateUploadFile('/tmp/video.mp4', 1024),
        UploadValidationError.unsupportedType,
      );
    });

    test('rejects a file with no extension', () {
      expect(
        validateUploadFile('/tmp/noextension', 1024),
        UploadValidationError.unsupportedType,
      );
    });

    test('rejects a file over the size cap', () {
      expect(
        validateUploadFile('/tmp/scan.pdf', kMaxUploadSizeBytes + 1),
        UploadValidationError.tooLarge,
      );
    });

    test('passes exactly at the size cap', () {
      expect(validateUploadFile('/tmp/scan.pdf', kMaxUploadSizeBytes), isNull);
    });

    test(
      'reports unsupportedType (not tooLarge) when both checks would fail',
      () {
        expect(
          validateUploadFile('/tmp/video.mp4', kMaxUploadSizeBytes + 1),
          UploadValidationError.unsupportedType,
        );
      },
    );
  });
}
