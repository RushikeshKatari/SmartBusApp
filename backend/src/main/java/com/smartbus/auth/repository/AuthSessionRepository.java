package com.smartbus.auth.repository;

import com.smartbus.auth.entity.AuthSession;
import com.smartbus.auth.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface AuthSessionRepository extends JpaRepository<AuthSession, UUID> {
    
    @Modifying
    @Query("UPDATE AuthSession s SET s.active = false WHERE s.student = :student AND s.active = true")
    void deactivateAllForStudent(Student student);
}
