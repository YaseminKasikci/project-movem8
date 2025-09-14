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
//	 @Query("SELECT a FROM Activity a " +
//	            "JOIN a.categorySport c " +
//	            "WHERE (:name IS NULL OR a.name LIKE %:name%) " + //activity
//	            "AND (:category_sport IS NULL OR c.category_name LIKE %:category_sport%) " + // category
//	            "AND (:name IS NULL OR a.name LIKE %:name%) " + //sport
//	            "AND (:date_hour IS NULL OR a.date_hour = :date_hour) " +  // date / hour activity
//	            "AND (:location IS NULL OR a.location LIKE %:location%) " + // location activity
//	            "AND (:firstName IS NULL OR a.users.name LIKE %:firstName%) " + // creator activity
//	            "AND (:level IS NULL OR a.level = :level)") //level activity
//	    List<Activity> searchActivities(String activityName, String category, String sportName,
//	                                     LocalDateTime activityDate, String location, String creatorName,
//	                                     Level level);
	
	List<Activity> findByCreatorId(Long creatorId);
	
	// pour lister les activités d'une communauté
    List<Activity> findAllByCommunityIdOrderByDateHourDesc(Long communityId);
}
