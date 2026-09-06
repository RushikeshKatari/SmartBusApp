create table emergency_attendance_reports (
    id uuid primary key,
    emergency_id uuid references emergency_reports(id) on delete set null,
    bus_number varchar(64) not null,
    bus_name varchar(255),
    incharge_name varchar(160),
    reason varchar(255) not null,
    location varchar(255),
    status varchar(32) not null default 'SENT_TO_TRANSPORT',
    sent_to_transport_at timestamptz not null default now(),
    sent_to_hod_at timestamptz,
    sent_to_hod_by uuid references app_users(id)
);

create table emergency_report_students (
    id uuid primary key,
    report_id uuid not null references emergency_attendance_reports(id) on delete cascade,
    roll_number varchar(64) not null,
    student_name varchar(160) not null,
    department varchar(120),
    scanned_at timestamptz not null default now()
);
create index emergency_attendance_reports_status_idx on emergency_attendance_reports(status, sent_to_transport_at desc);
