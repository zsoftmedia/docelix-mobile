import 'package:docelix_mobileapp/controllers/clients_controller.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {

  final ClientsController controller = Get.put(ClientsController());

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Get.back();
          },

          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF0A2342),
            size: width * 0.05,
          ),
        ),

        title: Text(
          "Clients",
          style: TextStyle(
            color: const Color(0xFF0A2342),
            fontSize: width * 0.055,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: false,

        actions: [

          IconButton(
            onPressed: () {
              // Search clients
            },

            icon: Icon(
              Icons.search_rounded,
              color: const Color(0xFF0A2342),
              size: width * 0.065,
            ),
          ),

          SizedBox(
            width: width * 0.02,
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: Column(
          children: [

            // --------------------------------------------------------
            // HEADER
            // --------------------------------------------------------

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    "All Clients",
                    style: TextStyle(
                      color: const Color(0xFF172A46),
                      fontSize: width * 0.045,
                     // fontWeight: FontWeight.w700,
                    ),
                  ),

                  Obx(() => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: height * 0.008,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FB),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        "${controller.clients.length} Clients",
                        style: TextStyle(
                          color: const Color(0xFF063C70),
                          fontSize: width * 0.032,
                         // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // CLIENT LIST
            // --------------------------------------------------------

            Expanded(
              child: Obx(() {
                // ----------------------------------------------------------
                // LOADING
                // ----------------------------------------------------------

                if (controller.isLoading.value &&
                    controller.clients.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF063C70),
                    ),
                  );
                }

                // ----------------------------------------------------------
                // EMPTY
                // ----------------------------------------------------------

                if (controller.clients.isEmpty) {
                  return const Center(
                    child: Text(
                      'No clients found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  );
                }

                // ----------------------------------------------------------
                // CLIENT LIST
                // ----------------------------------------------------------

                return ListView.builder(
                  padding: EdgeInsets.only(
                    left: width * 0.04,
                    right: width * 0.04,
                    bottom: height * 0.12,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.clients.length,
                  itemBuilder: (context, index) {
                    final client = controller.clients[index];

                    return _clientCard(
                      context: context,
                      client: client,
                      width: width,
                      height: height,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      // ============================================================
      // ADD CLIENT BUTTON
      // ============================================================

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          // ----------------------------------------------------------
          // OPEN ADD CLIENT PAGE
          // ----------------------------------------------------------

          Get.toNamed(
            '/AddClientScreen',
            arguments: 'Add Client Screen',);

          // Get.to(
          //   () => const AddClientScreen(),
          // );

          // Temporary action
          Get.snackbar(
            "Add Client",
            "Add Client page will open here.",
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(15),
            backgroundColor: const Color(0xFF063C70),
            colorText: Colors.white,
          );
        },

        backgroundColor: const Color(0xFF063C70),
        foregroundColor: Colors.white,

        elevation: 4,

        icon: const Icon(
          Icons.person_add_alt_1_rounded,
        ),

        label: Text(
          "Add Client",
          style: TextStyle(
            fontSize: width * 0.038,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CLIENT CARD
  // ================================================================

  Widget _clientCard({
    required BuildContext context,
    required ClientScreenModel client,
    required double width,
    required double height,
  }) {
    final String name = client.name.trim().isNotEmpty
        ? client.name.trim()
        : "Unnamed Client";

    final String? email = client.email?.trim().isNotEmpty == true
        ? client.email!.trim()
        : null;

    final String? phone = client.phone?.trim().isNotEmpty == true
        ? client.phone!.trim()
        : null;

    final String city = client.city?.trim() ?? "";
    final String country = client.country?.trim() ?? "";

    final String location = [
      if (city.isNotEmpty) city,
      if (country.isNotEmpty) country,
    ].join(", ");

    return Material(
      color: colorsList.colorWhite,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(
            '/ClientDetailsScreen',
            arguments: client,
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ------------------------------------------------
                  // AVATAR
                  // ------------------------------------------------

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ------------------------------------------------
                  // CLIENT INFORMATION
                  // ------------------------------------------------

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF172033),
                            fontSize: 18,
                          //  fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),

                        if (email != null || phone != null) ...[
                          const SizedBox(height: 5),

                          Row(
                            children: [
                              if (email != null)
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.email_outlined,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12.5,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (email != null && phone != null)
                                const SizedBox(width: 12),

                              if (phone != null)
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          phone,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12.5,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],

                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Color(0xFFB0BAC7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              thickness: 1,
              indent: 52,
              endIndent: 4,
              color: Color(0xFFEFF2F6),
            ),
          ],
        ),
      ),
    );
  }

}