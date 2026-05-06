# 🔌 Admin Module - Backend API Contract

> This document defines the exact API contract that the frontend Admin Module expects.
> Use this to implement backend endpoints.

---

## Base Configuration

```
Base URL: https://parkmitra.com/api
Content-Type: application/json
Authentication: Bearer {token} in Authorization header
```

---

## Authentication

### 1. Admin Login

**Endpoint:**
```
POST /admin/login
```

**Description:** Authenticate admin with email and password

**Request:**
```json
{
  "email": "admin@easyfit.com",
  "password": "admin123456"
}
```

**Response (200 OK):**
```json
{
  "adminId": "admin_001",
  "name": "Sarah Johnson",
  "email": "admin@easyfit.com",
  "role": "admin",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_abc123...",
  "profileImage": null,
  "permissions": [
    "view_users",
    "view_subscriptions",
    "approve_subscriptions",
    "reject_subscriptions",
    "send_messages"
  ]
}
```

**Error (401 Unauthorized):**
```json
{
  "error": "Invalid credentials",
  "message": "Email or password is incorrect"
}
```

---

### 2. Get Admin Profile

**Endpoint:**
```
GET /admin/profile
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "adminId": "admin_001",
  "name": "Sarah Johnson",
  "email": "admin@easyfit.com",
  "role": "admin",
  "profileImage": null,
  "permissions": ["view_users", "approve_subscriptions", ...],
  "createdAt": "2023-06-15T10:30:00Z",
  "lastLogin": "2024-04-20T15:45:00Z",
  "isActive": true
}
```

**Error (401 Unauthorized):**
```json
{
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

---

## Dashboard

### 3. Get Dashboard Statistics

**Endpoint:**
```
GET /admin/dashboard/stats
Authorization: Bearer {token}
```

**Description:** Get overview statistics for dashboard

**Response (200 OK):**
```json
{
  "totalUsers": 2847,
  "pendingRequests": 34,
  "approvedSubscriptions": 1923,
  "rejectedSubscriptions": 156,
  "activeSubscriptions": 1834,
  "totalRevenue": 145678.50,
  "recentRequests": [
    {
      "subscriptionId": "sub_001",
      "userName": "John Doe",
      "userEmail": "john@example.com",
      "plan": "monthly",
      "status": "pending",
      "requestedDate": "2024-04-20T08:15:00Z",
      "price": 29.99,
      "billingCycle": "monthly"
    }
  ]
}
```

**Notes:**
- `totalUsers`: Count of all registered users
- `activeSubscriptions`: Users with active/approved subscriptions
- `recentRequests`: Last 5-10 pending requests

---

## User Management

### 4. Get All Users

**Endpoint:**
```
GET /admin/users
Authorization: Bearer {token}
```

**Query Parameters:**
```
?page=1&limit=20&search=john&status=active
```

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | int | No | 1 | Page number (1-indexed) |
| limit | int | No | 20 | Items per page |
| search | string | No | null | Search by name or email |
| status | string | No | null | Filter: active, pending, approved, rejected |

**Response (200 OK):**
```json
[
  {
    "userId": "user_123",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1-555-0123",
    "subscriptionStatus": "active",
    "createdAt": "2024-01-15T10:30:00Z",
    "lastLogin": "2024-04-20T15:45:00Z",
    "isActive": true,
    "profileImage": null
  },
  {
    "userId": "user_124",
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "+1-555-0124",
    "subscriptionStatus": "pending",
    "createdAt": "2024-02-20T14:20:00Z",
    "lastLogin": "2024-04-19T10:15:00Z",
    "isActive": true,
    "profileImage": null
  }
]
```

**Error (400 Bad Request):**
```json
{
  "error": "Invalid parameters",
  "message": "Page must be >= 1"
}
```

**Notes:**
- Returns paginated results
- Search should be case-insensitive
- Status filter is optional

---

### 5. Get User Details

**Endpoint:**
```
GET /admin/users/{userId}
Authorization: Bearer {token}
```

**Path Parameters:**
```
{userId} - User ID (e.g., "user_123")
```

**Response (200 OK):**
```json
{
  "userId": "user_123",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1-555-0123",
  "subscriptionStatus": "active",
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLogin": "2024-04-20T15:45:00Z",
  "isActive": true,
  "profileImage": "https://cdn.example.com/profiles/user_123.jpg",
  "address": "123 Main Street",
  "city": "San Francisco",
  "country": "United States",
  "emergencyContact": "+1-555-0999",
  "totalSessions": 127,
  "totalSteps": 2453000,
  "totalCalories": 89500,
  "subscriptionHistory": [
    {
      "subscriptionId": "sub_001",
      "plan": "monthly",
      "status": "approved",
      "requestedDate": "2024-03-15T08:20:00Z",
      "approvedDate": "2024-03-15T12:00:00Z",
      "price": 29.99,
      "billingCycle": "monthly"
    }
  ]
}
```

**Error (404 Not Found):**
```json
{
  "error": "User not found",
  "message": "User with ID 'user_123' does not exist"
}
```

**Notes:**
- Include full user profile with activity stats
- `subscriptionHistory` includes all past/current subscriptions
- Activity stats should come from activity service

---

## Subscription Management

### 6. Get Subscriptions

**Endpoint:**
```
GET /admin/subscriptions
Authorization: Bearer {token}
```

**Query Parameters:**
```
?status=pending&page=1&limit=20
```

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| status | string | No | null | Filter: pending, approved, rejected |
| page | int | No | 1 | Page number |
| limit | int | No | 20 | Items per page |

**Response (200 OK):**
```json
[
  {
    "subscriptionId": "sub_001",
    "userId": "user_123",
    "userName": "John Doe",
    "userEmail": "john@example.com",
    "plan": "monthly",
    "status": "pending",
    "requestedDate": "2024-04-18T08:20:00Z",
    "approvedDate": null,
    "rejectedDate": null,
    "approvedBy": null,
    "rejectedBy": null,
    "rejectionReason": null,
    "approvalNote": null,
    "price": 29.99,
    "billingCycle": "monthly"
  },
  {
    "subscriptionId": "sub_002",
    "userId": "user_124",
    "userName": "Jane Smith",
    "userEmail": "jane@example.com",
    "plan": "yearly",
    "status": "approved",
    "requestedDate": "2024-03-10T14:30:00Z",
    "approvedDate": "2024-03-10T15:00:00Z",
    "rejectedDate": null,
    "approvedBy": "admin@easyfit.com",
    "rejectedBy": null,
    "rejectionReason": null,
    "approvalNote": "Approved for premium features",
    "price": 299.99,
    "billingCycle": "yearly"
  },
  {
    "subscriptionId": "sub_003",
    "userId": "user_125",
    "userName": "Mike Johnson",
    "userEmail": "mike@example.com",
    "plan": "monthly",
    "status": "rejected",
    "requestedDate": "2024-04-15T10:00:00Z",
    "approvedDate": null,
    "rejectedDate": "2024-04-15T11:30:00Z",
    "approvedBy": null,
    "rejectedBy": "admin@easyfit.com",
    "rejectionReason": "Age requirement not met",
    "approvalNote": null,
    "price": 29.99,
    "billingCycle": "monthly"
  }
]
```

**Error (400 Bad Request):**
```json
{
  "error": "Invalid status",
  "message": "Status must be one of: pending, approved, rejected"
}
```

**Notes:**
- If no status filter, return all
- Paginate results
- Include all timestamp and admin info

---

### 7. Approve Subscription

**Endpoint:**
```
PATCH /admin/subscriptions/{subscriptionId}/approve
Authorization: Bearer {token}
Content-Type: application/json
```

**Path Parameters:**
```
{subscriptionId} - Subscription ID (e.g., "sub_001")
```

**Request:**
```json
{
  "note": "Approved for premium access"
}
```

**Note:** The `note` field is optional.

**Response (200 OK):**
```json
{
  "subscriptionId": "sub_001",
  "userId": "user_123",
  "userName": "John Doe",
  "userEmail": "john@example.com",
  "plan": "monthly",
  "status": "approved",
  "requestedDate": "2024-04-18T08:20:00Z",
  "approvedDate": "2024-04-21T10:15:00Z",
  "rejectedDate": null,
  "approvedBy": "admin@easyfit.com",
  "rejectedBy": null,
  "rejectionReason": null,
  "approvalNote": "Approved for premium access",
  "price": 29.99,
  "billingCycle": "monthly"
}
```

**Errors:**

**(409 Conflict)** - Subscription already approved
```json
{
  "error": "Subscription already approved",
  "message": "Cannot approve an already approved subscription"
}
```

**(404 Not Found)** - Subscription not found
```json
{
  "error": "Subscription not found",
  "message": "Subscription with ID 'sub_001' does not exist"
}
```

**Side Effects:**
- Update subscription status to "approved"
- Set `approvedDate` to current timestamp
- Set `approvedBy` to admin email
- Optionally: Send notification to user
- Optionally: Trigger subscription activation workflow

---

### 8. Reject Subscription

**Endpoint:**
```
PATCH /admin/subscriptions/{subscriptionId}/reject
Authorization: Bearer {token}
Content-Type: application/json
```

**Path Parameters:**
```
{subscriptionId} - Subscription ID (e.g., "sub_001")
```

**Request:**
```json
{
  "reason": "Age requirement not met"
}
```

**Note:** The `reason` field is **required**.

**Response (200 OK):**
```json
{
  "subscriptionId": "sub_001",
  "userId": "user_123",
  "userName": "John Doe",
  "userEmail": "john@example.com",
  "plan": "monthly",
  "status": "rejected",
  "requestedDate": "2024-04-18T08:20:00Z",
  "approvedDate": null,
  "rejectedDate": "2024-04-21T10:15:00Z",
  "approvedBy": null,
  "rejectedBy": "admin@easyfit.com",
  "rejectionReason": "Age requirement not met",
  "approvalNote": null,
  "price": 29.99,
  "billingCycle": "monthly"
}
```

**Errors:**

**(400 Bad Request)** - Missing reason
```json
{
  "error": "Missing required field",
  "message": "Field 'reason' is required"
}
```

**(409 Conflict)** - Subscription already rejected
```json
{
  "error": "Subscription already rejected",
  "message": "Cannot reject an already rejected subscription"
}
```

**(404 Not Found)** - Subscription not found
```json
{
  "error": "Subscription not found",
  "message": "Subscription with ID 'sub_001' does not exist"
}
```

**Side Effects:**
- Update subscription status to "rejected"
- Set `rejectedDate` to current timestamp
- Set `rejectedBy` to admin email
- Store rejection reason
- Optionally: Send notification to user explaining rejection
- Optionally: Disable user from re-requesting for X days

---

## Error Response Format

All errors follow this format:

```json
{
  "error": "Error Type",
  "message": "Human-readable error message",
  "statusCode": 400,
  "timestamp": "2024-04-21T10:15:00Z"
}
```

### Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request succeeded |
| 201 | Created - Resource created |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid/missing token |
| 403 | Forbidden - No permission |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Invalid state for operation |
| 500 | Internal Server Error |

---

## Request/Response Examples

### Complete Login Flow

**Request:**
```bash
curl -X POST https://parkmitra.com/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@easyfit.com",
    "password": "admin123456"
  }'
```

**Response:**
```json
{
  "adminId": "admin_001",
  "name": "Sarah Johnson",
  "email": "admin@easyfit.com",
  "role": "admin",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_abc123...",
  "profileImage": null,
  "permissions": ["view_users", "approve_subscriptions"]
}
```

### Complete Approval Flow

**1. Get pending subscriptions:**
```bash
curl -X GET "https://parkmitra.com/api/admin/subscriptions?status=pending" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**2. Approve one:**
```bash
curl -X PATCH "https://parkmitra.com/api/admin/subscriptions/sub_001/approve" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "note": "Approved for premium access"
  }'
```

---

## Validation Rules

### Email
- Must be valid email format
- Must be lowercase
- Must be unique for new admin

### Password
- Minimum 8 characters
- For admin login, can be simple (improve for security)

### Subscription Fields
- `plan`: One of [monthly, yearly]
- `status`: One of [pending, approved, rejected]
- `price`: Must be > 0
- `billingCycle`: One of [monthly, yearly]

### Search
- Case-insensitive
- Supports partial matches
- Works on name and email

### Pagination
- `page` must be >= 1
- `limit` should be between 1 and 100
- Default limit: 20

---

## Rate Limiting (Recommended)

- Login: 5 attempts per 15 minutes
- General endpoints: 100 requests per minute
- Search: 30 requests per minute

---

## Deployment Checklist

- [ ] All endpoints implemented
- [ ] Error handling for edge cases
- [ ] Database queries optimized
- [ ] Input validation implemented
- [ ] Authentication/Authorization verified
- [ ] CORS headers configured
- [ ] Rate limiting configured
- [ ] Logging implemented
- [ ] Error tracking (Sentry/etc) configured
- [ ] Database backups configured
- [ ] API documentation published
- [ ] Load testing completed

---

## Testing

### Test Cases for Each Endpoint

1. **Valid request** → 200 response with correct data
2. **Invalid token** → 401 response
3. **Missing token** → 401 response
4. **Invalid parameters** → 400 response
5. **Resource not found** → 404 response
6. **Rate limit exceeded** → 429 response

### Example Test Scenarios

```bash
# Test 1: Valid login
POST /admin/login
{"email": "admin@easyfit.com", "password": "admin123456"}
Expected: 200 with token

# Test 2: Invalid password
POST /admin/login
{"email": "admin@easyfit.com", "password": "wrong"}
Expected: 401

# Test 3: Get users with invalid token
GET /admin/users
Authorization: Bearer invalid_token
Expected: 401

# Test 4: Approve non-existent subscription
PATCH /admin/subscriptions/invalid_id/approve
Expected: 404
```

---

## Notes for Backend Developers

1. **Token Generation**: Use JWT with 24-hour expiry
2. **Refresh Token**: Separate long-lived token for rotation
3. **Date Format**: Always use ISO-8601 format (UTC timezone)
4. **Sorting**: Default sort by date (newest first)
5. **Filtering**: Support case-insensitive search
6. **Pagination**: Important for large datasets
7. **Notifications**: Consider async email/SMS after approval/rejection
8. **Audit Log**: Log all admin actions (approve, reject, view)
9. **Database**: Ensure proper indexing on user_id, subscription_status
10. **Security**: Validate and sanitize all inputs

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-04-21 | Initial API contract |

---

**Last Updated**: April 21, 2024
**Status**: ✅ Ready for Implementation
