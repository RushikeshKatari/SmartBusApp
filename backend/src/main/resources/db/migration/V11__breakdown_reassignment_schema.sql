-- V11__breakdown_reassignment_schema.sql

create table if not exists breakdown_events (
    id uuid primary key,
    broken_bus_id uuid not null references buses(id) on delete cascade,
    broken_bus_number varchar(64) not null,
    incharge_name varchar(160),
    breakdown_reason varchar(255) not null,
    breakdown_location varchar(255) not null,
    latitude float8,
    longitude float8,
    stranded_students_count int not null default 0,
    assigned_pickup_bus_id uuid references buses(id),
    assigned_pickup_bus_number varchar(64),
    assigned_pickup_driver varchar(160),
    assigned_pickup_driver_phone varchar(64),
    status varchar(32) not null default 'ACTIVE_REROUTING', -- ACTIVE_REROUTING, COMPLETED, CANCELLED
    detour_distance_km float8 default 0,
    detour_eta_minutes int default 0,
    created_at timestamptz not null default now(),
    resolved_at timestamptz
);

create table if not exists breakdown_diverted_stops (
    id uuid primary key,
    breakdown_id uuid not null references breakdown_events(id) on delete cascade,
    stop_id uuid references stops(id),
    stop_name varchar(255) not null,
    latitude float8 not null,
    longitude float8 not null,
    stop_sequence int not null,
    estimated_pickup_time varchar(32),
    is_picked_up boolean not null default false
);

create index if not exists breakdown_events_status_idx on breakdown_events(status, created_at desc);
create index if not exists breakdown_diverted_stops_event_idx on breakdown_diverted_stops(breakdown_id, stop_sequence);
