package com.smartbus.fleet.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name="stops")
public class Stop {
    @Id
    public UUID id = UUID.randomUUID();
    
    @ManyToOne
    @JoinColumn(name="route_id")
    public Route route;
    
    @Column(nullable = false)
    public String name;
    
    public double latitude;
    public double longitude;
    
    @Column(name="stop_order")
    public int stopOrder;
}
