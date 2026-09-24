import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceRecognitionController extends GetxController {
  // ==========================================================
  // SPEECH TO TEXT
  // ==========================================================

  final stt.SpeechToText speech = stt.SpeechToText();

  // ==========================================================
  // TEXT
  // ==========================================================

  final TextEditingController textController =
  TextEditingController();

  // ==========================================================
  // OBSERVABLES
  // ==========================================================

  final RxBool isListening = false.obs;
  final RxBool isAvailable = false.obs;
  final RxString recognizedText = ''.obs;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();
    initializeSpeech();
  }

  // ==========================================================
  // INITIALIZE SPEECH
  // ==========================================================

  Future<void> initializeSpeech() async {
    try {
      final available = await speech.initialize(
        onStatus: (status) {
          debugPrint('Speech Status: $status');

          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (error) {

          AppSnackbar.error(
            title: 'Speech Error',
            message: '${error.errorMsg}',
          );

          isListening.value = false;
        },
      );

      isAvailable.value = available;

      debugPrint('Speech Available: $available');
    } catch (e) {
      debugPrint('Speech Initialization Error: $e');
      isAvailable.value = false;
    }
  }

  // ==========================================================
  // START LISTENING
  // ==========================================================

  Future<void> startListening() async {
    if (!isAvailable.value) {
      await initializeSpeech();
    }

    if (!isAvailable.value) {

      AppSnackbar.error(
        title: 'Voice Recognition',
        message: 'Speech recognition is not available.',
      );

      return;
    }

    if (isListening.value) return;

    // Don't clear existing text unless you want every recording
    // to start from empty.
    recognizedText.value = '';

    textController.clear();

    await speech.listen(
      onResult: (result) {
        final text = result.recognizedWords;

        recognizedText.value = text;

        textController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
            offset: text.length,
          ),
        );

        debugPrint('Recognized Text: $text');
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: true,
      ),
    );

    isListening.value = true;
  }

  // ==========================================================
  // STOP LISTENING
  // ==========================================================

  Future<void> stopListening() async {
    await speech.stop();

    isListening.value = false;

    debugPrint('Speech recognition stopped');
  }

  // ==========================================================
  // TOGGLE LISTENING
  // ==========================================================

  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  // ==========================================================
  // CLEAR TEXT
  // ==========================================================

  void clearText() {
    textController.clear();
    recognizedText.value = '';
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void onClose() {
    speech.stop();
    textController.dispose();
    super.onClose();
  }
}