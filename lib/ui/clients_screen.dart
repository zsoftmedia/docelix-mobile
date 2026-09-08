import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {

  // ============================================================
  // DUMMY CLIENT DATA
  // ============================================================

  final List<Map<String, dynamic>> clients = [
    {
      "created": "08 Sep 2026",
      "name": "ABC Trading Company",
      "email": "info@abctrading.com",
      "phone": "+43 660 1234567",
      "address": "Mariahilfer Straße 25",
      "zip": "1060",
      "city": "Vienna",
      "country": "Austria",
      "vatId": "ATU12345678",
    },
    {
      "created": "06 Sep 2026",
      "name": "Global Solutions GmbH",
      "email": "office@globalsolutions.at",
      "phone": "+43 699 9876543",
      "address": "Hauptstraße 45",
      "zip": "4020",
      "city": "Linz",
      "country": "Austria",
      "vatId": "ATU87654321",
    },
    {
      "created": "03 Sep 2026",
      "name": "Tech World GmbH",
      "email": "contact@techworld.com",
      "phone": "+43 650 4567890",
      "address": "Kärntner Straße 18",
      "zip": "1010",
      "city": "Vienna",
      "country": "Austria",
      "vatId": "ATU45678912",
    },
    {
      "created": "01 Sep 2026",
      "name": "Modern Business Ltd.",
      "email": "hello@modernbusiness.com",
      "phone": "+43 664 1122334",
      "address": "Salzburger Straße 12",
      "zip": "5020",
      "city": "Salzburg",
      "country": "Austria",
      "vatId": "ATU99887766",
    },
    {
      "created": "29 Aug 2026",
      "name": "Smart Solutions",
      "email": "info@smartsolutions.at",
      "phone": "+43 676 5566778",
      "address": "Bahnhofstraße 30",
      "zip": "6020",
      "city": "Innsbruck",
      "country": "Austria",
      "vatId": "ATU33445566",
    },
  ];

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
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.035,
                      vertical: height * 0.008,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FB),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      "${clients.length} Clients",
                      style: TextStyle(
                        color: const Color(0xFF063C70),
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w600,
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
              child: ListView.builder(
                padding: EdgeInsets.only(
                  left: width * 0.04,
                  right: width * 0.04,

                  // Space for Add Client button
                  bottom: height * 0.12,
                ),

                physics: const BouncingScrollPhysics(),

                itemCount: clients.length,

                itemBuilder: (context, index) {

                  final client = clients[index];

                  return _clientCard(
                    context: context,
                    client: client,
                    width: width,
                    height: height,
                  );
                },
              ),
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
    required Map<String, dynamic> client,
    required double width,
    required double height,
  }) {

    return Container(
      margin: EdgeInsets.only(
        bottom: height * 0.015,
      ),

      padding: EdgeInsets.all(
        width * 0.045,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(
          width * 0.045,
        ),

        border: Border.all(
          color: const Color(0xFFE1E7EF),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ==========================================================
          // CLIENT HEADER
          // ==========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // Client Icon
              Container(
                width: width * 0.115,
                height: width * 0.115,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FB),

                  borderRadius: BorderRadius.circular(
                    width * 0.03,
                  ),
                ),

                child: Icon(
                  Icons.person_outline_rounded,
                  color: const Color(0xFF063C70),
                  size: width * 0.06,
                ),
              ),

              SizedBox(
                width: width * 0.035,
              ),

              // Name + Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      client["name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(
                      height: height * 0.005,
                    ),

                    Text(
                      client["email"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: const Color(0xFF60728D),
                        fontSize: width * 0.033,
                      ),
                    ),
                  ],
                ),
              ),

              // More button
              IconButton(
                onPressed: () {
                  _showClientOptions(
                    context,
                    client,
                  );
                },

                padding: EdgeInsets.zero,

                constraints: const BoxConstraints(),

                icon: Icon(
                  Icons.more_vert_rounded,
                  color: const Color(0xFF71829A),
                  size: width * 0.06,
                ),
              ),
            ],
          ),

          SizedBox(
            height: height * 0.018,
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE9EDF3),
          ),

          SizedBox(
            height: height * 0.015,
          ),

          // ==========================================================
          // CREATED
          // ==========================================================

          _clientInfoRow(
            width: width,
            icon: Icons.calendar_today_outlined,
            label: "Created",
            value: client["created"],
          ),

          SizedBox(
            height: height * 0.012,
          ),

          // ==========================================================
          // PHONE
          // ==========================================================

          _clientInfoRow(
            width: width,
            icon: Icons.phone_outlined,
            label: "Phone",
            value: client["phone"],
          ),

          SizedBox(
            height: height * 0.012,
          ),

          // ==========================================================
          // ADDRESS
          // ==========================================================

          _clientInfoRow(
            width: width,
            icon: Icons.location_on_outlined,
            label: "Address",
            value: client["address"],
          ),

          SizedBox(
            height: height * 0.012,
          ),

          // ==========================================================
          // ZIP + CITY
          // ==========================================================

          Row(
            children: [

              Expanded(
                child: _clientInfoRow(
                  width: width,
                  icon: Icons.markunread_mailbox_outlined,
                  label: "ZIP",
                  value: client["zip"],
                ),
              ),

              SizedBox(
                width: width * 0.04,
              ),

              Expanded(
                child: _clientInfoRow(
                  width: width,
                  icon: Icons.location_city_outlined,
                  label: "City",
                  value: client["city"],
                ),
              ),
            ],
          ),

          SizedBox(
            height: height * 0.012,
          ),

          // ==========================================================
          // COUNTRY + VAT ID
          // ==========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Expanded(
                child: _clientInfoRow(
                  width: width,
                  icon: Icons.public_outlined,
                  label: "Country",
                  value: client["country"],
                ),
              ),

              SizedBox(
                width: width * 0.04,
              ),

              Expanded(
                child: _clientInfoRow(
                  width: width,
                  icon: Icons.badge_outlined,
                  label: "VAT ID",
                  value: client["vatId"],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CLIENT INFORMATION ROW
  // ================================================================

  Widget _clientInfoRow({
    required double width,
    required IconData icon,
    required String label,
    required String value,
  }) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Icon(
          icon,
          color: const Color(0xFF71829A),
          size: width * 0.038,
        ),

        SizedBox(
          width: width * 0.018,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF71829A),
                  fontSize: width * 0.028,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(
                height: width * 0.005,
              ),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: const Color(0xFF172A46),
                  fontSize: width * 0.033,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // CLIENT OPTIONS
  // ================================================================

  void _showClientOptions(
      BuildContext context,
      Map<String, dynamic> client,
      ) {

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                ListTile(
                  leading: const Icon(
                    Icons.visibility_outlined,
                  ),

                  title: const Text(
                    "View Client",
                  ),

                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),

                  title: const Text(
                    "Edit Client",
                  ),

                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),

                  title: const Text(
                    "Delete Client",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}