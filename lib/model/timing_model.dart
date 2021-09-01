import 'dart:convert';

class TimingModel {
  TimingModel({
    this.index,
    this.id,
    this.day,
    this.startTime,
    this.endTime,
    this.isClosed = true,
  });
  final int index;
  final String id;
  String day;
  String startTime;
  String endTime;
  bool isClosed;

  factory TimingModel.fromRawJson(String str) =>
      TimingModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TimingModel.fromJson(Map<String, dynamic> json) => TimingModel(
        index: json["index"] == null ? null : json["index"],
        id: json["id"] == null ? null : json["id"],
        day: json["day"] == null ? null : json["day"],
        startTime: json["startTime"] == null ? null : json["startTime"],
        endTime: json["endTime"] == null ? null : json["endTime"],
        isClosed: json["isClosed"] == null ? null : json["isClosed"],
      );

  Map<String, dynamic> toJson() => {
        "index": index == null ? null : index,
        "id": id == null ? null : id,
        "day": day == null ? null : day,
        "startTime": startTime == null ? null : startTime,
        "endTime": endTime == null ? null : endTime,
        "isClosed": isClosed == null ? null : isClosed,
      };

  static List<TimingModel> timingList() {
    return [
      TimingModel(
          index: 0,
          day: "Monday",
          startTime: "9:00 am",
          endTime: "6:00 pm",
          isClosed: false),
      TimingModel(
          index: 1, day: "Tuesday", startTime: "9:00 am", endTime: "6:00 pm"),
      TimingModel(
          index: 2, day: "Wednesday", startTime: "9:00 am", endTime: "6:00 pm"),
      TimingModel(
          index: 3, day: "Thursday", startTime: "9:00 am", endTime: "6:00 pm"),
      TimingModel(
          index: 4, day: "Friday", startTime: "9:00 am", endTime: "6:00 pm"),
      TimingModel(
          index: 5, day: "Saturday", startTime: "9:00 am", endTime: "6:00 pm"),
      TimingModel(
          index: 6, day: "Sunday", startTime: "9:00 am", endTime: "6:00 pm"),
    ];
  }
}
