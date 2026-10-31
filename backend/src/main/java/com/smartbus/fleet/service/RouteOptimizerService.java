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
import java.util.Set;
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
            String estimateSource,
            int estimatedArrivalMinutes,
            double weightedAssignmentCost,
            String assignmentReason) {}

    public record OptimalRerouteResult(
            List<StopAssignment> assignments,
            Map<String, Integer> unassignedStudentsByStop,
            int unassignedStudents,
            int strandedStudents,
            int affectedStopsCount,
            int coveredStopsCount,
            double totalDetourDistanceKm,
            int estimatedAdditionalMinutes,
            double dispatchObjectiveScore,
            boolean allStopsCovered,
            String explanation) {}

    private static final double ARRIVAL_WEIGHT = 0.55;
    private static final double DETOUR_TIME_WEIGHT = 0.30;
    private static final double DETOUR_DISTANCE_WEIGHT = 0.15;
    private static final double UNSERVED_PASSENGER_PENALTY = 1000.0;

    /** Capacity-constrained, scarcity-first dispatch. An OSRM-compatible router supplies
     * road distance/time when configured; without a key, estimates are marked
     * as straight-line approximations. */
    public OptimalRerouteResult calculateOptimalReroute(
            UUID brokenBusId,
            String brokenBusNumber,
            double breakdownLat,
            double breakdownLng,
            int strandedStudents,
            Set<String> unavailableBusNumbers,
            Map<String, Integer> alreadyCommittedPassengers) {
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
                .toList();

        if (affectedStops.isEmpty()) {
            return new OptimalRerouteResult(
                    List.of(), Map.of(), strandedStudents, strandedStudents,
                    affectedStops.size(), 0, 0, 0, 0, false,
                    "No remaining pickup groups were found for this breakdown scenario.");
        }

        List<Bus> availableBuses = busRepository.findAll().stream()
                .filter(bus -> !bus.id.equals(brokenBus.id))
                .filter(bus -> !unavailableBusNumbers.contains(bus.registrationNumber))
                .filter(bus -> bus.status != null &&
                        (bus.status.equalsIgnoreCase("ACTIVE") || bus.status.equalsIgnoreCase("ON_DUTY")))
                .filter(bus -> bus.route != null && bus.capacity > 0)
                .toList();
        Map<String, Integer> remainingSeats = new HashMap<>();
        for (Bus bus : availableBuses) {
            remainingSeats.put(bus.registrationNumber,
                    Math.max(0, bus.capacity - Math.max(0, bus.currentOccupancy)
                            - alreadyCommittedPassengers.getOrDefault(bus.registrationNumber, 0)));
        }

        int base = strandedStudents / affectedStops.size();
        int remainder = strandedStudents % affectedStops.size();
        List<Demand> demand = new ArrayList<>();
        for (int i = 0; i < affectedStops.size(); i++) {
            demand.add(new Demand(affectedStops.get(i), base + (i < remainder ? 1 : 0), i));
        }
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
        double dispatchObjectiveScore = 0;
        Map<String, CandidateCost> candidateCostCache = new HashMap<>();
        Map<String, OsmRoutingClient.RouteEstimate> routeEstimateCache = new HashMap<>();

        for (Demand group : demand) {
            int passengersLeft = group.passengers();
            if (passengersLeft == 0) {
                Bus nearestBus = availableBuses.stream()
                        .min(Comparator
                                .comparingDouble((Bus bus) -> weightedCost(candidateCostCache, routeEstimateCache, bus, group.stop(), breakdownLat, breakdownLng).score())
                                .thenComparing(bus -> bus.registrationNumber))
                        .orElse(null);
                if (nearestBus == null) {
                    continue;
                }
                Stop origin = nearestRoutePoint(nearestBus, breakdownLat, breakdownLng);
                OsmRoutingClient.RouteEstimate toBreakdown = estimate(routeEstimateCache,
                        origin.latitude, origin.longitude, breakdownLat, breakdownLng);
                OsmRoutingClient.RouteEstimate toPickup = estimate(routeEstimateCache,
                        breakdownLat, breakdownLng, group.stop().latitude, group.stop().longitude);
                double detourKm = toBreakdown.distanceKm() + toPickup.distanceKm();
                int detourMinutes = toBreakdown.durationMinutes() + toPickup.durationMinutes();
                assignments.add(new StopAssignment(
                        group.stop().id.toString(), group.stop().name,
                        nearestBus.registrationNumber, nearestBus.route.name,
                        nearestBus.driverName, nearestBus.driverPhone,
                        group.stop().latitude, group.stop().longitude, 0,
                        remainingSeats.getOrDefault(nearestBus.registrationNumber, 0),
                        detourKm,
                        detourMinutes,
                        toBreakdown.source().equals(toPickup.source())
                                ? toBreakdown.source()
                                : "MIXED_ROUTE_ESTIMATES",
                        toBreakdown.durationMinutes(),
                        weightedCost(candidateCostCache, routeEstimateCache, nearestBus, group.stop(), breakdownLat, breakdownLng).score(),
                        assignmentReason(availableBuses, remainingSeats, nearestBus, group.stop(),
                                breakdownLat, breakdownLng,
                                remainingSeats.getOrDefault(nearestBus.registrationNumber, 0),
                                toBreakdown.durationMinutes(), toPickup.durationMinutes(),
                                weightedCost(candidateCostCache, routeEstimateCache, nearestBus,
                                        group.stop(), breakdownLat, breakdownLng).score(), 0, 0)));
                addedDistance += detourKm;
                addedMinutes = Math.max(addedMinutes, detourMinutes);
                dispatchObjectiveScore += weightedCost(candidateCostCache, routeEstimateCache, nearestBus, group.stop(), breakdownLat, breakdownLng).score()
                        * group.passengers();
                continue;
            }
            while (passengersLeft > 0) {
                int passengersNeededForThisPass = passengersLeft;
                List<Bus> feasible = availableBuses.stream()
                        .filter(bus -> remainingSeats.getOrDefault(bus.registrationNumber, 0) > 0)
                        .sorted(Comparator
                                .comparingDouble((Bus bus) -> {
                                    CandidateCost cost = weightedCost(candidateCostCache, routeEstimateCache, bus, group.stop(), breakdownLat, breakdownLng);
                                    int capacity = remainingSeats.getOrDefault(bus.registrationNumber, 0);
                                    double splitPenalty = capacity < passengersNeededForThisPass ? 8.0 : 0.0;
                                    return cost.score() + splitPenalty;
                                })
                                .thenComparing(bus -> bus.registrationNumber))
                        .toList();
                if (feasible.isEmpty()) {
                    unassigned += passengersLeft;
                    unassignedByStop.merge(group.stop().name, passengersLeft, Integer::sum);
                    break;
                }

                // Prefer nearby spare buses; split a pickup group across additional
                // vehicles if the closest bus cannot take the whole group.
                Bus rescueBus = feasible.getFirst();
                int spareBefore = remainingSeats.get(rescueBus.registrationNumber);
                int assignedPassengers = Math.min(passengersLeft, spareBefore);
                remainingSeats.put(rescueBus.registrationNumber, spareBefore - assignedPassengers);

                Stop origin = nearestRoutePoint(rescueBus, breakdownLat, breakdownLng);
                OsmRoutingClient.RouteEstimate toBreakdown = estimate(routeEstimateCache,
                        origin.latitude, origin.longitude, breakdownLat, breakdownLng);
                OsmRoutingClient.RouteEstimate toPickup = estimate(routeEstimateCache,
                        breakdownLat, breakdownLng, group.stop().latitude, group.stop().longitude);
                double detourKm = toBreakdown.distanceKm() + toPickup.distanceKm();
                int detourMinutes = toBreakdown.durationMinutes() + toPickup.durationMinutes();
                String source = toBreakdown.source().equals(toPickup.source())
                        ? toBreakdown.source()
                        : "MIXED_ROUTE_ESTIMATES";
                assignments.add(new StopAssignment(
                        group.stop().id.toString(), group.stop().name,
                        rescueBus.registrationNumber,
                        rescueBus.route.name,
                        rescueBus.driverName, rescueBus.driverPhone,
                        group.stop().latitude, group.stop().longitude,
                        assignedPassengers, spareBefore, detourKm, detourMinutes,
                        source,
                        toBreakdown.durationMinutes(),
                        weightedCost(candidateCostCache, routeEstimateCache, rescueBus, group.stop(), breakdownLat, breakdownLng).score(),
                        assignmentReason(availableBuses, remainingSeats, rescueBus, group.stop(),
                                breakdownLat, breakdownLng, spareBefore,
                                toBreakdown.durationMinutes(), toPickup.durationMinutes(),
                                weightedCost(candidateCostCache, routeEstimateCache, rescueBus,
                                        group.stop(), breakdownLat, breakdownLng).score(),
                                passengersNeededForThisPass, assignedPassengers)));
                addedDistance += detourKm;
                addedMinutes = Math.max(addedMinutes, detourMinutes);
                dispatchObjectiveScore += weightedCost(candidateCostCache, routeEstimateCache, rescueBus, group.stop(), breakdownLat, breakdownLng).score()
                        * assignedPassengers;
                passengersLeft -= assignedPassengers;
            }
        }

        assignments.sort(Comparator.comparingInt(item -> {
            for (int i = 0; i < affectedStops.size(); i++) {
                if (affectedStops.get(i).id.toString().equals(item.stopId())) return i;
            }
            return Integer.MAX_VALUE;
        }));

        int covered = assignments.stream().mapToInt(StopAssignment::studentCount).sum();
        int stopsCovered = (int) assignments.stream().map(StopAssignment::stopId).distinct().count();
        dispatchObjectiveScore += unassigned * UNSERVED_PASSENGER_PENALTY;
        String explanation = String.format(
                java.util.Locale.ROOT,
                "Rolling Java dispatch assigned %d of %d passengers to %d rescue buses across %d of %d pickup groups; %d passengers need manual support. Objective = sum over served passengers of (0.55×response minutes + 0.30×detour minutes + 0.15×(2×detour km×2 min/km)) plus %.0f penalty points per unserved passenger. Earlier active incidents retain first-commit capacity. Current score: %.1f weighted passenger-minutes. Detour values use %s.",
                covered, strandedStudents,
                assignments.stream().map(StopAssignment::assignedBusNumber).distinct().count(),
                stopsCovered, affectedStops.size(), unassigned,
                UNSERVED_PASSENGER_PENALTY,
                dispatchObjectiveScore,
                assignments.stream().anyMatch(a -> a.estimateSource().equals("OSRM_OPENSTREETMAP"))
                        ? "OpenStreetMap-based OSRM road estimates"
                        : "straight-line simulation estimates");

        return new OptimalRerouteResult(
                List.copyOf(assignments), Map.copyOf(unassignedByStop), unassigned,
                strandedStudents, affectedStops.size(), stopsCovered,
                addedDistance, addedMinutes, dispatchObjectiveScore,
                stopsCovered == affectedStops.size(), explanation);
    }

    private CandidateCost weightedCost(Map<String, CandidateCost> cache,
                                       Map<String, OsmRoutingClient.RouteEstimate> estimateCache,
                                       Bus bus, Stop pickup,
                                       double breakdownLat, double breakdownLng) {
        String key = bus.registrationNumber + "|" + pickup.id;
        return cache.computeIfAbsent(key, ignored -> calculateWeightedCost(estimateCache, bus, pickup, breakdownLat, breakdownLng));
    }

    private CandidateCost calculateWeightedCost(Map<String, OsmRoutingClient.RouteEstimate> estimateCache,
                                                Bus bus, Stop pickup, double breakdownLat, double breakdownLng) {
        Stop origin = nearestRoutePoint(bus, breakdownLat, breakdownLng);
        OsmRoutingClient.RouteEstimate response = estimate(estimateCache,
                origin.latitude, origin.longitude, breakdownLat, breakdownLng);
        OsmRoutingClient.RouteEstimate detour = estimate(estimateCache,
                breakdownLat, breakdownLng, pickup.latitude, pickup.longitude);
        double score = ARRIVAL_WEIGHT * response.durationMinutes()
                + DETOUR_TIME_WEIGHT * detour.durationMinutes()
                + DETOUR_DISTANCE_WEIGHT * (2.0 * detour.distanceKm() * 2.0);
        return new CandidateCost(response, detour, score);
    }

    private OsmRoutingClient.RouteEstimate estimate(Map<String, OsmRoutingClient.RouteEstimate> cache,
                                                      double fromLat, double fromLng,
                                                      double toLat, double toLng) {
        String key = String.format(java.util.Locale.ROOT, "%.5f,%.5f:%.5f,%.5f",
                fromLat, fromLng, toLat, toLng);
        return cache.computeIfAbsent(key, ignored ->
                osmRouting.estimate(fromLat, fromLng, toLat, toLng));
    }

    private String assignmentReason(List<Bus> availableBuses, Map<String, Integer> remainingSeats,
                                    Bus selected, Stop pickup, double breakdownLat, double breakdownLng,
                                    int seatsBefore, int responseMinutes, int detourMinutes,
                                    double weightedCost, int requested, int assigned) {
        Bus geographicallyNearest = availableBuses.stream()
                .min(Comparator.comparingDouble(bus ->
                        nearestRoutePointKm(bus, breakdownLat, breakdownLng)
                                + nearestRoutePointKm(bus, pickup)))
                .orElse(selected);
        String tradeoff = "the selected bus had the lowest weighted road-time score";
        if (!geographicallyNearest.registrationNumber.equals(selected.registrationNumber)) {
            int nearbySeats = remainingSeats.getOrDefault(geographicallyNearest.registrationNumber, 0);
            tradeoff = nearbySeats < Math.max(1, requested)
                    ? String.format(java.util.Locale.ROOT,
                            "geographically closer %s had only %d spare seats for this pickup group",
                            geographicallyNearest.registrationNumber, nearbySeats)
                    : String.format(java.util.Locale.ROOT,
                            "weighted road-time scoring preferred this bus over geographically closer %s",
                            geographicallyNearest.registrationNumber);
        }
        return String.format(java.util.Locale.ROOT,
                "Assigned %d passengers; %d seats were free before dispatch. Estimated arrival %d min and detour %d min; weighted cost %.2f per passenger. %s.",
                assigned, seatsBefore, responseMinutes, detourMinutes, weightedCost, tradeoff);
    }

    private Stop nearestRoutePoint(Bus bus, Stop target) {
        return stopRepository.findByRouteIdOrderByStopOrderAsc(bus.route.id).stream()
                .min(Comparator.comparingDouble(stop -> haversineKm(
                        stop.latitude, stop.longitude, target.latitude, target.longitude)))
                .orElse(target);
    }

    private Stop nearestRoutePoint(Bus bus, double latitude, double longitude) {
        Stop fallback = new Stop();
        fallback.latitude = latitude;
        fallback.longitude = longitude;
        return stopRepository.findByRouteIdOrderByStopOrderAsc(bus.route.id).stream()
                .min(Comparator.comparingDouble(stop -> haversineKm(
                        stop.latitude, stop.longitude, latitude, longitude)))
                .orElse(fallback);
    }

    private double nearestRoutePointKm(Bus bus, Stop target) {
        Stop nearest = nearestRoutePoint(bus, target);
        return haversineKm(nearest.latitude, nearest.longitude, target.latitude, target.longitude);
    }

    private double nearestRoutePointKm(Bus bus, double latitude, double longitude) {
        Stop nearest = nearestRoutePoint(bus, latitude, longitude);
        return haversineKm(nearest.latitude, nearest.longitude, latitude, longitude);
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
    private record CandidateCost(OsmRoutingClient.RouteEstimate response,
                                 OsmRoutingClient.RouteEstimate detour,
                                 double score) {}
}
