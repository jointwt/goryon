// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    username: json['username'] as String,
    podURL: json['podURL'] == null ? null : Uri.parse(json['podURL'] as String),
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'podURL': instance.podURL?.toString(),
      'token': instance.token,
    };

AuthReponse _$AuthReponseFromJson(Map<String, dynamic> json) {
  return AuthReponse(
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$AuthReponseToJson(AuthReponse instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

PagerResponse _$PagerResponseFromJson(Map<String, dynamic> json) {
  return PagerResponse(
    currentPage: json['current_page'] as int,
    maxPages: json['max_pages'] as int,
    totalTwts: json['total_twts'] as int,
  );
}

Map<String, dynamic> _$PagerResponseToJson(PagerResponse instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'max_pages': instance.maxPages,
      'total_twts': instance.totalTwts,
    };

Twter _$TwterFromJson(Map<String, dynamic> json) {
  return Twter(
    nick: json['Nick'] as String,
    uri: json['URL'] == null ? null : Uri.parse(json['URL'] as String),
    avatar: json['Avatar'] == null ? null : Uri.parse(json['Avatar'] as String),
  );
}

Map<String, dynamic> _$TwterToJson(Twter instance) => <String, dynamic>{
      'Nick': instance.nick,
      'URL': instance.uri?.toString(),
      'Avatar': instance.avatar?.toString(),
    };

Twt _$TwtFromJson(Map<String, dynamic> json) {
  return Twt(
    twter: json['Twter'] == null
        ? null
        : Twter.fromJson(json['Twter'] as Map<String, dynamic>),
    text: json['Text'] as String,
    createdTime: json['Created'] == null
        ? null
        : DateTime.parse(json['Created'] as String),
  );
}

Map<String, dynamic> _$TwtToJson(Twt instance) => <String, dynamic>{
      'Twter': instance.twter,
      'Text': instance.text,
      'Created': instance.createdTime?.toIso8601String(),
    };

TimelineResponse _$TimelineResponseFromJson(Map<String, dynamic> json) {
  return TimelineResponse(
    (json['twts'] as List)
        ?.map((e) => e == null ? null : Twt.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['Pager'] == null
        ? null
        : PagerResponse.fromJson(json['Pager'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TimelineResponseToJson(TimelineResponse instance) =>
    <String, dynamic>{
      'twts': instance.twts,
      'Pager': instance.pagerResponse,
    };

PostRequest _$PostRequestFromJson(Map<String, dynamic> json) {
  return PostRequest(
    json['post_as'] as String,
    json['text'] as String,
  );
}

Map<String, dynamic> _$PostRequestToJson(PostRequest instance) =>
    <String, dynamic>{
      'post_as': instance.postAs,
      'text': instance.text,
    };
