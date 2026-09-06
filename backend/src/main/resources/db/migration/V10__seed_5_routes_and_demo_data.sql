-- V10__seed_5_routes_and_demo_data.sql

-- 1. App Users for all roles
insert into app_users (id, username, password_hash, display_name, role, active, created_at)
values 
    (gen_random_uuid(), 'superadmin', '$2a$10$e8eM24zIeGzCj/dY2i0W7ep0o48o/FkGj0Z2kYgE7G2sC3hC3a42C', 'Application Manager', 'APP_MANAGER', true, now()),
    (gen_random_uuid(), 'admin', '$2a$10$e8eM24zIeGzCj/dY2i0W7ep0o48o/FkGj0Z2kYgE7G2sC3hC3a42C', 'Transport Administrator', 'ADMIN', true, now()),
    (gen_random_uuid(), 'incharge', '$2a$10$e8eM24zIeGzCj/dY2i0W7ep0o48o/FkGj0Z2kYgE7G2sC3hC3a42C', 'Meera Singh (Incharge)', 'INCHARGE', true, now()),
    (gen_random_uuid(), 'hod', '$2a$10$e8eM24zIeGzCj/dY2i0W7ep0o48o/FkGj0Z2kYgE7G2sC3hC3a42C', 'Head of Department (CSE)', 'HOD', true, now()),
    (gen_random_uuid(), 'student', '$2a$10$e8eM24zIeGzCj/dY2i0W7ep0o48o/FkGj0Z2kYgE7G2sC3hC3a42C', 'Aarav Sharma (Student)', 'STUDENT', true, now())
on conflict (username) do nothing;

-- 2. Seed 5 Bus Routes (~1 km stop spacing)
insert into routes (id, name, start_location, end_location) values
    ('11111111-1111-1111-1111-111111111111', 'Route 1 - North Campus Express', 'North Terminal', 'Campus Central Gate'),
    ('22222222-2222-2222-2222-222222222222', 'Route 2 - West City Connector', 'West Metro Station', 'Campus Central Gate'),
    ('33333333-3333-3333-3333-333333333333', 'Route 3 - South Campus Loop', 'South Ring Junction', 'Campus Central Gate'),
    ('44444444-4444-4444-4444-444444444444', 'Route 4 - East Corridor Line', 'East Technology Park', 'Campus Central Gate'),
    ('55555555-5555-5555-5555-555555555555', 'Route 5 - Outer Ring Shuttle', 'Suburban Heights', 'Campus Central Gate')
on conflict (id) do nothing;

-- 3. Seed 5 Buses assigned to routes
insert into buses (id, registration_number, capacity, route_id, driver_name, driver_phone) values
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'KA-01-EQ-1004', 50, '11111111-1111-1111-1111-111111111111', 'Ravi Kumar', '+91 98765 43210'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'KA-01-EQ-1012', 55, '22222222-2222-2222-2222-222222222222', 'Imran Khan', '+91 87654 32109'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'KA-01-EQ-1009', 45, '33333333-3333-3333-3333-333333333333', 'Nisha Patel', '+91 76543 21098'),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'KA-01-EQ-1002', 50, '44444444-4444-4444-4444-444444444444', 'Suresh Rao', '+91 65432 10987'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'KA-01-EQ-1017', 40, '55555555-5555-5555-5555-555555555555', 'Priya Rao', '+91 54321 09876')
on conflict (id) do nothing;

-- 4. Seed Stops for all 5 Routes (~1 km apart)
-- Route 1: North Campus Express (5.2 km)
insert into stops (id, route_id, name, latitude, longitude, stop_order) values
    (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'North Terminal Gate', 12.9800, 77.5800, 1),
    (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Library Circle (1 km)', 12.9730, 77.5840, 2),
    (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Tech Park Gate (2 km)', 12.9660, 77.5880, 3),
    (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'North Hostel Block (3 km)', 12.9590, 77.5920, 4),
    (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Sports Complex (4 km)', 12.9520, 77.5960, 5),
    (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Campus Central Gate (5.2 km)', 12.9450, 77.6000, 6);

-- Route 2: West City Connector (4.8 km)
insert into stops (id, route_id, name, latitude, longitude, stop_order) values
    (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'West Metro Station', 12.9450, 77.5500, 1),
    (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'City Market Junction (1.1 km)', 12.9450, 77.5620, 2),
    (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'West Hostel A (2.2 km)', 12.9450, 77.5740, 3),
    (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'Innovation Square (3.4 km)', 12.9450, 77.5860, 4),
    (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'Campus Central Gate (4.8 km)', 12.9450, 77.6000, 5);

-- Route 3: South Campus Loop (4.9 km)
insert into stops (id, route_id, name, latitude, longitude, stop_order) values
    (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'South Ring Junction', 12.9100, 77.6000, 1),
    (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'Medical College Block (1.0 km)', 12.9190, 77.6000, 2),
    (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'Research Park (2.1 km)', 12.9280, 77.6000, 3),
    (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'Botanical Garden (3.2 km)', 12.9370, 77.6000, 4),
    (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'Campus Central Gate (4.9 km)', 12.9450, 77.6000, 5);

-- Route 4: East Corridor Line (5.1 km)
insert into stops (id, route_id, name, latitude, longitude, stop_order) values
    (gen_random_uuid(), '44444444-4444-4444-4444-444444444444', 'East Tech Terminal', 12.9450, 77.6500, 1),
    (gen_random_uuid(), '44444444-4444-4444-4444-444444444444', 'Engineering Complex (1.2 km)', 12.9450, 77.6380, 2),
    (gen_random_uuid(), '44444444-4444-4444-4444-444444444444', 'East Lake Point (2.4 km)', 12.9450, 77.6260, 3),
    (gen_random_uuid(), '44444444-4444-4444-4444-444444444444', 'Polytechnic Block (3.7 km)', 12.9450, 77.6140, 4),
    (gen_random_uuid(), '44444444-4444-4444-4444-444444444444', 'Campus Central Gate (5.1 km)', 12.9450, 77.6000, 5);

-- Route 5: Outer Ring Shuttle (5.5 km)
insert into stops (id, route_id, name, latitude, longitude, stop_order) values
    (gen_random_uuid(), '55555555-5555-5555-5555-555555555555', 'Suburban Heights Station', 12.9750, 77.6350, 1),
    (gen_random_uuid(), '55555555-5555-5555-5555-555555555555', 'Innovation Square East (1.0 km)', 12.9680, 77.6280, 2),
    (gen_random_uuid(), '55555555-5555-5555-5555-555555555555', 'Faculty Enclave (2.2 km)', 12.9610, 77.6210, 3),
    (gen_random_uuid(), '55555555-5555-5555-5555-555555555555', 'Observatory Circle (3.3 km)', 12.9540, 77.6140, 4),
    (gen_random_uuid(), '55555555-5555-5555-5555-555555555555', 'Auditorium Junction (4.4 km)', 12.9480, 77.6070, 5),
    (gen_random_uuid(), '55555555-5555-5555-5555-555555555555', 'Campus Central Gate (5.5 km)', 12.9450, 77.6000, 6);

-- 5. Seed Students with assigned buses
insert into students (id, roll_no, name, department, year, phone, bus_id, status) values
    ('99999999-9999-9999-9999-999999999901', 'CS2024-117', 'Aarav Sharma', 'Computer Science & Engineering', 3, '+91 98765 43210', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ACTIVE'),
    ('99999999-9999-9999-9999-999999999902', 'EC2024-042', 'Priya Patel', 'Electronics & Communication', 2, '+91 87654 32109', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'ACTIVE'),
    ('99999999-9999-9999-9999-999999999903', 'ME2024-089', 'Rohan Verma', 'Mechanical Engineering', 4, '+91 76543 21098', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'ACTIVE'),
    ('99999999-9999-9999-9999-999999999904', 'CS2024-118', 'Diya Nair', 'Computer Science & Engineering', 3, '+91 65432 10987', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ACTIVE'),
    ('99999999-9999-9999-9999-999999999905', 'CI2024-099', 'Kiran Shah', 'Civil Engineering', 2, '+91 54321 09876', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'ACTIVE')
on conflict (roll_no) do nothing;
