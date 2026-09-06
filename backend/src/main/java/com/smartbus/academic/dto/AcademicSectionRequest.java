package com.smartbus.academic.dto;
import jakarta.validation.Valid; import jakarta.validation.constraints.*; import java.util.*;
public record AcademicSectionRequest(@Min(1) @Max(4) int academicYear, @NotBlank String specialization, @NotBlank String sectionNumber, @NotEmpty List<@Valid Student> students) { public record Student(@NotBlank String name, @NotBlank String rollNumber, @DecimalMin("0") @DecimalMax("100") double attendancePercent) {} }
