import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:social_alert_app/service/credential.dart';
import 'package:social_alert_app/service/dataobjet.dart';
import 'package:social_alert_app/service/httpservice.dart';
import 'package:social_alert_app/service/serviceprodiver.dart';

class _LoginTokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiration;

  _LoginTokenResponse.fromJson(Map<String, dynamic> json) :
        accessToken = json['accessToken'],
        refreshToken =  json['refreshToken'],
        expiration = json['expiration'];
}

class _LoginResponse extends _LoginTokenResponse {
  final String userId;
  final String username;
  final String email;
  final String firstname;
  final String lastname;
  final String country;
  final String biography;
  final String birthdate;
  final String gender;
  final String imageUri;
  final UserStatistic statistic;

  _LoginResponse.fromJson(Map<String, dynamic> json) :
    userId = json['id'],
    username = json['username'],
    email = json['email'],
    firstname = json['firstname'],
    lastname = json['lastname'],
    country = json['country'],
    biography = json['biography'],
    birthdate = json['birthdate'],
    gender = json['gender'],
    imageUri = json['imageUri'],
    statistic = json['statistic'] != null ? UserStatistic.fromJson(json['statistic']) : null,
    super.fromJson(json);
}

class _AuthenticationApi {

  final JsonHttpService httpService;

  _AuthenticationApi(this.httpService);

  Future<_LoginResponse> loginUser(Credential credential) async {
    final response = await httpService.postJson(uri: '/user/login', body: credential);
    if (response.statusCode == 200) {
      return _LoginResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw 'Bad credential';
    }
    throw response.reasonPhrase;
  }

  Future<_LoginTokenResponse> renewLogin(String refreshToken) async {
    final response = await httpService.postText(uri: '/user/renewLogin', body: refreshToken);
    if (response.statusCode == 200) {
      return _LoginTokenResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw 'Session timeout';
    }
    throw response.reasonPhrase;
  }

  Future<UserProfile> currentUser(String accessToken) async {
    final response = await httpService.getJson(uri: '/user/current', accessToken: accessToken ?? '');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      return null;
    }
    throw response.reasonPhrase;
  }

  Future<void> logout(String accessToken) async {
    final response = await httpService.post(uri: '/user/logout', accessToken: accessToken);
    if (response.statusCode == 204) {
      return;
    }
    throw response.reasonPhrase;
  }
}

class _AuthToken {
  static const refreshTokenDelta = 10000;

  final accessToken;
  final refreshToken;
  final _expiration;

  _AuthToken(_LoginTokenResponse login)
      : accessToken = login.accessToken,
        refreshToken = login.refreshToken,
        _expiration = login.expiration;

  bool get expired {
    return _expiration - refreshTokenDelta <
        DateTime.now().millisecondsSinceEpoch;
  }
}

class UserProfile {
  final String userId;
  final String username;
  final bool online;
  final String email;
  final String firstname;
  final String lastname;
  final String country;
  final String imageUri;
  final String birthdate;
  final String biography;
  final String gender;
  final UserStatistic statistic;
  final DateTime followedSince;

  UserProfile.fromLogin(_LoginResponse login) :
      userId = login.userId,
      username = login.username,
      online = true,
      email = login.email,
      firstname = login.firstname,
      lastname = login.lastname,
      imageUri = login.imageUri,
      country = login.country,
      birthdate = login.birthdate,
      biography = login.biography,
      gender = login.gender,
      statistic = login.statistic,
      followedSince = null;

  UserProfile.fromInfo(UserInfo info) :
        userId = info.userId,
        username = info.username,
        online = info.online,
        email = info.email,
        firstname = info.firstname,
        lastname = info.lastname,
        imageUri = info.imageUri,
        country = info.country,
        birthdate = info.birthdate,
        biography = info.biography,
        gender = info.gender,
        statistic = info.statistic,
        followedSince = null;

  UserProfile.anonym() :
        userId = null,
        username = null,
        online = false,
        email = null,
        firstname = null,
        lastname = null,
        country = null,
        imageUri = null,
        birthdate = null,
        biography = null,
        gender = null,
        statistic = null,
        followedSince = null;

  UserProfile.fromJson(Map<String, dynamic> json) :
        userId = json['id'],
        username = json['username'],
        online = json['online'],
        email = json['email'],
        firstname = json['firstname'],
        lastname =  json['lastname'],
        country = json['country'],
        biography = json['biography'],
        birthdate = json['birthdate'],
        gender = json['gender'],
        imageUri = json['imageUri'],
        statistic = UserStatistic.fromJson(json['statistic']),
        followedSince = json['followedSince'] != null ? DateTime.fromMillisecondsSinceEpoch(json['followedSince']) : null;

  static List<UserProfile> fromJsonList(List<dynamic> json) {
    return json.map((e) => UserProfile.fromJson(e)).toList();
  }

  bool get anonym => userId == null;

  bool get followed => followedSince != null;

  bool get incomplete => (firstname?.isEmpty ?? true) || (lastname?.isEmpty ?? true) || country == null || (biography?.isEmpty ?? true) || birthdate == null || gender == null || imageUri == null;

  bool same(UserProfile other) =>
      userId == other.userId &&
      username == other.username &&
      email == other.email &&
      firstname == other.firstname &&
      lastname == other.lastname &&
      country == other.country &&
      imageUri == other.imageUri &&
      birthdate == other.birthdate &&
      biography == other.biography &&
      gender == other.gender;

}

class AuthService extends Service {

  final _credentialStore = CredentialStore();
  final _profileController = StreamController<UserProfile>();
  _AuthToken _token;

  AuthService(BuildContext context) : super(context);

  static AuthService current(BuildContext context) => ServiceProvider.of(context);

  Stream<UserProfile> get profileStream => _profileController.stream;

  void dispose() {
    _profileController.close();
  }

  _AuthenticationApi get _authApi => _AuthenticationApi(lookup());

  Future<Credential> get initialCredential {
    return _credentialStore.load();
  }

  Future<UserProfile> authenticate(Credential credential) async {
    await _credentialStore.store(credential);
    var login = await _authApi.loginUser(credential);

    _token = _AuthToken(login);

    final profile = UserProfile.fromLogin(login);
    _profileController.add(profile);
    return profile;
  }

  Future<UserProfile> currentUser() async {
    UserProfile profile;
    try {
      profile = await _authApi.currentUser(await accessToken);
    } catch (e) {
      // no server connection
      profile = UserProfile.anonym();
    }
    if (profile != null) {
      _profileController.add(profile);
    }
    return profile;
  }

  Future<String> get accessToken async {
    if (_token == null) {
      return null;
    }
    if (_token.expired) {
      var login = await _authApi.renewLogin(_token.refreshToken);
      _token = _AuthToken(login);
    }
    return _token.accessToken;
  }

  Future<void> logout() async {
    try {
      await _authApi.logout(await accessToken);
    } catch (e) {
      // ignore
      print(e.toString());
    }
    _token = null;
    _profileController.add(null);
  }

  Future<void> signOut() async {
    await logout();
    await _credentialStore.clear();
  }
}