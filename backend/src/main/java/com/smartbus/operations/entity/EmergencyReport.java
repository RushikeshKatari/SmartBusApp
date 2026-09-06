package com.smartbus.operations.entity;
import com.smartbus.fleet.entity.Bus; import jakarta.persistence.*; import java.time.Instant; import java.util.UUID;
@Entity @Table(name="emergency_reports") public class EmergencyReport { @Id public UUID id; @ManyToOne @JoinColumn(name="bus_id") public Bus bus; public String type, details, location, status; @Column(name="created_at") public Instant createdAt; @Column(name="resolved_at") public Instant resolvedAt; }
