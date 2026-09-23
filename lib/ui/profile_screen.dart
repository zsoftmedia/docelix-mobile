import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController =
  TextEditingController(text: 'anees.irshad');

  final TextEditingController emailController =
  TextEditingController(text: 'anees.irshad@berrinex.com');

  final TextEditingController usernameController =
  TextEditingController(text: 'anees.irshad');

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    setState(() {
      isSaving = true;
    });

    // TODO: Call profile update API here
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.045,
            vertical: 20,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ============================================================
              // PROFILE HEADER
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: const Color(0xFFE4E7EC),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [

                        Container(
                          width: 92,
                          height: 92,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8EEF5),

                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),

                          child: const Icon(
                            Icons.person_outline,
                            size: 55,
                            color: Color(0xFF98A2B3),
                          ),
                        ),

                        Container(
                          width: 30,
                          height: 30,

                          decoration: BoxDecoration(
                            color: const Color(0xFF1769AA),
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),

                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'anees.irshad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'anees.irshad@berrinex.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Plan + Role
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        _buildBadge(
                          icon: Icons.bolt,
                          text: 'Free',
                          backgroundColor:
                          const Color(0xFFF2F4F7),
                          textColor:
                          const Color(0xFF344054),
                        ),

                        const SizedBox(width: 8),

                        _buildBadge(
                          icon: Icons.verified_user_outlined,
                          text: 'Owner',
                          backgroundColor:
                          const Color(0xFFE8F1FA),
                          textColor:
                          const Color(0xFF175A8A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============================================================
              // ACCOUNT INFORMATION
              // ============================================================

              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: const Color(0xFFE4E7EC),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Name
                    _buildLabel('Name'),

                    const SizedBox(height: 7),

                    AppTextField(
                      controller: nameController,
                      hintText: 'Enter your name',
                      keyboardType: TextInputType.name,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),


                    const SizedBox(height: 18),

                    // Username
                    _buildLabel('Username'),

                    const SizedBox(height: 7),

                    AppTextField(
                      controller: usernameController,
                      hintText: 'Enter your username',
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
                    _buildLabel('Email'),

                    const SizedBox(height: 7),

                    AppTextField(
                      controller: emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Plan
                    _buildLabel('Plan'),

                    const SizedBox(height: 8),

                    _buildInfoValue(
                      icon: Icons.bolt,
                      value: 'Free',
                    ),

                    const SizedBox(height: 18),

                    // Role
                    _buildLabel('Role'),

                    const SizedBox(height: 8),

                    _buildInfoValue(
                      icon: Icons.verified_user_outlined,
                      value: 'Owner',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============================================================
              // ACCOUNT DETAILS
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: const Color(0xFFE4E7EC),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildDetailRow(
                      title: 'Account created',
                      value: '9 Sep 2026',
                    ),

                    const SizedBox(height: 14),

                    _buildDetailRow(
                      title: 'Last login',
                      value: 'Today',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // SAVE BUTTON
              // ============================================================

              /*SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: isSaving ? null : saveChanges,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF1769AA),

                    disabledBackgroundColor:
                    const Color(0xFF98A2B3),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.check,
                        size: 20,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),*/

              AppButton(
                text: 'Save',

               // isLoading: loginController.isLoading.value,

                onPressed: () {
                 // loginController.login();
                },

                width: double.infinity,
                height: height * 0.070,

                backgroundColor: colorsList.primaryBlue,
                disabledBackgroundColor: colorsList.primaryBlue,

                foregroundColor: Colors.white,
                loadingColor: Colors.white,

                borderRadius: 4,

                fontSize: width * 0.043,
                fontWeight: FontWeight.w700,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475467),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 15,
            color: textColor,
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoValue({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [

        Icon(
          icon,
          size: 18,
          color: const Color(0xFF1769AA),
        ),

        const SizedBox(width: 8),

        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF667085),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF344054),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF98A2B3),
      ),

      filled: true,
      fillColor: const Color(0xFFF9FAFB),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      suffixIcon: suffixIcon,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD0D5DD),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD0D5DD),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF1769AA),
          width: 1.5,
        ),
      ),
    );
  }
}