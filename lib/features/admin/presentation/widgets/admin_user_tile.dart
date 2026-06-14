import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';
import 'status_badge.dart';

class AdminUserTile extends StatelessWidget {
  final AdminUserEntity user;
  final VoidCallback onTap;

  const AdminUserTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  static const Color _cardColor = Color(0xFF1A1A1A);
  static const Color _accent = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _accent.withOpacity(0.15),
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge.fromString(user.status),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}