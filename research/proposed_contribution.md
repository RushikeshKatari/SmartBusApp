# Proposed SmartBus research contribution

## Working title

**Capacity-Aware, Explainable Multi-Bus Recovery for Campus Bus Breakdowns**

This is a candidate applied-systems paper direction, not a novelty claim. SmartBus now has a prototype rescue planner that assigns estimated stop groups across available buses subject to spare-seat limits, estimates detours, exposes unassigned groups, and allows a dispatcher to manually reassign a group only when the selected bus has enough capacity.

## Why this is a better fit for SmartBus

The repository already contains an emergency breakdown workflow, so improving it addresses a real inconsistency in the project: the old client assigned every remaining stop to a preset bus, used fixed detour/arrival values, and declared full coverage without checking occupancy. The new planner uses the demo fleet's configured capacity and occupancy, excludes maintenance/down buses, prioritizes groups with fewer feasible buses, and selects the nearest feasible rescue route. If no single bus can carry a whole estimated stop group, it reports that group as unassigned for dispatcher action instead of asserting success.

The result is an explainable operational decision: **which passengers are covered, by which bus, using how much spare capacity, at what approximate detour cost, and who still needs help**. This is more defensible for an application paper than describing a list of unconnected screens as innovation.

## Related-work caution

Capacity-aware emergency bus planning is an established research area. Luo and Xu model bus-bridging plans under uncertain passenger demand and spare capacity; other work compares adaptive operating modes such as all-stop, skip-stop, express-local and on-demand service; recent 2026 studies address multi-objective/rolling-horizon emergency routing and capacity-constrained services. Therefore, **do not claim that multi-bus rerouting or capacity awareness is itself novel**. A potential contribution to investigate is the transparent, campus-scale decision workflow for discrete passenger groups and finite small-fleet capacity, including explicit infeasibility and a human dispatcher override. Whether that is a publishable gap requires a broader systematic search and comparison against directly related school/campus and bus-failure studies.

## Implemented prototype behavior and assumptions

- The planner lives in `lib/services/breakdown_dispatch_planner.dart` and is invoked by the SmartBus provider.
- Available seats come from the repository's mock fleet (`capacity - currentOccupancy`); maintenance buses are excluded.
- The UI exposes a demo breakdown scenario from 1 to 60 stranded passengers so capacity limits can be observed.
- Because the current data model has no per-stop passenger counts, the prototype distributes the entered total evenly across remaining stops. These are **estimated groups**, not measured boarding demand.
- A group is kept together and assigned only if one bus can carry it. This is a simplifying policy choice, not a universal transit rule.
- Detour is twice the straight-line distance from the candidate route's nearest stored stop to the affected stop. ETA uses a fixed assumed average speed of 25 km/h. These values are lower-bound/simulation estimates, not road routing or live ETAs.
- Fleet occupancy, bus locations, and routes are seeded sample data. The flow is not yet evidence of live dispatch in a deployed fleet.

## Research question

**In a small campus fleet, how does an explainable capacity-constrained multi-bus heuristic affect passenger coverage and estimated detour compared with a fixed single-rescue-bus policy when breakdown demand and spare capacity vary?**

### Hypotheses to test

1. Capacity-aware multi-bus allocation will reduce the number of passengers assigned beyond available seats to zero by construction.
2. Relative to fixed single-bus dispatch, it will improve assigned passenger coverage when the fixed bus lacks sufficient capacity and other buses have spare seats.
3. Coverage gains may increase total estimated detour or the number of buses diverted; quantify this trade-off rather than assuming the heuristic is better overall.

## Evaluation plan

Compare three policies against the same route, capacity, and demand snapshots:

1. **Fixed-bus baseline:** assign every affected stop to the preset rescue bus, matching the prior behavior.
2. **Nearest single-bus baseline:** select the closest active bus and assign only groups that fit its remaining capacity.
3. **Capacity-aware multi-bus heuristic:** current implementation; scarce-first stop ordering, then nearest feasible bus, whole-group assignment.

Vary breakdown route, stranded passenger total, and rescue-bus occupancy. First use reproducible synthetic scenarios. Then replace the evenly distributed passenger estimates with observed counts by stop and use route distances from a road-network source or collected GPS traces. Report at least:

- assigned passengers / total affected passengers;
- unassigned passengers and affected pickup groups;
- any capacity violations (target: zero for policies that enforce capacity);
- rescue buses used;
- added detour distance and time (label approximations separately from measured values);
- planner runtime;
- sensitivity to occupancy uncertainty and different group-size distributions.

Use multiple demand/occupancy scenarios and publish the generated inputs, policy parameters, and raw outputs. If conducting a field study, record the route, time period, sample sizes, consent process, GPS accuracy, network gaps, and how actual arrival/detour ground truth is measured. A prototype-only simulation supports a prototype evaluation claim, not a real-world reliability or safety claim.

## What would make the paper stronger

1. Store observed passenger counts by affected stop rather than distributing one total evenly.
2. Persist dispatch plans and changes in the backend so student/in-charge/admin clients see the same plan.
3. Replace nearest-point geometry with road-network travel time and account for current bus positions.
4. Include demand uncertainty and a conservative capacity margin, validated against actual occupancy errors.
5. Compare the heuristic to a small exact integer-programming baseline or an exhaustive solver for small cases; state whether the heuristic is optimal (it currently is not).
6. Add deterministic scenarios demonstrating feasible full coverage, partial coverage, maintenance-bus exclusion, and dispatcher reassignment rejection when a bus lacks seats.
7. Complete a broader literature search before stating a research gap. This feature is an implementation candidate; publication and acceptance depend on the research question, methods, evidence, venue fit, and peer review.

## Selected disruption-planning literature to review next

- C. Luo and L. Xu, “Railway disruption management: Designing bus bridging services under uncertainty,” *Computers & Operations Research*, vol. 131, 105284, 2021. DOI: [10.1016/j.cor.2021.105284](https://doi.org/10.1016/j.cor.2021.105284). The authors account for uncertain demand and spare capacities in a stochastic bus-bridging plan.
- “Exploring alternative bus operations strategies for adaptive and efficient transit systems in the face of disruptions,” *Journal of Public Transportation*, vol. 25, 100060, 2023. DOI: [10.1016/j.jpubtr.2023.100060](https://doi.org/10.1016/j.jpubtr.2023.100060). It compares all-stop, skip-stop, express-local, and on-demand service strategies under disruption scenarios.
- “Emergency bus route optimization for passenger evacuation in response to metro disruptions,” *Journal of Public Transportation*, vol. 28, 100159, 2026. DOI: [10.1016/j.jpubtr.2026.100159](https://doi.org/10.1016/j.jpubtr.2026.100159). It reports multi-objective emergency routing and rolling-horizon adaptation under disruption.
- “Design and optimisation of emergency bus shuttle services under urban rail transit disruptions,” *Transportmetrica A: Transport Science*, online 2026. DOI: [10.1080/23249935.2026.2644548](https://doi.org/10.1080/23249935.2026.2644548). Its abstract describes capacity/load-factor constraints and multiple service modes; inspect the full paper and exact issue metadata before citing.

These papers concern urban rail disruption and evacuation. Their objective functions and scale differ from a campus bus failure, but they establish that capacity constraints, passenger coverage, adaptive dispatch and detour costs are not new concepts. A manuscript should position SmartBus accordingly.
