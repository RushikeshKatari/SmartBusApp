alter table academic_roster_students
    alter column attendance_percent type float8 using attendance_percent::float8;
