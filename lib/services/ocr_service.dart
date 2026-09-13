import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  /// Extract text from image
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      final RecognizedText recognizedText =
      await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  /// Extract text blocks with their individual text
  Future<List<String>> extractTextBlocks(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      final RecognizedText recognizedText =
      await _textRecognizer.processImage(inputImage);

      return recognizedText.blocks
          .map((block) => block.text)
          .toList();
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}