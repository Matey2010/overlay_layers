import 'package:flutter/material.dart';
import 'package:overlay_layers/overlay_layers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overlay Layers Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplesPage(),
    );
  }
}

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Overlay Layers Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'POPUPS',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('Multiple popups can be displayed simultaneously'),
          const SizedBox(height: 16),
          _buildExampleButton(
            context,
            '1. Simple Popup',
            'Basic popup with centered content',
            () => _showExample1(context),
          ),
          _buildExampleButton(
            context,
            '2. Popup with Data',
            'Popup with type-safe data and updates',
            () => _showExample2(context),
          ),
          _buildExampleButton(
            context,
            '3. Multiple Popups',
            'Open multiple popups at once',
            () => _showExample3(context),
          ),
          const SizedBox(height: 32),
          const Text(
            'MODALS',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Only one modal at a time (interchangeable)',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          _buildExampleButton(
            context,
            '4. Simple Modal',
            'Basic modal with centered content',
            () => _showExample4(context),
          ),
          _buildExampleButton(
            context,
            '5. Slide-Up Modal',
            'Modal that slides up from bottom',
            () => _showExample5(context),
          ),
          _buildExampleButton(
            context,
            '6. Interchangeable Modals',
            'Opening new modal closes previous',
            () => _showExample6(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleButton(
    BuildContext context,
    String title,
    String description,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  // Example 1: Simple Popup
  void _showExample1(BuildContext context) {
    PopupController.of(context).open(
      builder: (context) => PopupScaffold(
        onBackdropTap: () => PopupDataContext.of(context).close(),
        child: AnimatedPopup(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Simple Popup',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('This is a basic popup example'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => PopupDataContext.of(context).close(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Example 2: Popup with Data
  void _showExample2(BuildContext context) {
    PopupController.of(context).open<Map<String, dynamic>>(
      builder: (context) {
        final popup = PopupDataContext.of<Map<String, dynamic>>(context);
        return PopupScaffold(
          onBackdropTap: () => popup.close(),
          child: AnimatedPopup(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Data Counter',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Count: ${popup.data['count']}',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => popup.updatePopupData({
                          'count': (popup.data['count'] as int) + 1,
                        }),
                        child: const Text('Increment'),
                      ),
                      ElevatedButton(
                        onPressed: () => popup.close(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      options: OverlayCreateOptions(
        initialData: {'count': 0} as Map<String, dynamic>,
      ),
    );
  }

  // Example 3: Multiple Popups
  void _showExample3(BuildContext context) {
    final controller = PopupController.of(context);

    // Open first popup
    controller.open(
      builder: (context) => PopupScaffold(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100),
        onBackdropTap: () => PopupDataContext.of(context).close(),
        child: AnimatedPopup(
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'First Popup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => PopupDataContext.of(context).close(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Open second popup
    Future.delayed(const Duration(milliseconds: 200), () {
      controller.open(
        builder: (context) => PopupScaffold(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 100),
          onBackdropTap: () => PopupDataContext.of(context).close(),
          child: AnimatedPopup(
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Second Popup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Both popups visible!'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => PopupDataContext.of(context).close(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Example 4: Simple Modal
  void _showExample4(BuildContext context) {
    ModalController.of(context).open(
      builder: (context) => ModalScaffold(
        onBackdropTap: () => ModalDataContext.of(context).close(),
        child: AnimatedModal(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 72),
                const SizedBox(height: 20),
                const Text(
                  'Simple Modal',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This is a basic modal example.\nOnly one modal can be displayed at a time.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ModalDataContext.of(context).close(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Example 5: Slide-Up Modal
  void _showExample5(BuildContext context) {
    ModalController.of(context).open(
      builder: (context) => ModalScaffold(
        alignment: Alignment.bottomCenter,
        onBackdropTap: () => ModalDataContext.of(context).close(),
        child: SlideUpModal(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Slide-Up Modal',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This modal slides up from the bottom like a bottom sheet',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ModalDataContext.of(context).close(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Example 6: Interchangeable Modals
  void _showExample6(BuildContext context) {
    _openModalWithColor(context, 'First Modal', Colors.red.shade100, 1);
  }

  void _openModalWithColor(
    BuildContext context,
    String title,
    Color color,
    int number,
  ) {
    ModalController.of(context).open(
      builder: (context) => ModalScaffold(
        onBackdropTap: () => ModalDataContext.of(context).close(),
        child: AnimatedModal(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Opening a new modal automatically closes this one',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (number < 3)
                  ElevatedButton(
                    onPressed: () => _openModalWithColor(
                      context,
                      'Modal ${number + 1}',
                      number == 1
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      number + 1,
                    ),
                    child: Text('Open Modal ${number + 1}'),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ModalDataContext.of(context).close(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
