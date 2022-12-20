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
              return SingleChildScrollView(
                child: Obx(
                  () {
                    var contacts = service.contacts$;
                    return ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) =>
                          setState(() {
                        expanded![panelIndex] = !isExpanded;
                      }),
                      children: contacts.asMap().keys.map(
                        (i) {
                          var contact = contacts[i];
                          return ExpansionPanel(
                              isExpanded: expanded![i],
                              headerBuilder: (c, _) => Text(contact.name!),
                              body: Column(
                                children: [
                                  Row(
                                    children: [
                                      ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.red
                                                          .withOpacity(0.8))),
                                          onPressed: () async {
                                            var remove =
                                                await _showConfirmDialog();
                                            if (remove) {
                                              service.removeContact(contact);
                                            }
                                          },
                                          child: const Text('Löschen')),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            _showDialog(contact: contact);
                                          },
                                          child: const Text('Bearbeiten')),
                                    ],
                                  ),
                                  Table(
                                    border: const TableBorder(
                                        horizontalInside:
                                            BorderSide(color: Colors.black)),
                                    children: [
                                      if (contact.phoneNumber != null)
                                        TableRow(
                                          children: [
                                            const Text('Kontaktnummer'),
                                            Text(contact.phoneNumber!)
                                          ],
                                        ),
                                      if (contact.email != null)
                                        TableRow(children: [
                                          const Text('Email'),
                                          Text(contact.email!)
                                        ]),
                                      if (contact.additionalInfo != null)
                                        TableRow(children: [
                                          const Text(
                                              'Zusätzliche Informationen'),
                                          Text(contact.additionalInfo!)
                                        ]),
                                    ],
                                  ),
                                ],
                              ));
                        },
                      ).toList(),
                    );
                  },
                ),
              );
            })),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showDialog,
            child: const Icon(Icons.add),
          ),
        ),
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
                          var editMode = contact != null;
                          if (nameController.text.isEmpty ||
                              (location == null && !editMode)) {
                            return;
                          }
                          var lat = editMode
                              ? location?.latitude ?? contact.lat
                              : location!.latitude;
                          var lng = editMode
                              ? location?.longitude ?? contact.lng
                              : location!.longitude;
                          var tempContact = Contact(
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
                              lat: lat,
                              lng: lng);
                          var service = Get.find<ContactsService>();
                          if (contact == null) {
                            service.addContact(tempContact);
                            setState(() {
                              expanded!.add(false);
                            });
                          } else {
                            tempContact.id = contact.id;
                            service.updateContact(tempContact);
                          }
                          Navigator.pop(c);
                        },
                        child: Text(
                            contact == null ? 'Hinzufügen' : 'Aktualisieren'))
                  ],
                ),
              )
            ],
          );
        });
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Bitte bestätigen'),
            content: const Text('Diesen Kontakt wirlich löschen??'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Ja')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Nein'))
            ],
          );
        });
  }
}
