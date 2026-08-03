package com.smartbus.auth.dto; public record AuthResponse(String accessToken, StudentProfile student) { public record StudentProfile(String name,String rollNumber,String department){} }
