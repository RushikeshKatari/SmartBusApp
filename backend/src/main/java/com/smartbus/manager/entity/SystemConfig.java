package com.smartbus.manager.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name="system_configs")
public class SystemConfig {
    @Id
    public UUID id = UUID.randomUUID();
    
    @Column(unique = true, nullable = false)
    public String configKey;
    
    @Column(nullable = false, length = 1024)
    public String configValue;
    
    public String description;
    
    @Column(name="updated_at")
    public Instant updatedAt = Instant.now();
    
    @Column(name="updated_by")
    public String updatedBy;
}
