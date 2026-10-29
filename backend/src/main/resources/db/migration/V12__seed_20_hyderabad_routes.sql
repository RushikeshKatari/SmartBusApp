-- Twenty representative KLH Hyderabad demo corridors for breakdown simulation.
-- Coordinates are locality-level simulation points, not surveyed stop locations or road polylines.
alter table buses add column if not exists current_occupancy integer not null default 0;
alter table buses add column if not exists status varchar(24) not null default 'ACTIVE';

update routes set name='Aziz Nagar–Chilkur', start_location='Chilkur Balaji Temple', end_location='KLH Aziz Nagar Campus' where id='11111111-1111-1111-1111-111111111111';
update routes set name='Moinabad–Himayat Sagar', start_location='Moinabad Bus Stop', end_location='KLH Aziz Nagar Campus' where id='22222222-2222-2222-2222-222222222222';
update routes set name='Shankarpally–Gandipet', start_location='Shankarpally Town', end_location='KLH Aziz Nagar Campus' where id='33333333-3333-3333-3333-333333333333';
update routes set name='Kokapet–Narsingi', start_location='Kokapet SEZ', end_location='KLH Aziz Nagar Campus' where id='44444444-4444-4444-4444-444444444444';
update routes set name='Gachibowli–Nanakramguda', start_location='Gachibowli Stadium', end_location='KLH Aziz Nagar Campus' where id='55555555-5555-5555-5555-555555555555';
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000006','Kondapur–Gachibowli','Kondapur RTO','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000007','Miyapur–Hafeezpet','Miyapur Metro','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000008','Lingampally–Tellapur','Lingampally Station','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000009','Manikonda–Puppalaguda','Manikonda Marrichettu','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000010','Mehdipatnam–Narsingi','Mehdipatnam Bus Depot','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000011','Jubilee Hills–Manikonda','Jubilee Hills Checkpost','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000012','Banjara Hills–Tolichowki','Banjara Hills Road No. 12','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000013','Ameerpet–Shaikpet','Ameerpet Metro','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000014','Secunderabad–Mehdipatnam','Secunderabad Station','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000015','Uppal–Ameerpet–Campus','Uppal Metro','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000016','LB Nagar–Mehdipatnam','LB Nagar Metro','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000017','Kukatpally–Gachibowli','Kukatpally Metro','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000018','Shamshabad–Rajendranagar','Shamshabad Bus Station','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000019','Tellapur–Gandipet','Tellapur Junction','KLH Aziz Nagar Campus');
insert into routes (id,name,start_location,end_location) values ('10000000-0000-0000-0000-000000000020','Patancheru–Lingampally','Patancheru Bus Station','KLH Aziz Nagar Campus');

update buses set registration_number='SB-04', capacity=48, route_id='11111111-1111-1111-1111-111111111111', driver_name='Ravi Kumar', driver_phone='+91 98765 43210', current_occupancy=34, status='ACTIVE' where id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
update buses set registration_number='SB-12', capacity=52, route_id='22222222-2222-2222-2222-222222222222', driver_name='Imran Khan', driver_phone='+91 87654 32109', current_occupancy=35, status='ACTIVE' where id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
update buses set registration_number='SB-09', capacity=44, route_id='33333333-3333-3333-3333-333333333333', driver_name='Nisha Patel', driver_phone='+91 76543 21098', current_occupancy=24, status='ACTIVE' where id='cccccccc-cccc-cccc-cccc-cccccccccccc';
update buses set registration_number='SB-02', capacity=56, route_id='44444444-4444-4444-4444-444444444444', driver_name='Suresh Rao', driver_phone='+91 65432 10987', current_occupancy=30, status='MAINTENANCE' where id='dddddddd-dddd-dddd-dddd-dddddddddddd';
update buses set registration_number='SB-17', capacity=38, route_id='55555555-5555-5555-5555-555555555555', driver_name='Priya Rao', driver_phone='+91 54321 09876', current_occupancy=19, status='ACTIVE' where id='eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000006','SB-06',50,'10000000-0000-0000-0000-000000000006','Demo Driver 06','+91 90000 00006',35,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000007','SB-07',52,'10000000-0000-0000-0000-000000000007','Demo Driver 07','+91 90000 00007',37,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000008','SB-08',46,'10000000-0000-0000-0000-000000000008','Demo Driver 08','+91 90000 00008',31,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000009','SB-10',48,'10000000-0000-0000-0000-000000000009','Demo Driver 10','+91 90000 00010',32,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000010','SB-13',50,'10000000-0000-0000-0000-000000000010','Demo Driver 13','+91 90000 00013',34,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000011','SB-14',48,'10000000-0000-0000-0000-000000000011','Demo Driver 14','+91 90000 00014',33,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000012','SB-15',52,'10000000-0000-0000-0000-000000000012','Demo Driver 15','+91 90000 00015',36,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000013','SB-16',50,'10000000-0000-0000-0000-000000000013','Demo Driver 16','+91 90000 00016',35,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000014','SB-18',56,'10000000-0000-0000-0000-000000000014','Demo Driver 18','+91 90000 00018',41,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000015','SB-19',52,'10000000-0000-0000-0000-000000000015','Demo Driver 19','+91 90000 00019',37,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000016','SB-20',54,'10000000-0000-0000-0000-000000000016','Demo Driver 20','+91 90000 00020',39,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000017','SB-21',56,'10000000-0000-0000-0000-000000000017','Demo Driver 21','+91 90000 00021',42,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000018','SB-22',50,'10000000-0000-0000-0000-000000000018','Demo Driver 22','+91 90000 00022',35,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000019','SB-23',48,'10000000-0000-0000-0000-000000000019','Demo Driver 23','+91 90000 00023',33,'ACTIVE');
insert into buses (id,registration_number,capacity,route_id,driver_name,driver_phone,current_occupancy,status) values ('20000000-0000-0000-0000-000000000020','SB-24',56,'10000000-0000-0000-0000-000000000020','Demo Driver 24','+91 90000 00024',40,'ACTIVE');

delete from stops where route_id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', '55555555-5555-5555-5555-555555555555', '10000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000016', '10000000-0000-0000-0000-000000000017', '10000000-0000-0000-0000-000000000018', '10000000-0000-0000-0000-000000000019', '10000000-0000-0000-0000-000000000020');

-- 01. Aziz Nagar–Chilkur (SB-04)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'11111111-1111-1111-1111-111111111111','Chilkur Balaji Temple', 17.358700, 78.308500, 1),
    (gen_random_uuid(),'11111111-1111-1111-1111-111111111111','Himayat Sagar Road', 17.356000, 78.321000, 2),
    (gen_random_uuid(),'11111111-1111-1111-1111-111111111111','Aziz Nagar X Roads', 17.352000, 78.330000, 3),
    (gen_random_uuid(),'11111111-1111-1111-1111-111111111111','Aziz Nagar Main Road', 17.350500, 78.333000, 4),
    (gen_random_uuid(),'11111111-1111-1111-1111-111111111111','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'11111111-1111-1111-1111-111111111111','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 02. Moinabad–Himayat Sagar (SB-12)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'22222222-2222-2222-2222-222222222222','Moinabad Bus Stop', 17.321000, 78.315000, 1),
    (gen_random_uuid(),'22222222-2222-2222-2222-222222222222','Kethireddypally Road', 17.331000, 78.319000, 2),
    (gen_random_uuid(),'22222222-2222-2222-2222-222222222222','Chilkur Road Junction', 17.339000, 78.326000, 3),
    (gen_random_uuid(),'22222222-2222-2222-2222-222222222222','Aziz Nagar X Roads', 17.352000, 78.330000, 4),
    (gen_random_uuid(),'22222222-2222-2222-2222-222222222222','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'22222222-2222-2222-2222-222222222222','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 03. Shankarpally–Gandipet (SB-09)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'33333333-3333-3333-3333-333333333333','Shankarpally Town', 17.452000, 78.127000, 1),
    (gen_random_uuid(),'33333333-3333-3333-3333-333333333333','Mokila Junction', 17.421000, 78.207000, 2),
    (gen_random_uuid(),'33333333-3333-3333-3333-333333333333','Gandipet Lake Road', 17.390000, 78.304000, 3),
    (gen_random_uuid(),'33333333-3333-3333-3333-333333333333','Gandipet Road Junction', 17.365000, 78.347000, 4),
    (gen_random_uuid(),'33333333-3333-3333-3333-333333333333','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'33333333-3333-3333-3333-333333333333','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 04. Kokapet–Narsingi (SB-02)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'44444444-4444-4444-4444-444444444444','Kokapet SEZ', 17.390000, 78.333000, 1),
    (gen_random_uuid(),'44444444-4444-4444-4444-444444444444','Financial District Gate', 17.415000, 78.337000, 2),
    (gen_random_uuid(),'44444444-4444-4444-4444-444444444444','Narsingi Junction', 17.387600, 78.357000, 3),
    (gen_random_uuid(),'44444444-4444-4444-4444-444444444444','Gandipet Road Junction', 17.365000, 78.347000, 4),
    (gen_random_uuid(),'44444444-4444-4444-4444-444444444444','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'44444444-4444-4444-4444-444444444444','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 05. Gachibowli–Nanakramguda (SB-17)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'55555555-5555-5555-5555-555555555555','Gachibowli Stadium', 17.443600, 78.352000, 1),
    (gen_random_uuid(),'55555555-5555-5555-5555-555555555555','IIIT Hyderabad', 17.445000, 78.348000, 2),
    (gen_random_uuid(),'55555555-5555-5555-5555-555555555555','Nanakramguda Circle', 17.416000, 78.342000, 3),
    (gen_random_uuid(),'55555555-5555-5555-5555-555555555555','Narsingi Junction', 17.387600, 78.357000, 4),
    (gen_random_uuid(),'55555555-5555-5555-5555-555555555555','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'55555555-5555-5555-5555-555555555555','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 06. Kondapur–Gachibowli (SB-06)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000006','Kondapur RTO', 17.463000, 78.363000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000006','Botanical Garden Road', 17.456000, 78.365000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000006','Gachibowli Circle', 17.440000, 78.348000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000006','Nanakramguda Circle', 17.416000, 78.342000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000006','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000006','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 07. Miyapur–Hafeezpet (SB-07)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000007','Miyapur Metro', 17.496800, 78.361400, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000007','Madinaguda Junction', 17.493000, 78.350000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000007','Hafeezpet MMTS', 17.486000, 78.333000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000007','Gachibowli Circle', 17.440000, 78.348000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000007','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000007','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 08. Lingampally–Tellapur (SB-08)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000008','Lingampally Station', 17.489000, 78.316000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000008','Chandanagar Circle', 17.494000, 78.322000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000008','Tellapur Junction', 17.459000, 78.284000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000008','Osman Sagar Road', 17.390000, 78.310000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000008','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000008','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 09. Manikonda–Puppalaguda (SB-10)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000009','Manikonda Marrichettu', 17.406000, 78.389000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000009','Lanco Hills', 17.407000, 78.381000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000009','Puppalaguda Circle', 17.398000, 78.370000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000009','Narsingi Junction', 17.387600, 78.357000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000009','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000009','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 10. Mehdipatnam–Narsingi (SB-13)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000010','Mehdipatnam Bus Depot', 17.395900, 78.431200, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000010','Rethi Bowli', 17.392000, 78.420000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000010','Tolichowki X Roads', 17.400300, 78.411800, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000010','Puppalaguda Circle', 17.398000, 78.370000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000010','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000010','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 11. Jubilee Hills–Manikonda (SB-14)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000011','Jubilee Hills Checkpost', 17.423000, 78.407000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000011','Film Nagar Junction', 17.414000, 78.405000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000011','Shaikpet Nala', 17.390000, 78.390000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000011','Manikonda Gate', 17.406000, 78.375000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000011','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000011','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 12. Banjara Hills–Tolichowki (SB-15)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000012','Banjara Hills Road No. 12', 17.416800, 78.438400, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000012','Masab Tank', 17.400000, 78.456000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000012','Mehdipatnam Bus Depot', 17.395900, 78.431200, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000012','Tolichowki X Roads', 17.400300, 78.411800, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000012','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000012','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 13. Ameerpet–Shaikpet (SB-16)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000013','Ameerpet Metro', 17.437000, 78.448000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000013','Yousufguda Checkpost', 17.432000, 78.429000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000013','Jubilee Hills Checkpost', 17.423000, 78.407000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000013','Shaikpet Nala', 17.390000, 78.390000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000013','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000013','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 14. Secunderabad–Mehdipatnam (SB-18)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000014','Secunderabad Station', 17.439900, 78.498300, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000014','Paradise Circle', 17.443000, 78.487000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000014','Ameerpet Metro', 17.437000, 78.448000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000014','Mehdipatnam Bus Depot', 17.395900, 78.431200, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000014','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000014','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 15. Uppal–Ameerpet–Campus (SB-19)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000015','Uppal Metro', 17.405000, 78.559000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000015','Habsiguda Metro', 17.417000, 78.543000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000015','Tarnaka Junction', 17.428000, 78.538000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000015','Ameerpet Metro', 17.437000, 78.448000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000015','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000015','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 16. LB Nagar–Mehdipatnam (SB-20)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000016','LB Nagar Metro', 17.345700, 78.552200, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000016','Dilsukhnagar Metro', 17.368000, 78.524000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000016','Lakdikapul', 17.402000, 78.465000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000016','Mehdipatnam Bus Depot', 17.395900, 78.431200, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000016','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000016','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 17. Kukatpally–Gachibowli (SB-21)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000017','Kukatpally Metro', 17.485100, 78.409400, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000017','KPHB Colony', 17.493000, 78.399000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000017','Miyapur Metro', 17.496800, 78.361400, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000017','Gachibowli Circle', 17.440000, 78.348000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000017','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000017','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 18. Shamshabad–Rajendranagar (SB-22)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000018','Shamshabad Bus Station', 17.211000, 78.398000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000018','RGIA Approach Road', 17.240000, 78.405000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000018','Rajendranagar', 17.321000, 78.402000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000018','Attapur Ring Road', 17.365000, 78.425000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000018','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000018','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 19. Tellapur–Gandipet (SB-23)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000019','Tellapur Junction', 17.459000, 78.284000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000019','Osman Sagar Road', 17.420000, 78.293000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000019','Gandipet Lake Road', 17.390000, 78.304000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000019','Chilkur Road Junction', 17.339000, 78.326000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000019','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000019','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);

-- 20. Patancheru–Lingampally (SB-24)
insert into stops (id,route_id,name,latitude,longitude,stop_order) values
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000020','Patancheru Bus Station', 17.533000, 78.264000, 1),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000020','BHEL Township', 17.511000, 78.299000, 2),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000020','Lingampally Station', 17.489000, 78.316000, 3),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000020','Tellapur Junction', 17.459000, 78.284000, 4),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000020','TSPA Junction', 17.349500, 78.336000, 5),
    (gen_random_uuid(),'10000000-0000-0000-0000-000000000020','KLH Aziz Nagar Campus', 17.348301, 78.339918, 6);
