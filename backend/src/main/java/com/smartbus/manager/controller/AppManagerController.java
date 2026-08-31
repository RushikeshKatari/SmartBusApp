package com.smartbus.manager.controller;

import com.smartbus.manager.dto.ManagerLoginRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.Map;

import com.smartbus.manager.repository.SystemConfigRepository;
import com.smartbus.manager.entity.SystemConfig;

@RestController
@RequestMapping("/api/manager")
public class AppManagerController {

    private final SecretKey key;
    private final long jwtTtlHours;
    private final SystemConfigRepository configs;

    public AppManagerController(
            @Value("${smartbus.jwt-secret}") String secret,
            @Value("${smartbus.jwt-ttl-hours}") long jwtTtlHours,
            SystemConfigRepository configs) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
        this.jwtTtlHours = jwtTtlHours;
        this.configs = configs;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody ManagerLoginRequest request) {
        // In a real app, verify against a database of Managers.
        // For demonstration, hardcoding the superadmin credentials.
        if ("superadmin".equals(request.username()) && "admin123".equals(request.password())) {
            String jwt = Jwts.builder()
                .subject("app-manager-id")
                .claim("role", "APP_MANAGER")
                .issuedAt(Date.from(Instant.now()))
                .expiration(Date.from(Instant.now().plus(jwtTtlHours, ChronoUnit.HOURS)))
                .signWith(key)
                .compact();
            
            return ResponseEntity.ok(Map.of("token", jwt, "role", "APP_MANAGER"));
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }
    
    @GetMapping("/metrics")
    public ResponseEntity<?> getMetrics(@RequestParam(defaultValue = "today") String timeframe) {
        int activeUsers = 1450;
        String billing = "$12.50";
        int apiCalls = 4500;
        
        if ("weekly".equals(timeframe)) {
            activeUsers = 1600; billing = "$84.00"; apiCalls = 31500;
        } else if ("monthly".equals(timeframe)) {
            activeUsers = 1800; billing = "$124.50"; apiCalls = 135000;
        }
        
        return ResponseEntity.ok(Map.of(
            "activeUsers", activeUsers,
            "billingEstimate", billing,
            "apiCalls", apiCalls,
            "status", "HEALTHY",
            "timeframe", timeframe
        ));
    }

    @GetMapping("/billing/services")
    public ResponseEntity<?> getServiceBilling() {
        return ResponseEntity.ok(java.util.List.of(
            Map.of("service", "Google Maps API", "cost", 45.20, "calls", 12500, "status", "active"),
            Map.of("service", "PostgreSQL Database", "cost", 20.00, "calls", 450000, "status", "active"),
            Map.of("service", "Firebase Notifications", "cost", 5.50, "calls", 3200, "status", "active"),
            Map.of("service", "Stripe Fees", "cost", 12.00, "calls", 150, "status", "active"),
            Map.of("service", "Redis Cache", "cost", 10.00, "calls", 850000, "status", "active")
        ));
    }

    @GetMapping("/configs")
    public ResponseEntity<?> getConfigs() {
        return ResponseEntity.ok(configs.findAll());
    }

    @PostMapping("/configs")
    public ResponseEntity<?> updateConfig(@RequestBody SystemConfig config) {
        SystemConfig existing = configs.findByConfigKey(config.configKey).orElse(config);
        if (existing.id != config.id) {
            existing.configValue = config.configValue;
            existing.description = config.description;
            existing.updatedAt = Instant.now();
        }
        configs.save(existing);
        return ResponseEntity.ok(existing);
    }
}
