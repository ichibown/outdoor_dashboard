import 'dart:convert';

class AppConfig {
  String? avatar;
  String? title;
  String? subTitle;
  String? mapboxToken;
  String? mapStyleLight;
  String? mapStyleDark;
  String? mapLineColorLight;
  String? mapLineColorDark;

  AppConfig({
    this.avatar,
    this.title,
    this.subTitle,
    this.mapboxToken,
    this.mapStyleLight,
    this.mapStyleDark,
    this.mapLineColorLight,
    this.mapLineColorDark,
  });

  factory AppConfig.fromMap(Map<String, dynamic> data) => AppConfig(
        avatar: data['avatar'] as String?,
        title: data['title'] as String?,
        subTitle: data['subTitle'] as String?,
        mapboxToken: data['mapboxToken'] as String?,
        mapStyleLight: data['mapStyleLight'] as String?,
        mapStyleDark: data['mapStyleDark'] as String?,
        mapLineColorLight: data['mapLineColorLight'] as String?,
        mapLineColorDark: data['mapLineColorDark'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'avatar': avatar,
        'title': title,
        'subTitle': subTitle,
        'mapboxToken': mapboxToken,
        'mapStyleLight': mapStyleLight,
        'mapStyleDark': mapStyleDark,
        'mapLineColorLight': mapLineColorLight,
        'mapLineColorDark': mapLineColorDark,
      };

  factory AppConfig.fromJson(String data) {
    return AppConfig.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}
