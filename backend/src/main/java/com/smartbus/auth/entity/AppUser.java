package com.smartbus.auth.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "app_users")
public class AppUser {
    @Id public UUID id;
    @Column(nullable = false, unique = true) public String username;
    @Column(name = "password_hash", nullable = false) public String passwordHash;
    @Column(name = "display_name", nullable = false) public String displayName;
    @Column(nullable = false) public String role;
    @Column(nullable = false) public boolean active = true;
    @Column(name = "created_at", nullable = false) public Instant createdAt;
}
