package com.smartbus.auth.entity;
import jakarta.persistence.*; import java.time.Instant; import java.util.UUID;
@Entity @Table(name="students") public class Student { @Id public UUID id; @Column(name="roll_no") public String rollNo; public String name,department,phone,status; public int year; @Column(name="telegram_enabled") public boolean telegramEnabled; @Column(name="created_at") public Instant createdAt; }
