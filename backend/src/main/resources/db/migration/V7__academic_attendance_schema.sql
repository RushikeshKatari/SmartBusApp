create table academic_sections (
    id uuid primary key,
    academic_year integer not null check (academic_year between 1 and 4),
    specialization varchar(160) not null,
    section_number varchar(32) not null,
    created_at timestamptz not null default now(),
    unique (academic_year, specialization, section_number)
);

create table academic_roster_students (
    id uuid primary key,
    section_id uuid not null references academic_sections(id) on delete cascade,
    student_name varchar(160) not null,
    roll_number varchar(64) not null,
    attendance_percent numeric(5,2) not null default 0 check (attendance_percent between 0 and 100),
    unique (section_id, roll_number)
);
create index academic_roster_section_idx on academic_roster_students(section_id);
