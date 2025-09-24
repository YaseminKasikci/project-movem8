package fr.yasemin.movem8.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.enums.Level;

@Repository
public interface IActivityRepository extends JpaRepository<Activity, Long>{

	
	List<Activity> findByCreatorId(Long creatorId);
	
	// pour lister les activités d'une communauté
    List<Activity> findAllByCommunityIdOrderByDateHourDesc(Long communityId);
    
}
