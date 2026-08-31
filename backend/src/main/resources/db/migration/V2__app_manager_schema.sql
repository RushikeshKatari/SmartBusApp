create table system_configs (
    id uuid primary key,
    config_key varchar(255) unique not null,
    config_value varchar(1024) not null,
    description varchar(255),
    updated_at timestamptz not null default now(),
    updated_by varchar(255)
);

-- Insert some default configurations
insert into system_configs (id, config_key, config_value, description) 
values (gen_random_uuid(), 'google_maps_api_key', 'AIzaSy_DEFAULT_KEY', 'API key for Google Maps integration');

insert into system_configs (id, config_key, config_value, description) 
values (gen_random_uuid(), 'stripe_secret_key', 'sk_test_DEFAULT_KEY', 'Secret key for Stripe billing');
