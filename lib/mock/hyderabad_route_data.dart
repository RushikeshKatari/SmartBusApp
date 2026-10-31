import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/app_models.dart';

/// Representative Hyderabad-area coordinates for reroute simulation.
/// Stops are corridor markers, not surveyed boarding points or road geometry.
class DemoStopPoint {
  const DemoStopPoint(this.name, this.latitude, this.longitude, this.landmark);

  final String name;
  final double latitude;
  final double longitude;
  final String landmark;
}

class DemoRouteDefinition {
  const DemoRouteDefinition({
    required this.name,
    required this.busNumber,
    required this.busName,
    required this.driverName,
    required this.driverPhone,
    required this.capacity,
    required this.occupancy,
    required this.stops,
  });

  final String name, busNumber, busName, driverName, driverPhone;
  final int capacity, occupancy;
  final List<DemoStopPoint> stops;
}

class HyderabadRouteData {
  HyderabadRouteData._();

  static const campus = DemoStopPoint(
    'KLH Aziz Nagar Campus Parking',
    17.348301,
    78.339918,
    'College bus parking · RVS Nagar, Moinabad Road',
  );
  static const campusApproach = DemoStopPoint(
    'TSPA Junction',
    17.3495,
    78.3360,
    'ORR Exit 18 / campus approach',
  );

  static const routes = <DemoRouteDefinition>[
    DemoRouteDefinition(
      name: 'Aziz Nagar–Chilkur',
      busNumber: 'SB-04',
      busName: 'Campus Express',
      driverName: 'Ravi Kumar',
      driverPhone: '+91 98765 43210',
      capacity: 48,
      occupancy: 34,
      stops: [
        DemoStopPoint(
          'Chilkur Balaji Temple',
          17.3587,
          78.3085,
          'Temple approach',
        ),
        DemoStopPoint('Himayat Sagar Road', 17.3560, 78.3210, 'Road junction'),
        DemoStopPoint('Aziz Nagar X Roads', 17.3520, 78.3300, 'Aziz Nagar'),
        DemoStopPoint('Aziz Nagar Main Road', 17.3505, 78.3330, 'Aziz Nagar'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Moinabad–Himayat Sagar',
      busNumber: 'SB-12',
      busName: 'City Connector',
      driverName: 'Imran Khan',
      driverPhone: '+91 87654 32109',
      capacity: 52,
      occupancy: 35,
      stops: [
        DemoStopPoint('Moinabad Bus Stop', 17.3210, 78.3150, 'Moinabad Road'),
        DemoStopPoint(
          'Kethireddypally Road',
          17.3310,
          78.3190,
          'Village junction',
        ),
        DemoStopPoint(
          'Chilkur Road Junction',
          17.3390,
          78.3260,
          'Chilkur Road',
        ),
        DemoStopPoint('Aziz Nagar X Roads', 17.3520, 78.3300, 'Aziz Nagar'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Shankarpally–Gandipet',
      busNumber: 'SB-09',
      busName: 'Green Line',
      driverName: 'Nisha Patel',
      driverPhone: '+91 76543 21098',
      capacity: 44,
      occupancy: 24,
      stops: [
        DemoStopPoint(
          'Shankarpally Town',
          17.4520,
          78.1270,
          'Town center marker',
        ),
        DemoStopPoint('Mokila Junction', 17.4210, 78.2070, 'Mokila Road'),
        DemoStopPoint('Gandipet Lake Road', 17.3900, 78.3040, 'Gandipet'),
        DemoStopPoint(
          'Gandipet Road Junction',
          17.3650,
          78.3470,
          'Gandipet Road',
        ),
      ],
    ),
    DemoRouteDefinition(
      name: 'Kokapet–Narsingi',
      busNumber: 'SB-02',
      busName: 'Blue Arrow',
      driverName: 'Suresh Rao',
      driverPhone: '+91 65432 10987',
      capacity: 56,
      occupancy: 30,
      stops: [
        DemoStopPoint('Kokapet SEZ', 17.3900, 78.3330, 'Kokapet'),
        DemoStopPoint(
          'Financial District Gate',
          17.4150,
          78.3370,
          'Nanakramguda',
        ),
        DemoStopPoint('Narsingi Junction', 17.3876, 78.3570, 'Narsingi'),
        DemoStopPoint(
          'Gandipet Road Junction',
          17.3650,
          78.3470,
          'Gandipet Road',
        ),
      ],
    ),
    DemoRouteDefinition(
      name: 'Gachibowli–Nanakramguda',
      busNumber: 'SB-17',
      busName: 'North Shuttle',
      driverName: 'Priya Rao',
      driverPhone: '+91 54321 09876',
      capacity: 38,
      occupancy: 19,
      stops: [
        DemoStopPoint('Gachibowli Stadium', 17.4436, 78.3520, 'Stadium Road'),
        DemoStopPoint('IIIT Hyderabad', 17.4450, 78.3480, 'Gachibowli'),
        DemoStopPoint(
          'Nanakramguda Circle',
          17.4160,
          78.3420,
          'Financial District',
        ),
        DemoStopPoint('Narsingi Junction', 17.3876, 78.3570, 'Narsingi'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Kondapur–Gachibowli',
      busNumber: 'SB-06',
      busName: 'Kondapur Link',
      driverName: 'Demo Driver 06',
      driverPhone: '+91 90000 00006',
      capacity: 50,
      occupancy: 35,
      stops: [
        DemoStopPoint('Kondapur RTO', 17.4630, 78.3630, 'Kondapur'),
        DemoStopPoint('Botanical Garden Road', 17.4560, 78.3650, 'Kondapur'),
        DemoStopPoint('Gachibowli Circle', 17.4400, 78.3480, 'Gachibowli'),
        DemoStopPoint(
          'Nanakramguda Circle',
          17.4160,
          78.3420,
          'Financial District',
        ),
      ],
    ),
    DemoRouteDefinition(
      name: 'Miyapur–Hafeezpet',
      busNumber: 'SB-07',
      busName: 'Miyapur Rapid',
      driverName: 'Demo Driver 07',
      driverPhone: '+91 90000 00007',
      capacity: 52,
      occupancy: 37,
      stops: [
        DemoStopPoint('Miyapur Metro', 17.4968, 78.3614, 'Metro station area'),
        DemoStopPoint('Madinaguda Junction', 17.4930, 78.3500, 'Madinaguda'),
        DemoStopPoint(
          'Hafeezpet MMTS',
          17.4860,
          78.3330,
          'Railway station area',
        ),
        DemoStopPoint('Gachibowli Circle', 17.4400, 78.3480, 'Gachibowli'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Lingampally–Tellapur',
      busNumber: 'SB-08',
      busName: 'Tellapur Shuttle',
      driverName: 'Demo Driver 08',
      driverPhone: '+91 90000 00008',
      capacity: 46,
      occupancy: 31,
      stops: [
        DemoStopPoint('Lingampally Station', 17.4890, 78.3160, 'Lingampally'),
        DemoStopPoint('Chandanagar Circle', 17.4940, 78.3220, 'Chandanagar'),
        DemoStopPoint('Tellapur Junction', 17.4590, 78.2840, 'Tellapur'),
        DemoStopPoint('Osman Sagar Road', 17.3900, 78.3100, 'Gandipet side'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Manikonda–Puppalaguda',
      busNumber: 'SB-10',
      busName: 'Manikonda Loop',
      driverName: 'Demo Driver 10',
      driverPhone: '+91 90000 00010',
      capacity: 48,
      occupancy: 32,
      stops: [
        DemoStopPoint('Manikonda Marrichettu', 17.4060, 78.3890, 'Manikonda'),
        DemoStopPoint('Lanco Hills', 17.4070, 78.3810, 'Manikonda Road'),
        DemoStopPoint('Puppalaguda Circle', 17.3980, 78.3700, 'Puppalaguda'),
        DemoStopPoint('Narsingi Junction', 17.3876, 78.3570, 'Narsingi'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Mehdipatnam–Narsingi',
      busNumber: 'SB-13',
      busName: 'Mehdipatnam Link',
      driverName: 'Demo Driver 13',
      driverPhone: '+91 90000 00013',
      capacity: 50,
      occupancy: 34,
      stops: [
        DemoStopPoint('Mehdipatnam Bus Depot', 17.3959, 78.4312, 'Mehdipatnam'),
        DemoStopPoint('Rethi Bowli', 17.3920, 78.4200, 'Mehdipatnam'),
        DemoStopPoint('Tolichowki X Roads', 17.4003, 78.4118, 'Tolichowki'),
        DemoStopPoint('Puppalaguda Circle', 17.3980, 78.3700, 'Puppalaguda'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Jubilee Hills–Manikonda',
      busNumber: 'SB-14',
      busName: 'Jubilee Link',
      driverName: 'Demo Driver 14',
      driverPhone: '+91 90000 00014',
      capacity: 48,
      occupancy: 33,
      stops: [
        DemoStopPoint(
          'Jubilee Hills Checkpost',
          17.4230,
          78.4070,
          'Road No. 10',
        ),
        DemoStopPoint('Film Nagar Junction', 17.4140, 78.4050, 'Jubilee Hills'),
        DemoStopPoint('Shaikpet Nala', 17.3900, 78.3900, 'Shaikpet'),
        DemoStopPoint('Manikonda Gate', 17.4060, 78.3750, 'Manikonda Road'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Banjara Hills–Tolichowki',
      busNumber: 'SB-15',
      busName: 'Banjara Campus Link',
      driverName: 'Demo Driver 15',
      driverPhone: '+91 90000 00015',
      capacity: 52,
      occupancy: 36,
      stops: [
        DemoStopPoint(
          'Banjara Hills Road No. 12',
          17.4168,
          78.4384,
          'Banjara Hills',
        ),
        DemoStopPoint('Masab Tank', 17.4000, 78.4560, 'Masab Tank'),
        DemoStopPoint('Mehdipatnam Bus Depot', 17.3959, 78.4312, 'Mehdipatnam'),
        DemoStopPoint('Tolichowki X Roads', 17.4003, 78.4118, 'Tolichowki'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Ameerpet–Shaikpet',
      busNumber: 'SB-16',
      busName: 'Ameerpet Express',
      driverName: 'Demo Driver 16',
      driverPhone: '+91 90000 00016',
      capacity: 50,
      occupancy: 35,
      stops: [
        DemoStopPoint('Ameerpet Metro', 17.4370, 78.4480, 'Ameerpet'),
        DemoStopPoint('Yousufguda Checkpost', 17.4320, 78.4290, 'Yousufguda'),
        DemoStopPoint(
          'Jubilee Hills Checkpost',
          17.4230,
          78.4070,
          'Jubilee Hills',
        ),
        DemoStopPoint('Shaikpet Nala', 17.3900, 78.3900, 'Shaikpet'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Secunderabad–Mehdipatnam',
      busNumber: 'SB-18',
      busName: 'Secunderabad Longhaul',
      driverName: 'Demo Driver 18',
      driverPhone: '+91 90000 00018',
      capacity: 56,
      occupancy: 41,
      stops: [
        DemoStopPoint(
          'Secunderabad Station',
          17.4399,
          78.4983,
          'Railway station',
        ),
        DemoStopPoint('Paradise Circle', 17.4430, 78.4870, 'Paradise'),
        DemoStopPoint('Ameerpet Metro', 17.4370, 78.4480, 'Ameerpet'),
        DemoStopPoint('Mehdipatnam Bus Depot', 17.3959, 78.4312, 'Mehdipatnam'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Uppal–Ameerpet–Campus',
      busNumber: 'SB-19',
      busName: 'Uppal City Line',
      driverName: 'Demo Driver 19',
      driverPhone: '+91 90000 00019',
      capacity: 52,
      occupancy: 37,
      stops: [
        DemoStopPoint('Uppal Metro', 17.4050, 78.5590, 'Uppal'),
        DemoStopPoint('Habsiguda Metro', 17.4170, 78.5430, 'Habsiguda'),
        DemoStopPoint('Tarnaka Junction', 17.4280, 78.5380, 'Tarnaka'),
        DemoStopPoint('Ameerpet Metro', 17.4370, 78.4480, 'Ameerpet'),
      ],
    ),
    DemoRouteDefinition(
      name: 'LB Nagar–Mehdipatnam',
      busNumber: 'SB-20',
      busName: 'LB Nagar Connector',
      driverName: 'Demo Driver 20',
      driverPhone: '+91 90000 00020',
      capacity: 54,
      occupancy: 39,
      stops: [
        DemoStopPoint('LB Nagar Metro', 17.3457, 78.5522, 'LB Nagar'),
        DemoStopPoint('Dilsukhnagar Metro', 17.3680, 78.5240, 'Dilsukhnagar'),
        DemoStopPoint('Lakdikapul', 17.4020, 78.4650, 'Central Hyderabad'),
        DemoStopPoint('Mehdipatnam Bus Depot', 17.3959, 78.4312, 'Mehdipatnam'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Kukatpally–Gachibowli',
      busNumber: 'SB-21',
      busName: 'Kukatpally Rapid',
      driverName: 'Demo Driver 21',
      driverPhone: '+91 90000 00021',
      capacity: 56,
      occupancy: 42,
      stops: [
        DemoStopPoint('Kukatpally Metro', 17.4851, 78.4094, 'Kukatpally'),
        DemoStopPoint('KPHB Colony', 17.4930, 78.3990, 'KPHB'),
        DemoStopPoint('Miyapur Metro', 17.4968, 78.3614, 'Miyapur'),
        DemoStopPoint('Gachibowli Circle', 17.4400, 78.3480, 'Gachibowli'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Shamshabad–Rajendranagar',
      busNumber: 'SB-22',
      busName: 'Airport South Line',
      driverName: 'Demo Driver 22',
      driverPhone: '+91 90000 00022',
      capacity: 50,
      occupancy: 35,
      stops: [
        DemoStopPoint('Shamshabad Bus Station', 17.2110, 78.3980, 'Shamshabad'),
        DemoStopPoint(
          'RGIA Approach Road',
          17.2400,
          78.4050,
          'Airport corridor',
        ),
        DemoStopPoint('Rajendranagar', 17.3210, 78.4020, 'Rajendranagar'),
        DemoStopPoint('Attapur Ring Road', 17.3650, 78.4250, 'Attapur'),
      ],
    ),
    DemoRouteDefinition(
      name: 'Tellapur–Gandipet',
      busNumber: 'SB-23',
      busName: 'Tellapur West Line',
      driverName: 'Demo Driver 23',
      driverPhone: '+91 90000 00023',
      capacity: 48,
      occupancy: 33,
      stops: [
        DemoStopPoint('Tellapur Junction', 17.4590, 78.2840, 'Tellapur'),
        DemoStopPoint('Osman Sagar Road', 17.4200, 78.2930, 'Lake road'),
        DemoStopPoint('Gandipet Lake Road', 17.3900, 78.3040, 'Gandipet'),
        DemoStopPoint(
          'Chilkur Road Junction',
          17.3390,
          78.3260,
          'Chilkur Road',
        ),
      ],
    ),
    DemoRouteDefinition(
      name: 'Patancheru–Lingampally',
      busNumber: 'SB-24',
      busName: 'Patancheru Longhaul',
      driverName: 'Demo Driver 24',
      driverPhone: '+91 90000 00024',
      capacity: 56,
      occupancy: 40,
      stops: [
        DemoStopPoint('Patancheru Bus Station', 17.5330, 78.2640, 'Patancheru'),
        DemoStopPoint('BHEL Township', 17.5110, 78.2990, 'BHEL'),
        DemoStopPoint('Lingampally Station', 17.4890, 78.3160, 'Lingampally'),
        DemoStopPoint('Tellapur Junction', 17.4590, 78.2840, 'Tellapur'),
      ],
    ),
  ];

  static const _colors = <Color>[
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF0891B2),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  static final List<LiveBusRoute> liveRoutes = List.generate(routes.length, (
    i,
  ) {
    final route = routes[i];
    final points = [...route.stops, campusApproach, campus];
    var distance = 0.0;
    var elapsedMinutes = 0;
    final stops = <LiveRouteStop>[];
    for (var j = 0; j < points.length; j++) {
      final point = points[j];
      final segment = j == 0 ? 0.0 : _distanceKm(points[j - 1], point);
      distance += segment;
      elapsedMinutes += (segment / 25 * 60).round();
      stops.add(
        LiveRouteStop(
          id: 'HYD-${(i + 1).toString().padLeft(2, '0')}-${(j + 1).toString().padLeft(2, '0')}',
          name: point.name,
          landmark: point.landmark,
          latitude: point.latitude,
          longitude: point.longitude,
          order: j + 1,
          distanceFromPreviousKm: segment,
          estimatedArrivalMinutes: elapsedMinutes,
        ),
      );
    }
    return LiveBusRoute(
      id: 'HYD-R${(i + 1).toString().padLeft(2, '0')}',
      routeNumber: 'Route ${(i + 1).toString().padLeft(2, '0')}',
      name: route.name,
      busNumber: route.busNumber,
      busName: route.busName,
      driverName: route.driverName,
      driverPhone: route.driverPhone,
      color: _colors[i % _colors.length],
      stops: stops,
      totalDistanceKm: distance,
      totalDurationMinutes: elapsedMinutes,
    );
  });

  static final List<AdminBus> buses = List.generate(routes.length, (i) {
    final route = routes[i];
    return AdminBus(
      id: 'HYD-B${(i + 1).toString().padLeft(2, '0')}',
      busNumber: route.busNumber,
      busName: route.busName,
      registrationNumber: 'KLH-DEMO-${(i + 1).toString().padLeft(2, '0')}',
      capacity: route.capacity,
      currentOccupancy: route.occupancy,
      driverName: route.driverName,
      driverPhone: route.driverPhone,
      assignedRoute: route.name,
      assignedInchargeId: i < 5
          ? const ['I001', 'I002', 'I003', 'I004', 'I005'][i]
          : 'DEMO-I${(i + 1).toString().padLeft(2, '0')}',
      assignedInchargeName: i < 5
          ? const [
              'Meera Singh',
              'Suresh Rao',
              'Fatima Khan',
              'Ranjit Verma',
              'Lakshmi Pillai',
            ][i]
          : 'Demo In-charge ${(i + 1).toString().padLeft(2, '0')}',
      status: route.busNumber == 'SB-02' ? 'Maintenance' : 'Active',
      lastService: 'Demo data',
    );
  });

  static double _distanceKm(DemoStopPoint a, DemoStopPoint b) {
    const radius = 6371.0;
    final dLat = _radians(b.latitude - a.latitude);
    final dLon = _radians(b.longitude - a.longitude);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(a.latitude)) *
            math.cos(_radians(b.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return radius * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  static double _radians(double degree) => degree * math.pi / 180;
}
