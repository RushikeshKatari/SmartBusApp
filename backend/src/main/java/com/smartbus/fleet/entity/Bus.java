package com.smartbus.fleet.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name="buses")
public class Bus {
    @Id
    public UUID id = UUID.randomUUID();
    
    @Column(nullable = false)
    public String registrationNumber;
    
    public int capacity;
    
    @ManyToOne
    @JoinColumn(name="route_id")
    public Route route;
    
    public String driverName;
    public String driverPhone;
}
