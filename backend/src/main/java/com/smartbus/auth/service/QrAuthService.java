package com.smartbus.auth.service;

import com.smartbus.auth.dto.*;
import com.smartbus.auth.entity.*;
import com.smartbus.auth.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;

@Service
public class QrAuthService {
    
    private final LoginQrTokenRepository tokens;
    private final AuthSessionRepository sessions;
    private final StudentRepository students;
    private final JwtService jwtService;

    public QrAuthService(LoginQrTokenRepository tokens, 
                         AuthSessionRepository sessions,
                         StudentRepository students,
                         JwtService jwtService) {
        this.tokens = tokens;
        this.sessions = sessions;
        this.students = students;
        this.jwtService = jwtService;
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
        if (qr.expiresAt.isBefore(Instant.now())) {
            throw new IllegalStateException("This login QR has expired");
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
        String jwt = jwtService.issue(qr.student.id.toString(), "STUDENT", session.id.toString());

        return new AuthResponse(jwt, new AuthResponse.StudentProfile(
                qr.student.name, 
                qr.student.rollNo, 
                qr.student.department));
    }

    /** Issues a one-time login token. Tokens are deliberately opaque UUIDs, not JWTs. */
    @Transactional
    public QrTokenResponse issue(UUID studentId, long telegramChatId) {
        tokens.invalidateUnused(studentId);
        LoginQrToken qr = new LoginQrToken();
        qr.id = UUID.randomUUID();
        qr.student = students.findById(studentId).orElseThrow(() -> new IllegalArgumentException("Student not found"));
        qr.token = UUID.randomUUID(); qr.telegramChatId = telegramChatId;
        qr.createdAt = Instant.now(); qr.expiresAt = qr.createdAt.plus(10, ChronoUnit.MINUTES); qr.used = false;
        tokens.save(qr);
        return new QrTokenResponse(qr.token, qr.expiresAt);
    }
}
