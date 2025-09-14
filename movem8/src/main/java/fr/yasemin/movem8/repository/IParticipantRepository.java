package fr.yasemin.movem8.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import fr.yasemin.movem8.entity.Participant;
import fr.yasemin.movem8.enums.StatusParticipant;

@Repository
public interface IParticipantRepository extends JpaRepository<Participant, Long> {
	Optional<Participant> findByActivityIdAndUserId(Long activityId, Long userId);

	boolean existsByActivityIdAndUserId(Long activityId, Long userId);

	Optional<Participant> findByUserIdAndActivityIdAndStatusParticipant(Long userId, Long activityId,
			StatusParticipant statusParticipant);

	List<Participant> findByUserId(Long userId);
}
