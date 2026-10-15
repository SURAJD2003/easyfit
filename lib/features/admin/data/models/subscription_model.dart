import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userEmail,
    required super.plan,
    required super.status,
    super.requestedAt,
    super.resolvedAt,
    super.expiryDate,
    super.note,
    super.reason,
    super.history = const [],
  });

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    final s = val.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;

    // 1. Standard ISO-8601 parsing
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // 2. Format: DD/MM/YYYY or DD-MM-YYYY
    final dmyRegex = RegExp(
        r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})(?:[ T](\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?');
    final match = dmyRegex.firstMatch(s);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      final hour = match.group(4) != null ? int.parse(match.group(4)!) : 0;
      final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;
      final second = match.group(6) != null ? int.parse(match.group(6)!) : 0;
      return DateTime(year, month, day, hour, minute, second);
    }

    // 3. Numeric timestamp (seconds or milliseconds)
    final numVal = num.tryParse(s);
    if (numVal != null) {
      if (numVal > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal.toInt());
      } else if (numVal > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch((numVal * 1000).toInt());
      }
    }

    return null;
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiryDate'] ??
        json['ExpiryDate'] ??
        json['dueDate'] ??
        json['DueDate'] ??
        json['expiresAt'] ??
        json['ExpiresAt'] ??
        json['endDate'] ??
        json['EndDate'] ??
        json['end_date'] ??
        json['due_date'] ??
        json['expiry_date'] ??
        json['expireDate'] ??
        json['ExpireDate'] ??
        json['expiredAt'] ??
        json['ExpiredAt'] ??
        json['validUntil'] ??
        json['ValidUntil'] ??
        json['validTo'] ??
        json['ValidTo'] ??
        json['nextBillingDate'] ??
        json['NextBillingDate'];

    final rawRequested = json['requestedAt'] ??
        json['RequestedAt'] ??
        json['createdAt'] ??
        json['CreatedAt'] ??
        json['created_at'] ??
        json['startDate'] ??
        json['StartDate'] ??
        json['start_date'];

    final rawResolved = json['resolvedAt'] ??
        json['ResolvedAt'] ??
        json['updatedAt'] ??
        json['UpdatedAt'] ??
        json['updated_at'] ??
        json['approvedAt'] ??
        json['ApprovedAt'];

    final rawHistory = json['history'] ?? json['History'];
    final List<SubscriptionHistoryItem> historyList = [];
    if (rawHistory is List) {
      for (final h in rawHistory) {
        if (h is Map<String, dynamic>) {
          historyList.add(SubscriptionHistoryItem.fromJson(h));
        }
      }
    }

    return SubscriptionModel(
      id: json['id']?.toString() ??
          json['Id']?.toString() ??
          json['_id']?.toString() ??
          json['subscriptionId']?.toString() ??
          json['SubscriptionId']?.toString() ??
          json['userId']?.toString() ??
          json['UserId']?.toString() ??
          '',
      userId: json['userId']?.toString() ??
          json['UserId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      userName: json['userName']?.toString() ??
          json['UserName']?.toString() ??
          json['name']?.toString() ??
          json['Name']?.toString() ??
          json['user_name']?.toString() ??
          json['fullName']?.toString() ??
          json['FullName']?.toString() ??
          'Unknown User',
      userEmail: json['userEmail']?.toString() ??
          json['UserEmail']?.toString() ??
          json['email']?.toString() ??
          json['Email']?.toString() ??
          json['user_email']?.toString() ??
          json['userPhone']?.toString() ??
          json['UserPhone']?.toString() ??
          json['phone']?.toString() ??
          json['Phone']?.toString() ??
          json['mobile']?.toString() ??
          json['Mobile']?.toString() ??
          '',
      plan: json['plan']?.toString() ??
          json['Plan']?.toString() ??
          json['planId']?.toString() ??
          json['PlanId']?.toString() ??
          json['planName']?.toString() ??
          json['PlanName']?.toString() ??
          'free',
      status: json['status']?.toString() ?? json['Status']?.toString() ?? 'pending',
      requestedAt: _parseDate(rawRequested),
      resolvedAt: _parseDate(rawResolved),
      expiryDate: _parseDate(rawExpiry),
      note: json['note']?.toString() ?? json['Note']?.toString(),
      reason: json['reason']?.toString() ?? json['Reason']?.toString(),
      history: historyList,
    );
  }
}