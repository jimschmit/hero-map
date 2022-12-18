import 'package:fip_search/models/contact_model.dart';
import 'package:fip_search/services/contacts_service.dart';
import 'package:fip_search/tabs/contacts_tab/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  List<bool>? expanded;
  ContactsService service = Get.find<ContactsService>();

  @override
  void initState() {
    super.initState();
    service.fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showDialog,
            child: const Icon(Icons.add),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              if (service.loading$.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              expanded ??=
                  service.contacts$.asMap().keys.map((e) => false).toList();
              var contacts = service.contacts$;
              return SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: (panelIndex, isExpanded) => setState(() {
                    expanded![panelIndex] = !isExpanded;
                  }),
                  children: contacts.asMap().keys.map(
                    (i) {
                      var contact = contacts[i];
                      return ExpansionPanel(
                          isExpanded: expanded![i],
                          headerBuilder: (c, _) => Text(contact.name!),
                          body: Table(
                            border: const TableBorder(
                                horizontalInside:
                                    BorderSide(color: Colors.black)),
                            children: [
                              if (contact.phoneNumber != null)
                                TableRow(
                                  children: [
                                    const Text('Kontaktnummer'),
                                    Text(contact.name!)
                                  ],
                                ),
                              if (contact.email != null)
                                TableRow(children: [
                                  const Text('Email'),
                                  Text(contact.email!)
                                ]),
                              if (contact.additionalInfo != null)
                                TableRow(children: [
                                  const Text('Zusätzliche Informationen'),
                                  Text(contact.additionalInfo!)
                                ]),
                            ],
                          ));
                    },
                  ).toList(),
                ),
              );
            })),
      ],
    );
  }

  _showDialog({Contact? contact}) {
    showDialog(
        context: context,
        builder: (c) {
          TextEditingController nameController =
              TextEditingController(text: contact?.name);
          TextEditingController emailController =
              TextEditingController(text: contact?.email);
          TextEditingController phoneController =
              TextEditingController(text: contact?.phoneNumber);
          TextEditingController infoController =
              TextEditingController(text: contact?.additionalInfo);
          LatLng? location;

          return SimpleDialog(
            title: Text(
                contact != null ? 'Kontakt bearbeiten' : 'Kontakt hinzufügen'),
            contentPadding: const EdgeInsets.all(6),
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Telefonnummer'),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: infoController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Zusätzliche Informationen'),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                        height: 150,
                        width: 400,
                        child: LocationPicker(
                          onLocationUpdate: (el) => location = el,
                        )),
                    TextButton(
                        onPressed: () {
                          if (nameController.text.isEmpty || location == null) {
                            return;
                          }
                          Get.find<ContactsService>().addContact(Contact(
                            name: nameController.text,
                            email: emailController.text.isEmpty
                                ? null
                                : emailController.text,
                            phoneNumber: phoneController.text.isEmpty
                                ? null
                                : phoneController.text,
                            additionalInfo: infoController.text.isEmpty
                                ? null
                                : infoController.text,
                            lat: location!.latitude,
                            lng: location!.longitude,
                          ));
                          setState(() {
                            expanded!.add(false);
                          });
                          Navigator.pop(c);
                        },
                        child: const Text('Hinzufügen'))
                  ],
                ),
              )
            ],
          );
        });
  }
}
