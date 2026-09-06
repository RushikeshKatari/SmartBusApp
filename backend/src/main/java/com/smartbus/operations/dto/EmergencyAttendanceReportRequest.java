package com.smartbus.operations.dto;
import jakarta.validation.Valid; import jakarta.validation.constraints.*; import java.util.List;
public record EmergencyAttendanceReportRequest(@NotBlank String busNumber, String busName, String inchargeName, @NotBlank String reason, String location, @NotEmpty List<@Valid Student> students) { public record Student(@NotBlank String rollNumber, @NotBlank String studentName, String department) {} }
