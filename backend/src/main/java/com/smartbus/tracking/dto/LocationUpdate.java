package com.smartbus.tracking.dto;

import java.util.UUID;

public record LocationUpdate(UUID busId, double latitude, double longitude, double speed, long timestamp) {}
