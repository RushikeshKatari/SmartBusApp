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
    private static final String LEGACY_SEED_PASSWORD_HASH =
            "$2a$10$e8eM24zIeGzCj/dY2i0W7ep0o48o/FkGj0Z2kYgE7G2sC3hC3a42C";
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
        ensureBootstrapUser(bootstrapUsername, bootstrapPassword, "Application Manager", "APP_MANAGER");
        ensureBootstrapUser(hodUsername, hodPassword, "Head of Department", "HOD");
        ensureBootstrapUser(adminUsername, adminPassword, "Transport Administrator", "ADMIN");
        ensureBootstrapUser(inchargeUsername, inchargePassword, "Meera Singh (Incharge)", "INCHARGE");
        ensureBootstrapUser(studentUsername, studentPassword, "Aarav Sharma (Student)", "STUDENT");
    }

    private void ensureBootstrapUser(String username, String password, String displayName, String role) {
        AppUser user = users.findByUsernameIgnoreCase(username).orElse(null);
        if (user == null) {
            user = new AppUser();
            user.id = UUID.randomUUID();
            user.username = username;
            user.passwordHash = encoder.encode(password);
            user.displayName = displayName;
            user.role = role;
            user.active = true;
            user.createdAt = Instant.now();
            users.save(user);
        } else if (LEGACY_SEED_PASSWORD_HASH.equals(user.passwordHash)) {
            // V10 used a placeholder BCrypt value that never matched the documented
            // demo passwords. Repair only this known placeholder; leave real/custom
            // passwords untouched on every subsequent startup.
            user.passwordHash = encoder.encode(password);
            user.active = true;
            users.save(user);
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
