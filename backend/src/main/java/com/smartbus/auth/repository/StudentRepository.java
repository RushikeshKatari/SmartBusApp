package com.smartbus.auth.repository;

import com.smartbus.auth.entity.Student;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface StudentRepository extends JpaRepository<Student, UUID> {
    Optional<Student> findByRollNo(String rollNo);

    @Query(value = "select b.registration_number || '|' || coalesce(r.id::text, '') || '|' || coalesce(r.name, b.registration_number) "
            + "from students s join buses b on b.id = s.bus_id "
            + "left join routes r on r.id = b.route_id where s.roll_no = :rollNo", nativeQuery = true)
    Optional<String> findAssignedBusDetails(@Param("rollNo") String rollNo);
}
