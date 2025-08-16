import 'package:dinmajur_customer/configs/services/socket/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  void initState() {
    super.initState();

    // Delay connection until the widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketProvider = context.read<SocketProvider>();
      socketProvider.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket.IO Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Socket.IO Test')),
        body: Center(
          child: Consumer<SocketProvider>(
            builder: (context, socketProvider, _) {
              return Text(
                socketProvider.isConnected
                    ? "✅ Connected to WebSocket"
                    : "❌ Not Connected",
                style: const TextStyle(fontSize: 18),
              );
            },
          ),
        ),
      ),
    );
  }}