package com.smartbus.operations.dto; import jakarta.validation.constraints.NotNull; import java.util.UUID; public record AttendanceRequest(@NotNull UUID studentId, UUID busId) {}
