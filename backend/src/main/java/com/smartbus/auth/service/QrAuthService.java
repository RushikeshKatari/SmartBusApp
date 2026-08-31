package com.smartbus.auth.service;

import com.smartbus.auth.dto.*;
import com.smartbus.auth.entity.*;
import com.smartbus.auth.repository.*;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;

@Service
public class QrAuthService {
    
    private final LoginQrTokenRepository tokens;
    private final AuthSessionRepository sessions;
    private final SecretKey key;
    private final long jwtTtlHours;

    public QrAuthService(LoginQrTokenRepository tokens, 
                         AuthSessionRepository sessions,
                         @Value("${smartbus.jwt-secret}") String secret,
                         @Value("${smartbus.jwt-ttl-hours}") long jwtTtlHours) {
        this.tokens = tokens;
        this.sessions = sessions;
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
        this.jwtTtlHours = jwtTtlHours;
    }

    @Transactional
    public AuthResponse login(QrLoginRequest request) {
        UUID value;
        try {
            value = UUID.fromString(request.token());
        } catch(IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid login QR");
        }
        
        LoginQrToken qr = tokens.findByToken(value)
                .orElseThrow(() -> new IllegalArgumentException("Invalid login QR"));
                
        if (qr.used) {
            throw new IllegalStateException("This login QR has already been used");
        }
        if (!"ACTIVE".equals(qr.student.status) || !qr.student.telegramEnabled) {
            throw new IllegalStateException("Student access is disabled");
        }
        
        qr.used = true;
        qr.usedAt = Instant.now();
        
        // Deactivate prior session
        sessions.deactivateAllForStudent(qr.student);
        
        // Persist the new session
        AuthSession session = new AuthSession();
        session.id = UUID.randomUUID();
        session.student = qr.student;
        session.deviceId = request.deviceId();
        session.platform = request.platform();
        session.active = true;
        session.createdAt = Instant.now();
        session.lastSeenAt = Instant.now();
        sessions.save(session);
        
        // Sign JWT
        String jwt = Jwts.builder()
                .subject(qr.student.id.toString())
                .claim("role", "STUDENT")
                .claim("sessionId", session.id.toString())
                .issuedAt(Date.from(Instant.now()))
                .expiration(Date.from(Instant.now().plus(jwtTtlHours, ChronoUnit.HOURS)))
                .signWith(key)
                .compact();

        return new AuthResponse(jwt, new AuthResponse.StudentProfile(
                qr.student.name, 
                qr.student.rollNo, 
                qr.student.department));
    }
}
