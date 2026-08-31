package com.smartbus.fleet.repository;
import com.smartbus.fleet.entity.Stop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;
@Repository
public interface StopRepository extends JpaRepository<Stop, UUID> {
    java.util.List<Stop> findByRouteIdOrderByStopOrderAsc(UUID routeId);
}
