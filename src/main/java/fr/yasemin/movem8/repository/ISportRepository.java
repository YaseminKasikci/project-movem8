package fr.yasemin.movem8.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Sport;

@Repository
public interface ISportRepository extends JpaRepository<Sport, Long>{
    List<Sport> findByCategoryId(Long categoryId);
}
