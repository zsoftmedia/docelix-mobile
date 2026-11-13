import 'package:docelix_mobileapp/controllers/clients_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final ClientsController controller = Get.put(ClientsController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // 1. TOP HEADER BAR (BACK BUTTON & TITLE)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2ECF8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF063C70),
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Customers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0A2342),
                          fontSize: rs.sp(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance back button
                  ],
                ),
              ),

              SizedBox(height: rs.s(8)),

              // ======================================================
              // 2. TITLE & SUBTITLE SECTION WITH COUNT BADGE
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customers',
                            style: TextStyle(
                              color: const Color(0xFF0A2342),
                              fontSize: rs.sp(22),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: rs.s(2)),
                          Text(
                            'Manage, track, and organize your customer profiles.',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: rs.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs.s(12),
                          vertical: rs.s(6),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          '${controller.clients.length} Total',
                          style: TextStyle(
                            color: const Color(0xFF2563EB),
                            fontSize: rs.sp(11),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 3. SEARCH BAR
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44),
                  padding: EdgeInsets.symmetric(horizontal: rs.s(14)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: colorsList.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      SizedBox(width: rs.s(10)),
                      Expanded(
                        child: TextField(
                          onChanged: controller.searchClients,
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(13),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search customer name, email, phone...',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () => controller.closeSearch(),
                          );
                        }
                        return const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 4. CUSTOMER LIST / GRID
              // ======================================================
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.filteredClients.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.filteredClients.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshClients,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: rs.s(120)),
                          Center(
                            child: Text(
                              controller.searchQuery.value.isNotEmpty
                                  ? 'No matching customers found.'
                                  : 'No customers available.',
                              style: TextStyle(
                                color: colorsList.textHintColor,
                                fontSize: rs.sp(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final cols = rs.listColumns;
                  final clients = controller.filteredClients;

                  if (cols <= 1) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshClients,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          top: rs.s(4),
                          left: rs.pagePaddingH,
                          right: rs.pagePaddingH,
                          bottom: rs.s(96),
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(
                            context: context,
                            client: clients[index],
                            asGridTile: false,
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshClients,
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        left: rs.pagePaddingH,
                        right: rs.pagePaddingH,
                        bottom: rs.s(96),
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: rs.s(12),
                        mainAxisSpacing: rs.s(12),
                        childAspectRatio: rs.isTablet
                            ? (rs.isLandscape ? 1.65 : 1.25)
                            : (rs.isLandscape ? 2.6 : 1.8),
                      ),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        return _buildCustomerCard(
                          context: context,
                          client: clients[index],
                          asGridTile: true,
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(
            '/AddCustomersScreen',
            arguments: 'Add Customers Screen',
          );

          if (result == true) {
            controller.refreshClients();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.person_add_alt_1_rounded,
        ),
        label: Text(
          'Add Customer',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCustomerActions(BuildContext context, ClientScreenModel client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        client.name.isNotEmpty ? client.name : 'Customer #${client.id}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: const Icon(Icons.visibility_outlined, color: Color(0xFF2563EB)),
                  title: const Text('View Customer Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/CustomerDetailsScreen', arguments: client);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PROFESSIONAL CUSTOMER CARD WIDGET
  // ================================================================

  Widget _buildCustomerCard({
    required BuildContext context,
    required ClientScreenModel client,
    required bool asGridTile,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final String name = client.name.trim().isNotEmpty
        ? client.name.trim()
        : 'Unnamed Customer';

    final String? contactPerson = client.contactName?.trim().isNotEmpty == true
        ? client.contactName!.trim()
        : null;

    final String? email = client.email?.trim().isNotEmpty == true
        ? client.email!.trim()
        : null;

    final String? phone = client.phone?.trim().isNotEmpty == true
        ? client.phone!.trim()
        : null;

    final String city = client.city?.trim() ?? '';
    final String country = client.country?.trim() ?? '';

    final String location = [
      if (client.addressLine1?.isNotEmpty == true) client.addressLine1!,
      if (city.isNotEmpty) city,
      if (country.isNotEmpty) country,
    ].join(', ');

    // Initials for Avatar
    final nameParts = name.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'C');

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.toNamed(
              '/CustomerDetailsScreen',
              arguments: client,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TOP HEADER ROW (AVATAR + NAME + CONTACT PERSON + MORE MENU)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isTab ? 42 : 44,
                      height: isTab ? 42 : 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: isTab ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTab ? 15 : rs.sp(16),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A2342),
                            ),
                          ),
                          if (contactPerson != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              contactPerson,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isTab ? 12 : rs.sp(12),
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showCustomerActions(context, client),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 12),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 2. MIDDLE CONTACT DETAILS
                if (email != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTab ? 12.5 : rs.sp(12.5),
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (phone != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTab ? 12.5 : rs.sp(12.5),
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (location.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTab ? 12.5 : rs.sp(12.5),
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}