package com.smartbus.operations.entity;
import com.fasterxml.jackson.annotation.JsonIgnore; import jakarta.persistence.*; import java.time.Instant; import java.util.UUID;
@Entity @Table(name="emergency_report_students") public class EmergencyReportStudent { @Id public UUID id; @JsonIgnore @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="report_id") public EmergencyAttendanceReport report; @Column(name="roll_number") public String rollNumber; @Column(name="student_name") public String studentName; public String department; @Column(name="scanned_at") public Instant scannedAt; }
