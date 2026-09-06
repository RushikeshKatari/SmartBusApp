package com.smartbus.auth.controller;

import com.smartbus.auth.dto.*;
import com.smartbus.auth.service.QrAuthService;
import com.smartbus.auth.service.UserAuthService;
import jakarta.validation.Valid;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
public class AuthController {
    private final QrAuthService qrService;
    private final UserAuthService userAuthService;

    public AuthController(QrAuthService qrService, UserAuthService userAuthService) {
        this.qrService = qrService;
        this.userAuthService = userAuthService;
    }

    public record LoginRequest(String username, String password, String role) {}

    @PostMapping("/api/auth/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(userAuthService.login(request.username(), request.password(), request.role()));
    }

    @PostMapping("/api/auth/login/qr")
    public ResponseEntity<AuthResponse> loginWithQr(@Valid @RequestBody QrLoginRequest request) {
        return ResponseEntity.ok(qrService.login(request));
    }

    @PostMapping("/api/admin/students/{studentId}/login-qr")
    public ResponseEntity<QrTokenResponse> issueQrToken(@PathVariable UUID studentId, @RequestParam long telegramChatId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(qrService.issue(studentId, telegramChatId));
    }
}

