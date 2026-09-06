create table app_users (
    id uuid primary key,
    username varchar(100) unique not null,
    password_hash varchar(255) not null,
    display_name varchar(160) not null,
    role varchar(32) not null,
    active boolean not null default true,
    created_at timestamptz not null default now()
);

create table bus_locations (
    bus_id uuid primary key references buses(id) on delete cascade,
    latitude float8 not null,
    longitude float8 not null,
    speed float8 not null default 0,
    recorded_at timestamptz not null default now()
);

create table attendance_records (
    id uuid primary key,
    student_id uuid not null references students(id),
    bus_id uuid references buses(id),
    scanned_by uuid references app_users(id),
    scanned_at timestamptz not null default now(),
    attendance_date date not null default current_date,
    status varchar(16) not null default 'BOARDED'
);
create unique index attendance_once_per_day_idx on attendance_records(student_id, attendance_date);

create table emergency_reports (
    id uuid primary key,
    bus_id uuid references buses(id),
    reported_by uuid references app_users(id),
    type varchar(64) not null,
    details varchar(2000),
    location varchar(255),
    status varchar(16) not null default 'OPEN',
    created_at timestamptz not null default now(),
    resolved_at timestamptz
);

create table notifications (
    id uuid primary key,
    title varchar(255) not null,
    message varchar(2000) not null,
    audience varchar(32) not null,
    created_by uuid references app_users(id),
    created_at timestamptz not null default now()
);
