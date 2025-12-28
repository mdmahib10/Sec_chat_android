import 'package:flutter/material.dart';
import 'socket_io_service.dart' as soc_server;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sec Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Sec Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> messages = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _serverIpController =
      TextEditingController(text: "localhost");
  final ScrollController _scrollCon = ScrollController();

  void _messageTake(String message) {
    setState(() {
      messages.add(message);

      _textController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollCon.animateTo(
          _scrollCon.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _connectToServer() {
    final serverIp = _serverIpController.text;
    if (serverIp.isNotEmpty) {
      soc_server.serverConnect(serverIp);
      messageListen();
    }
  }

  @override
  void dispose() {
    soc_server.socket?.dispose();
    _textController.dispose();
    _serverIpController.dispose();
    _scrollCon.dispose();
    super.dispose();
  }

  void messageListen() {
    soc_server.socket?.on('chat', (data) {
      if (mounted) {
        setState(() {
          messages.add(data);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollCon.animateTo(
              _scrollCon.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serverIpController,
                    decoration: const InputDecoration(
                      labelText: 'Server IP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _connectToServer,
                  child: const Text('Connect'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _scrollCon,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(title: SelectableText(messages[index]));
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (message) {
                      if (message.isNotEmpty) {
                        soc_server.msgSend(message);
                        _messageTake(message);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _textController.text;
                    if (message.isNotEmpty) {
                      soc_server.msgSend(message);
                      _messageTake(message);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
