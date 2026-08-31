package com.smartbus.fleet.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name="routes")
public class Route {
    @Id
    public UUID id = UUID.randomUUID();
    
    @Column(nullable = false)
    public String name;
    
    public String startLocation;
    public String endLocation;
}
