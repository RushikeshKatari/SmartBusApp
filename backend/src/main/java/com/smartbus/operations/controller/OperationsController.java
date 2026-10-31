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
        String createdAt,
        double dispatchObjectiveScore,
        int replanningRevision
    ) {}

    // Active scenario state is replayed in incident order whenever fleet state changes.
    private final List<BreakdownResponse> activeBreakdowns = new java.util.concurrent.CopyOnWriteArrayList<>();
    private final List<PendingIncident> pendingIncidents = new java.util.concurrent.CopyOnWriteArrayList<>();
    private int replanningRevision = 0;

    private record PendingIncident(UUID id, BreakdownRequest request, String createdAt) {}

    @PostMapping({"/operations/breakdown", "/incharge/breakdown"})
    public synchronized ResponseEntity<BreakdownResponse> reportBreakdown(@RequestBody BreakdownRequest request) {
        if (pendingIncidents.stream().anyMatch(i -> i.request().busNumber().equalsIgnoreCase(request.busNumber()))) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "This bus already has an active breakdown incident");
        }
        PendingIncident addedIncident = new PendingIncident(
                UUID.randomUUID(), request, Instant.now().toString());
        pendingIncidents.add(addedIncident);
        try {
            replanAllActiveIncidents();
        } catch (RuntimeException exception) {
            pendingIncidents.remove(addedIncident);
            replanAllActiveIncidents();
            throw exception;
        }
        BreakdownResponse response = activeBreakdowns.stream()
                .filter(active -> active.id().equals(addedIncident.id()))
                .findFirst().orElseThrow();

        // Also record the incident under the same id so resolving it updates the dispatch state.
        EmergencyReport report = new EmergencyReport();
        report.id = addedIncident.id();
        report.type = "BREAKDOWN: " + request.reason();
        report.details = response.explanation();
        report.location = request.location();
        report.status = "OPEN";
        report.createdAt = Instant.now();
        emergencies.save(report);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    private void replanAllActiveIncidents() {
        replanningRevision++;
        var unavailableBusNumbers = new HashSet<String>();
        pendingIncidents.forEach(i -> unavailableBusNumbers.add(i.request().busNumber()));
        var committedPassengers = new HashMap<String, Integer>();
        var replanned = new ArrayList<BreakdownResponse>();
        for (PendingIncident incident : pendingIncidents) {
            BreakdownRequest request = incident.request();
            var plan = routeOptimizer.calculateOptimalReroute(
                    request.busId(), request.busNumber(), request.latitude(), request.longitude(),
                    Math.max(0, request.strandedStudentsCount()), unavailableBusNumbers, committedPassengers);
            List<String> rescueBuses = plan.assignments().stream()
                    .map(RouteOptimizerService.StopAssignment::assignedBusNumber).distinct().toList();
            var firstAssignment = plan.assignments().isEmpty() ? null : plan.assignments().getFirst();
            String explanation = plan.explanation() + " Replanning revision " + replanningRevision
                    + " recalculates all active incidents in reported order.";
            replanned.add(new BreakdownResponse(
                    incident.id(), request.busNumber(), request.inchargeName(), request.reason(), request.location(),
                    firstAssignment == null ? "No capacity available" : firstAssignment.assignedBusNumber(),
                    firstAssignment == null ? "Unassigned" : firstAssignment.driverName(),
                    firstAssignment == null ? "" : firstAssignment.driverPhone(),
                    plan.totalDetourDistanceKm(), plan.estimatedAdditionalMinutes(),
                    plan.strandedStudents(), plan.strandedStudents() - plan.unassignedStudents(),
                    plan.unassignedStudents(), plan.affectedStopsCount(), plan.coveredStopsCount(),
                    plan.allStopsCovered(), plan.assignments(), plan.unassignedStudentsByStop(), rescueBuses,
                    "ACTIVE_REROUTING", explanation, incident.createdAt(),
                    plan.dispatchObjectiveScore(), replanningRevision));
            emergencies.findById(incident.id()).ifPresent(report -> {
                report.details = explanation;
                emergencies.save(report);
            });
            plan.assignments().forEach(a -> committedPassengers.merge(
                    a.assignedBusNumber(), a.studentCount(), Integer::sum));
        }
        activeBreakdowns.clear();
        for (int i = replanned.size() - 1; i >= 0; i--) activeBreakdowns.add(replanned.get(i));
    }

    @GetMapping("/operations/breakdowns/active")
    public List<BreakdownResponse> getActiveBreakdowns() {
        return activeBreakdowns;
    }

    @PostMapping("/operations/breakdowns/resolve")
    public synchronized ResponseEntity<Void> resolveActiveBreakdowns() {
        activeBreakdowns.clear();
        pendingIncidents.clear();
        replanningRevision++;
        return ResponseEntity.noContent().build();
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
        synchronized (this) {
            pendingIncidents.removeIf(i -> i.id().equals(id));
            replanAllActiveIncidents();
        }
        return emergencies.save(r);
    }
}

