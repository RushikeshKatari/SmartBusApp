package com.smartbus.operations.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "emergency_attendance_reports")
public class EmergencyAttendanceReport {
    @Id public UUID id;
    @Column(name = "bus_number") public String busNumber;
    @Column(name = "bus_name") public String busName;
    @Column(name = "incharge_name") public String inchargeName;
    public String reason, location, status;
    @Column(name = "sent_to_transport_at") public Instant sentToTransportAt;
    @Column(name = "sent_to_hod_at") public Instant sentToHodAt;
    @Column(name = "attendance_approved_at") public Instant attendanceApprovedAt;
    @Column(name = "permission_granted_at") public Instant permissionGrantedAt;
    @OneToMany(mappedBy = "report", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("scannedAt ASC") public List<EmergencyReportStudent> students = new ArrayList<>();
}
