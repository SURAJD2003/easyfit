import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.isActive,
    super.subscriptionPlan,
    super.profileImage,
    super.createdAt,
    super.subscription,
    required super.status,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString().toLowerCase() ?? '';
    final isActive = status == 'active';

    final subJson = json['subscription'] as Map<String, dynamic>?;
    SubscriptionInfo? subInfo;
    if (subJson != null) {
      subInfo = SubscriptionInfo(
        plan: subJson['plan']?.toString() ?? 'Free',
        status: subJson['status']?.toString() ?? 'free',
        expiryDate: subJson['expiryDate'] != null
            ? DateTime.tryParse(subJson['expiryDate'].toString())
            : null,
        lastRenewalDate: subJson['lastRenewalDate'] != null
            ? DateTime.tryParse(subJson['lastRenewalDate'].toString())
            : subJson['updatedAt'] != null
                ? DateTime.tryParse(subJson['updatedAt'].toString())
                : null,
      );
    }

    return AdminUserModel(
      id: json['userId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      isActive: isActive,
      subscriptionPlan: subInfo?.plan ?? json['subscriptionPlan']?.toString(),
      profileImage: json['profileImage']?.toString() ?? json['photoUrl']?.toString(),
      createdAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      subscription: subInfo,
      status: status.isNotEmpty ? status : (isActive ? 'active' : 'inactive'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isActive': isActive,
      'status': status,
      'subscriptionPlan': subscriptionPlan,
      'profileImage': profileImage,
    };
  }
}