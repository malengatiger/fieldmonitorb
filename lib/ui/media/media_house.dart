import 'dart:io';

import 'package:fieldmonitor3/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/api/storage_bloc.dart';
import 'package:monitorlibrary/data/position.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/project_position.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/snack.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Manage the process of creating media for the project
class MediaHouse extends StatefulWidget {
  final Project project;
  final ProjectPosition projectPosition;

  MediaHouse({@required this.project, @required this.projectPosition});

  @override
  _MediaHouseState createState() => _MediaHouseState();
}

class _MediaHouseState extends State<MediaHouse>
    with SingleTickerProviderStateMixin
    implements StorageBlocListener {
  AnimationController _controller;
  User user;
  String filePath;
  var _imageChannel = MethodChannel('com.boha.image.channel');
  var _videoChannel = MethodChannel('com.boha.video.channel');
  img.Image thumbnail;
  File imageFile;
  File videoFile;
  String imageFilePath;
  String videoFilePath;
  var isVideo = false;
  String label;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUser();
  }

  void _getUser() async {
    user = await Prefs.getUser();
    //todo - test apia
    await monitorBloc.getProjectPhotos(projectId: widget.project.projectId);
    await monitorBloc.getProjectVideos(projectId: widget.project.projectId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openImageCamera() async {
    print('_openImageCamera ......................');
    try {
      final result = await _imageChannel.invokeMethod('startImageCamera');
      pp('💜 💜 💜 💜  MediaHouse: Back from the BadLands: 💜 imageFilePath: 🍏 🍏 🍏 $result 🍏 🍏 🍏');
      setState(() {
        isUploading = true;
      });
      imageFile = File(result);
      var thumbnailFile = await getThumbnail(imageFile);
      setState(() {
        isUploading = true;
      });
      storageBloc.uploadPhotoOrVideo(
          listener: this,
          file: imageFile,
          thumbnailFile: thumbnailFile,
          project: widget.project,
          projectPosition: widget.projectPosition.position,
          isVideo: false);

      setState(() {});
    } on PlatformException catch (e) {
      pp("🌸 Failed to get or process image: ${e.message} ");
    }
  }

  void _openVideoCamera() async {
    pp('_openVideoCamera 🍏 🍏 🍏 ......................');

    try {
      final result = await _videoChannel.invokeMethod('startVideoCamera');
      pp('Back from the BadLands: 💜 💜 💜 💜 video filePath: 🍏 🍏 🍏 $result 🍏 🍏 🍏');
      videoFile = File(result);
      var len = await videoFile.length();
      pp('Back from the BadLands: 💜 💜 💜 💜 video file length: 🍏 🍏 🍏 $len bytes 🍏 🍏 🍏');
      setState(() {
        isUploading = true;
      });
      var thumbnailFile = await getVideoThumbnail(imageFile);
      storageBloc.uploadPhotoOrVideo(
          listener: this,
          file: videoFile,
          thumbnailFile: thumbnailFile,
          project: widget.project,
          projectPosition: widget.projectPosition.position,
          isVideo: true);
    } on PlatformException catch (e) {
      print("🌸 Failed to get or process video: ${e.message} ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaBag>>(
        stream: storageBloc.mediaStream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            mediaBags = snapshot.data;
            pp('🇿🇦 💙💙 💙💙 💙💙 mediaStream reporting something in stream ... mediaBags: ${mediaBags.length}');
          }
          return SafeArea(
            child: Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  widget.project.name,
                  style: Styles.whiteBoldSmall,
                ),
                bottom: PreferredSize(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        isUploading
                            ? Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '$bytesTransferred',
                                      style: Styles.blackTiny,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text('of'),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text('$totalByteCount',
                                        style: Styles.blackTiny),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text('downloaded', style: Styles.blackTiny),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(
                              label == null ? 'Photos' : '$label',
                              style: Styles.blackBoldSmall,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Switch(
                              onChanged: (bool value) {
                                pp('😡 😡 😡 switch changed to: 😡 isVideo = $value');
                                if (value) {
                                  label = 'Video';
                                } else {
                                  label = 'Photos';
                                }
                                setState(() {
                                  isVideo = value;
                                });
                              },
                              value: isVideo,
                            ),
                            SizedBox(
                              width: 80,
                            ),
                            RaisedButton(
                              color: isVideo ? Colors.pink : Colors.indigo,
                              elevation: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  isVideo ? 'Shoot Video' : 'Take Picture',
                                  style: Styles.whiteSmall,
                                ),
                              ),
                              onPressed: () {
                                if (isVideo) {
                                  _openVideoCamera();
                                } else {
                                  _openImageCamera();
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        )
                      ],
                    ),
                  ),
                  preferredSize: Size.fromHeight(140),
                ),
              ),
              backgroundColor:
                  filePath == null ? Colors.brown[100] : Colors.black,
              body: Stack(
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1),
                    itemCount: mediaBags.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = mediaBags.elementAt(index);
                      return Container(
                        height: 120,
                        width: 120,
                        child: item.isVideo
                            ? Image.asset(
                                'assets/video3.png',
                                width: 160,
                                height: 160,
                                fit: BoxFit.fill,
                              )
                            : Image.file(
                                item.thumbnailFile == null
                                    ? item.file
                                    : item.thumbnailFile,
                                fit: BoxFit.fill,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  List<MediaBag> mediaBags = [];

  Future<File> getThumbnail(File file) async {
    img.Image image = img.decodeImage(file.readAsBytesSync());
    var thumbnail = img.copyResize(image, width: 160);
    final Directory directory = await getApplicationDocumentsDirectory();
    final File mFile = File(
        '${directory.path}/thumbnail${DateTime.now().millisecondsSinceEpoch}.jpg');
    var thumb = mFile..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 100));
    var len = await thumb.length();
    pp('....... 💜  .... thumbnail generated: 😡 ${(len / 1024).toStringAsFixed(1)} KB');
    return thumb;
  }

  Future<File> getVideoThumbnail(File file) async {
    try {
      pp('....... 💜  ....getVideoThumbnail, check for spaces in name; path: ${file.path}');
      final path = await VideoThumbnail.thumbnailFile(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 160,
        // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 90,
      );
      var thumb = File(path);
      var len = await thumb.length();
      pp('....... 💜  .... video thumbnail generated: 😡 ${(len / 1024).toStringAsFixed(1)} KB - 🍏 🍏 🍏 path: $path');
      return thumb;
    } catch (e) {
      //get default image from assets as a file
      //read and write
      final filename = 'video3.png';
      var bytes = await rootBundle.load("assets/video3.png");
      String dir = (await getApplicationDocumentsDirectory()).path;
      writeToFile(bytes, '$dir/$filename');
      var thumb = File('$dir/$filename');
      var len = await thumb.length();
      pp('....... 💜  .... video thumbnail from assets: 😡 ${(len / 1024).toStringAsFixed(1)} KB - 🍏 🍏 🍏 ');
      return thumb;
    }
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  var isUploading = false;
  String totalByteCount, bytesTransferred;
  String fileUrl, thumbnailUrl;
  Position nearestPosition;

  @override
  onError(String message) {
    pp(message);
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _key,
        message: message == null ? 'Download failed' : '$message',
        actionLabel: '');
  }

  @override
  onFileProgress(int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 file Upload progress: bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    setState(() {
      this.totalByteCount = '${(totalByteCount / 1024).toStringAsFixed(1)} KB';
      this.bytesTransferred =
          '${(bytesTransferred / 1024).toStringAsFixed(1)} KB';
    });
  }

  @override
  onFileUploadComplete(String url, int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 😡 file Upload has been completed 😡 bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    pp('MediaHouse: 😡 😡 😡 this file url should be saved somewhere .... 😡😡 $url 😡😡');
    if (isVideo) {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  onThumbnailProgress(int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 thumbnail Upload progress: bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
  }

  @override
  onThumbnailUploadComplete(
      String url, int totalByteCount, int bytesTransferred) async {
    pp('MediaHouse: 🍏 🍏 🍏 😡 thumbnail Upload has been completed 😡 bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    setState(() {
      isUploading = false;
    });
  }

  var _key = GlobalKey<ScaffoldState>();
}
