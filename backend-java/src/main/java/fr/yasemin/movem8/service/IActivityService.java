package fr.yasemin.movem8.service;

import java.util.List;

import fr.yasemin.movem8.dto.ActivityUpdateDTO;
import fr.yasemin.movem8.dto.CreateActivityRequestDTO;
import fr.yasemin.movem8.entity.Activity;
import fr.yasemin.movem8.entity.Category;
import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.entity.User;
import fr.yasemin.movem8.enums.Level;





public interface IActivityService  {
	
	
	// CRUD

	Activity getActivitiById(Long id) throws Exception;
	
	Activity createActivity(CreateActivityRequestDTO req) throws Exception;
	
	// dans ActivityService (interface) ajoute :
	Activity updateActivityPartial(Long id, ActivityUpdateDTO dto) throws Exception;


	boolean deleteActivity(Long id) throws Exception;

	List<Activity> getAllActivities() throws Exception;

	 List<Activity> findAllByCommunity(Long communityId) throws Exception;
	 
		// Createur d'activité HISTORY
		
		List<Activity> getCreatedActivities(Long userId);
	// PARTICIPANT

	boolean requestParticipant(Long activityId, Long userId, Level level) throws Exception;

	Participant validateParticipation(Long participationId, Long creatorId) throws Exception;

	Participant refuseParticipant(Long participantId, Long creatorId) throws Exception;

	boolean removeParticipant(Long activityId, Long userId) throws Exception;

	float rateActivity(Long activityId, float rating) throws Exception;

	List<Participant> getParticipantsByActivityId(Long activityId);
	

	
	
	
	// FILTER

//    List<Activity> searchActivities(String activityName, String category, String sportName,
//                                     LocalDateTime activityDate, String location, String creatorName,
//                                     Level level);

}
