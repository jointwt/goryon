import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'api.dart';
import 'models.dart';

class AuthViewModel {
  final Api _api;

  final _user = BehaviorSubject<User>();

  AuthViewModel(this._api) {
    _api.user.then(_user.add);
  }

  Stream get user => _user.stream;

  void logout() {
    if (_user.value == null) return;
    _api.clearUserToken();
    _user.add(null);
  }

  Future login(String username, String password, String podURL) async {
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
    _isLoading = false;
  }

  final Api _api;
  bool _isLoading;
  TimelineResponse _lastTimelineResponse;
  List<Twt> _twts;

  bool get isLoading => _isLoading;

  List<Twt> get twts => _twts;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Future refreshPost() async {
    _lastTimelineResponse = await _api.timeline(0);
    _twts = _lastTimelineResponse.twts;
    notifyListeners();
  }

  void fetchNewPost() async {
    isLoading = true;

    try {
      _lastTimelineResponse = await _api.timeline(0);
      _twts = _lastTimelineResponse.twts;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void gotoNextPage() async {
    isLoading = true;
    try {
      final page =
          (_lastTimelineResponse?.pagerResponse?.currentPage ?? -1) + 1;
      _lastTimelineResponse = await _api.timeline(page);
      _twts = [..._twts, ..._lastTimelineResponse.twts];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class DiscoverViewModel extends ChangeNotifier {
  DiscoverViewModel(this._api) {
    _twts = [];
    _isLoading = false;
  }

  final Api _api;
  bool _isLoading;
  TimelineResponse _lastTimelineResponse;
  List<Twt> _twts;

  bool get isLoading => _isLoading;

  List<Twt> get twts => _twts;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Future refreshPost() async {
    _lastTimelineResponse = await _api.discover(0);
    _twts = _lastTimelineResponse.twts;
    notifyListeners();
  }

  void fetchNewPost() async {
    isLoading = true;

    try {
      _lastTimelineResponse = await _api.discover(0);
      _twts = _lastTimelineResponse.twts;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void gotoNextPage() async {
    isLoading = true;
    try {
      final page =
          (_lastTimelineResponse?.pagerResponse?.currentPage ?? -1) + 1;
      _lastTimelineResponse = await _api.discover(page);
      _twts = [..._twts, ..._lastTimelineResponse.twts];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
