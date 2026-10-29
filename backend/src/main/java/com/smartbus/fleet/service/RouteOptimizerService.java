package com.smartbus.fleet.service;

import com.smartbus.fleet.entity.Bus;
import com.smartbus.fleet.entity.Stop;
import com.smartbus.fleet.repository.BusRepository;
import com.smartbus.fleet.repository.StopRepository;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RouteOptimizerService {
    private final BusRepository busRepository;
    private final StopRepository stopRepository;
    private final OsmRoutingClient osmRouting;

    public RouteOptimizerService(
            BusRepository busRepository,
            StopRepository stopRepository,
            OsmRoutingClient osmRouting) {
        this.busRepository = busRepository;
        this.stopRepository = stopRepository;
        this.osmRouting = osmRouting;
    }

    public record StopAssignment(
            String stopId,
            String stopName,
            String assignedBusNumber,
            String assignedBusName,
            String driverName,
            String driverPhone,
            double latitude,
            double longitude,
            int studentCount,
            int spareSeatsBefore,
            double detourDistanceKm,
            int detourEtaMinutes,
            String estimateSource) {}

    public record OptimalRerouteResult(
            List<StopAssignment> assignments,
            Map<String, Integer> unassignedStudentsByStop,
            int unassignedStudents,
            int strandedStudents,
            int affectedStopsCount,
            int coveredStopsCount,
            double totalDetourDistanceKm,
            int estimatedAdditionalMinutes,
            boolean allStopsCovered,
            String explanation) {}

    /** Capacity-constrained, scarcity-first dispatch. An OSRM-compatible router supplies
     * road distance/time when configured; without a key, estimates are marked
     * as straight-line approximations. */
    public OptimalRerouteResult calculateOptimalReroute(
            UUID brokenBusId,
            String brokenBusNumber,
            double breakdownLat,
            double breakdownLng,
            int strandedStudents) {
        Bus brokenBus = brokenBusId == null
                ? busRepository.findByRegistrationNumberIgnoreCase(brokenBusNumber)
                        .orElseThrow(() -> new ResponseStatusException(
                                HttpStatus.NOT_FOUND, "Broken-down bus is not in the configured fleet"))
                : busRepository.findById(brokenBusId)
                        .orElseThrow(() -> new ResponseStatusException(
                                HttpStatus.NOT_FOUND, "Broken-down bus is not in the configured fleet"));

        if (strandedStudents < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Stranded passenger count cannot be negative");
        }

        List<Stop> routeStops = brokenBus.route == null
                ? List.of()
                : stopRepository.findByRouteIdOrderByStopOrderAsc(brokenBus.route.id);
        List<Stop> affectedStops = routeStops.stream()
                .skip(Math.min(2, routeStops.size()))
                .filter(stop -> !isCampus(stop.name))
                .limit(Math.max(0, strandedStudents))
                .toList();

        if (affectedStops.isEmpty() || strandedStudents == 0) {
            return new OptimalRerouteResult(
                    List.of(), Map.of(), strandedStudents, strandedStudents,
                    affectedStops.size(), 0, 0, 0, affectedStops.isEmpty(),
                    "No remaining pickup groups were found for this breakdown scenario.");
        }

        List<Bus> availableBuses = busRepository.findAll().stream()
                .filter(bus -> !bus.id.equals(brokenBus.id))
                .filter(bus -> bus.status != null &&
                        (bus.status.equalsIgnoreCase("ACTIVE") || bus.status.equalsIgnoreCase("ON_DUTY")))
                .filter(bus -> bus.route != null && bus.capacity > 0)
                .toList();
        Map<String, Integer> remainingSeats = new HashMap<>();
        for (Bus bus : availableBuses) {
            remainingSeats.put(bus.registrationNumber,
                    Math.max(0, bus.capacity - Math.max(0, bus.currentOccupancy)));
        }

        int base = strandedStudents / affectedStops.size();
        int remainder = strandedStudents % affectedStops.size();
        List<Demand> demand = new ArrayList<>();
        for (int i = 0; i < affectedStops.size(); i++) {
            demand.add(new Demand(affectedStops.get(i), base + (i < remainder ? 1 : 0), i));
        }
        demand.removeIf(group -> group.passengers() == 0);
        demand.sort(Comparator
                .comparingInt((Demand group) -> (int) availableBuses.stream()
                        .filter(bus -> remainingSeats.getOrDefault(bus.registrationNumber, 0) >= group.passengers())
                        .count())
                .thenComparing(Demand::passengers, Comparator.reverseOrder())
                .thenComparingInt(Demand::routeOrder));

        List<StopAssignment> assignments = new ArrayList<>();
        Map<String, Integer> unassignedByStop = new HashMap<>();
        int unassigned = 0;
        double addedDistance = 0;
        int addedMinutes = 0;

        for (Demand group : demand) {
            List<Bus> feasible = availableBuses.stream()
                    .filter(bus -> remainingSeats.getOrDefault(bus.registrationNumber, 0) >= group.passengers())
                    .sorted(Comparator
                            .comparingDouble((Bus bus) -> nearestRoutePointKm(bus, group.stop()))
                            .thenComparing(bus -> bus.registrationNumber))
                    .toList();
            if (feasible.isEmpty()) {
                unassigned += group.passengers();
                unassignedByStop.put(group.stop().name, group.passengers());
                continue;
            }

            Bus rescueBus = feasible.getFirst();
            int spareBefore = remainingSeats.get(rescueBus.registrationNumber);
            remainingSeats.put(rescueBus.registrationNumber, spareBefore - group.passengers());
            Stop origin = nearestRoutePoint(rescueBus, group.stop());
            OsmRoutingClient.RouteEstimate estimate = osmRouting.estimate(
                    origin.latitude, origin.longitude, group.stop().latitude, group.stop().longitude);
            double roundTripKm = estimate.distanceKm() * 2;
            int roundTripMinutes = estimate.durationMinutes() * 2;
            assignments.add(new StopAssignment(
                    group.stop().id.toString(), group.stop().name,
                    rescueBus.registrationNumber,
                    rescueBus.route.name,
                    rescueBus.driverName, rescueBus.driverPhone,
                    group.stop().latitude, group.stop().longitude,
                    group.passengers(), spareBefore, roundTripKm, roundTripMinutes,
                    estimate.source()));
            addedDistance += roundTripKm;
            addedMinutes = Math.max(addedMinutes, roundTripMinutes);
        }

        assignments.sort(Comparator.comparingInt(item -> {
            for (int i = 0; i < affectedStops.size(); i++) {
                if (affectedStops.get(i).id.toString().equals(item.stopId())) return i;
            }
            return Integer.MAX_VALUE;
        }));

        int covered = assignments.stream().mapToInt(StopAssignment::studentCount).sum();
        int stopsCovered = (int) assignments.stream().map(StopAssignment::stopId).distinct().count();
        String explanation = String.format(
                "Java dispatch assigned %d of %d passengers to %d rescue buses across %d of %d pickup groups; %d passengers need manual support. Detour values use %s.",
                covered, strandedStudents,
                assignments.stream().map(StopAssignment::assignedBusNumber).distinct().count(),
                stopsCovered, affectedStops.size(), unassigned,
                assignments.stream().anyMatch(a -> a.estimateSource().equals("OSRM_OPENSTREETMAP"))
                        ? "OpenStreetMap-based OSRM road estimates"
                        : "straight-line simulation estimates");

        return new OptimalRerouteResult(
                List.copyOf(assignments), Map.copyOf(unassignedByStop), unassigned,
                strandedStudents, affectedStops.size(), stopsCovered,
                addedDistance, addedMinutes, stopsCovered == affectedStops.size(), explanation);
    }

    private Stop nearestRoutePoint(Bus bus, Stop target) {
        return stopRepository.findByRouteIdOrderByStopOrderAsc(bus.route.id).stream()
                .min(Comparator.comparingDouble(stop -> haversineKm(
                        stop.latitude, stop.longitude, target.latitude, target.longitude)))
                .orElse(target);
    }

    private double nearestRoutePointKm(Bus bus, Stop target) {
        Stop nearest = nearestRoutePoint(bus, target);
        return haversineKm(nearest.latitude, nearest.longitude, target.latitude, target.longitude);
    }

    private static boolean isCampus(String name) {
        String normalized = name.toLowerCase();
        return normalized.contains("campus gate") || normalized.contains("klh aziz nagar campus");
    }

    private static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private record Demand(Stop stop, int passengers, int routeOrder) {}
}
