class ChatMessage {
  String key;
  String senderId;
  String message;
  bool seen;
  String createdAt;
  String timeStamp;
  String senderName;
  String receiverId;
  String receiverImage;
  String receiverName;

  ChatMessage({
    this.key,
    this.senderId,
    this.message,
    this.seen,
    this.createdAt,
    this.receiverId,
    this.senderName,
    this.timeStamp,
    this.receiverImage,
    this.receiverName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        key: json["key"],
        senderId: json["sender_id"],
        message: json["message"],
        seen: json["seen"],
        createdAt: json["created_at"],
        timeStamp: json['timeStamp'],
        senderName: json["senderName"],
        receiverId: json["receiverId"],
        receiverImage: json["receiverImage"],
        receiverName: json["receiverName"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "sender_id": senderId,
        "message": message,
        "receiverId": receiverId,
        "seen": seen,
        "created_at": createdAt,
        "senderName": senderName,
        "timeStamp": timeStamp,
        "receiverImage": receiverImage,
        "receiverName": receiverName,
      };

  ChatMessage copyWith({
    String key,
    String senderId,
    String message,
    bool seen,
    String createdAt,
    String timeStamp,
    String senderName,
    String receiverId,
    String receiverImage,
    String receiverName,
  }) {
    return ChatMessage(
      key: key ?? this.key,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
      timeStamp: timeStamp ?? this.timeStamp,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverImage: receiverImage ?? this.receiverImage,
      receiverName: receiverName ?? this.receiverName,
    );
  }
}
