package com.smartbus.auth.service;

import com.smartbus.auth.entity.AppUser;
import com.smartbus.auth.repository.AppUserRepository;
import jakarta.annotation.PostConstruct;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class UserAuthService {
    private final AppUserRepository users; private final PasswordEncoder encoder; private final JwtService jwt;
    @Value("${smartbus.bootstrap-manager-username}") private String bootstrapUsername;
    @Value("${smartbus.bootstrap-manager-password}") private String bootstrapPassword;
    @Value("${smartbus.bootstrap-hod-username}") private String hodUsername;
    @Value("${smartbus.bootstrap-hod-password}") private String hodPassword;
    @Value("${smartbus.bootstrap-admin-username:admin}") private String adminUsername;
    @Value("${smartbus.bootstrap-admin-password:admin123}") private String adminPassword;
    @Value("${smartbus.bootstrap-incharge-username:incharge}") private String inchargeUsername;
    @Value("${smartbus.bootstrap-incharge-password:incharge123}") private String inchargePassword;
    @Value("${smartbus.bootstrap-student-username:student}") private String studentUsername;
    @Value("${smartbus.bootstrap-student-password:student123}") private String studentPassword;

    public UserAuthService(AppUserRepository users, PasswordEncoder encoder, JwtService jwt) { this.users=users; this.encoder=encoder; this.jwt=jwt; }
    @PostConstruct void bootstrapManager() {
        if (users.findByUsernameIgnoreCase(bootstrapUsername).isEmpty()) {
            AppUser user = new AppUser(); user.id=UUID.randomUUID(); user.username=bootstrapUsername;
            user.passwordHash=encoder.encode(bootstrapPassword); user.displayName="Application Manager";
            user.role="APP_MANAGER"; user.active=true; user.createdAt=Instant.now(); users.save(user);
        }
        if (users.findByUsernameIgnoreCase(hodUsername).isEmpty()) {
            AppUser user = new AppUser(); user.id=UUID.randomUUID(); user.username=hodUsername;
            user.passwordHash=encoder.encode(hodPassword); user.displayName="Head of Department";
            user.role="HOD"; user.active=true; user.createdAt=Instant.now(); users.save(user);
        }
        if (users.findByUsernameIgnoreCase(adminUsername).isEmpty()) {
            AppUser user = new AppUser(); user.id=UUID.randomUUID(); user.username=adminUsername;
            user.passwordHash=encoder.encode(adminPassword); user.displayName="Transport Administrator";
            user.role="ADMIN"; user.active=true; user.createdAt=Instant.now(); users.save(user);
        }
        if (users.findByUsernameIgnoreCase(inchargeUsername).isEmpty()) {
            AppUser user = new AppUser(); user.id=UUID.randomUUID(); user.username=inchargeUsername;
            user.passwordHash=encoder.encode(inchargePassword); user.displayName="Meera Singh (Incharge)";
            user.role="INCHARGE"; user.active=true; user.createdAt=Instant.now(); users.save(user);
        }
        if (users.findByUsernameIgnoreCase(studentUsername).isEmpty()) {
            AppUser user = new AppUser(); user.id=UUID.randomUUID(); user.username=studentUsername;
            user.passwordHash=encoder.encode(studentPassword); user.displayName="Aarav Sharma (Student)";
            user.role="STUDENT"; user.active=true; user.createdAt=Instant.now(); users.save(user);
        }
    }
    public Map<String,String> login(String username, String password, String requiredRole) {
        AppUser user=users.findByUsernameIgnoreCase(username).filter(u -> u.active)
            .filter(u -> requiredRole == null || requiredRole.equals(u.role))
            .filter(u -> encoder.matches(password, u.passwordHash))
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));
        return Map.of("token", jwt.issue(user.id.toString(), user.role, null), "role", user.role, "username", user.username, "displayName", user.displayName);
    }
}
