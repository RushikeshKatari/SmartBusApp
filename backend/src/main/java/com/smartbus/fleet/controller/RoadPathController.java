package com.smartbus.fleet.controller;

import com.smartbus.fleet.entity.Bus;
import com.smartbus.fleet.entity.Stop;
import com.smartbus.fleet.repository.BusRepository;
import com.smartbus.fleet.repository.StopRepository;
import com.smartbus.fleet.service.OsmRoutingClient;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Road-following route geometry for authenticated student and dispatch maps. */
@RestController
@RequestMapping("/api/fleet")
public class RoadPathController {
    private final BusRepository buses;
    private final StopRepository stops;
    private final OsmRoutingClient routing;
    private final Map<String, OsmRoutingClient.RoadPath> cache = new ConcurrentHashMap<>();

    public RoadPathController(BusRepository buses, StopRepository stops, OsmRoutingClient routing) {
        this.buses = buses;
        this.stops = stops;
        this.routing = routing;
    }

    @GetMapping("/road-paths")
    @Transactional(readOnly = true)
    public Map<String, Object> roadPaths(@RequestParam(required = false) String busNumber) {
        Map<String, Object> result = new HashMap<>();
        List<Bus> fleet = buses.findAll().stream()
                .filter(bus -> bus.route != null)
                .filter(bus -> busNumber == null || bus.registrationNumber.equalsIgnoreCase(busNumber))
                .toList();
        for (Bus bus : fleet) {
            List<Stop> routeStops = stops.findByRouteIdOrderByStopOrderAsc(bus.route.id);
            List<OsmRoutingClient.GeoPoint> points = routeStops.stream()
                    .map(stop -> new OsmRoutingClient.GeoPoint(stop.latitude, stop.longitude))
                    .toList();
            String cacheKey = bus.registrationNumber + ":" + points;
            OsmRoutingClient.RoadPath roadPath = cache.computeIfAbsent(
                    cacheKey, ignored -> routing.roadPath(points));
            result.put(bus.registrationNumber, Map.of(
                    "points", roadPath.points(),
                    "source", roadPath.source()));
        }
        return result;
    }
}
