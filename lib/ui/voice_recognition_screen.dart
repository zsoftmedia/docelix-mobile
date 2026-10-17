import 'package:docelix_mobileapp/controllers/voice_recognition_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceRecognitionScreen extends StatelessWidget {
  VoiceRecognitionScreen({super.key});

  final VoiceRecognitionController controller =
      Get.put(VoiceRecognitionController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Voice Recognition',
          style: TextStyle(fontSize: rs.sp(18)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.all(rs.s(20)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rs.s(16)),
                  ),
                  child: TextField(
                    controller: controller.textController,
                    minLines: 5,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: rs.sp(15)),
                    decoration: InputDecoration(
                      hintText: 'Speak something...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: rs.sp(15),
                      ),
                      contentPadding: EdgeInsets.all(rs.s(16)),
                      suffixIcon: Obx(
                        () => controller.recognizedText.value.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                onPressed: controller.clearText,
                                icon: Icon(
                                  Icons.clear,
                                  color: colorsList.iconColor,
                                  size: rs.s(22),
                                ),
                              ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(rs.s(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: rs.s(30)),
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
                        fontSize: rs.sp(16),
                        fontWeight: FontWeight.w500,
                        color: controller.isListening.value
                            ? Colors.red
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: rs.s(20)),
                Obx(
                  () => GestureDetector(
                    onTap: controller.toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: rs.s(80),
                      height: rs.s(80),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isListening.value
                            ? Colors.red
                            : const Color(0xFF2563EB),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
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
                        size: rs.s(35),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: rs.s(30)),
                Obx(
                  () {
                    final text = controller.recognizedText.value;

                    if (text.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(rs.s(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rs.s(16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recognized Text',
                            style: TextStyle(
                              fontSize: rs.sp(14),
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: rs.s(8)),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: rs.sp(16),
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
      ),
    );
  }
}
