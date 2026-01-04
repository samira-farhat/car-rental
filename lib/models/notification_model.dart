class UserNotification {
  final int notificationid;
  final String message;
  final String type; // 'reservation', 'rental', 'payment', 'general'
  final String sentAt; // formatted as string for display
  String status; // 'unread' or 'read'

  UserNotification({
    required this.notificationid,
    required this.message,
    required this.type,
    required this.sentAt,
    required this.status,
  });

  // ----------------- From JSON -----------------
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      notificationid: json['NotificationID'] as int,
      message: json['Message'] as String,
      type: json['Type'] as String,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at']).toLocal().toString()
          : '', // convert to local string
      status: json['status'] as String,
    );
  }

  // ----------------- To JSON -----------------
  Map<String, dynamic> toJson() {
    return {
      'NotificationID': notificationid,
      'Message': message,
      'Type': type,
      'sent_at': sentAt,
      'status': status,
    };
  }
}
