import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'models.g.dart';

@JsonSerializable()
class User {
  final String username;
  final Uri podURL;
  final String token;

  User({
    @required this.username,
    @required this.podURL,
    @required this.token,
  });

  String get imageUrl =>
      podURL.replace(path: "/user/$username/avatar").toString();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthReponse {
  final String token;

  AuthReponse({this.token});

  factory AuthReponse.fromJson(Map<String, dynamic> json) =>
      _$AuthReponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthReponseToJson(this);
}

@JsonSerializable()
class PagerResponse {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'max_pages')
  final int maxPages;
  @JsonKey(name: 'total_twts')
  final int totalTwts;

  PagerResponse({this.currentPage, this.maxPages, this.totalTwts});

  factory PagerResponse.fromJson(Map<String, dynamic> json) =>
      _$PagerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PagerResponseToJson(this);
}

@JsonSerializable()
class Twter {
  @JsonKey(name: 'Nick')
  final String nick;
  @JsonKey(name: 'URL')
  final Uri uri;
  @JsonKey(name: 'Avatar')
  final Uri avatar;

  Twter({this.nick, this.uri, this.avatar});

  factory Twter.fromJson(Map<String, dynamic> json) => _$TwterFromJson(json);
  Map<String, dynamic> toJson() => _$TwterToJson(this);
}

@JsonSerializable()
class Twt {
  @JsonKey(name: 'Twter')
  final Twter twter;
  @JsonKey(name: 'Text')
  final String text;
  @JsonKey(name: 'Created')
  final DateTime createdTime;

  static final mentionAndHashtagExp = RegExp(r'(@|#)<([^ ]+) *([^>]+)>');
  static final mentionsExp = RegExp(r"@<(.*?) .*?>");
  static final subjectExp = RegExp(r"^(@<.*>[, ]*)*(\(.*?\))(.*)");

  Twt({this.twter, this.text, this.createdTime});

  String get sanitizedTxt =>
      text.replaceAllMapped(mentionAndHashtagExp, (match) {
        final prefix = match.group(1);
        final nick = match.group(2);
        final url = match.group(3);
        return "[$prefix$nick]($url)";
      });

  List<String> get mentions =>
      mentionsExp.allMatches(text).map((e) => e.group(1)).toSet().toList();

  String get subject {
    final match = subjectExp.firstMatch(text);
    if (match == null) {
      return "";
    }

    return match.group(2);
  }

  String replyText(String usernameToExclude) {
    var _subject = subject;
    if (_subject != "") {
      _subject = _subject.replaceAllMapped(mentionAndHashtagExp, (match) {
        final prefix = match.group(1);
        final nick = match.group(2);
        return "$prefix$nick";
      });
    }

    return "${mentions.where((element) => element != usernameToExclude).map((e) => "@$e").join(" ")} $subject ";
  }

  factory Twt.fromJson(Map<String, dynamic> json) => _$TwtFromJson(json);
  Map<String, dynamic> toJson() => _$TwtToJson(this);
}

@JsonSerializable()
class TimelineResponse {
  final List<Twt> twts;
  @JsonKey(name: 'PagerResponse')
  final PagerResponse pagerResponse;

  TimelineResponse(this.twts, this.pagerResponse);

  factory TimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$TimelineResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TimelineResponseToJson(this);
}

@JsonSerializable()
class PostRequest {
  @JsonKey(name: 'post_as')
  final String postAs;
  final String text;

  PostRequest(this.postAs, this.text);
  factory PostRequest.fromJson(Map<String, dynamic> json) =>
      _$PostRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PostRequestToJson(this);
}
