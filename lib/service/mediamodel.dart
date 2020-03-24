

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:social_alert_app/service/configuration.dart';
import 'package:social_alert_app/service/geolocation.dart';

class PagingParameter {
  final int pageNumber;
  final int pageSize;
  final int timestamp;

  PagingParameter({@required this.pageNumber, @required this.pageSize}) : timestamp = null;

  PagingParameter.fromJson(Map<String, dynamic> json) :
        pageNumber = json['pageNumber'],
        pageSize = json['pageSize'],
        timestamp = json['timestamp'];
}

class MediaInfo {
  final String title;
  final String mediaUri;
  final int hitCount;
  final int likeCount;
  final int dislikeCount;

  MediaInfo.fromJson(Map<String, dynamic> json) :
        title = json['title'],
        mediaUri = json['mediaUri'],
        hitCount = json['hitCount'],
        likeCount = json['likeCount'],
        dislikeCount = json['dislikeCount'];

  static List<MediaInfo> fromJsonList(List<dynamic> json) {
    return json.map((e) => MediaInfo.fromJson(e)).toList();
  }
}

enum ApprovalModifier {
  LIKE,
  DISLIKE,
}

const Map<String, ApprovalModifier> _approvalModifierMap = {
  'LIKE': ApprovalModifier.LIKE,
  'DISLIKE': ApprovalModifier.DISLIKE,
};

class CreatorInfo {
  final String id;
  final String username;
  final bool online;
  final String imageUri;

  CreatorInfo.fromJson(Map<String, dynamic> json) :
        id = json['id'],
        username = json['username'],
        online = json['online'],
        imageUri = json['imageUri'];
}

class MediaDetail {
  static final oneMega = 1000 * 1000;
  static final numberFormat = new NumberFormat('0.0');

  final String title;
  final String description;
  final DateTime timestamp;
  final String mediaUri;
  final int hitCount;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final double latitude;
  final double longitude;
  final String locality;
  final String country;
  final String category;
  final List<String> tags;
  final ApprovalModifier userApprovalModifier;
  final CreatorInfo creator;
  final String cameraMaker;
  final String cameraModel;

  MediaDetail.fromJson(Map<String, dynamic> json) :
        title = json['title'],
        description = json['description'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        mediaUri = json['mediaUri'],
        hitCount = json['hitCount'],
        likeCount = json['likeCount'],
        dislikeCount = json['dislikeCount'],
        commentCount = json['commentCount'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        locality = json['locality'],
        country = json['country'],
        category = json['category'],
        tags = List<String>.from(json['tags']),
        userApprovalModifier = _approvalModifierMap[json['userApprovalModifier']],
        creator = CreatorInfo.fromJson(json['creator']),
        cameraMaker = json['cameraMaker'],
        cameraModel = json['cameraModel'];

  GeoLocation get location {
    if (latitude != null && longitude != null) {
      return GeoLocation(longitude: longitude,
          latitude: latitude,
          locality: locality,
          country: country,
          address: null);
    } else {
      return null;
    }
  }

  String get format => numberFormat.format(previewHeight * previewWidth / oneMega) + 'MP - $previewWidth x $previewHeight';

  String get camera {
    if (cameraModel != null && cameraMaker != null) {
      return cameraMaker + " " + cameraModel;
    } else {
      return null;
    }
  }
}

typedef PageContentBuilder<T> = List<T> Function(List<dynamic> json);

abstract class ResultPage<T> {
  final List<T> content;
  final PagingParameter nextPage;
  final int pageCount;
  final int pageNumber;

  ResultPage.fromJson(Map<String, dynamic> json, PageContentBuilder<T> contentBuilder) :
        content = contentBuilder(json['content']),
        nextPage = json['nextPage'] != null ? PagingParameter.fromJson(json['nextPage']) : null,
        pageCount = json['pageCount'],
        pageNumber = json['pageNumber'];
}

class MediaInfoPage extends ResultPage<MediaInfo> {
  MediaInfoPage.fromJson(Map<String, dynamic> json) : super.fromJson(json, MediaInfo.fromJsonList);
}

class MediaCommentInfo {
  final String comment;
  final DateTime creation;
  final String id;
  final CreatorInfo creator;
  final int likeCount;
  final int dislikeCount;

  MediaCommentInfo.fromJson(Map<String, dynamic> json) :
        comment = json['comment'],
        creation = DateTime.fromMillisecondsSinceEpoch(json['creation']),
        id = json['id'],
        creator = CreatorInfo.fromJson(json['creator']),
        likeCount = json['likeCount'],
        dislikeCount = json['dislikeCount'];

  static List<MediaCommentInfo> fromJsonList(List<dynamic> json) {
    return json.map((e) => MediaCommentInfo.fromJson(e)).toList();
  }

  String get approvalDelta {
    if (likeCount < dislikeCount) {
      return '- ${dislikeCount - likeCount}';
    }
    return '+ ${likeCount - dislikeCount}';
  }

  @deprecated
  MediaCommentInfo.copy(MediaCommentInfo src) :
  comment = src.comment,
  creation =src.creation,
  id = src.id,
  creator = src.creator,
  likeCount = 9,
  dislikeCount = 8;
}

class MediaCommentPage extends ResultPage<MediaCommentInfo> {
  MediaCommentPage.fromJson(Map<String, dynamic> json) : super.fromJson(json, MediaCommentInfo.fromJsonList);
}