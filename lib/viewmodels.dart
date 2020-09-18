import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

import 'api.dart';
import 'models.dart';

class AuthViewModel {
  final Api _api;

  final _user = BehaviorSubject<User>();

  AuthViewModel(this._api) {
    _api.loginUsingCachedData().then(_user.add).catchError((_) {
      _api.clearUserToken();
      _user.add(null);
    });
  }

  Stream get user => _user.stream;

  void logout() {
    if (_user.value == null) return;
    _api.clearUserToken();
    _user.add(null);
  }

  Future<void> unfollow(String nick) async {
    final user = await _user.first;
    _api.unfollow(nick);
    user.profile.following.remove(nick);
    _user.add(user);
  }

  Future<void> follow(String nick, String url) async {
    final user = await _user.first;
    _api.follow(nick, url);
    user.profile.following.putIfAbsent(nick, () => url);
    _user.add(user);
  }

  Future<void> login(String username, String password, String podURL) async {
    var uri = Uri.parse(podURL);

    if (!uri.hasScheme) {
      uri = Uri.https(podURL, "");
    }

    final user = await _api.login(
      username,
      password,
      uri,
    );
    _user.add(user);
  }
}

class TimelineViewModel extends ChangeNotifier {
  TimelineViewModel(this._api) {
    _twts = [];
    _isEntireListLoading = false;
    _isBottomListLoading = false;
  }

  final Api _api;
  bool _isEntireListLoading;
  bool _isBottomListLoading;
  PagedResponse _lastTimelineResponse;
  List<Twt> _twts;

  bool get isEntireListLoading => _isEntireListLoading;
  bool get isBottomListLoading => _isBottomListLoading;

  List<Twt> get twts => _twts;

  set isEntireListLoading(bool isLoading) {
    _isEntireListLoading = isLoading;
    notifyListeners();
  }

  set isBottomListLoading(bool isLoading) {
    _isBottomListLoading = isLoading;
    notifyListeners();
  }

  Future refreshPost() async {
    _lastTimelineResponse = await _api.timeline(0);
    _twts = _lastTimelineResponse.twts;
    notifyListeners();
  }

  void fetchNewPost() async {
    isEntireListLoading = true;

    try {
      _lastTimelineResponse = await _api.timeline(0);
      _twts = _lastTimelineResponse.twts;
    } finally {
      isEntireListLoading = false;
    }
  }

  void gotoNextPage() async {
    if (_lastTimelineResponse.pagerResponse.currentPage ==
        _lastTimelineResponse.pagerResponse.maxPages) {
      return;
    }

    isBottomListLoading = true;
    try {
      final page = _lastTimelineResponse.pagerResponse.currentPage + 1;
      _lastTimelineResponse = await _api.timeline(page);
      _twts = [..._twts, ..._lastTimelineResponse.twts];
    } finally {
      isBottomListLoading = false;
    }
  }
}

class DiscoverViewModel extends ChangeNotifier {
  DiscoverViewModel(this._api) {
    _twts = [];
    _isBottomListLoading = false;
  }

  final Api _api;
  bool _isBottomListLoading;
  PagedResponse _lastTimelineResponse;
  List<Twt> _twts;

  bool get isBottomListLoading => _isBottomListLoading;

  List<Twt> get twts => _twts;

  set isBottomListLoading(bool isLoading) {
    _isBottomListLoading = isLoading;
    notifyListeners();
  }

  Future refreshPost() async {
    _lastTimelineResponse = await _api.discover(0);
    _twts = _lastTimelineResponse.twts;
    notifyListeners();
  }

  Future<void> gotoNextPage() async {
    if (_lastTimelineResponse.pagerResponse.currentPage ==
        _lastTimelineResponse.pagerResponse.maxPages) {
      return;
    }

    isBottomListLoading = true;
    try {
      final page = _lastTimelineResponse.pagerResponse.currentPage + 1;
      _lastTimelineResponse = await _api.discover(page);
      _twts = [..._twts, ..._lastTimelineResponse.twts];
    } finally {
      isBottomListLoading = false;
    }
  }
}

class NewTwtViewModel {
  final _picker = ImagePicker();
  final Api _api;

  NewTwtViewModel(this._api);

  Future<String> prompUserForImageAndUpload(ImageSource imageSource) async {
    final pickedFile = await _picker.getImage(source: imageSource);
    if (pickedFile == null) {
      return null;
    }

    return _api.uploadImage(pickedFile.path);
  }
}

class ProfileViewModel extends ChangeNotifier {
  final Api _api;
  ProfileResponse _profileResponse;
  bool _isBottomListLoading;
  PagedResponse _lastTimelineResponse;
  List<Twt> _twts;

  bool get isBottomListLoading => _isBottomListLoading;

  List<Twt> get twts => _twts;

  Profile get profile => _profileResponse.profile;
  Twter get twter => _profileResponse.twter;
  bool get hasProfile => _profileResponse?.profile != null;

  Map<String, String> get following => _profileResponse?.profile?.following;
  int get followingCount => following?.length ?? 0;
  bool get hasFollowing => followingCount > 0;

  Map<String, String> get followers => _profileResponse?.profile?.followers;
  int get followerCount => followers?.length ?? 0;
  bool get hasFollowers => followerCount > 0;

  set profileResponse(ProfileResponse profileResponse) {
    _profileResponse = profileResponse;
    notifyListeners();
  }

  set isBottomListLoading(bool isLoading) {
    _isBottomListLoading = isLoading;
    notifyListeners();
  }

  Future refreshPost() async {
    _lastTimelineResponse = await _api.getUserTwts(0, profile.username);
    _twts = _lastTimelineResponse.twts;
    notifyListeners();
  }

  ProfileViewModel(this._api) {
    _twts = [];
    _isBottomListLoading = false;
  }

  Future<void> fetchProfile(String name, [String url]) async {
    if (url != null) {
      profileResponse = await _api.getExternalProfile(name, url);
      return;
    }
    profileResponse = await _api.getProfile(name);
  }

  Future<void> gotoNextPage() async {
    if (_lastTimelineResponse.pagerResponse.currentPage ==
        _lastTimelineResponse.pagerResponse.maxPages) {
      return;
    }

    isBottomListLoading = true;
    try {
      final page = _lastTimelineResponse.pagerResponse.currentPage + 1;
      _lastTimelineResponse = await _api.getUserTwts(page, profile.username);
      _twts = [..._twts, ..._lastTimelineResponse.twts];
    } finally {
      isBottomListLoading = false;
    }
  }
}
