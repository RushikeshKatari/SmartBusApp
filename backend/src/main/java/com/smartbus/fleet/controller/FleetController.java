package com.smartbus.fleet.controller;

import com.smartbus.fleet.entity.*;
import com.smartbus.fleet.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/fleet")
public class FleetController {
    
    private final BusRepository buses;
    private final RouteRepository routes;
    private final StopRepository stops;
    
    public FleetController(BusRepository buses, RouteRepository routes, StopRepository stops) {
        this.buses = buses;
        this.routes = routes;
        this.stops = stops;
    }
    
    @GetMapping("/routes")
    public ResponseEntity<List<Route>> getRoutes() {
        return ResponseEntity.ok(routes.findAll());
    }
    
    @PostMapping("/routes")
    public ResponseEntity<Route> createRoute(@RequestBody Route route) {
        return ResponseEntity.ok(routes.save(route));
    }
    
    @GetMapping("/buses")
    public ResponseEntity<List<Bus>> getBuses() {
        return ResponseEntity.ok(buses.findAll());
    }
    
    @PostMapping("/buses")
    public ResponseEntity<Bus> createBus(@RequestBody Bus bus) {
        return ResponseEntity.ok(buses.save(bus));
    }
    
    @GetMapping("/routes/{routeId}/stops")
    public ResponseEntity<List<Stop>> getRouteStops(@PathVariable UUID routeId) {
        return ResponseEntity.ok(stops.findByRouteIdOrderByStopOrderAsc(routeId));
    }
}
