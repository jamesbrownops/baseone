import 'package:flutter/material.dart';

void main() {
  runApp(const BaseOneApp());
}

class BaseOneApp extends StatelessWidget {
  const BaseOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaseOne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const BaseOneShell(),
    );
  }
}

class BaseOneShell extends StatefulWidget {
  const BaseOneShell({super.key});

  @override
  State<BaseOneShell> createState() => _BaseOneShellState();
}

class _BaseOneShellState extends State<BaseOneShell> {
  int _currentIndex = 0;

  // Screens
  final List<Widget> _pages = const [
    HomePage(),
    NotesPage(),
    CalendarPage(),
    SettingsPage(),
  ];

  // Titles for AppBar
  static const List<String> _titles = [
    'BaseOne Home',
    'Notes',
    'Calendar',
    'Settings',
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _onFabPressed() {
    // Simple placeholder actions per tab.
    final String message = switch (_currentIndex) {
      0 => 'Home action (placeholder)',
      1 => 'Create a new note (placeholder)',
      2 => 'Create a new event (placeholder)',
      3 => 'Settings action (placeholder)',
      _ => 'Action',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// -------------------- PAGES --------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'BaseOne is alive.',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          Text(
            'Notes (placeholder)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _CardLine(title: 'Quick Note', subtitle: 'Tap + to create a note later.'),
          _CardLine(title: 'Ideas', subtitle: 'We’ll wire storage next.'),
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          Text(
            'Calendar (placeholder)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _CardLine(title: 'No events yet', subtitle: 'Tap + to add an event later.'),
          _CardLine(title: 'Next step', subtitle: 'We’ll add a real event model + list.'),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Settings (placeholder)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        _CardLine(title: 'Security', subtitle: 'Biometric / PIN later.'),
        _CardLine(title: 'Integrations', subtitle: 'Calendar/Contacts later.'),
        _CardLine(title: 'About', subtitle: 'BaseOne shell running clean.'),
      ],
    );
  }
}

// -------------------- SMALL WIDGETS --------------------

class _CardLine extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CardLine({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}