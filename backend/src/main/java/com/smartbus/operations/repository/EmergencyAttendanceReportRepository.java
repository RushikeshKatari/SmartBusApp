package com.smartbus.operations.repository;
import com.smartbus.operations.entity.EmergencyAttendanceReport; import java.util.*; import org.springframework.data.jpa.repository.*;
public interface EmergencyAttendanceReportRepository extends JpaRepository<EmergencyAttendanceReport, UUID> { @EntityGraph(attributePaths="students") List<EmergencyAttendanceReport> findAllByOrderBySentToTransportAtDesc(); @EntityGraph(attributePaths="students") List<EmergencyAttendanceReport> findByStatusOrderBySentToHodAtDesc(String status); }
