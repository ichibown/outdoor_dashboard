import 'dart:convert';

class AppConfig {
  String? avatar;
  String? title;
  String? subTitle;
  String? mapboxToken;

  AppConfig({this.avatar, this.title, this.subTitle, this.mapboxToken});

  factory AppConfig.fromMap(Map<String, dynamic> data) => AppConfig(
        avatar: data['avatar'] as String?,
        title: data['title'] as String?,
        subTitle: data['subTitle'] as String?,
        mapboxToken: data['mapboxToken'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'avatar': avatar,
        'title': title,
        'subTitle': subTitle,
        'mapboxToken': mapboxToken,
      };

  factory AppConfig.fromJson(String data) {
    return AppConfig.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}
