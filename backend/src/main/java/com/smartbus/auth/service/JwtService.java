package com.smartbus.auth.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
    private final SecretKey key;
    private final long ttlHours;

    public JwtService(@Value("${smartbus.jwt-secret}") String secret,
                      @Value("${smartbus.jwt-ttl-hours}") long ttlHours) {
        if (secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalArgumentException("JWT_SECRET must be at least 32 bytes");
        }
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.ttlHours = ttlHours;
    }

    public String issue(String subject, String role, String sessionId) {
        Instant now = Instant.now();
        var builder = Jwts.builder().subject(subject).claim("role", role)
                .issuedAt(Date.from(now)).expiration(Date.from(now.plus(ttlHours, ChronoUnit.HOURS)));
        if (sessionId != null) builder.claim("sessionId", sessionId);
        return builder.signWith(key).compact();
    }

    public Claims parse(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }
}
