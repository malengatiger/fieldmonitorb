import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:monitorlibrary/api/data_api.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/api/storage_api.dart';
import 'package:monitorlibrary/data/photo.dart';
import 'package:monitorlibrary/data/position.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/location/loc_bloc.dart';
import 'package:path_provider/path_provider.dart';

class MediaHouse extends StatefulWidget {
  final Project project;
  final Position projectPosition;

  MediaHouse({@required this.project, @required this.projectPosition});

  @override
  _MediaHouseState createState() => _MediaHouseState();
}

class _MediaHouseState extends State<MediaHouse>
    with SingleTickerProviderStateMixin
    implements StorageUploadListener {
  AnimationController _controller;
  User user;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUser();
  }

  void _getUser() async {
    user = await Prefs.getUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String filePath;
  var _imageChannel = MethodChannel('com.boha.image.channel');
  var _videoChannel = MethodChannel('com.boha.video.channel');
  img.Image thumbnail;
  void _openImageCamera() async {
    print('_openImageCamera ......................');
    try {
      final result = await _imageChannel.invokeMethod('startImageCamera');
      pp('💜 MediaHouse: Back from the BadLands: 💜 imageFilePath: 🍏 🍏 🍏 $result 🍏 🍏 🍏');
      setState(() {
        isUploading = true;
      });
      pp('....... 💜 This file should be uploaded to cloud storage somewhere .... 😡 starting upload...');
      imageFile = File(result);

      var l = await imageFile.length();
      pp('....... 💜  .... imageFile: 😡 ${(l / 1024).toStringAsFixed(1)} KB');
// Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
      img.Image image = img.decodeImage(File(result).readAsBytesSync());
      // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
      thumbnail = img.copyResize(image, width: 160);
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File(
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      var thumb = file
        ..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 100));
      var len = await thumb.length();
      pp('....... 💜  .... thumb: 😡 ${(len / 1024).toStringAsFixed(1)} KB');
      thumbnails.add(thumb);
      fileUrl = null;
      thumbnailUrl = null;
      StorageAPI.uploadPhoto(
          listener: this,
          file: imageFile,
          isVideo: false,
          projectId: widget.project.projectId);
      setState(() {});
    } on PlatformException catch (e) {
      print("🌸 Failed to get image: ${e.message} ");
    }
  }

  void _openVideoCamera() async {
    print('_openVideoCamera ......................');
    try {
      final result = await _videoChannel.invokeMethod('startVideoCamera');
      print(
          'Back from the BadLands: 💜 video filePath: 🍏 🍏 🍏 $result 🍏 🍏 🍏');

      setState(() {
        videoFilePath = result;
      });
    } on PlatformException catch (e) {
      print("🌸 Failed to get video: ${e.message} ");
    }
  }

  File imageFile;
  File videoFile;

  String imageFilePath;
  String videoFilePath;
  var isVideo = false;

  String label;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.project.name,
            style: Styles.whiteSmall,
          ),
          bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
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
                          pp('😡 😡 😡 switch changed to: $value');
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
                        elevation: 4,
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
            preferredSize: Size.fromHeight(100),
          ),
        ),
        backgroundColor: filePath == null ? Colors.brown[100] : Colors.black,
        body: isVideo
            ? Container(
                child: Center(
                  child: Text('Video to play soon!'),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(4.0),
                child: _getImageCard(),
              ),
      ),
    );
  }

  Widget _getImageCard() {
    if (thumbnails.isEmpty) {
      return Container(
        child: Center(
          child: Text('Images not made yet'),
        ),
      );
    } else {
      pp('🌈 🌈 There is a valid file which does not show up well .......');
      return Stack(
        children: [
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 1, crossAxisSpacing: 1),
            itemCount: thumbnails.length,
            itemBuilder: (BuildContext context, int index) {
              var item = thumbnails.elementAt(index);
              return Container(
                height: 120,
                width: 120,
                child: Image.file(
                  item,
                  fit: BoxFit.fill,
                ),
              );
            },
          ),
          isUploading
              ? Positioned(
                  left: 20,
                  bottom: 20,
                  child: Container(
                    width: 300,
                    height: 100,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text('Uploading ...', style: Styles.blackBoldSmall),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${(bytesTransferred / 1024).toStringAsFixed(1)} KB',
                                  style: Styles.tealBoldSmall,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text('of'),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                    '${(totalByteCount / 1024).toStringAsFixed(1)} KB',
                                    style: Styles.pinkBoldSmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      );
    }
  }

  List<File> thumbnails = [];
  var isUploading = false;
  int totalByteCount = 0, bytesTransferred = 0;
  String fileUrl, thumbnailUrl;
  Position nearestPosition;

  @override
  onError(String message) {
    pp(message);
  }

  @override
  onFileProgress(int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 file Upload progress: bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    setState(() {
      this.totalByteCount = totalByteCount;
      this.bytesTransferred = bytesTransferred;
    });
  }

  @override
  onFileUploadComplete(String url, int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 😡 file Upload has been completed 😡 bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    pp('MediaHouse: 😡 😡 😡 this file url should be saved somewhere .... 😡😡 $url 😡😡');

    setState(() {
      fileUrl = url;
      this.totalByteCount = totalByteCount;
      this.bytesTransferred = bytesTransferred;
      //isUploading = false;
    });
  }

  @override
  onThumbnailProgress(int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 thumbnail Upload progress: bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    setState(() {
      this.totalByteCount = totalByteCount;
      this.bytesTransferred = bytesTransferred;
    });
  }

  @override
  onThumbnailUploadComplete(
      String url, int totalByteCount, int bytesTransferred) {
    pp('MediaHouse: 🍏 🍏 🍏 😡 thumbnail Upload has been completed 😡 bytesTransferred: ${(bytesTransferred / 1024).toStringAsFixed(1)} KB '
        'of totalByteCount: ${(totalByteCount / 1024).toStringAsFixed(1)} KB');
    pp('MediaHouse: 😡 😡 😡 this thumbnail url should be saved somewhere .... 😡😡 $url 😡😡');
    setState(() {
      thumbnailUrl = url;
      this.totalByteCount = totalByteCount;
      this.bytesTransferred = bytesTransferred;
      isUploading = false;
    });
    //
    _writePhoto();
  }

  void _writePhoto() async {
    pp('🎽 🎽 🎽 🎽 MediaHouse: _writePhoto : 🎽 🎽 adding photo .....');
    var distance = await locationBloc.getDistanceFromCurrentPosition(
        latitude: widget.projectPosition.coordinates[1],
        longitude: widget.projectPosition.coordinates[0]);

    pp('🎽 🎽 🎽 🎽 MediaHouse: _writePhoto : 🎽 🎽 adding photo ..... 😡😡 distance: $distance 😡😡');
    var photo = Photo(
        url: fileUrl,
        caption: 'tbd',
        created: DateTime.now().toIso8601String(),
        userId: user.userId,
        userName: user.name,
        projectPosition: widget.projectPosition,
        distanceFromProjectPosition: distance,
        projectId: widget.project.projectId,
        thumbnailUrl: thumbnailUrl,
        projectName: widget.project.name);

    var result = await DataAPI.addPhoto(photo);
    pp('🎽 🎽 🎽 🎽 🎁 🎁 Photo has been added to database: 🎁 $result');
  }
}
