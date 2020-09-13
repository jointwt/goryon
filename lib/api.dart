import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';

import 'models.dart';

class Api {
  final http.Client _httpClient;
  final FlutterSecureStorage _flutterSecureStorage;
  final String tokenKey = 'provile-v1';

  Api(this._httpClient, this._flutterSecureStorage);

  Future<User> get user async {
    String json = await _flutterSecureStorage.read(key: tokenKey);
    if (json == null) {
      return null;
    }
    return User.fromJson(jsonDecode(json));
  }

  void clearUserToken() {
    _flutterSecureStorage.delete(key: tokenKey);
  }

  Future<User> login(String username, String password, Uri podURI) async {
    final response = await _httpClient.post(
      podURI.replace(path: "/api/v1/auth"),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.toString()},
    );

    if (response.statusCode == 401) {
      throw http.ClientException(
        'Invalid username! Hint: Register an account?',
      );
    }

    if (response.statusCode >= 400) {
      throw http.ClientException('Failed to login');
    }

    final profileResponse = await getProfile(username, podURI);

    final user = User(
      profile: profileResponse.profile,
      twter: profileResponse.twter,
      token: AuthReponse.fromJson(jsonDecode(response.body)).token,
    );

    await _flutterSecureStorage.write(key: tokenKey, value: jsonEncode(user));

    return user;
  }

  Future<User> loginUsingCachedData() async {
    var _user = await user;

    final profileResponse =
        await getProfile(_user.profile.username, _user.profile.uri);

    _user = _user.copyWith(
        profile: profileResponse.profile, twter: profileResponse.twter);

    await _flutterSecureStorage.write(key: tokenKey, value: jsonEncode(_user));

    return _user;
  }

  Future<void> register(
      String uri, String username, String password, String email) async {
    final response = await _httpClient.post(
      Uri.parse(uri).replace(path: "/api/v1/register"),
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
      headers: {HttpHeaders.contentTypeHeader: ContentType.json.toString()},
    );

    if (response.statusCode >= 400) {
      throw http.ClientException('Failed to register. ${response.body}');
    }
  }

  Future<TimelineResponse> timeline(int page) async {
    final _user = await user;
    final response = await _httpClient.post(
      _user.profile.uri.replace(path: "/api/v1/timeline"),
      body: jsonEncode({'page': page}),
      headers: {
        'Token': _user.token,
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      },
    );

    if (response.statusCode >= 400) {
      throw http.ClientException('Failed to get posts');
    }

    return TimelineResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<TimelineResponse> discover(int page) async {
    final _user = await user;
    final response = await _httpClient.post(
      _user.profile.uri.replace(path: "/api/v1/discover"),
      body: jsonEncode({'page': page}),
      headers: {
        'Token': _user.token,
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      },
    );

    if (response.statusCode >= 400) {
      throw http.ClientException('Failed to get posts');
    }

    return TimelineResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<void> savePost(String text) async {
    final _user = await user;
    final response = await _httpClient.post(
      _user.profile.uri.replace(path: "/api/v1/post"),
      body: jsonEncode({'text': text, 'post_as': "me"}),
      headers: {
        'Token': _user.token,
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      },
    );

    if (response.statusCode >= 400) {
      throw http.ClientException('Failed post tweet. Please try again later');
    }
  }

  Future<void> follow(String nick, String url) async {
    final _user = await user;
    final response = await _httpClient.post(
      _user.profile.uri.replace(path: "/api/v1/follow"),
      body: jsonEncode({'nick': nick, 'url': url}),
      headers: {
        'Token': _user.token,
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      },
    );

    if (response.statusCode >= 400) {
      throw http.ClientException(
        'Follow request failed. Please try again later',
      );
    }
  }

  Future<void> unfollow(String nick) async {
    final _user = await user;
    final response = await _httpClient.post(
      _user.profile.uri.replace(path: "/api/v1/unfollow"),
      body: jsonEncode({'nick': nick}),
      headers: {
        'Token': _user.token,
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      },
    );

    if (response.statusCode >= 400) {
      throw http.ClientException(
        'Follow request failed. Please try again later',
      );
    }
  }

  Future<String> uploadImage(String filePath) async {
    final _user = await user;
    final request = http.MultipartRequest(
      'POST',
      _user.profile.uri.replace(path: "/api/v1/upload"),
    )
      ..headers['Token'] = _user.token
      ..files.add(
        await http.MultipartFile.fromPath(
          'media_file',
          filePath,
          filename: basename(filePath),
        ),
      );

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode >= 400) {
      throw http.ClientException(
        'Failed to upload image. Please try again later',
      );
    }

    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body)['Path'];
  }

  Future<ProfileResponse> getProfile(String name, [Uri uri]) async {
    Uri _uri;

    if (uri != null) {
      _uri = uri;
    } else {
      final _user = await user;
      _uri = _user.profile.uri;
    }

    final response = await _httpClient.get(
      _uri.replace(path: "/api/v1/profile/$name"),
    );

    if (response.statusCode >= 400) {
      throw http.ClientException(
        'Failed fetch profile. Please try again later',
      );
    }

    return ProfileResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<ProfileResponse> getExternalProfile(String nick, String url) async {
    throw UnimplementedError('getExternalProfile needs to be implemented');
  }
}
