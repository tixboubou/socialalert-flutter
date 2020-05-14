import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_alert_app/annotate.dart';
import 'package:social_alert_app/capture.dart';
import 'package:social_alert_app/home.dart';
import 'package:social_alert_app/local.dart';
import 'package:social_alert_app/login.dart';
import 'package:social_alert_app/network.dart';
import 'package:social_alert_app/profile.dart';
import 'package:social_alert_app/remote.dart';
import 'package:social_alert_app/service/authentication.dart';
import 'package:social_alert_app/service/cameradevice.dart';
import 'package:social_alert_app/service/commentquery.dart';
import 'package:social_alert_app/service/dataobjet.dart';
import 'package:social_alert_app/service/eventbus.dart';
import 'package:social_alert_app/service/feedquery.dart';
import 'package:social_alert_app/service/fileservice.dart';
import 'package:social_alert_app/service/geolocation.dart';
import 'package:social_alert_app/service/httpservice.dart';
import 'package:social_alert_app/service/mediaquery.dart';
import 'package:social_alert_app/service/mediaupdate.dart';
import 'package:social_alert_app/service/mediaupload.dart';
import 'package:social_alert_app/service/profilequery.dart';
import 'package:social_alert_app/service/profileupdate.dart';
import 'package:social_alert_app/service/serviceprodiver.dart';
import 'package:social_alert_app/service/videoservice.dart';
import 'package:social_alert_app/settings.dart';
import 'package:social_alert_app/upload.dart';

import 'helper.dart';

void main() => runApp(SocialAlertApp());

class SocialAlertApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ServiceProvider<JsonHttpService>(create: (context) => JsonHttpService(context)),
          ServiceProvider<CameraDeviceService>(create: (context) => CameraDeviceService(context)),
          ServiceProvider<GeoLocationService>(create: (context) => GeoLocationService(context)),
          StreamProvider<GeoLocation>(create: (context) => GeoLocationService.current(context).locationStream, lazy: false),
          ServiceProvider<AuthService>(create: (context) => AuthService(context)),
          ServiceProvider<ProfileQueryService>(create: (context) => ProfileQueryService(context)),
          ServiceProvider<ProfileUpdateService>(create: (context) => ProfileUpdateService(context)),
          StreamProvider<UserProfile>(create: (context) => ProfileUpdateService.current(context).profileStream, lazy: false),
          StreamProvider<AvatarUploadProgress>(create: (context) => ProfileUpdateService.current(context).uploadProgressStream, lazy: false),
          ServiceProvider<MediaUploadService>(create: (context) => MediaUploadService(context)),
          ServiceProvider<MediaQueryService>(create: (context) => MediaQueryService(context)),
          ServiceProvider<MediaUpdateService>(create: (context) => MediaUpdateService(context)),
          ServiceProvider<CommentQueryService>(create: (context) => CommentQueryService(context)),
          ServiceProvider<FeedQueryService>(create: (context) => FeedQueryService(context)),
          ServiceProvider<FileService>(create: (context) => FileService(context)),
          ServiceProvider<VideoService>(create: (context) => VideoService(context)),
          ServiceProvider<EventBus>(create: (context) => EventBus(context)),
        ],
        child: _buildApp()
    );
  }

  MaterialApp _buildApp() {
    return MaterialApp(
        title: 'Snypix',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color.fromARGB(255, 54, 71, 163),
          primaryColorDark: Color.fromARGB(255, 43, 56, 130),
          accentColor: Color.fromARGB(255, 82, 173, 243),
          buttonColor: Color.fromARGB(255, 32, 47, 128),
          backgroundColor: Color.fromARGB(255, 63, 79, 167),
          textTheme: TextTheme(
            button: TextStyle(fontSize: 18, color: Colors.white),
            subtitle2: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
          ),
        ),
        initialRoute: AppRoute.Login,
        onGenerateRoute: _buildRoute,
      );
  }

  MaterialPageRoute _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.Login: return MaterialPageRoute(
        builder: (context) => LoginPage()
      );
      case AppRoute.Home: return MaterialPageRoute(
          builder: (context) => HomePage()
      );
      case AppRoute.UploadManager: return MaterialPageRoute(
          builder: (context) => UploadManagerPage()
      );
      case AppRoute.AnnotateMedia: return MaterialPageRoute(
          builder: (context) => AnnotateMediaPage(settings.arguments)
      );
      case AppRoute.UserNetwork: return MaterialPageRoute(
          builder: (context) => UserNetworkPage()
      );
      case AppRoute.LocalMediaInfo: return MaterialPageRoute(
          builder: (context) => LocalMediaInfoPage(settings.arguments)
      );
      case AppRoute.RemoteMediaDetail: return MaterialPageRoute<MediaDetail>(
        builder: (context) => RemoteMediaDetailPage(settings.arguments)
      );
      case AppRoute.ProfileViewer: return MaterialPageRoute<UserProfile>(
        builder: (context) => ProfileViewerPage(settings.arguments)
      );
      case AppRoute.ProfileEditor: return MaterialPageRoute(
        builder: (context) => ProfileEditorPage()
      );
      case AppRoute.SettingsEditor: return MaterialPageRoute(
        builder: (context) => SettingsEditorPage()
      );
      case AppRoute.LocalMediaDisplay: return NoAnimationMaterialPageRoute(
          builder: (context) => LocalMediaDisplayPage(settings.arguments)
      );
      case AppRoute.RemoteMediaDisplay: return NoAnimationMaterialPageRoute(
        builder: (context) => RemoteMediaDisplayPage(settings.arguments)
      );
      case AppRoute.CaptureMedia: return NoAnimationMaterialPageRoute(
          builder: (context) => CaptureMediaPage()
      );
      default: return null;
    }
  }
}

class AppRoute {
  static const Login = 'login';
  static const Home = 'home';
  static const CaptureMedia = 'captureMedia';
  static const AnnotateMedia = 'annotateMedia';
  static const UploadManager = 'uploadManager';
  static const UserNetwork = 'userNetwork';
  static const LocalMediaInfo = 'localMediaInfo';
  static const LocalMediaDisplay = 'localMediaDisplay';
  static const RemoteMediaDetail = 'remoteMediaDetail';
  static const RemoteMediaDisplay = 'remoteMediaDisplay';
  static const ProfileEditor = 'profileEditor';
  static const ProfileViewer = 'profileViewer';
  static const SettingsEditor = 'settingsEditor';
}