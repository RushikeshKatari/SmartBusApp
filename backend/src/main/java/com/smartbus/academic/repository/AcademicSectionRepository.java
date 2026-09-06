package com.smartbus.academic.repository;
import com.smartbus.academic.entity.AcademicSection; import java.util.*; import org.springframework.data.jpa.repository.*;
public interface AcademicSectionRepository extends JpaRepository<AcademicSection,UUID> { @EntityGraph(attributePaths="students") List<AcademicSection> findAllByOrderByAcademicYearAscSpecializationAscSectionNumberAsc(); @EntityGraph(attributePaths="students") List<AcademicSection> findByAcademicYearOrderBySpecializationAscSectionNumberAsc(int year); }
