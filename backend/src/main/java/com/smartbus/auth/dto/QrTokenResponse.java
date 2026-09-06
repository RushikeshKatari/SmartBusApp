package com.smartbus.auth.dto;
import java.time.Instant;
import java.util.UUID;
public record QrTokenResponse(UUID token, Instant expiresAt) {}
