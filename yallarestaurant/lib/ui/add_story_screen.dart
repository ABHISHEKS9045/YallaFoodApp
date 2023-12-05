import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/story_model.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/video_widget.dart';
import 'package:image_picker/image_picker.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({Key? key}) : super(key: key);

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  List<dynamic> _mediaFiles = [];
  dynamic thumbnailFile;

  @override
  void initState() {
    getStory();
    super.initState();
  }

  num? videoDuration;
  getStory() async {
    await FireStoreUtils().getStory(MyAppState.currentUser!.vendorID).then((value) {
      if (value != null) {
        _mediaFiles.addAll(value.videoUrl);
        thumbnailFile = value.videoThumbnail;
        setState(() {});
      }
    });

    await FirebaseFirestore.instance.collection(Setting).doc('story').get().then((value) {
      videoDuration = value.data()!['videoDuration'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select humbling GIF / Image'.tr(),
                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(child: _imageBuilder()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Story Video'.tr(),
                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 260,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _onCameraClick(true);
                              },
                              child: Container(
                                width: 140,
                                height: MediaQuery.of(context).size.height,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide.none,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Color(COLOR_PRIMARY),
                                    child: Icon(
                                      CupertinoIcons.camera,
                                      size: 40,
                                      color: isDarkMode(context) ? Colors.black : Colors.white,
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ListView.builder(
                                itemCount: _mediaFiles.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Stack(children: [
                                      VideoWidget(url: _mediaFiles[index]),
                                      Positioned(
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _mediaFiles.removeAt(index);
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ))
                                    ]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(top: 12, bottom: 12), backgroundColor: Color(COLOR_PRIMARY),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: Color(COLOR_PRIMARY),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (thumbnailFile == null) {
                          final snackBar = SnackBar(
                            content: const Text('Please select thumbnail.').tr(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else if (_mediaFiles.isEmpty) {
                          final snackBar = SnackBar(
                            content: const Text('Please Select video').tr(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          showProgress(context, 'Please wait...', false);

                          String? url;
                          if (thumbnailFile is File) {
                            url = await FireStoreUtils().uploadImageOfStory(thumbnailFile!, context, getFileExtension(thumbnailFile!.path)!);
                          } else {
                            url = thumbnailFile;
                          }

                          List<String> mediaFilesURLs = _mediaFiles.where((element) => element is String).toList().cast<String>();
                          List<File> imagesToUpload = _mediaFiles.where((element) => element is File).toList().cast<File>();

                          if (imagesToUpload.isNotEmpty) {
                            updateProgress(
                              'Uploading  {} of {}'.tr(args: ['1', '${imagesToUpload.length}']),
                            );
                            for (int i = 0; i < imagesToUpload.length; i++) {
                              if (i != 0)
                                updateProgress(
                                  'Uploading  {} of {}'.tr(
                                    args: ['${i + 1}', '${imagesToUpload.length}'],
                                  ),
                                );
                              String? url = await FireStoreUtils().uploadVideoStory(
                                imagesToUpload[i],
                                context,
                              );
                              mediaFilesURLs.add(url!);
                            }
                          }

                          StoryModel? storyModel = StoryModel(vendorID: MyAppState.currentUser!.vendorID, videoThumbnail: url, videoUrl: mediaFilesURLs, createdAt: Timestamp.now());
                          FireStoreUtils().addOrUpdateStory(storyModel).then((value) {
                            hideProgress();
                            final snackBar = SnackBar(
                              content: const Text('Story upload successfully').tr(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          });
                        }
                      },
                      child: Text(
                        'Save Story',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode(context) ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(top: 12, bottom: 12), backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: Color(COLOR_PRIMARY),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        showProgress(context, 'Please wait...', false);
                        await FireStoreUtils().removeStory(MyAppState.currentUser!.vendorID.toString()).then((value) {
                          hideProgress();
                          final snackBar = SnackBar(
                            content: const Text('Story remove successfully').tr(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          getStory();
                        });
                      },
                      child: Text(
                        'Delete Story',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode(context) ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageBuilder() {
    return GestureDetector(
      onTap: () {
        _onCameraClick(false);
      },
      child: Container(
        width: 140,
        height: 260,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: Color(COLOR_PRIMARY),
          child: thumbnailFile == null
              ? Icon(
                  CupertinoIcons.camera,
                  size: 40,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: thumbnailFile is File ? Image.file(thumbnailFile!, fit: BoxFit.fill) : Image.network(thumbnailFile!, fit: BoxFit.fill),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    super.dispose();
  }

  final ImagePicker _imagePicker = ImagePicker();

  _onCameraClick(bool multipleSelect) {
    final action = CupertinoActionSheet(
      message: Text(
        'Send Video',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        Visibility(
          visible: multipleSelect,
          child: CupertinoActionSheetAction(
            child: Text('Choose video from gallery').tr(),
            isDefaultAction: false,
            onPressed: () async {
              Navigator.pop(context);
              XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
              if (galleryVideo != null) {
                var info = await FlutterVideoInfo().getVideoInfo(galleryVideo.path);
                String rounded = prettyDuration(info!.duration!);

                if (double.parse(rounded).round() <= videoDuration!) {
                  print(double.parse(rounded).round());
                  setState(() {
                    _mediaFiles.add(File(galleryVideo.path));
                  });
                } else {
                  final snackBar = SnackBar(
                    content:  Text('Please select ${videoDuration.toString()} second below video.').tr(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
          ),
        ),
        Visibility(
          visible: !multipleSelect,
          child: CupertinoActionSheetAction(
            child: Text('Choose thubling image / GIF').tr(),
            isDefaultAction: false,
            onPressed: () async {
              Navigator.pop(context);
              XFile? galleryVideo = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (galleryVideo != null) {
                setState(() {
                  thumbnailFile = File(galleryVideo.path);
                });
              }
            },
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel',
        ).tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  String prettyDuration(double duration) {
    var seconds = duration / 1000.round();
    return '$seconds';
  }

  String? getFileExtension(String fileName) {
    try {
      return "." + fileName.split('.').last;
    } catch (e) {
      return null;
    }
  }
}
