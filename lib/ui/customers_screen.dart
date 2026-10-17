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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Obx(() {
          final bool searching = controller.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                controller.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching
                  ? Icons.close_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: rs.s(20),
            ),
          );
        }),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: controller.searchClients,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: rs.sp(16),
              ),
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                hintStyle: TextStyle(
                  color: colorsList.textHintColor,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Customers',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: rs.sp(20),
              fontWeight: FontWeight.normal,
            ),
          );
        }),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: controller.openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: rs.s(24),
              ),
            );
          }),
          SizedBox(width: rs.s(8)),
        ],
      ),
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Customers',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: rs.sp(17),
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs.s(14),
                          vertical: rs.s(6),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${controller.clients.length} Customers',
                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: rs.sp(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.filteredClients.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorsList.textColor,
                      ),
                    );
                  }

                  if (controller.filteredClients.isEmpty) {
                    return Center(
                      child: Text(
                        'No customers found.',
                        style: TextStyle(
                          fontSize: rs.sp(14),
                          color: colorsList.textHintColor,
                        ),
                      ),
                    );
                  }

                  final cols = rs.listColumns;
                  final clients = controller.filteredClients;

                  if (cols <= 1) {
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: rs.pagePaddingH,
                        right: rs.pagePaddingH,
                        bottom: rs.s(96),
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        return _clientCard(
                          context: context,
                          client: clients[index],
                          asGridTile: false,
                        );
                      },
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.only(
                      left: rs.pagePaddingH,
                      right: rs.pagePaddingH,
                      bottom: rs.s(96),
                    ),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: rs.s(12),
                      mainAxisSpacing: rs.s(12),
                      childAspectRatio: rs.isLandscape ? 2.4 : 2.1,
                    ),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      return _clientCard(
                        context: context,
                        client: clients[index],
                        asGridTile: true,
                      );
                    },
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _clientCard({
    required BuildContext context,
    required ClientScreenModel client,
    required bool asGridTile,
  }) {
    final rs = context.rs;

    final String name = client.name.trim().isNotEmpty
        ? client.name.trim()
        : 'Unnamed Customer';

    final String? email = client.email?.trim().isNotEmpty == true
        ? client.email!.trim()
        : null;

    final String? phone = client.phone?.trim().isNotEmpty == true
        ? client.phone!.trim()
        : null;

    final String city = client.city?.trim() ?? '';
    final String country = client.country?.trim() ?? '';

    final String location = [
      if (city.isNotEmpty) city,
      if (country.isNotEmpty) country,
    ].join(', ');

    final content = Padding(
      padding: EdgeInsets.symmetric(
        vertical: rs.s(13),
        horizontal: asGridTile ? rs.s(12) : rs.s(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rs.s(40),
            height: rs.s(40),
            decoration: const BoxDecoration(
              color: colorsList.colorBoxDecoration,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: colorsList.iconColor,
              size: rs.s(21),
            ),
          ),
          SizedBox(width: rs.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.textColor,
                    fontSize: rs.sp(asGridTile ? 16 : 18),
                    height: 1.2,
                  ),
                ),
                if (email != null || phone != null) ...[
                  SizedBox(height: rs.s(5)),
                  Row(
                    children: [
                      if (email != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: rs.s(14),
                                color: colorsList.iconColor,
                              ),
                              SizedBox(width: rs.s(5)),
                              Expanded(
                                child: Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorsList.textColor,
                                    fontSize: rs.sp(12.5),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (email != null && phone != null)
                        SizedBox(width: rs.s(12)),
                      if (phone != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: rs.s(14),
                                color: colorsList.iconColor,
                              ),
                              SizedBox(width: rs.s(5)),
                              Expanded(
                                child: Text(
                                  phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorsList.textColor,
                                    fontSize: rs.sp(12.5),
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
                  SizedBox(height: rs.s(4)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: rs.s(13),
                        color: colorsList.iconColor,
                      ),
                      SizedBox(width: rs.s(4)),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: rs.sp(12),
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
    );

    return Material(
      color: colorsList.colorWhite,
      borderRadius: asGridTile ? BorderRadius.circular(rs.s(12)) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(rs.s(12)),
        onTap: () {
          Get.toNamed(
            '/CustomerDetailsScreen',
            arguments: client,
          );
        },
        child: asGridTile
            ? DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(rs.s(12)),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: content,
              )
            : Column(
                children: [
                  content,
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: rs.s(52),
                    endIndent: rs.s(4),
                    color: colorsList.dividerColor,
                  ),
                ],
              ),
      ),
    );
  }
}
