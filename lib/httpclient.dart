import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

/// Adds the app version to the user-agent header.
class UserAgentClient extends http.BaseClient {
  final http.Client _inner;
  final PackageInfo _packageInfo;

  UserAgentClient(this._inner, this._packageInfo);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers[HttpHeaders.userAgentHeader] =
        "Goryon/${_packageInfo.version}";
    return _inner.send(request);
  }
}
