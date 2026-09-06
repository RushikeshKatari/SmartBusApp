package com.smartbus.academic.entity;
import jakarta.persistence.*; import java.time.Instant; import java.util.*;
@Entity @Table(name="academic_sections") public class AcademicSection { @Id public UUID id; @Column(name="academic_year") public int academicYear; public String specialization; @Column(name="section_number") public String sectionNumber; @Column(name="created_at") public Instant createdAt; @OneToMany(mappedBy="section", cascade=CascadeType.ALL, orphanRemoval=true) public List<AcademicRosterStudent> students=new ArrayList<>(); }
