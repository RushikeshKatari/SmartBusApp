package com.smartbus.operations.entity;
import com.smartbus.auth.entity.Student; import com.smartbus.fleet.entity.Bus; import jakarta.persistence.*; import java.time.*; import java.util.UUID;
@Entity @Table(name="attendance_records") public class AttendanceRecord { @Id public UUID id; @ManyToOne @JoinColumn(name="student_id") public Student student; @ManyToOne @JoinColumn(name="bus_id") public Bus bus; @Column(name="scanned_at") public Instant scannedAt; @Column(name="attendance_date") public LocalDate attendanceDate; public String status; }
