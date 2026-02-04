import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class MediaPlayerResourceSelectionPage extends StatefulWidget {
  const MediaPlayerResourceSelectionPage({super.key});

  @override
  _MediaPlayerResourceSelectionPageState createState() =>
      _MediaPlayerResourceSelectionPageState();
}

class _MediaPlayerResourceSelectionPageState
    extends State<MediaPlayerResourceSelectionPage> {
  final _netResource = {
    "sample_bgm.mp3":
        "https://serv10.mrmazika.com/dl/waw/wael-gassar/albums/tw3edny-leh/10.Ghariba_El_Nas.mp3", //"https://storage.zego.im/demo/sample_astrix.mp3",
    "sample_network.mp4": "https://storage.zego.im/demo/201808270915.mp4"
  };
  var _localResource = <String, String>{};
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var pre = kIsWeb ? './assets/' : 'assert://';
    _localResource = {
      "sample.mp3": "assets/icons/aaaa.mp3",
      "test.wav": "${pre}resources/audio/test2.wav",
      "ad.mp4": "${pre}resources/video/ad2.mp4",
      "complex_lr.mp4": "${pre}resources/video/complex_lr.mp4",
    };
    if (!kIsWeb) {
      _writeAssertToLocal();
    }
  }

  Widget resourceListWidget(BuildContext context, Map map) {
    return SizedBox(
        height: map.length * 45.0,
        child: ListView.separated(
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              String text = map.keys.toList()[index];
              return SizedBox(
                  height: 40,
                  child: TextButton(
                      child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          child: AutoSizeText(text)),
                      onPressed: () {
                        // ZegoLog().addLog("${map[text]}");
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return SizedBox();
                          //  MediaPlayerPage(
                          //   url: map[text],
                          //   layoutType: _localResourceType[text] ??
                          //       ZegoAlphaLayoutType.None,
                          //   isVideo: text.contains("mp4"),
                          // );
                        }));
                      }));
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 4,
              );
            },
            itemCount: map.length));
  }

  Widget titleWidget(BuildContext context, String title) {
    return ListTile(
        tileColor: Colors.grey[300],
        title: AutoSizeText(
          title,
          style: TextStyle(color: Colors.grey[600]),
        ));
  }

  Widget urlInputWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          children: [
            const Padding(
                padding: EdgeInsets.only(right: 20),
                child: AutoSizeText('URL')),
            Expanded(
                child: TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            )),
            TextButton(onPressed: () {}, child: const AutoSizeText("ENTER"))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    var appWidget = kIsWeb ? [] : [urlInputWidget()];
    return Scaffold(
        appBar: AppBar(
          title: const AutoSizeText('Select Resource'),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
          children: [
            titleWidget(context, "net resource"),
            resourceListWidget(context, _netResource),
            titleWidget(context, "loacl resource"),
            resourceListWidget(context, _localResource),
            ...appWidget
          ],
        ))));
  }

  void _writeAssertToLocal() async {
    var path = await getApplicationDocumentsDirectory();

    var lacalFilePath = '${path.path}/';

    for (var key in _localResource.keys) {
      var img = File(lacalFilePath + key);
      if (!img.existsSync()) {
        var data = await rootBundle
            .load('resources/${key.contains('mp4') ? 'video' : 'audio'}/$key');
        img = await img.writeAsBytes(data.buffer.asUint8List());
      }
      _localResource[key] = img.path;
    }
    setState(() {});
  }
}
