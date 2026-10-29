update system_configs
set config_key = 'osrm_base_url',
    config_value = 'https://router.project-osrm.org',
    description = 'OSRM-compatible routing service base URL'
where config_key = 'google_maps_api_key';
