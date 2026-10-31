package com.smartbus.fleet.service;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/** Uses an OSRM-compatible OpenStreetMap router for road distance and duration. */
@Component
public class OsmRoutingClient {
    private final RestClient client = RestClient.create();

    @Value("${smartbus.osrm-base-url:https://router.project-osrm.org}")
    private String baseUrl;

    public record RouteEstimate(double distanceKm, int durationMinutes, String source) {}
    public record GeoPoint(double latitude, double longitude) {}
    public record RoadPath(List<Map<String, Double>> points, String source) {}

    public RoadPath roadPath(List<GeoPoint> waypoints) {
        List<Map<String, Double>> fallback = waypoints.stream()
                .map(point -> Map.of("latitude", point.latitude(), "longitude", point.longitude()))
                .toList();
        if (waypoints.size() < 2) return new RoadPath(fallback, "STOP_POINTS_ONLY");
        try {
            String coordinates = waypoints.stream()
                    .map(point -> point.longitude() + "," + point.latitude())
                    .collect(java.util.stream.Collectors.joining(";"));
            @SuppressWarnings("unchecked")
            Map<String, Object> response = client.get()
                    .uri(baseUrl.replaceAll("/$", "") + "/route/v1/driving/"
                            + coordinates + "?overview=full&geometries=geojson&steps=false&alternatives=false&continue_straight=true")
                    .retrieve()
                    .body(Map.class);
            if (!"Ok".equals(response.get("code"))) return new RoadPath(fallback, "STRAIGHT_LINE_FALLBACK");
            List<Map<String, Object>> routes = (List<Map<String, Object>>) response.get("routes");
            if (routes == null || routes.isEmpty()) return new RoadPath(fallback, "STRAIGHT_LINE_FALLBACK");
            Map<String, Object> geometry = (Map<String, Object>) routes.getFirst().get("geometry");
            List<List<Number>> coordinatesList = (List<List<Number>>) geometry.get("coordinates");
            List<Map<String, Double>> points = new ArrayList<>();
            for (List<Number> coordinate : coordinatesList) {
                points.add(Map.of(
                        "latitude", coordinate.get(1).doubleValue(),
                        "longitude", coordinate.get(0).doubleValue()));
            }
            return points.size() > 1
                    ? new RoadPath(List.copyOf(points), "OSRM_OPENSTREETMAP")
                    : new RoadPath(fallback, "STRAIGHT_LINE_FALLBACK");
        } catch (Exception ignored) {
            return new RoadPath(fallback, "STRAIGHT_LINE_FALLBACK");
        }
    }

    public RouteEstimate estimate(double originLat, double originLng,
                                  double destinationLat, double destinationLng) {
        try {
            String coordinates = originLng + "," + originLat + ";"
                    + destinationLng + "," + destinationLat;
            @SuppressWarnings("unchecked")
            Map<String, Object> response = client.get()
                    .uri(baseUrl.replaceAll("/$", "") + "/route/v1/driving/"
                            + coordinates + "?overview=false&alternatives=false&steps=false")
                    .retrieve()
                    .body(Map.class);
            if (!"Ok".equals(response.get("code"))) {
                return straightLine(originLat, originLng, destinationLat, destinationLng);
            }
            List<Map<String, Object>> routes = (List<Map<String, Object>>) response.get("routes");
            if (routes == null || routes.isEmpty()) {
                return straightLine(originLat, originLng, destinationLat, destinationLng);
            }
            Map<String, Object> best = routes.getFirst();
            double distanceKm = ((Number) best.get("distance")).doubleValue() / 1000.0;
            int durationMinutes = (int) Math.ceil(
                    ((Number) best.get("duration")).doubleValue() / 60.0);
            return new RouteEstimate(distanceKm, durationMinutes, "OSRM_OPENSTREETMAP");
        } catch (Exception ignored) {
            // Keep the simulation usable if the public router or configured service
            // is unavailable, and identify that estimate as a straight-line fallback.
            return straightLine(originLat, originLng, destinationLat, destinationLng);
        }
    }

    private static RouteEstimate straightLine(double lat1, double lon1,
                                               double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double km = 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return new RouteEstimate(km, (int) Math.ceil(km / 25.0 * 60.0),
                "STRAIGHT_LINE_ESTIMATE");
    }
}
