package com.smartbus.auth.controller;

import com.smartbus.auth.entity.AppUser;
import com.smartbus.auth.entity.Student;
import com.smartbus.auth.repository.AppUserRepository;
import com.smartbus.auth.repository.StudentRepository;
import com.smartbus.fleet.entity.Bus;
import com.smartbus.fleet.repository.BusRepository;
import com.smartbus.fleet.repository.StopRepository;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class AccountController {
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final char[] PASSWORD_CHARS =
            "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789".toCharArray();

    private final AppUserRepository users;
    private final StudentRepository students;
    private final BusRepository buses;
    private final StopRepository stops;
    private final PasswordEncoder passwordEncoder;

    public AccountController(
            AppUserRepository users,
            StudentRepository students,
            BusRepository buses,
            StopRepository stops,
            PasswordEncoder passwordEncoder) {
        this.users = users;
        this.students = students;
        this.buses = buses;
        this.stops = stops;
        this.passwordEncoder = passwordEncoder;
    }

    public record CreateAccountRequest(
            String username,
            String displayName,
            String role,
            String password,
            String rollNumber,
            String department,
            Integer academicYear,
            String phone,
            String busNumber) {}

    @PostMapping("/api/admin/accounts")
    @Transactional
    public Map<String, String> createAccount(@RequestBody CreateAccountRequest request) {
        String username = required(request.username(), "Username is required");
        String role = normalizeRole(request.role());
        if (!java.util.Set.of("STUDENT", "INCHARGE", "HOD").contains(role)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Only student, in-charge, or faculty (HOD) accounts can be created here");
        }
        if (users.existsByUsernameIgnoreCase(username)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already exists");
        }
        String displayName = required(request.displayName(), "Display name is required");
        String temporaryPassword = request.password() == null || request.password().isBlank()
                ? newTemporaryPassword()
                : request.password();
        if (temporaryPassword.length() < 8) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Password must contain at least eight characters");
        }
        AppUser user = new AppUser();
        user.id = UUID.randomUUID();
        user.username = username;
        user.passwordHash = passwordEncoder.encode(temporaryPassword);
        user.displayName = displayName;
        user.role = role;
        user.active = true;
        user.createdAt = Instant.now();
        users.save(user);

        if ("STUDENT".equals(role)) saveStudentProfile(request, username, displayName);
        return accountCredentials(user, temporaryPassword);
    }

    @PostMapping("/api/admin/students")
    @Transactional
    public Map<String, String> createStudent(@RequestBody CreateAccountRequest request) {
        String rollNumber = required(request.rollNumber(), "Student roll number is required");
        CreateAccountRequest normalized = new CreateAccountRequest(
                rollNumber,
                request.displayName(),
                "STUDENT",
                request.password(),
                rollNumber,
                request.department(),
                request.academicYear(),
                request.phone(),
                request.busNumber());
        return createAccount(normalized);
    }

    @PostMapping("/api/admin/accounts/{username}/reset-password")
    @Transactional
    public Map<String, String> resetPassword(@PathVariable String username) {
        AppUser user = users.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));
        String temporaryPassword = newTemporaryPassword();
        user.passwordHash = passwordEncoder.encode(temporaryPassword);
        users.save(user);
        return accountCredentials(user, temporaryPassword);
    }

    @PostMapping("/api/auth/password/change")
    @Transactional
    public Map<String, String> changePassword(
            Authentication authentication,
            @RequestBody Map<String, String> body) {
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getName())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Login required");
        }
        UUID userId = UUID.fromString(authentication.getName());
        AppUser user = users.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));
        String currentPassword = body.getOrDefault("currentPassword", "");
        String newPassword = body.getOrDefault("newPassword", "");
        if (!passwordEncoder.matches(currentPassword, user.passwordHash)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Current password is incorrect");
        }
        if (newPassword.length() < 8) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "New password must contain at least eight characters");
        }
        user.passwordHash = passwordEncoder.encode(newPassword);
        users.save(user);
        return Map.of("status", "PASSWORD_CHANGED");
    }

    @GetMapping("/api/auth/me")
    @Transactional(readOnly = true)
    public Map<String, Object> currentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getName())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Login required");
        }
        UUID userId = UUID.fromString(authentication.getName());
        AppUser user = users.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("username", user.username);
        result.put("displayName", user.displayName);
        result.put("role", user.role);
        if ("STUDENT".equals(user.role)) {
            String rollNumber = user.username.equalsIgnoreCase("student") ? "CS2024-117" : user.username;
            students.findByRollNo(rollNumber).ifPresent(student -> {
                result.put("rollNumber", student.rollNo);
                result.put("department", student.department);
                result.put("academicYear", student.year);
                result.put("phone", student.phone);
                students.findAssignedBusDetails(student.rollNo).ifPresent(details -> {
                    String[] assignment = details.split("\\|", 3);
                    result.put("busNumber", assignment[0]);
                    result.put("busName", assignment.length > 2 ? assignment[2] : assignment[0]);
                    if (assignment.length > 1 && !assignment[1].isBlank()) {
                        List<Map<String, Object>> routeStops = stops
                                .findByRouteIdOrderByStopOrderAsc(UUID.fromString(assignment[1]))
                                .stream()
                                .map(stop -> {
                                    Map<String, Object> point = new java.util.HashMap<>();
                                    point.put("id", stop.id.toString());
                                    point.put("name", stop.name);
                                    point.put("landmark", stop.name);
                                    point.put("latitude", stop.latitude);
                                    point.put("longitude", stop.longitude);
                                    point.put("order", stop.stopOrder);
                                    return point;
                                })
                                .toList();
                        result.put("routeStops", routeStops);
                    }
                });
            });
        }
        return result;
    }

    private void saveStudentProfile(CreateAccountRequest request, String username, String displayName) {
        if (request.rollNumber() == null || request.rollNumber().isBlank()) return;
        if (students.findByRollNo(request.rollNumber()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Student roll number already exists");
        }
        Student student = new Student();
        student.id = UUID.randomUUID();
        student.rollNo = request.rollNumber();
        student.name = displayName;
        student.department = request.department() == null || request.department().isBlank()
                ? "Unspecified"
                : request.department();
        student.year = request.academicYear() == null ? 1 : request.academicYear();
        student.phone = request.phone();
        if (request.busNumber() != null && !request.busNumber().isBlank()) {
            student.bus = buses.findByRegistrationNumberIgnoreCase(request.busNumber().trim())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Assigned bus was not found: " + request.busNumber()));
        }
        student.status = "ACTIVE";
        student.createdAt = Instant.now();
        students.save(student);
    }

    private static String normalizeRole(String role) {
        if (role == null) return "";
        String normalized = role.trim().toUpperCase();
        return normalized.equals("FACULTY") ? "HOD" : normalized;
    }

    private static String required(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
        }
        return value.trim();
    }

    private static String newTemporaryPassword() {
        StringBuilder password = new StringBuilder(14);
        for (int i = 0; i < 14; i++) {
            password.append(PASSWORD_CHARS[RANDOM.nextInt(PASSWORD_CHARS.length)]);
        }
        return password.toString();
    }

    private static Map<String, String> accountCredentials(AppUser user, String temporaryPassword) {
        return Map.of(
                "id", user.id.toString(),
                "username", user.username,
                "displayName", user.displayName,
                "role", user.role,
                "temporaryPassword", temporaryPassword);
    }
}
