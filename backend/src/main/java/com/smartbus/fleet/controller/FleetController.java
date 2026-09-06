package com.smartbus.fleet.controller;

import com.smartbus.fleet.entity.*;
import com.smartbus.fleet.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

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
        route.id = UUID.randomUUID(); return ResponseEntity.status(HttpStatus.CREATED).body(routes.save(route));
    }
    @PutMapping("/routes/{id}") public Route updateRoute(@PathVariable UUID id, @RequestBody Route input) { Route route=routes.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND)); route.name=input.name; route.startLocation=input.startLocation; route.endLocation=input.endLocation; return routes.save(route); }
    @DeleteMapping("/routes/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteRoute(@PathVariable UUID id) { if (!routes.existsById(id)) throw new ResponseStatusException(HttpStatus.NOT_FOUND); routes.deleteById(id); }
    
    @GetMapping("/buses")
    public ResponseEntity<List<Bus>> getBuses() {
        return ResponseEntity.ok(buses.findAll());
    }
    
    @PostMapping("/buses")
    public ResponseEntity<Bus> createBus(@RequestBody Bus bus) {
        bus.id = UUID.randomUUID(); return ResponseEntity.status(HttpStatus.CREATED).body(buses.save(bus));
    }
    @PutMapping("/buses/{id}") public Bus updateBus(@PathVariable UUID id, @RequestBody Bus input) { Bus bus=buses.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND)); bus.registrationNumber=input.registrationNumber; bus.capacity=input.capacity; bus.route=input.route; bus.driverName=input.driverName; bus.driverPhone=input.driverPhone; return buses.save(bus); }
    @DeleteMapping("/buses/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteBus(@PathVariable UUID id) { if (!buses.existsById(id)) throw new ResponseStatusException(HttpStatus.NOT_FOUND); buses.deleteById(id); }
    
    @GetMapping("/routes-with-stops")
    public ResponseEntity<?> getRoutesWithStops() {
        List<Route> allRoutes = routes.findAll();
        List<java.util.Map<String, Object>> result = new java.util.ArrayList<>();
        for (Route r : allRoutes) {
            List<Stop> routeStops = stops.findByRouteIdOrderByStopOrderAsc(r.id);
            result.add(java.util.Map.of(
                "id", r.id.toString(),
                "name", r.name,
                "startLocation", r.startLocation != null ? r.startLocation : "",
                "endLocation", r.endLocation != null ? r.endLocation : "",
                "stops", routeStops
            ));
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/routes/{routeId}/stops")
    public ResponseEntity<List<Stop>> getRouteStops(@PathVariable UUID routeId) {
        return ResponseEntity.ok(stops.findByRouteIdOrderByStopOrderAsc(routeId));
    }
    @PostMapping("/routes/{routeId}/stops") public ResponseEntity<Stop> addStop(@PathVariable UUID routeId, @RequestBody Stop stop) { stop.id=UUID.randomUUID(); stop.route=routes.findById(routeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND)); return ResponseEntity.status(HttpStatus.CREATED).body(stops.save(stop)); }
    @DeleteMapping("/stops/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteStop(@PathVariable UUID id) { if (!stops.existsById(id)) throw new ResponseStatusException(HttpStatus.NOT_FOUND); stops.deleteById(id); }
}

