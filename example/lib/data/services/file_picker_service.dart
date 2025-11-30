import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Model representing a picked file.
class PickedFile {
  final String name;
  final Uint8List bytes;
  final bool isImage;

  const PickedFile({
    required this.name,
    required this.bytes,
    required this.isImage,
  });

  int get size => bytes.length;
}

/// Service class for file picking operations.
class FilePickerService {
  final ImagePicker _imagePicker;

  FilePickerService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  /// Pick an image from gallery.
  Future<PickedFile?> pickImage({
    double? maxWidth,
    double? maxHeight,
  }) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth ?? 1920,
      maxHeight: maxHeight ?? 1920,
    );

    if (image == null) return null;

    final bytes = await image.readAsBytes();
    return PickedFile(
      name: image.name,
      bytes: bytes,
      isImage: true,
    );
  }

  /// Pick any file type.
  Future<PickedFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.bytes == null) return null;

    final extension = file.extension?.toLowerCase() ?? '';
    final isImageFile = _isImageExtension(extension);

    return PickedFile(
      name: file.name,
      bytes: file.bytes!,
      isImage: isImageFile,
    );
  }

  bool _isImageExtension(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }
}