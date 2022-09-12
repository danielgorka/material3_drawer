import 'package:flutter/material.dart';
import 'package:material3_drawer/material3_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material 3 Drawer Example',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            collapsible: true,
            headerBuilder: (context, animation) {
              return FadeTransition(
                opacity: animation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                  child: Text(
                    'Header',
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                  ),
                ),
              );
            },
            selectedIndex: _index,
            items: [
              NavigationDrawerItem(
                icon: const Icon(Icons.looks_one),
                label: 'Item 1',
              ),
              NavigationDrawerItem(
                icon: const Icon(Icons.looks_two),
                label: 'Item 2',
              ),
              NavigationDrawerItem(
                icon: const Icon(Icons.looks_3),
                label: 'Item 3',
                indicator: '2',
              ),
            ],
            onItemTap: (index) {
              setState(() {
                _index = index;
              });
            },
          ),
          Expanded(
            child: Center(
              child: Text('Item: ${_index + 1}'),
            ),
          ),
        ],
      ),
    );
  }
}
