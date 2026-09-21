import 'package:docelix_mobileapp/controllers/voice_recognition_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class VoiceRecognitionScreen extends StatelessWidget {
  VoiceRecognitionScreen({super.key});

  final VoiceRecognitionController controller =
  Get.put(VoiceRecognitionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text('Voice Recognition'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ==================================================
              // TEXT FIELD
              // ==================================================

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller.textController,
                  minLines: 5,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Speak something...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    contentPadding: const EdgeInsets.all(16),

                    suffixIcon: Obx(
                          () => controller.recognizedText.value.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                        onPressed: controller.clearText,
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // LISTENING STATUS
              // ==================================================

              Obx(
                    () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    controller.isListening.value
                        ? 'Listening...'
                        : 'Tap the microphone and speak',
                    key: ValueKey(
                      controller.isListening.value,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: controller.isListening.value
                          ? Colors.red
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // MICROPHONE BUTTON
              // ==================================================

              Obx(
                    () => GestureDetector(
                  onTap: controller.toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.isListening.value
                          ? Colors.red
                          : const Color(0xFF2563EB),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.isListening.value
                          ? Icons.stop
                          : Icons.mic,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // RECOGNIZED TEXT
              // ==================================================

              Obx(
                    () {
                  final text =
                      controller.recognizedText.value;

                  if (text.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recognized Text',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}