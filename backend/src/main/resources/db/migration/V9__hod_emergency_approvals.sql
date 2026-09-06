alter table emergency_attendance_reports
    add column attendance_approved_at timestamptz,
    add column permission_granted_at timestamptz;
