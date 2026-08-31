package com.smartbus.auth.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name="auth_sessions")
public class AuthSession {
    @Id
    public UUID id;
    
    @ManyToOne
    @JoinColumn(name="student_id")
    public Student student;
    
    @Column(name="device_id")
    public String deviceId;
    
    public String platform;
    public boolean active;
    
    @Column(name="created_at")
    public Instant createdAt;
    
    @Column(name="last_seen_at")
    public Instant lastSeenAt;
}
