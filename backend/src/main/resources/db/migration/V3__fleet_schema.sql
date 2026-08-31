create table routes (
    id uuid primary key,
    name varchar(255) not null,
    start_location varchar(255),
    end_location varchar(255)
);

create table buses (
    id uuid primary key,
    registration_number varchar(255) not null,
    capacity int not null,
    route_id uuid references routes(id),
    driver_name varchar(255),
    driver_phone varchar(255)
);

create table stops (
    id uuid primary key,
    route_id uuid not null references routes(id),
    name varchar(255) not null,
    latitude float8,
    longitude float8,
    stop_order int not null
);
