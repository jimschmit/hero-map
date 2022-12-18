import 'package:fip_search/models/contact_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsService {
  late SupabaseClient _client;
  RxList<Contact> contacts$ = <Contact>[].obs;
  var loading$ = true.obs;

  ContactsService() {
    _client = Get.find();
  }
  void fetchContacts() async {
    loading$ = true.obs;
    var result =
        await _client.from('contacts').select<List<Map<String, dynamic>>>();

    contacts$
      ..clear()
      ..addAll(result.map((el) => Contact.fromJson(el)));
    loading$.value = false;
  }

  addContact(Contact contact) async {
    loading$.value = true;
    var result = await _client
        .from('contacts')
        .insert(contact.toJson())
        .select<Map<String, dynamic>>()
        .single();
    contacts$.add(Contact.fromJson(result));
    loading$.value = false;
  }
}
