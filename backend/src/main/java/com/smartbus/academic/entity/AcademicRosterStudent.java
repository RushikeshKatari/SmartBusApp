package com.smartbus.academic.entity;
import com.fasterxml.jackson.annotation.JsonIgnore; import jakarta.persistence.*; import java.util.UUID;
@Entity @Table(name="academic_roster_students") public class AcademicRosterStudent { @Id public UUID id; @JsonIgnore @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="section_id") public AcademicSection section; @Column(name="student_name") public String studentName; @Column(name="roll_number") public String rollNumber; @Column(name="attendance_percent") public double attendancePercent; }
