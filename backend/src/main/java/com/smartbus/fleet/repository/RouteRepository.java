package com.smartbus.fleet.repository;
import com.smartbus.fleet.entity.Route;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;
@Repository
public interface RouteRepository extends JpaRepository<Route, UUID> {}
