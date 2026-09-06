package com.smartbus.auth.controller;
import java.time.Instant; import java.util.Map; import org.springframework.http.*; import org.springframework.web.bind.MethodArgumentNotValidException; import org.springframework.web.bind.annotation.*; import org.springframework.web.server.ResponseStatusException;
@RestControllerAdvice public class ApiExceptionHandler {
 @ExceptionHandler(ResponseStatusException.class) ResponseEntity<Map<String,Object>> responseStatus(ResponseStatusException e){return ResponseEntity.status(e.getStatusCode()).body(Map.of("timestamp",Instant.now().toString(),"status",e.getStatusCode().value(),"message",e.getReason()==null?"Request failed":e.getReason()));}
 @ExceptionHandler({IllegalArgumentException.class,IllegalStateException.class}) ResponseEntity<Map<String,Object>> invalid(RuntimeException e){return ResponseEntity.badRequest().body(Map.of("timestamp",Instant.now().toString(),"status",400,"message",e.getMessage()));}
 @ExceptionHandler(MethodArgumentNotValidException.class) ResponseEntity<Map<String,Object>> validation(MethodArgumentNotValidException e){return ResponseEntity.badRequest().body(Map.of("timestamp",Instant.now().toString(),"status",400,"message",e.getBindingResult().getFieldError()==null?"Invalid request":e.getBindingResult().getFieldError().getField()+" is invalid"));}
}
