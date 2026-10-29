package com.smartbus.operations.controller;

import com.smartbus.auth.entity.Student;
import com.smartbus.auth.repository.StudentRepository;
import com.smartbus.fleet.entity.Bus;
import com.smartbus.fleet.repository.BusRepository;
import com.smartbus.fleet.service.RouteOptimizerService;
import com.smartbus.operations.dto.*;
import com.smartbus.operations.entity.*;
import com.smartbus.operations.repository.*;
import jakarta.validation.Valid;
import java.time.*;
import java.util.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api")
public class OperationsController {
    private final AttendanceRecordRepository attendance;
    private final EmergencyReportRepository emergencies;
    private final StudentRepository students;
    private final BusRepository buses;
    private final RouteOptimizerService routeOptimizer;

    public OperationsController(
            AttendanceRecordRepository attendance,
            EmergencyReportRepository emergencies,
            StudentRepository students,
            BusRepository buses,
            RouteOptimizerService routeOptimizer
    ) {
        this.attendance = attendance;
        this.emergencies = emergencies;
        this.students = students;
        this.buses = buses;
        this.routeOptimizer = routeOptimizer;
    }

    public record BreakdownRequest(
        UUID busId,
        String busNumber,
        String inchargeName,
        String reason,
        String location,
        double latitude,
        double longitude,
        int strandedStudentsCount
    ) {}

    public record BreakdownResponse(
        UUID id,
        String brokenBusNumber,
        String inchargeName,
        String reason,
        String location,
        String assignedPickupBusNumber,
        String assignedPickupDriver,
        String assignedPickupDriverPhone,
        double detourDistanceKm,
        int detourEtaMinutes,
        int strandedStudentsCount,
        int coveredStudentsCount,
        int unassignedStudentsCount,
        int affectedStopsCount,
        int coveredStopsCount,
        boolean allStopsCovered,
        List<RouteOptimizerService.StopAssignment> assignments,
        java.util.Map<String, Integer> unassignedStudentsByStop,
        List<String> rescueBusNumbers,
        String status,
        String explanation,
        String createdAt
    ) {}

    // In-memory active breakdowns cache for instant real-time dispatch
    private final List<BreakdownResponse> activeBreakdowns = new java.util.concurrent.CopyOnWriteArrayList<>();

    @PostMapping({"/operations/breakdown", "/incharge/breakdown"})
    public ResponseEntity<BreakdownResponse> reportBreakdown(@RequestBody BreakdownRequest request) {
        // Automatic optimal bus evaluation & reroute calculation
        var reroute = routeOptimizer.calculateOptimalReroute(
            request.busId(),
            request.busNumber(),
            request.latitude(),
            request.longitude(),
            Math.max(0, request.strandedStudentsCount())
        );
        List<String> rescueBuses = reroute.assignments().stream()
                .map(RouteOptimizerService.StopAssignment::assignedBusNumber)
                .distinct().toList();
        var firstAssignment = reroute.assignments().isEmpty() ? null : reroute.assignments().getFirst();

        BreakdownResponse response = new BreakdownResponse(
            UUID.randomUUID(),
            request.busNumber(),
            request.inchargeName(),
            request.reason(),
            request.location(),
            firstAssignment == null ? "No capacity available" : firstAssignment.assignedBusNumber(),
            firstAssignment == null ? "Unassigned" : firstAssignment.driverName(),
            firstAssignment == null ? "" : firstAssignment.driverPhone(),
            reroute.totalDetourDistanceKm(),
            reroute.estimatedAdditionalMinutes(),
            reroute.strandedStudents(),
            reroute.strandedStudents() - reroute.unassignedStudents(),
            reroute.unassignedStudents(),
            reroute.affectedStopsCount(),
            reroute.coveredStopsCount(),
            reroute.allStopsCovered(),
            reroute.assignments(),
            reroute.unassignedStudentsByStop(),
            rescueBuses,
            "ACTIVE_REROUTING",
            reroute.explanation(),
            Instant.now().toString()
        );

        activeBreakdowns.add(0, response);

        // Also record as an emergency report in DB
        EmergencyReport report = new EmergencyReport();
        report.id = UUID.randomUUID();
        report.type = "BREAKDOWN: " + request.reason();
        report.details = response.explanation();
        report.location = request.location();
        report.status = "OPEN";
        report.createdAt = Instant.now();
        emergencies.save(report);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/operations/breakdowns/active")
    public List<BreakdownResponse> getActiveBreakdowns() {
        return activeBreakdowns;
    }

    @PostMapping("/incharge/attendance")
    public ResponseEntity<AttendanceRecord> recordAttendance(@Valid @RequestBody AttendanceRequest request) {
        LocalDate today = LocalDate.now();
        if (attendance.findByStudentIdAndAttendanceDate(request.studentId(), today).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Student already recorded today");
        }
        AttendanceRecord record = new AttendanceRecord();
        record.id = UUID.randomUUID();
        record.student = students.findById(request.studentId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));
        record.bus = request.busId() == null ? null : buses.findById(request.busId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Bus not found"));
        record.scannedAt = Instant.now();
        record.attendanceDate = today;
        record.status = "BOARDED";
        return ResponseEntity.status(HttpStatus.CREATED).body(attendance.save(record));
    }

    @GetMapping("/admin/attendance")
    public List<AttendanceRecord> attendance(@RequestParam(required = false) String date) {
        return attendance.findByAttendanceDateOrderByScannedAtDesc(
            date == null ? LocalDate.now() : LocalDate.parse(date)
        );
    }

    @PostMapping("/incharge/emergency")
    public ResponseEntity<EmergencyReport> createEmergency(@Valid @RequestBody EmergencyRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(saveEmergency(request));
    }

    @PostMapping("/manager/emergency")
    public EmergencyReport createManagerEmergency(@Valid @RequestBody EmergencyRequest request) {
        return saveEmergency(request);
    }

    private EmergencyReport saveEmergency(EmergencyRequest request) {
        EmergencyReport r = new EmergencyReport();
        r.id = UUID.randomUUID();
        r.bus = request.busId() == null ? null : buses.findById(request.busId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Bus not found"));
        r.type = request.type();
        r.details = request.details();
        r.location = request.location();
        r.status = "OPEN";
        r.createdAt = Instant.now();
        return emergencies.save(r);
    }

    @GetMapping("/admin/emergencies")
    public List<EmergencyReport> emergencies(@RequestParam(required = false) String status) {
        return status == null ? emergencies.findAllByOrderByCreatedAtDesc() : emergencies.findByStatusOrderByCreatedAtDesc(status);
    }

    @PatchMapping("/admin/emergencies/{id}/resolve")
    public EmergencyReport resolve(@PathVariable UUID id) {
        EmergencyReport r = emergencies.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        r.status = "RESOLVED";
        r.resolvedAt = Instant.now();
        activeBreakdowns.removeIf(b -> b.id().equals(id));
        return emergencies.save(r);
    }
}

