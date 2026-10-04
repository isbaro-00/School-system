# Phase 13 — Notifications

Added:
- Notifications dashboard
- Create notification
- Notification types:
  - Announcement
  - Fee
  - Exam
  - Attendance
  - System
- My Notifications screen
- Read/unread state
- Mark as read
- Delete notification

Database tables expected:
- notifications
- user_notifications

Important production notes:
1. Creating a notification and delivering it to every target user are separate operations.
2. This phase provides the UI/service foundation. Target-recipient assignment should be handled by a secure backend/Edge Function according to school role, class, student, parent, or teacher.
3. Do not let the Flutter client bypass RLS to insert arbitrary user_notifications.
4. Push notifications (FCM/APNs) can be added after in-app notifications are working.
5. Verify exact notification column names against the SQL executed in Supabase before production.
