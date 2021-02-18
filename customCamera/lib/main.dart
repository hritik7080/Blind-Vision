import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_tts_improved/flutter_tts_improved.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  File _image;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String url = "http://17c80528e79b.ngrok.io/file/upload/";
  bool loading = false;
  String _platformVersion = 'Unknown';
  FlutterTtsImproved tts = FlutterTtsImproved();

  upload(File file) async {
    if (file == null) return;

    setState(() {
      loading = true;
    });
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    var uri = Uri.parse(url);
    var length = await file.length();
    print(length);
    tts.speak("Uploading");
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        // replace file with your field name exampe: image
        http.MultipartFile('file', file.openRead(), length,
            filename: 'test.png'),
      );
    var respons = await http.Response.fromStream(await request.send());
    print(respons);
    setState(() {
      loading = false;
    });
    if (respons.statusCode == 201) {
      var decoded = json.decode(respons.body);
      print(decoded['result']);
      tts.speak(decoded['result']);
      // setState(() {
      //   message = ' Upload Success \n Detected: ' + decoded['result'];
      // });
      return;
    } else {
      tts.speak("Something is wrong");
    }
    // setState(() {
    //   message = ' image not upload';
    // });
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    print('VOICES: ${await tts.getVoices}');
    print('LANGUAGES: ${await tts.getLanguages}');

    tts.setProgressHandler((String words, int start, int end, String word) {
      setState(() {
        _platformVersion = word;
      });
      print('PROGRESS: $word => $start - $end');
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blind Vision')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(20),
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: 130,
        child: loading
            ? Padding(
                padding: EdgeInsets.only(top: 52),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : FlatButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await _controller.takePicture();

                    setState(() {
                      _image = File(image?.path);
                    });

                    upload(_image);

                    // If the picture was taken, display it on a new screen.

                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
                color: Colors.greenAccent[400],
                child: Text(
                  "CAPTURE",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Raleway',
                    fontSize: 22.0,
                  ),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
