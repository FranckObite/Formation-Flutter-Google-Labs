// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';

// TODO import Dialogflow
class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatMessage> _messages = <ChatMessage>[];

  bool _isRecording = false;

  final RecorderStream _recorder = RecorderStream();
  late StreamSubscription _recorderStatus;
  late StreamSubscription<List<int>> _audioStreamSubscription;
  late BehaviorSubject<List<int>> _audioStream;

  // TODO DialogflowGrpc class instance

  final TextEditingController _textController = TextEditingController();

  late DialogFlowtter dialogFlowtter;

  // TODO impletement message

  List<Map<String, dynamic>> messages = [];

  // TODO Implement sendMessages

  sendMessage(String text) async {
    if (text.isEmpty) {
      print("=========Message is Empty ===========");
    } else {
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
        _textController.clear();
      });
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));
      if (response.message == null) {
        return;
      } else {
        setState(() {
          addMessage(response.message!);
          //addMessage(Message(text: DialogText(text: [text])));
        });
      }
    }
  }

  //TODO IMMPLEMENT ADD MESSAGES

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({"Messages": message, "isUserMessage": isUserMessage});
  }

  @override
  void initState() {
    super.initState();
    initPlugin();
    _initDialogflow();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    _audioStreamSubscription.cancel();
    super.dispose();
  }

  //TODO init DialogFow

  Future<void> _initDialogflow() async {
    DialogAuthCredentials credentials =
        await DialogAuthCredentials.fromFile("assets/dialog_flow_auth.json");
    dialogFlowtter = DialogFlowtter(credentials: credentials);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
      }
    });

    await Future.wait([_recorder.initialize()]);

    // TODO Get a Service account
  }

  void stopStream() async {
    await _recorder.stop();
    await _audioStreamSubscription.cancel();
    await _audioStream.close();
  }

  void handleSubmitted(text) async {
    print("=======Message $text ===========");
    _textController.clear();

    //TODO Dialogflow Code
  }

  void handleStream() async {
    _recorder.start();

    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((data) {
      print("=======Data : $data ====");
      _audioStream.add(data);
    });

    // TODO Create SpeechContexts
    // Create an audio InputConfig

    // TODO Make the streamingDetectIntent call, with the InputConfig and the audioStream
    // TODO Get the transcript and detectedIntent and show on screen
  }

  // The chat interface
  //
  //------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(children: <Widget>[
      Flexible(
          child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: false,
              itemBuilder: (_, int index) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: messages[index]["isUserMessage"]
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: messages[index]["isUserMessage"]
                                ? Colors.deepPurple
                                : Colors.green.shade800,
                            borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(20),
                                topLeft: const Radius.circular(20),
                                bottomRight: Radius.circular(
                                  messages[index]["isUserMessage"] ? 0 : 20,
                                ),
                                topRight: Radius.circular(
                                  messages[index]["isUserMessage"] ? 20 : 0,
                                )),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: size.width * 2 / 3,
                          ),
                          child: Text(
                            messages[index]["Messages"].text.text[0],
                          ),
                        ),
                      ]),
                );
              },
              //_messages[index],
              itemCount: messages.length
              //_messages.length,
              )),
      const Divider(height: 1.0),
      Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: handleSubmitted,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Send a message"),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => sendMessage(_textController.text)
                        //handleSubmitted(_textController.text),
                        ),
                  ),
                  IconButton(
                    iconSize: 30.0,
                    icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
                    onPressed: _isRecording ? stopStream : handleStream,
                  ),
                ],
              ),
            ),
          )),
    ]);
  }
}

//------------------------------------------------------------------------------------
// The chat message balloon
//
//------------------------------------------------------------------------------------
class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {super.key, required this.text, required this.name, required this.type});

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: const CircleAvatar(child: Text('B')),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
            child: Text(
          name[0],
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
