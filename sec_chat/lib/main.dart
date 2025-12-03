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
    soc_server.serverConnect();
    messageListen();
  }

  @override
  void dispose() {
    soc_server.socket.dispose();
    super.dispose();
  }

  void messageListen() {
    soc_server.socket.on('chat', (data) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200,

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(
          'Sec Chat',
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          BottomAppBar(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),

                //contentPadding: EdgeInsets.all(8),
                labelText: 'Type a message',
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              reverse: true,
              controller: _scrollCon,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: SelectableText(messages[index]));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final message = _textController.text;
          if (message.isNotEmpty) {
            soc_server.msgSend(message);
            _messageTake(message);
          }
        },
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );
  }
}
