import 'dart:convert';

import 'package:chat_gpt/models/message_list_model.dart';
import 'package:chat_gpt/models/message_model.dart';
import 'package:chat_gpt/models/thread_list_model.dart';
import 'package:chat_gpt/models/thread_model.dart';
import 'package:chat_gpt/services/chat_gpt.dart';
import 'package:chat_gpt/widgets/message_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MessageListModel>(
          create: (context) => MessageListModel(
            messages: [],
          ),
        ),
        ChangeNotifierProvider<ThreadListModel>(
          create: (context) => ThreadListModel(
            threads: [],
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'ChatGPT'),
      ),
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
  void getThreads() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('threads');

    if (json != null) {
      List<dynamic> data = jsonDecode(json);

      var threads = data.map((e) => ThreadModel.fromJson(e)).toList();

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.read<ThreadListModel>().setThreads(threads);

        context.read<MessageListModel>().setMessages(
              MessageListModel.fromJson(
                jsonDecode(prefs.getString(threads[0].id) ?? ""),
                threads[0].id,
              ),
            );
      });
    }
  }

  @override
  void initState() {
    getThreads();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MessageListModel messages = context.watch<MessageListModel>();
    ThreadListModel threads = context.watch<ThreadListModel>();
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: threads.data.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemBuilder: (context, index) => ListTile(
                      tileColor: messages.id == threads.data[index].id
                          ? Colors.deepPurple[400]
                          : Colors.deepPurple[100],
                      textColor: messages.id == threads.data[index].id
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(
                        Icons.chat_bubble_outline,
                        color: messages.id == threads.data[index].id
                            ? Colors.white
                            : Colors.black54,
                      ),
                      title: Text(threads.data[index].title),
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        threads.data[index].id;
                        String? json = prefs.getString(threads.data[index].id);

                        messages.setMessages(MessageListModel.fromJson(
                          jsonDecode(json ?? ""),
                          threads.data[index].id,
                        ));

                        if (context.mounted) {
                          Scaffold.of(context).closeDrawer();
                        }
                      },
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[800],
                        ),
                        onPressed: () {
                          showConfirmDialog(context, threads.data[index]);
                        },
                      ),
                    ),
                  ),
                ),
                Builder(builder: (context) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        messages.setMessages(
                          MessageListModel(
                            messages: [],
                          ),
                        );

                        Scaffold.of(context).closeDrawer();
                      },
                      child: const Text('New Chat'),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: messages,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                enabled: !messages.isLoading(),
                hintText: 'Message',
                suffixIcon: IconButton(
                  onPressed: () {
                    messages.removeTypingMessage();

                    final message = MessageModel(
                      message: controller.text,
                      timestamp: DateTime.now(),
                      type: MessageType.sender,
                    );

                    controller.clear();
                    messages.addMessage(message, threads);

                    //add typing message
                    messages.addMessage(
                      MessageModel(
                        message: '',
                        timestamp: DateTime.now(),
                        type: MessageType.typing,
                      ),
                      threads,
                    );

                    chat(messages)
                        .whenComplete(() => setState(() {
                              messages.removeTypingMessage();
                            }))
                        .then((value) {
                      messages.addMessage(value, threads);
                    });
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showConfirmDialog(BuildContext context, ThreadModel thread) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Confirm"),
      onPressed: () {
        if (context.read<MessageListModel>().id == thread.id) {
          context.read<MessageListModel>().setMessages(
                MessageListModel(
                  messages: [],
                ),
              );
        }

        context.read<ThreadListModel>().removeThread(thread);

        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Message Confirmation"),
      content: const Text(
        "Would you like to continue delete this message?",
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
