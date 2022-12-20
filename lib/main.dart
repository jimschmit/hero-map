import 'package:fip_search/services/contacts_service.dart';
import 'package:fip_search/tabs/contacts_tab/contacts_tab.dart';
import 'package:fip_search/tabs/map_tab/map_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var supabase = await Supabase.initialize(
    url: 'https://cucjvynjzwtpfuprwrfm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1Y2p2eW5qend0cGZ1cHJ3cmZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzEzNTAyNzksImV4cCI6MTk4NjkyNjI3OX0.fEssyaAn2WbsKewMXiRd-c71vaAUMWjZki-qh2O9_S8',
  );
  Get.put(supabase.client);
  Get.put(ContactsService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HERO Suche',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  Column(
                    children: const [
                      Text('Nutzung auf eigene Verantwortung'),
                      Text(
                        'Bitte keine genauen Daten angeben, die Daten sind öffentlich',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      launchUrl(
                          Uri.parse('https://github.com/jimschmit/hero-map'));
                    },
                    child: SvgPicture.asset('assets/images/github.svg'),
                  )
                ],
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.map)),
                  Tab(icon: Icon(Icons.contact_page)),
                ],
              ),
            ),
            body: const TabBarView(
              children: [MapsTab(), ContactsTab()],
            ),
          ),
        ));
  }
}
