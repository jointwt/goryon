import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'models.g.dart';

@JsonSerializable()
class User {
  final Profile profile;
  final String token;
  final Twter twter;

  User({
    @required this.token,
    @required this.profile,
    @required this.twter,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    Profile profile,
    String token,
    Twter twter,
  }) {
    return User(
      profile: profile ?? this.profile,
      token: token ?? this.token,
      twter: twter ?? this.twter,
    );
  }
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
  @JsonKey(name: 'nick')
  final String nick;

  // uri is the twtxt for this twter. If uri is set to null, it usually means that it's an
  // external user
  @JsonKey(name: 'url')
  final Uri uri;

  @JsonKey(name: 'avatar')
  final Uri avatar;
  @JsonKey(name: 'slug')
  final String slug;

  Twter({this.nick, this.uri, this.avatar, this.slug});

  bool isPodMember(Uri podUri) {
    if (uri == null) {
      return false;
    }
    return podUri.authority == uri.authority;
  }

  factory Twter.fromJson(Map<String, dynamic> json) => _$TwterFromJson(json);
  Map<String, dynamic> toJson() => _$TwterToJson(this);
}

@JsonSerializable()
class Twt {
  @JsonKey(name: 'twter')
  final Twter twter;
  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'created')
  final DateTime createdTime;
  @JsonKey(name: 'hash')
  final String hash;

  static final mentionAndHashtagExp = RegExp(r'(@|#)<([^ ]+) *([^>]+)>');
  static final mentionsExp = RegExp(r"@<(.*?) .*?>");
  static final subjectExp = RegExp(r"^(@<.*>[, ]*)*(\(.*?\))(.*)");

  Twt({this.twter, this.text, this.createdTime, this.hash});

  Set<String> get mentions =>
      mentionsExp.allMatches(text).map((e) => e.group(1)).toSet();

  String get subject {
    final match = subjectExp.firstMatch(text);
    if (match == null) {
      return "(#$hash)";
    }

    return match.group(2);
  }

  String replyText(String usernameToExclude) {
    var _subject = subject;

    final _mentions = mentions
      ..add(twter.nick)
      ..remove(usernameToExclude);

    final mentionsStr = _mentions.map((e) => "@$e").join(" ");

    if (_subject != "") {
      _subject = _subject.replaceAllMapped(mentionAndHashtagExp, (match) {
        final prefix = match.group(1);
        final nick = match.group(2);
        return "$prefix$nick";
      });

      return "$mentionsStr $subject ";
    }

    return "$mentionsStr ";
  }

  factory Twt.fromJson(Map<String, dynamic> json) => _$TwtFromJson(json);
  Map<String, dynamic> toJson() => _$TwtToJson(this);
}

@JsonSerializable()
class PagedResponse {
  final List<Twt> twts;
  @JsonKey(name: 'Pager')
  final PagerResponse pagerResponse;

  PagedResponse(this.twts, this.pagerResponse);

  factory PagedResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PagedResponseToJson(this);
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

@JsonSerializable()
class ProfileResponse {
  final Profile profile;
  final List<Link> links;
  final List<Alternative> alternatives;
  final Twter twter;

  ProfileResponse(this.profile, this.links, this.alternatives, this.twter);

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

@JsonSerializable()
class Profile {
  @JsonKey(name: 'Type')
  final String type;
  @JsonKey(name: 'Username')
  final String username;
  @JsonKey(name: 'URL')
  final Uri uri;
  @JsonKey(name: 'Followers')
  final Map<String, String> followers;
  @JsonKey(name: 'Following')
  final Map<String, String> following;
  @JsonKey(name: 'Tagline', defaultValue: '')
  final String tagline;

  Profile(
    this.type,
    this.username,
    this.uri,
    this.followers,
    this.following,
    this.tagline,
  );

  String get mention {
    return '@$username';
  }

  bool isFollowing(String uri) {
    return following.containsValue(uri);
  }

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class Link {
  @JsonKey(name: 'Href')
  final String href;
  @JsonKey(name: 'Rel')
  final String rel;

  Link(this.href, this.rel);
  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);
  Map<String, dynamic> toJson() => _$LinkToJson(this);
}

@JsonSerializable()
class Alternative {
  @JsonKey(name: 'Type')
  final String type;
  @JsonKey(name: 'Title')
  final String title;
  @JsonKey(name: 'URL')
  final String url;

  Alternative(this.type, this.title, this.url);
  factory Alternative.fromJson(Map<String, dynamic> json) =>
      _$AlternativeFromJson(json);
  Map<String, dynamic> toJson() => _$AlternativeToJson(this);
}
